function [psapi,xmsn_reset,mf_p] = read_psap3w_bnli(ins);
% psapi = read_psap3w_bnli(ins);
% Reads a BNL csv capture of PSAP "I" packet
% Defines time from the BNL supplied date/time string
% Defines instrument time "itime" as reported by PSAP
% Captures "I" ASCII string for later parsing for reset times
% Parses valve position, dilution flow set point, and dilution flow reading
% Parses last filter change time and normalization
% Parses mass-flow  into mf_p struct with fields AD, flow_LPM, and P
%
if ~isavar('ins')||isempty(ins)
   ins = getfullname_('*psap3wI*.tsv','bnl_psapi');
end

if iscell(ins)&&length(ins)>1
   [psapi,xmsn_reset,mf_p] = read_psap3w_bnli(ins{1});
   [psapi2,xmsn_reset2,mf_p2] = read_psap3w_bnli(ins(2:end));
   if ~isempty(psapi)
       psapi_.fname = unique([psapi.fname,psapi2.fname]);
       psapi = cat_timeseries(psapi, psapi2);psapi.fname = psapi_.fname;
       xmsn_reset.time = xmsn_reset.R_time; xmsn_reset2.time = xmsn_reset2.R_time;
       xmsn_reset = cat_timeseries(xmsn_reset, xmsn_reset2);
   else
       psapi = psapi2; xmsn_reset= xmsn_reset2; mf_p = mf_p2;
   end
else
   if iscell(ins);
      fid = fopen(ins{1});
      [psapi.pname,psapi.fname,ext] = fileparts(ins{1});
   else
      fid = fopen(ins);
      [psapi.pname,psapi.fname,ext] = fileparts(ins);
   end
   
   psapi.pname = {psapi.pname}; psapi.fname = {[psapi.fname, ext]};
   
   this = fgetl(fid);
   a = 1;
   while isempty(strfind(this,'yyyy-mm-dd'))&&isempty(strfind(this,'hh:mm:ss.sss'))&&isempty(strfind(this,'YYMMDDhhmmss'))
      this = fgetl(fid);
      a = a + 1;
   end
   
   % Date	Time	Inst. Time	Information record	Valve position	Flow setpoint	Flow read
   % UTC	UTC
   % yyyy-mm-dd	hh:mm:ss.sss	YYMMDDhhmmss	"x,h,h,h,..."	open/closed	SCCM	SCCM
   %
   %
   % 2018-06-28	19:00:00.151	180628185001	"01,00132596c7,001fdda41b,00b9f0,00,K0=0.866,K1=1.317"	error	NaN	NaN
   
   format_str = '%s %s %s %s %s %f %f %*[^\n]';
