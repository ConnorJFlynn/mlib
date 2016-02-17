function psap_txt = rd_psap_txt_g1(ins);
if ~exist('ins','var') || ~exist(ins,'file')
   ins = getfullname_('*psap.txt','aaf_psap');
end

%  TimeM300,Time(YYMMDDhhmmss),Abs_b(Mm^-1),Abs_g(Mm^-1),Abs_r(Mm^-1),Trns_b,Trns_g,Trns_r,Flow(lpm),FlowVAvg(mV),AvgTime,Status, T_isok_PSAP(C),RH_isok_PSAP(%)  
% 19:58:41.41,150607105220,0.000,0.200,1.800,0.994000018,0.995000005,0.995999992,1.565,2252.000,        2,       82,19.11,10.13
% 16:59:03.92,8.957e-007,1.628e-006,2.377e-006,2.027e-007,5.073e-007,2.213e-006, 719.9,312.3,22.1,312.5,12.7, 5.9,   1,   0,   0
fid = fopen(ins);
if fid>0
   [psap_txt.pname,psap_txt.fname,ext] = fileparts(ins);
   psap_txt.pname = [psap_txt.pname, filesep]; psap_txt.fname = [psap_txt.fname, ext];
   
   % 22:12:12.53,150604130603   -2.9   -2.3   -6.4 1.000 1.000 1.000  .000  .100   2 0092 "03,007dbea296,00773aa880,02e310,00"
   this = fgetl(fid);
   if ~isempty(strfind(this,'Abs_b(Mm^-1)'))
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
%    19:58:41.41,150607105220,0.000,0.200,1.800,0.994000018,0.995000005,0.995999992,1.565,2252.000,        2,       82,19.11,10.13
   fseek(fid,b4,-1);  % rewind to the point "before" the line read above
   done_reading = false;
   while ~done_reading
       % This should read the entire file
      [A, pos] = textscan(fid,'%s %d %f %f %f %f %f %f %f %f %f %f %f %f %*[^\n] %*[\n]', 'delimiter',',');
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
   TS = A{1};DS = datenum(psap_txt.fname(1:8),'yyyymmdd');
   psap_txt.time = datenum(TS,'HH:MM:SS.FFF')-datenum('00:00:00','HH:MM:SS') + DS;
   % Handle day roll-over
   while any(diff(psap_txt.time)<0)
      mark = find(diff(psap_txt.time)<0);
      psap_txt.time(mark+1:end) = psap_txt.time(mark+1:end) +1;
   end
   
 %  TimeM300,Time(YYMMDDhhmmss),Abs_b(Mm^-1),Abs_g(Mm^-1),Abs_r(Mm^-1),Trns_b,Trns_g,Trns_r,Flow(lpm),FlowVAvg(mV),AvgTime,Status, T_isok_PSAP(C),RH_isok_PSAP(%)  

   psap_txt.Ba_B = A{3}; psap_txt.Ba_G = A{4}; psap_txt.Ba_R = A{5};
   psap_txt.Tr_B = A{6}; psap_txt.Tr_G = A{7}; psap_txt.Tr_R = A{8};
   psap_txt.mass_flow_last= A{9}; psap_txt.mass_flow_Avg = A{10};
   psap_txt.N_secs = A{11}; psap_txt.status = A{12};
   psap_txt.T_post_PSAP = A{13};
   psap_txt.RH_post_PSAP = A{14};
   % We'll want to cycle through these fields to clean up bad records when found
   dmp = fieldnames(psap_txt); dmp(1) = []; dmp(1) = []; dmp(1) = [];
%    dmp = {'time','N_secs','status','Ba_B','Ba_G','Ba_R','Tr_B','Tr_G','Tr_R','endstr','mass_flow_last','mass_flow_mv'};
   for N = length(psap_txt.time):-1:2
      if length(TS{N})~=11 % If the timestring is malformed then delete the entire record
         TS(N) = [];
         for d = 1:length(dmp)
            psap_txt.(char(dmp{d}))(N) = [];
         end
%          psap_txt.time(N) = []; psap_txt.N_secs(N) = [];psap_txt.status(N) = [];
%          psap_txt.Ba_B(N) = [];psap_txt.Ba_G(N) = [];psap_txt.Ba_R(N) = [];
%          psap_txt.Tr_B(N) = []; psap_txt.Tr_G(N) = [];psap_txt.Tr_R(N) = [];
%          psap_txt.endstr(N) = []; psap_txt.mass_flow_last(N)= [];psap_txt.mass_flow_mv(N) = [];
      end
   end
end
matdir = [psap_txt.pname, filesep,'..',filesep,'mats'];
if ~exist(matdir,'dir')
    mkdir(matdir);
    matdir = [matdir, filesep];
end
save([matdir, psap_txt.fname(1:10), 'psap_txt.mat'],'-struct','psap_txt');

return
