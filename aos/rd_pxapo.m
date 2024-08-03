function [pxap, resets] = rd_pxapo(infile);

if ~isavar('infile')
   infile = getfullname('P*AP*.o.*dat','pxap_amice','Select AMICE PXAP "o" file.');
end

if iscell(infile)&&length(infile)>1
   [pxap, raw] = rd_pxapo(infile{1});
   raw.time = pxap.time; pxap.fname = raw.fname; 
   [pxap2, raw2] = rd_pxapo(infile(2:end));
   raw2.time = pxap2.time;pxap2.fname = raw2.fname;
%    xap_.fname = unique([xap.fname,xap2.fname]);
   raw_.fname = unique([raw.fname, raw2.fname]);
   raw = cat_timeseries(raw, raw2);raw.fname = raw_.fname;
   pxap = cat_timeseries(pxap, pxap2); pxap.fname = raw.fname; pxap.pname = raw.pname;
else
   if iscell(infile); infile = infile{1}; end
   if isafile(infile)
      %   Detailed explanation goes here
      % 2024-07-26, 20:16:02, 240727005804   -3.04   -2.77   -2.11  .768  .789  .818  .106  1085  60 0084 "04,08,00375ccc,0d08,fffffa,ffffff,04,240725210812"
      fid = fopen(infile);
   else
      disp('No valid file selected.')
      return
   end

   [raw.pname,raw.fname, ext] = fileparts(infile); raw.fname = [raw.fname, ext];
   if iscell(raw.fname)
      raw.fname = raw.fname{1}; 
   end
   [~, fname] = fileparts(raw.fname);

   raw.pname = {[raw.pname, filesep]}; raw.fname = {[raw.fname, ext]};
   pxap.fname = raw.fname; pxap.pname = raw.pname;
   
   n = 1;
   fmt_str = ''; 
   % 2024-07-26, 20:16:02, 240727005804   -3.04   -2.77   -2.11  .768  .789  .818  .106  1085  60 0084 "04,08,00375ccc,0d08,fffffa,ffffff,04,240725210812"
   %  2024-07-26, 20:16:02, 240727005804
   fmt_str = [fmt_str, '%s %s %d64 ']; % date, time, itime, 
   % -3.04   -2.77   -2.11    
   fmt_str = [fmt_str, '%f %f %f ']; % Ba_B, Ba_G, Ba_R
   %  .768  .789  .818 
   fmt_str = [fmt_str, '%f %f %f ']; % Tr_B, Tr_G, Tr_R
   % .106  1085  60 0084 
  fmt_str = [fmt_str, '%f %f %f %x %s']; % flow_LPM, flow_AD, avg status
   %"04,08,00375ccc,0d08,fffffa,ffffff,04,240725210812" 


  Aa = textscan(fid,fmt_str); fclose(fid);
  Dd = Aa{1}; Tt = Aa{2};
  for dt = length(Dd):-1:1 
     DT(dt) = {[Dd{dt}, Tt{dt}]};
  end
  raw.time = datenum(DT,'yyyy-mm-dd,HH:MM:SS,');
  raw.itime = Aa{3};


  Aa(1:3) = [];
  raw.Ba_B = Aa{1}; raw.Ba_G = Aa{2}; raw.Ba_R = Aa{3}; 
  Aa(1:3) = [];
  raw.Tr_B = Aa{1}; raw.Tr_G = Aa{2}; raw.Tr_R = Aa{3}; 
  Aa(1:3) = [];
  raw.flow_LPM = Aa{1}; raw.flow_AD = Aa{2}; raw.Avg_S = Aa{3}; raw.status = Aa{4};
  Aa(1:4) = [];
  raw.I_str = Aa{1}; raw.I_str = strrep(raw.I_str,'"','');
  
  raw.i_sec = rem(raw.itime,100);
  ios = find(raw.i_sec==4);
  for ii = 1:length(ios)
     io = ios(ii);
     I_str = raw.I_str{io};
     I_str = textscan(I_str,'%*f %*x %*x %*x %*x %*x %*x %s', 'delimiter',','); I_str = I_str{1};
     resets.itime(ii) = datenum(I_str,'yymmddHHMMSS');
     B_str = raw.I_str{io+1}; B = textscan(B_str,'%*f %x %x %x %x %f', 'delimiter',',');
     resets.Io(ii,1) = B{end};
     resets.Bo(ii) = (double(B{1})-double(B{3}-B{4})*256)./ (double(B{2})-double(B{3}-B{4})*256);    
     G_str = raw.I_str{io+2}; G = textscan(G_str,'%*f %x %x %x %x %f', 'delimiter',',');
     resets.Go(ii) = (double(G{1})-double(G{3}-G{4})*256)./ (double(G{2})-double(G{3}-G{4})*256);
     resets.Io(ii,2) = G{end};
     R_str = raw.I_str{io+3}; R = textscan(R_str,'%*f %x %x %x %x %f', 'delimiter',',');
     resets.Ro(ii) = (double(R{1})-double(R{3}-R{4})*256)./ (double(R{2})-double(R{3}-R{4})*256);
     resets.Io(ii,3) = R{end};

     (double(B{1})-double(B{3}-B{4})*256)./ (double(B{2})-double(B{3}-B{4})*256);
     (double(B{1}))./ (double(B{2}));


  end

  pxap = raw;
  pxap.nm = [470, 522, 660];
 
end

return


function resets =  parse_Is(Is)
for x = length(Is):-1:1
   As = textscan(Is{x},'%s'); As = As{1};
   IT(x,:) = ['20',As{2}];
   I_str(x) = As(3);
end
psapi.time  = datenum(IT,'yyyymmddHHMMSS');
psapi.itime = psapi.time;
V = datevec(psapi.itime);
psapi.I_SS = floor(V(:,6));
psapi.I_str = strrep(I_str, '"','');
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

return
