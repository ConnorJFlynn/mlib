function [neph_grid, neph] = rd_neph_g1(ins,cal);
if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname_('*nephD.txt','aaf_neph');
end

if exist('cal','var')&&istruct(cal)
tbs_offset=cal.tbs_offset;  
tgs_offset=cal.tgs_offset;
trs_offset=cal.trs_offset;
bbs_offset=cal.bbs_offset;
bgs_offset=cal.bgs_offset;
brs_offset=cal.brs_offset;

tbs_factor=cal.tbs_factor;  
tgs_factor=cal.tgs_factor;  
trs_factor=cal.trs_factor;
bbs_factor=cal.bbs_factor;  
bgs_factor=cal.bgs_factor;  
brs_factor=cal.brs_factor;
    
else
    
tbs_offset=0.466;  
tgs_offset=0.228;
trs_offset=1.023;
bbs_offset=-0.236;
bgs_offset=0.105;
brs_offset=0.509;

tbs_factor=0.9889;  
tgs_factor=0.9962;  
trs_factor=0.9794;
bbs_factor=0.9773;  
bgs_factor=0.9657;  
brs_factor=0.9560;

    
end
%  TimeM300,D-BCoef(Mm^-1),D-GCoef(Mm^-1),D-RCoef(Mm^-1),D-BCoefBk(Mm^-1),D-GCoefBk(Mm^-1),D-RCoefBk(Mm^-1),P(mb),Ts(K),RH(%),Ti(K),Lamp(V),Lamp(A),D-ModeCode,ValveNormFlag,ValvState
% 21:18:57.81,2.636e-005,1.276e-005,8.231e-006,1.321e-005,5.941e-006,4.575e-006, 995.7,309.7,35.4,308.7,12.2, 6.0,   2,   1,   1
% 21:18:58.71,2.636e-005,1.276e-005,8.231e-006,1.321e-005,5.941e-006,4.575e-006, 995.7,309.7,35.4,308.7,12.5, 6.0,   2,   1,  -1
[neph.pname,neph.fname,ext] = fileparts(ins);
neph.pname = [neph.pname, filesep]; neph.fname = [neph.fname, ext];

matdir = [neph.pname,'..',filesep,'mats',filesep];
if ~exist(matdir,'dir')
    mkdir(matdir);
    matdir = [matdir, filesep];
end
neph_mat = [matdir, neph.fname(1:10), 'neph.mat'];
neph_grid_mat = [matdir, neph.fname(1:10), 'neph_grid.mat'];
if exist(neph_mat,'file') &&  exist(neph_grid_mat,'file')
    disp(['Loading from save mat files'])
    neph = load(neph_mat);
    neph_grid = load(neph_grid_mat);
else
    
    fid = fopen(ins);
    if fid>0
        
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
        TS = A{1};
        DS = datenum(neph.fname(1:8),'yyyymmdd');
        neph.time=  datenum(TS,'HH:MM:SS.FFF')-datenum('00:00:00','HH:MM:SS') + DS;
        % Handle day roll-over
        while any(diff(neph.time)<0)
            mark = find(diff(neph.time)<0);
            neph.time(mark+1:end) = neph.time(mark+1:end) +1;
        end
        
        [neph.time, ij] = unique(neph.time);
        for aa = 1:length(A)
            A(aa) = {A{aa}(ij)};
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

        for N = length(neph.time):-1:2
            if length(TS{N})~=11 % If the timestring is malformed then delete the entire record
                TS(N) = [];
                for d = 1:length(dmp)
                    neph.(char(dmp{d}))(N) = [];
                end
            end
        end
    end
    [utime,ii] = unique(neph.time);
    % dup = setxor([1:length(neph.time)],ii);
    % neph.time_new = neph.time;
    % neph.time_new(dup) = neph.time_new(dup-1)+1./(24*60*60);
    %
    % figure; plot(serial2doys(neph.time), neph.Bs_B, '-b.',serial2doys(neph.time_new(dup)), neph.Bs_B(dup), 'ro');
    
    % neph calibrations coefficinets
