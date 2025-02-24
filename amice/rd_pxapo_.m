function [resets,raw] = rd_pxapo_(infile);
% [resets,raw] = rd_pxapo_
% 2024-12-24: Connor, modifying rd_pxapo to use line-by-line read
% Interactivity introduced in AMICE 1c have generated fragmented packets.
% Shifting to slower line-by-line read of file to screen out partial packets
% 
if ~isavar('infile')
   infile = getfullname('P*AP*.o.*dat','pxap_amice','Select AMICE PXAP "o" file.');
end

if iscell(infile)&&length(infile)>1
   [resets,raw] = rd_pxapo_(infile{1});
   [resets2, raw2] = rd_pxapo_(infile(2:end));
   raw_.fname = unique([raw.fname, raw2.fname]);
   raw = cat_timeseries(raw, raw2);raw.fname = raw_.fname;
   resets.fname = raw.fname; resets.pname = raw.pname;
else
   if iscell(infile); infile = infile{1}; end
   if isafile(infile)
      %   Detailed explanation goes here
      % 2024-07-26, 20:16:02, 240727005804   -3.04   -2.77   -2.11  .768  .789  .818  .106  1085  60 0084 "04,08,00375ccc,0d08,fffffa,ffffff,04,240725210812"
      disp(['Opening ',infile])
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

   raw.pname = {[raw.pname, filesep]}; raw.fname = {[fname, ext]};
   
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
 
   while ~feof(fid)
      inline = fgetl(fid);
      inline = deblank(inline); enil = fliplr(inline);
      enil = deblank(enil); inline = fliplr(enil);
      if length(inline)>131 && strcmp(inline(1:2),'20') && strcmp(inline(21),'2')
         % e75 = findstr(inline,'e75');
         try
             % disp(inline)
           Aa_ = textscan(inline, fmt_str);
         catch
            disp(inline);
            clear Aa_
         end
         if isavar('Aa_') && ~isempty(Aa_{end})
            if isavar('Aa')
               c =1; while c<=length(Aa_); Aa(c) = {[Aa{c};Aa_{c}]}; c = c + 1; end
            else
               Aa = Aa_;
            end
         end
      end
   end
   fclose(fid);

  Dd = Aa{1}; Tt = Aa{2};
  bad = foundstr(Dd,'999')|~foundstr(Dd,'-');
  for dt = length(Dd):-1:1 
     DT(dt) = {[Dd{dt},' ', Tt{dt}]};
  end
  DT = DT(~bad);
  if any(bad) 
     c = 1; while c<=length(Aa); Aa{c} = Aa{c}(~bad); c = c+1; end
  end
  try
     raw.time = datenum(DT,'yyyy-mm-dd, HH:MM:SS,');
  catch
     raw.time = datenum(DT,'yyyy-mm-dd HH:MM:SS');
  end
  raw.itime = Aa{3}; raw.itime(bad) = [];


  Aa(1:3) = [];
  raw.Ba_B = Aa{1}; raw.Ba_G = Aa{2}; raw.Ba_R = Aa{3};  
  raw.Ba_B(bad) = []; raw.Ba_G(bad) = []; raw.Ba_R(bad) = []; 
  Aa(1:3) = [];
  raw.Tr_B = Aa{1}; raw.Tr_G = Aa{2}; raw.Tr_R = Aa{3}; 
    raw.Tr_B(bad)=[]; raw.Tr_G(bad)=[]; raw.Tr_R(bad)=[]; 
  Aa(1:3) = [];
  raw.flow_LPM = Aa{1}; raw.flow_AD = Aa{2}; raw.Avg_S = Aa{3}; raw.status = Aa{4};
    raw.flow_LPM(bad)=[]; raw.flow_AD(bad)=[]; raw.Avg_S(bad)=[]; raw.status(bad)=[];
  Aa(1:4) = [];
  raw.I_str = Aa{1}; raw.I_str = strrep(raw.I_str,'"','');
    raw.I_str(bad)=[]; 

  
  raw.i_sec = rem(raw.itime,100);
  ios = find(raw.i_sec==4); 
  ios((ios+3)>length(raw.i_sec)) = [];
% try
   ios = ios(raw.i_sec(ios)==4 & raw.i_sec(ios+1)==5 & raw.i_sec(ios+2)==6 & raw.i_sec(ios+3)==7);
% catch
% 
%    ios = ios(raw.i_sec(ios+1)==5 & raw.i_sec(ios+2)==6 & raw.i_sec(ios+3)==7);
% end
for ii = length(ios):-1:1
   io = ios(ii);
   I4_str = raw.I_str{io}; I5_str = raw.I_str{io+1}; I6_str = raw.I_str{io+2}; I7_str = raw.I_str{io+3};
   tmp  = {fliplr(strtok(fliplr(I4_str),','))};
   if length(tmp{:})==12
      reset.itime_str(ii) = tmp;
      reset.time(ii) = raw.time(io);
      reset.Bo(ii) = sscanf(fliplr(strtok(fliplr(I5_str),',')),'%f');
      reset.Go(ii) = sscanf(fliplr(strtok(fliplr(I6_str),',')),'%f');
      reset.Ro(ii) = sscanf(fliplr(strtok(fliplr(I7_str),',')),'%f');
   else
      if isavar('reset')&&isfield(reset,'time')
         reset.itime_str(ii) = [];
         reset.time(ii) = [];
         reset.Bo(ii) = [];
         reset.Go(ii) = [];
         reset.Ro(ii) = [];
      end
   end
end
[tmp,ii] = unique(reset.itime_str);
  resets.time = reset.time(ii);
  resets.itime_str = reset.itime_str{ii};  
  resets.Bo = reset.Bo(ii);
  resets.Go = reset.Go(ii);
  resets.Ro = reset.Ro(ii);
  raw.nm = [470, 522, 660];
  resets.itime = datenum(resets.itime_str,'yymmddHHMMSS');
 
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
