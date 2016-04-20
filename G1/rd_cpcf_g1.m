function [cpcf_grid, cpcf] = rd_cpc_3010_g1(ins);
% [cpcf_grid, cpcf] = rd_cpc_3010_g1(ins);
% Works for ACME V
if ~exist('ins','var') || ~exist(ins,'file')
   ins = getfullname_('*.3010.txt','aaf_cpcf');
end

%  TimeM300,Conc(cm^-3),1-s_count,Vac_Status,Liq_Level,Tcond(C),Tsat(C),Envir 
% 22:09:48.53,0.00e+000,       0,       0,       1,     3.7,    20.6,       0
fid = fopen(ins);
if fid>0
   [cpcf.pname,cpcf.fname,ext] = fileparts(ins);
   cpcf.pname = [cpcf.pname, filesep]; cpcf.fname = [cpcf.fname, ext];
   
   this = fgetl(fid);
   if ~isempty(strfind(this,'TimeM300'))
       C = textscan(this, '%s','delimiter',',');
       C = C{:};
       cols = length(C);
   end
   % skip records until we find colons in 3 and 6 position. 
   while ~strcmp(this(3),':')&&~strcmp(this(6),':')&&~feof(fid)
      %%
      b4 = ftell(fid); % "before"
      this = fgetl(fid);
      %%
   end
   
% 22:09:47.53,1002.7,-0.35,-0.35,-5.08,70.39,5.18,5.2,-2,0.2,-5.2,-2.8   
   fseek(fid,b4,-1);  % rewind to the point "before" the line read above
   done_reading = false;
   while ~done_reading
       % This should read the entire file
      [A, pos] = textscan(fid,'%s %f %f %f %f %f %f %f %*[^\n] %*[\n]', 'delimiter',',');
      if any(size(A{1})~=size(A{end}))
         disp('File read error! Continuing past error...')
         A_sz = size(A{end});
         % delete uneven records.
         for aa = length(A)-1 : -1:1
            if any(A_sz~=size(A{aa}))
               B = A{aa};
               B(end) = [];
               A(aa) = {B};
            end
         end
         % The input file might not have complete 4-second sequences so 
         % save original portion in Z for later concatenation
         if ~exist('Z','var')
            Z = A;
         else
            for L = length(A):-1:1
               Z(L) = {[Z{L}; A{L}]};
            end
            
         end
         clear A
         this = fgetl(fid); % Trash next line in case it is bogus.
      else
         done_reading = true;
      end
      % If both A and Z exist, concatenate them
      if exist('A','var')&&exist('Z','var')
         for L = length(Z):-1:1
            ZZ = Z{L}; AA = A{L};
            Z(L) = {[Z{L}; A{L}]};
         end
      end
      
   end
   if exist('Z','var')
      A = Z; 
      clear Z 
   end
   TS = A{1};DS = datenum(cpcf.fname(1:8),'yyyymmdd');
   cpcf.time = datenum(TS,'HH:MM:SS.FFF')-datenum('00:00:00','HH:MM:SS') + DS;
   % Handle day roll-over
   while any(diff(cpcf.time)<0)
      mark = find(diff(cpcf.time)<0);
      cpcf.time(mark+1:end) = cpcf.time(mark+1:end) +1;
   end
   
%  TimeM300,Conc(cm^-3),1-s_count,Vac_Status,Liq_Level,Tcond(C),Tsat(C),Envir 
% 22:09:47.53,1002.7,-0.35,-0.35,-5.08,70.39,5.18,5.2,-2,0.2,-5.2,-2.8

   cpcf.N_CN_conc = A{2}; cpcf.N_CN_count = A{3}; cpcf.Vac_status = A{4};
   cpcf.liquid_level = A{5}; cpcf.T_cond_C = A{6}; cpcf.T_sat_C = A{7};
   cpcf.Envir = A{8}; 
   % We'll want to cycle through these fields to clean up bad records when found
   dmp = fieldnames(cpcf); 
   for N = length(cpcf.time):-1:2
      if length(TS{N})~=11 % If the timestring is malformed then delete the entire record
         TS(N) = [];
         for d = 1:length(dmp)
            cpcf.(char(dmp{d}))(N) = [];
         end
      end
   end
end
[utime,ii] = unique(cpcf.time);
% dup = setxor([1:length(cpcf.time)],ii);
% cpcf.time_new = cpcf.time; 
% cpcf.time_new(dup) = cpcf.time_new(dup-1)+1./(24*60*60);
% 
% figure; plot(serial2doys(cpcf.time), cpcf.Bs_B, '-b.',serial2doys(cpcf.time_new(dup)), cpcf.Bs_B(dup), 'ro');

cpcf_grid.time = [utime(1):(1./(24*60*60)):utime(end)]';
[ainb, bina] = nearest(utime,cpcf_grid.time);
fields = fieldnames(cpcf);
for f = 1:length(fields)
   field = fields{f};
   if ~strcmp(field,'time')&&~strcmp(field,'pname')&&~strcmp(field,'fname')
      cpcf_grid.(field) = NaN(size(cpcf_grid.time));
      cpcf_grid.(field)(bina) = cpcf.(field)(ii(ainb));
   end      
end
disp('smoothing...  be patient')
% cpcf_grid.Bs_B_sm = smooth(cpcf_grid.Bs_B,60); cpcf_grid.Bb_B_sm = smooth(cpcf_grid.Bb_B,60);
% cpcf_grid.Bs_G_sm = smooth(cpcf_grid.Bs_G,60); cpcf_grid.Bb_G_sm = smooth(cpcf_grid.Bb_G,60);
% cpcf_grid.Bs_R_sm = smooth(cpcf_grid.Bs_R,60); cpcf_grid.Bb_R_sm = smooth(cpcf_grid.Bb_R,60);

matdir = [cpcf.pname, filesep,'..',filesep,'mats',filesep];
if ~exist(matdir,'dir')
    mkdir(matdir);
    matdir = [matdir, filesep];
end
save([matdir, cpcf.fname(1:10), 'cpcf.mat'],'-struct','cpcf');
save([matdir, cpcf.fname(1:10), 'cpcf_grid.mat'],'-struct','cpcf_grid');

return