% correction equation is: (observed-offset)*Factor
% correction equation is: (observed-offset)*Factor

% convert  in situ to STP: dens proportional to P/T    = P_stp/P_vol * T_vol/T_stp
% This will be used to determine scattering correction to apply to the PSAP

% Use only neph data with ValvState= 1.  
% This should be used after correcting for offset and scale factor, and
% then applying truncation corrections
% Convert to ambient (outside aircraft)   = P_ambient/P_vol * T_vol/T_ambient

neph.Bs_B = (neph.Bs_B-tbs_offset.*1e-6).*tbs_factor;
neph.Bs_G = (neph.Bs_G-tgs_offset.*1e-6).*tgs_factor;
neph.Bs_R = (neph.Bs_R-trs_offset.*1e-6).*trs_factor;

neph.Bb_B = (neph.Bb_B-bbs_offset.*1e-6).*bbs_factor;
neph.Bb_G = (neph.Bb_G-bgs_offset.*1e-6).*bgs_factor;
neph.Bb_R = (neph.Bb_R-brs_offset.*1e-6).*brs_factor;

% So the idea is to compute angstrom exponent

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
    
    neph_grid.Ae_GB = angst(neph_grid.Bs_B_sm, neph_grid.Bs_G_sm, 450, 550); 
    neph_grid.Ae_RG = angst(neph_grid.Bs_R_sm, neph_grid.Bs_G_sm, 700, 550);
    neph_grid.Ae_RB = angst(neph_grid.Bs_R_sm, neph_grid.Bs_B_sm, 700, 450);

    %C = a + b .* ang
%     Blue_a = 1.165; Blue_b = -0.046; % 1 um
%     Green_a = 1.152; Green_b = -0.044; % 1 um
%     Red_a = 1.12; Red_b = -0.035; % 1 um
    Blue_a = 1.365; Blue_b = -0.156; % no cut
    Green_a = 1.337; Green_b = -0.138; % no cut
    Red_a = 1.297; Red_b = -0.113; % no cut
    
    neph_grid.Bs_B_sm_tr = neph_grid.Bs_B_sm .* (Blue_a + Blue_b .* neph_grid.Ae_GB);
    neph_grid.Bs_G_sm_tr = neph_grid.Bs_G_sm .* (Green_a + Green_b .* neph_grid.Ae_RB);
    neph_grid.Bs_R_sm_tr = neph_grid.Bs_R_sm .* (Red_a + Red_b .* neph_grid.Ae_RG);
%     neph_grid.Bb_B_sm_tr = neph_grid.Bb_B_sm .* .951; % 1 um
%     neph_grid.Bb_G_sm_tr = neph_grid.Bb_G_sm .* .947; % 1 um
%     neph_grid.Bb_R_sm_tr = neph_grid.Bb_R_sm .* .952; % 1 um
    neph_grid.Bb_B_sm_tr = neph_grid.Bb_B_sm .* .981; % no cut
    neph_grid.Bb_G_sm_tr = neph_grid.Bb_G_sm .* .982; % no cut
    neph_grid.Bb_R_sm_tr = neph_grid.Bb_R_sm .* .985; % no cut
    
    neph.dens_corr = (1013.5./neph.P).*(neph.T_vol./273.15);
    neph_grid.dens_corr = (1013.5./neph_grid.P).*(neph_grid.T_vol./273.15);
    % STP 1013.5 Pa, 0 C
% Multiply neph scattering by this density correction factor to get values at STP.

    % The values with _tr have truncation correction applied.
    
    save([matdir, neph.fname(1:10), 'neph.mat'],'-struct','neph');
    save([matdir, neph.fname(1:10), 'neph_grid.mat'],'-struct','neph_grid');
end

return

function ang = angst(A,B,a,b);
ang = NaN(size(A));
NaNs = ~isfinite(A)|~isfinite(B)|(A<0)|(B<=0);
ang(~NaNs) = log(A(~NaNs)./B(~NaNs))./log(b/a);