function [cpc3025_grid, cpc3025] = rd_cpc3025_g1(ins);
% [cpc3025_grid, cpc3025] = rd_cpc3025_g1(ins);
% Works for ACME V
if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname_('*.3025.txt','aaf_cpc3025');
end

[cpc3025.pname,cpc3025.fname,ext] = fileparts(ins);
cpc3025.pname = [cpc3025.pname, filesep]; cpc3025.fname = [cpc3025.fname, ext];
matdir = [cpc3025.pname,'..',filesep,'mats',filesep];
if ~exist(matdir,'dir')
    mkdir(matdir);
    matdir = [matdir, filesep];
end

cpc3025_grid_mat = [matdir, cpc3025.fname(1:10), 'cpc3025_grid.mat'];
cpc3025_mat = [matdir, cpc3025.fname(1:10), 'cpc3025.mat'];

if exist(cpc3025_mat, 'file')&&exist(cpc3025_grid_mat,'file')
    cpc3025 = load(cpc3025_mat);
    cpc3025_grid = load(cpc3025_grid_mat);
else
    %  TimeM300,Conc(cm^-3),1-s_count,Liq_Level,Tcond(C),Tsat(C),Topt(C),Flow(cm^3/s),Envir,Ref(V),Det(V),Pump_Set,Cap_flow(cm^3/s)
    % 22:09:48.53,0.00e+000,       0,       0,    10.1,    37.1,    39.1,    0.00,       0,   4.557,  -0.019,     255,0.002
    fid = fopen(ins);
    if fid>0
        
        
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
        
        % 222:09:48.53,0.00e+000,       0,       0,    10.1,    37.1,    39.1,    0.00,       0,   4.557,  -0.019,     255,0.002
        fseek(fid,b4,-1);  % rewind to the point "before" the line read above
        done_reading = false;
        while ~done_reading
            % This should read the entire file
            [A, pos] = textscan(fid,'%s %f %f %f %f %f %f %f %f %f %f %f %f %*[^\n] %*[\n]', 'delimiter',',');
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
        TS = A{1};DS = datenum(cpc3025.fname(1:8),'yyyymmdd');
        cpc3025.time = datenum(TS,'HH:MM:SS.FFF')-datenum('00:00:00','HH:MM:SS') + DS;
        % Handle day roll-over
        while any(diff(cpc3025.time)<0)
            mark = find(diff(cpc3025.time)<0);
            cpc3025.time(mark+1:end) = cpc3025.time(mark+1:end) +1;
        end
        
        
        [cpc3025.time, ij] = unique(cpc3025.time);
        
        for aa = 1:length(A)
            A(aa) = {A{aa}(ij)};
        end
        
        %  TimeM300,Conc(cm^-3),1-s_count,Liq_Level,Tcond(C),Tsat(C),Topt(C),Flow(cm^3/s),Envir,Ref(V),Det(V),Pump_Set,Cap_flow(cm^3/s)
        
        
        cpc3025.N_CN_conc = A{2}; cpc3025.N_CN_count = A{3};  cpc3025.liquid_level = A{4};
        cpc3025.T_cond_C = A{5}; cpc3025.T_sat_C = A{6};cpc3025.T_opt_C = A{7};
        cpc3025.Flow_ccps = A{8};cpc3025.Envir = A{9}; cpc3025.Ref_V = A{10};
        cpc3025.Det_V = A{11};cpc3025.Pump_SP = A{12};cpc3025.Cap_flow_ccps = A{13};
        % We'll want to cycle through these fields to clean up bad records when found
        dmp = fieldnames(cpc3025);
        for N = length(cpc3025.time):-1:2
            if length(TS{N})~=11 % If the timestring is malformed then delete the entire record
                TS(N) = [];
                for d = 1:length(dmp)
                    cpc3025.(char(dmp{d}))(N) = [];
                end
            end
        end
    end
    % [utime,ii] = unique(cpc3025.time);
    % dup = setxor([1:length(cpc3025.time)],ii);
    % cpc3025.time_new = cpc3025.time;
    % cpc3025.time_new(dup) = cpc3025.time_new(dup-1)+1./(24*60*60);
    %
    % figure; plot(serial2doys(cpc3025.time), cpc3025.Bs_B, '-b.',serial2doys(cpc3025.time_new(dup)), cpc3025.Bs_B(dup), 'ro');
    
    cpc3025_grid.time = [cpc3025.time(1):(1./(24*60*60)):cpc3025.time(end)]';
    [ainb, bina] = nearest(cpc3025.time,cpc3025_grid.time);
    fields = fieldnames(cpc3025);
    for f = 1:length(fields)
        field = fields{f};
        if ~strcmp(field,'time')&&~strcmp(field,'pname')&&~strcmp(field,'fname')
            cpc3025_grid.(field) = NaN(size(cpc3025_grid.time));
            cpc3025_grid.(field)(bina) = cpc3025.(field)(ainb);
        end
    end
    disp('smoothing...  be patient')
    % cpc3025_grid.Bs_B_sm = smooth(cpc3025_grid.Bs_B,60); cpc3025_grid.Bb_B_sm = smooth(cpc3025_grid.Bb_B,60);
    % cpc3025_grid.Bs_G_sm = smooth(cpc3025_grid.Bs_G,60); cpc3025_grid.Bb_G_sm = smooth(cpc3025_grid.Bb_G,60);
    % cpc3025_grid.Bs_R_sm = smooth(cpc3025_grid.Bs_R,60); cpc3025_grid.Bb_R_sm = smooth(cpc3025_grid.Bb_R,60);
    
    
    save([matdir, cpc3025.fname(1:10), 'cpc3025.mat'],'-struct','cpc3025');
    save([matdir, cpc3025.fname(1:10), 'cpc3025_grid.mat'],'-struct','cpc3025_grid');
end
return