C = textscan(fid, format_str);
   % Clean up incomplete C
   first_len = size(C{1},1);last_len = size(C{end},1);
   if first_len ~= last_len
      for CC = length(C):-1:1
         if size(C{CC},1)~=last_len
            C{CC}(last_len+1:end) = [];
         end
      end
   end
   D = {[]};
   while ~feof(fid) %then get_more_parts
      disp(['Bad packet in :',psapi.fname])
      while isempty(D{end})
         tmp = fgetl(fid); D = textscan(tmp,format_str);
      end
      C_ = textscan(fid, format_str);   first_len = size(C_{1},1);last_len = size(C_{end},1);
      if first_len ~= last_len
         for CC = length(C_):-1:1
            if size(C_{CC},1)~=last_len
               C_{CC}(last_len+1:end) = [];
            end
         end
      end
      for L = 1:length(C_)
         C(L) = {[C{L};C_{L}]};
      end
   end
   fclose(fid);
   nonan = ~strcmp(C{4},'NaN');
   if any(nonan)
       C(1)= {char(C{1})};
       C(2)= {char(C{2})};
       C(3) ={char(C{3})};
       T = [C{1},repmat(' ',[length(C{7}),1]), C{2}];
       psapi.time = datenum(T,'yyyy-mm-dd HH:MM:SS.fff');
       nans = NaN(size(psapi.time));
       psapi.itime = nans; psapi.I_SS = nans;
       
       IT = [repmat('20',[length(C{7}),1]), C{3}];
       psapi.itime(nonan)  = datenum(IT(nonan,:),'yyyymmddHHMMSS');
       V = datevec(psapi.itime(nonan));
       psapi.I_SS(nonan) = floor(V(:,6));
       psapi.I_str = C{4}; psapi.I_str = strrep(psapi.I_str,'"','');
       psapi.valve_pos = NaN(size(psapi.time));
       tmp = C{5};
       psapi.valve_pos(strcmp(upper(tmp),'ON')) = 1; psapi.valve_pos(strcmp(upper(tmp),'OFF')) = 0;
       psapi.dil_flow_setpt = C{6};
       psapi.dil_flow_read = C{7};
       resets= find(psapi.I_SS==4);
       reset_str = psapi.I_str(resets);
       
       for no = length(reset_str):-1:1
           out = textscan(char(reset_str{no}),'%*s %*s %*s %*s %*s %*s %*s %s','delimiter',',');
           reset_time(no) = out{:};
       end
       if ~isavar('reset_time');
           reset_time = [];
       end
       [~, ij] = unique(reset_time);
       if length(psapi.time)>= resets(ij(end))+3
           % time:  04,14,00005634,0014,fffff6,fffffe,03,180618210120
           % blue:  05,0018663ad1,00289b8091,00ecf0,00,0.615
           % green: 06,0022f7e68b,0029b00fb5,00ecf0,00,0.868
           % red :  07,001a9adf01,002356a662,00ecf0,00,0.773
           for N = length(ij):-1:1
               tim_ = textscan(char(psapi.I_str(resets(ij(N)))),'%d %*s %*s %*s %*s %*s %*s %s','delimiter',',');
               blu_ = textscan(char(psapi.I_str(resets(ij(N))+1)),'%d %*s %*s %*s %*s %f','delimiter',',');
               grn_ = textscan(char(psapi.I_str(resets(ij(N))+2)),'%d %*s %*s %*s %*s %f','delimiter',',');
               red_ = textscan(char(psapi.I_str(resets(ij(N))+3)),'%d %*s %*s %*s %*s %f','delimiter',',');
               if tim_{1}==4 && blu_{1}==5 && grn_{1}==6 && red_{1}==7
                   try
                       xmsn_reset.R_time(N) = datenum(['20',char(tim_{2})],'yyyymmddHHMMSS');
                   catch
                       xmsn_reset.R_time(N) = psapi.itime(1);
                   end
                   xmsn_reset.R_timestr(N) = {datestr(xmsn_reset.R_time(N),'yymmddHHMMSS')};
                   xmsn_reset.blu_norm_factor(N) = blu_{2};
                   xmsn_reset.grn_norm_factor(N) = grn_{2};
                   xmsn_reset.red_norm_factor(N) = red_{2};
               end
           end
       end
       
       % Now to get nass flow parameters from SS = 21,22,23
       mf_p= find(psapi.I_SS==21,1,'first');
       if length(psapi.time)>= mf_p+2
           % "21,007c499f0a,00ced7cb9e,04b5f0,00,mf0p0=1000"
           % "22,00b1958224,00d3b0812d,04b5f0,00,mf0p3=1240"
           % "23,0086e4aef6,00b328d77d,04b5f0,00,mf2p0=2600"
           mf0p0 = textscan(char(psapi.I_str(mf_p)),'%d %*s %*s %*s %*s %s','delimiter',',');
           mf0p3 = textscan(char(psapi.I_str(mf_p+1)),'%d %*s %*s %*s %*s %s','delimiter',',');
           mf2p0 = textscan(char(psapi.I_str(mf_p+2)),'%d %*s %*s %*s %*s %s','delimiter',',');
           if mf0p0{1}==21 && mf0p3{1}==22 && mf2p0{1}==23
               [~,tmp] = strtok(mf0p0{2},'='); tmp = tmp{1};
               if ~isempty(tmp(2:end))
                  mfp(1) = sscanf([tmp(2:end), ' '],'%f');
               end
               [~,tmp] = strtok(mf0p3{2},'=');tmp = tmp{1};
               mfp(2) = sscanf(tmp(2:end),'%f');
               [~,tmp] = strtok(mf2p0{2},'=');tmp = tmp{1};
               mfp(3) = sscanf(tmp(2:end),'%f');
           end
           clear mf_p
           mf_p.AD = mfp; mf_p.flow_LPM = [0,.3,2];
           mf_p.P = polyfit(mf_p.AD,mf_p.flow_LPM ,2);
       end
   else
       psapi = []; xmsn_reset = [];mf_p = [];
   end
end
%%
return
