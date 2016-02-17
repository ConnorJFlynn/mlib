function [neph_grid, neph] = rd_neph_g1(ins);
if ~exist('ins','var') || ~exist(ins,'file')
   ins = getfullname_('*nephD.txt','aaf_neph');
end

%  TimeM300,D-BCoef(Mm^-1),D-GCoef(Mm^-1),D-RCoef(Mm^-1),D-BCoefBk(Mm^-1),D-GCoefBk(Mm^-1),D-RCoefBk(Mm^-1),P(mb),Ts(K),RH(%),Ti(K),Lamp(V),Lamp(A),D-ModeCode,ValveNormFlag,ValvState  
% 21:18:57.81,2.636e-005,1.276e-005,8.231e-006,1.321e-005,5.941e-006,4.575e-006, 995.7,309.7,35.4,308.7,12.2, 6.0,   2,   1,   1
% 21:18:58.71,2.636e-005,1.276e-005,8.231e-006,1.321e-005,5.941e-006,4.575e-006, 995.7,309.7,35.4,308.7,12.5, 6.0,   2,   1,  -1


fid = fopen(ins);
if fid>0
   [neph.pname,neph.fname,ext] = fileparts(ins);
   neph.pname = [neph.pname, filesep]; neph.fname = [neph.fname, ext];
   
   this = fgetl(fid);
   if ~isempty(strfind(this,'D-BCoef(Mm^-1)'))
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
   
% 21:18:58.71,2.636e-005,1.276e-005,8.231e-006,1.321e-005,5.941e-006,4.575e-006, 995.7,309.7,35.4,308.7,12.5, 6.0,   2,   1,  -1
   
   fseek(fid,b4,-1);  % rewind to the point "before" the line read above
   done_reading = false;
   while ~done_reading
       % This should read the entire file
      [A, pos] = textscan(fid,'%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f%*[^\n] %*[\n]', 'delimiter',',');
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
   TS = A{1};DS = datenum(neph.fname(1:8),'yyyymmdd');
   neph.time = datenum(TS,'HH:MM:SS.FFF')-datenum('00:00:00','HH:MM:SS') + DS;
   % Handle day roll-over
   while any(diff(neph.time)<0)
      mark = find(diff(neph.time)<0);
      neph.time(mark+1:end) = neph.time(mark+1:end) +1;
   end
   
%  TimeM300,D-BCoef(Mm^-1),D-GCoef(Mm^-1),D-RCoef(Mm^-1),D-BCoefBk(Mm^-1),D-GCoefBk(Mm^-1),D-RCoefBk(Mm^-1),P(mb),Ts(K),RH(%),Ti(K),Lamp(V),Lamp(A),D-ModeCode,ValveNormFlag,ValvState  
% P(mb),Ts(K),RH(%),Ti(K),Lamp(V),Lamp(A),D-ModeCode,ValveNormFlag,ValvState  
   neph.Bs_B = A{2}; neph.Bs_G = A{3}; neph.Bs_R = A{4};
   neph.Bb_B = A{5}; neph.Bb_G = A{6}; neph.Bb_R = A{7};
   neph.P = A{8}; neph.T_stat = A{9}; neph.RH = A{10};
   neph.T_vol= A{11}; neph.Lamp_V = A{12};; neph.Lamp_A = A{13};
   neph.ModeCode = A{14}; neph.ValveNormFlag = A{15};neph.ValveState = A{16};
   % We'll want to cycle through these fields to clean up bad records when found
   dmp = fieldnames(neph); 
%    dmp = {'time','N_secs','status','Ba_B','Ba_G','Ba_R','Tr_B','Tr_G','Tr_R','endstr','mass_flow_last','mass_flow_mv'};
   for N = length(neph.time):-1:2
      if length(TS{N})~=11 % If the timestring is malformed then delete the entire record
         TS(N) = [];
         for d = 1:length(dmp)
            neph.(char(dmp{d}))(N) = [];
         end
%          neph.time(N) = []; neph.N_secs(N) = [];neph.status(N) = [];
%          neph.Ba_B(N) = [];neph.Ba_G(N) = [];neph.Ba_R(N) = [];
%          neph.Tr_B(N) = []; neph.Tr_G(N) = [];neph.Tr_R(N) = [];
%          neph.endstr(N) = []; neph.mass_flow_last(N)= [];neph.mass_flow_mv(N) = [];
      end
   end
end
[utime,ii] = unique(neph.time);
% dup = setxor([1:length(neph.time)],ii);
% neph.time_new = neph.time; 
% neph.time_new(dup) = neph.time_new(dup-1)+1./(24*60*60);
% 
% figure; plot(serial2doys(neph.time), neph.Bs_B, '-b.',serial2doys(neph.time_new(dup)), neph.Bs_B(dup), 'ro');

neph_grid.time = [utime(1):(1./(24*60*60)):utime(end)]';
[ainb, bina] = nearest(utime,neph_grid.time);
fields = fieldnames(neph);
for f = 1:length(fields)
   field = fields{f};
   if ~strcmp(field,'time')&&~strcmp(field,'pname')&&~strcmp(field,'fname')
      neph_grid.(field) = NaN(size(neph_grid.time));
      neph_grid.(field)(bina) = neph.(field)(ii(ainb));
   end      
end
disp('smoothing...  be patient')
neph_grid.Bs_B_sm = smooth(neph_grid.Bs_B,60); neph_grid.Bb_B_sm = smooth(neph_grid.Bb_B,60);
neph_grid.Bs_G_sm = smooth(neph_grid.Bs_G,60); neph_grid.Bb_G_sm = smooth(neph_grid.Bb_G,60);
neph_grid.Bs_R_sm = smooth(neph_grid.Bs_R,60); neph_grid.Bb_R_sm = smooth(neph_grid.Bb_R,60);




matdir = [neph.pname, filesep,'..',filesep,'mats'];
if ~exist(matdir,'dir')
    mkdir(matdir);
    matdir = [matdir, filesep];
end
save([matdir, neph.fname(1:10), 'neph.mat'],'-struct','neph');
save([matdir, neph.fname(1:10), 'neph_grid.mat'],'-struct','neph_grid');

return
