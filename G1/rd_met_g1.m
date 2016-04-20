function [met_grid, met] = rd_met_g1(ins);
% [met_grid, met] = rd_met_g1(ins);
% Works for ACME V
if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname_('*met.txt','aaf_met');
end
[met.pname,met.fname,ext] = fileparts(ins);
met.pname = [met.pname, filesep]; met.fname = [met.fname, ext];
%  TimeM300,Pstat(mb),Tmeas(C),Tstat(C),Tdew_GE(C),RH_GE(%),TAS_gust(m/s),WndSpd(m/s),WndDir(deg),Wnd_u(m/s),Wnd_v(m/s),Wnd_w(m/s)
% 22:09:47.53,1002.7,-0.35,-0.35,-5.08,70.39,5.18,5.2,-2,0.2,-5.2,-2.8
% 22:09:48.53,1002.8,-0.34,-0.34,-5.08,70.28,8.24,8.2,-12,1.6,-8.1,-1.0
matdir = [met.pname,'..',filesep,'mats',filesep];
if ~exist(matdir,'dir')
    mkdir(matdir);
    matdir = [matdir, filesep];
end
met_mat = [matdir, met.fname(1:10), 'met.mat'];
met_grid_mat = [matdir, met.fname(1:10), 'met_grid.mat'];

if exist(met_mat,'file')&&exist(met_grid_mat,'file')
    
    met = load([matdir, met.fname(1:10), 'met.mat']);
    met_grid = load([matdir, met.fname(1:10), 'met_grid.mat']);
else
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
        
        % 22:09:47.53,1002.7,-0.35,-0.35,-5.08,70.39,5.18,5.2,-2,0.2,-5.2,-2.8
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
        TS = A{1};DS = datenum(met.fname(1:8),'yyyymmdd');
        met.time = datenum(TS,'HH:MM:SS.FFF')-datenum('00:00:00','HH:MM:SS') + DS;
        % Handle day roll-over
        while any(diff(met.time)<0)
            mark = find(diff(met.time)<0);
            met.time(mark+1:end) = met.time(mark+1:end) +1;
        end
        
        [met.time, ij] = unique(met.time);
        
        for aa = 1:length(A)
            A(aa) = {A{aa}(ij)};
        end
        
        
        %  TimeM300,Pstat(mb),Tmeas(C),Tstat(C),Tdew_GE(C),RH_GE(%),TAS_gust(m/s),WndSpd(m/s),WndDir(deg),Wnd_u(m/s),Wnd_v(m/s),Wnd_w(m/s)
        % 22:09:47.53,1002.7,-0.35,-0.35,-5.08,70.39,5.18,5.2,-2,0.2,-5.2,-2.8
        
        met.Pstat_mb = A{2}; met.Tmeas_C = A{3}; met.Tstat_C = A{4};
        met.Tdew_GE_C = A{5}; met.RH_GE = A{6}; met.TAS_Gust_mps = A{7};
        met.WndSpd_mps = A{8}; met.WinDir_deg = A{9}; met.Wind_u_mps = A{10};
        met.Wind_v_mps= A{11}; met.Wind_w_mps = A{12};
        % We'll want to cycle through these fields to clean up bad records when found
        dmp = fieldnames(met);
        for N = length(met.time):-1:2
            if length(TS{N})~=11 % If the timestring is malformed then delete the entire record
                TS(N) = [];
                for d = 1:length(dmp)
                    met.(char(dmp{d}))(N) = [];
                end
            end
        end
    end
    % [utime,ii] = unique(met.time);
    % dup = setxor([1:length(met.time)],ii);
    % met.time_new = met.time;
    % met.time_new(dup) = met.time_new(dup-1)+1./(24*60*60);
    %
    % figure; plot(serial2doys(met.time), met.Bs_B, '-b.',serial2doys(met.time_new(dup)), met.Bs_B(dup), 'ro');
    
    met_grid.time = [met.time(1):(1./(24*60*60)):met.time(end)]';
    [ainb, bina] = nearest(met.time,met_grid.time);
    fields = fieldnames(met);
    for f = 1:length(fields)
        field = fields{f};
        if ~strcmp(field,'time')&&~strcmp(field,'pname')&&~strcmp(field,'fname')
            met_grid.(field) = NaN(size(met_grid.time));
            met_grid.(field)(bina) = met.(field)(ainb);
        end
    end
    disp('smoothing...  be patient')
    % met_grid.Bs_B_sm = smooth(met_grid.Bs_B,60); met_grid.Bb_B_sm = smooth(met_grid.Bb_B,60);
    % met_grid.Bs_G_sm = smooth(met_grid.Bs_G,60); met_grid.Bb_G_sm = smooth(met_grid.Bb_G,60);
    % met_grid.Bs_R_sm = smooth(met_grid.Bs_R,60); met_grid.Bb_R_sm = smooth(met_grid.Bb_R,60);
    
    save([matdir, met.fname(1:10), 'met.mat'],'-struct','met');
    save([matdir, met.fname(1:10), 'met_grid.mat'],'-struct','met_grid');
end

return
