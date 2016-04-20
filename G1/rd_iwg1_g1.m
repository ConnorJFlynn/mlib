function [iwg_grid, iwg] = rd_iwg1_g1(ins)
%[iwg_grid, iwg] = rd_iwg1_g1(ins);
if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname_('*.iwg1.*.txt','aaf_iwg1');
end
[iwg.pname,iwg.fname,ext] = fileparts(ins);
iwg.pname = [iwg.pname, filesep]; iwg.fname = [iwg.fname, ext];

matdir = [iwg.pname,'..',filesep,'mats',filesep];
if ~exist(matdir,'dir')
    mkdir(matdir);
    matdir = [matdir, filesep];
end

iwg_mat = [matdir, iwg.fname(1:10), 'iwg.mat'];
iwg_grid_mat = [matdir, iwg.fname(1:10), 'iwg_grid.mat'];
if exist(iwg_mat,'file')&&exist(iwg_grid_mat,'file')
    iwg = load(iwg_mat);
    iwg_grid = load(iwg_grid_mat);
else
    % IWG1,Date_Time,Lat,Lon,GPS_MSL_Alt,WGS_84_Alt,Press_Alt,Radar_Alt,Grnd_Spd,True_Airspeed,Indicated_Airspeed,Mach_Number,Vert_Velocity,True_Hdg,Track,Drift,Pitch,Roll,Side_slip,Angle_of_Attack,Ambient_Temp,Dew_Point,Total_Temp,Static_Press,Dynamic_Press,Cabin_Pressure,Wind_speed,Wind_Dir,Vert_Wind_Spd,Solar_Zenith,Sun_Elev_AC,Sun_Az_Grd,Sun_Az_AC,Flag_qc,Flag_ac,Flag_cloud,RH_water,RH_ice,Theta,Cabin_Temperature,Leg_num
    % IWG1,YYYY-MM-DD hh:mm:ss,degree_N,degree_E,m,m,ft,ft,ms-1,ms-1,ktnots,dimensionless,ms-1,degrees_true,degrees_true,degrees,degrees,degrees,degrees,degrees,degrees_C,degrees_C,degrees_C,mbar,mbar,mbar,ms-1,degrees_true,ms-1,degrees, degrees,degrees_true,degrees_true,int,int,int,percent,percent,degrees_C,degrees_C,int
    %
    % IWG1,2015-05-21 17:07:20,45.25167,-118.17433,3452,3435,11030,7319,115.87,110.82,114,0.34,0.6,332.5,328,-4,1.62,-2.74,-0.60,-1.70,-2.7,-1.9,3.2,669,53,1000,4.5,135,0.13,48,45,113,358,11776,0,-9999,106,108,30.2,5.8,1
    
    % One header row identifying column names
    % One header row identifying units or format
    % One blank line
    % column separated fields.
    
% IWG1,Date_Time,Lat,Lon,GPS_MSL_Alt,WGS_84_Alt,Press_Alt,Radar_Alt,Grnd_Spd,True_Airspeed,Indicated_Airspeed,Mach_Number,Vert_Velocity,True_Hdg,Track,Drift,Pitch,Roll,Side_slip,Angle_of_Attack,Ambient_Temp,Dew_Point,Total_Temp,Static_Press,Dynamic_Press,Cabin_Pressure,Wind_speed,Wind_Dir,Vert_Wind_Spd,Solar_Zenith,Sun_Elev_AC,Sun_Az_Grd,Sun_Az_AC,Flag_qc,Flag_ac,Flag_cloud,RH_water,RH_ice,Theta,Cabin_Temperature,Leg_num
% IWG1,YYYY-MM-DD hh:mm:ss,degree_N,degree_E,m,m,ft,ft,ms-1,ms-1,ktnots,dimensionless,ms-1,degrees_true,degrees_true,degrees,degrees,degrees,degrees,degrees,degrees_C,degrees_C,degrees_C,mbar,mbar,mbar,ms-1,degrees_true,ms-1,degrees, degrees,degrees_true,degrees_true,int,int,int,percent,percent,degrees_C,degrees_C,int
% 
% IWG1,2015-07-16 19:58:43,70.19333,-148.48000,25,23,135,82,0.03,45.50,46,0.14,-0.0,178.4,75,-9999,2.88,0.54,0.10,4.90,5.8,4.5,6.9,1008,13,1008,8.6,66,-9999.00,38,33,143,322,11776,3,0,91,86,5.2,12.4,-9999

    
    fid = fopen(ins);
    if fid>0
        
        this = fgetl(fid);
        if ~isempty(strfind(this,'IWG1'))&&~isempty(strfind(this,'Date_Time'))
            header_row = textscan(this, '%s','delimiter',',');
            header_row = header_row{:};
            cols = length(header_row);
        end
        % skip records until we find a row that doesn't contain the IWG1 string (and is basically blank)
        units = textscan(fgetl(fid),'%s','delimiter',','); units = units{:};
        while ~isempty(strfind(fgetl(fid),'IWG1'))&&~feof(fid)
        end
        done_reading = false;
        fmt_str = ['%s %s ',repmat('%f ',[1,cols-2])];
        while ~done_reading
            % This should read the entire file
            [A, pos] = textscan(fid,[fmt_str,' %*[^\n] %*[\n]'], 'delimiter',',');
            fclose(fid);
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
        TS = A{2};TS_str = units{2};
        iwg.time = datenum(TS,'yyyy-mm-dd HH:MM:SS');
        % Handle day roll-over
        while any(diff(iwg.time)<0)
            mark = find(diff(iwg.time)<0);
            iwg.time(mark+1:end) = iwg.time(mark+1:end) +1;
        end
        [iwg.time, ij] = unique(iwg.time);
        
        for aa = 1:length(A)
            A(aa) = {A{aa}(ij)};
        end
        
        for N = 3:cols
            iwg.(legalize_fieldname(header_row{N})) = A{N};
        end
        
        
        %    % We'll want to cycle through these fields to clean up bad records when found
        %    dmp = fieldnames(iwg);
        % %    dmp = {'time','N_secs','status','Ba_B','Ba_G','Ba_R','Tr_B','Tr_G','Tr_R','endstr','mass_flow_last','mass_flow_mv'};
        %    for N = header_row:-1:3
        %       if length(TS{N})~=11 % If the timestring is malformed then delete the entire record
        %          TS(N) = [];
        %          for d = 1:length(dmp)
        %             iwg.(char(dmp{d}))(N) = [];
        %          end
        % %          iwg.time(N) = []; iwg.N_secs(N) = [];iwg.status(N) = [];
        % %          iwg.Ba_B(N) = [];iwg.Ba_G(N) = [];iwg.Ba_R(N) = [];
        % %          iwg.Tr_B(N) = []; iwg.Tr_G(N) = [];iwg.Tr_R(N) = [];
        % %          iwg.endstr(N) = []; iwg.mass_flow_last(N)= [];iwg.mass_flow_mv(N) = [];
        %       end
        %    end
        
        % [utime,ii] = unique(iwg.time);
        % dup = setxor([1:length(iwg.time)],ii);
        % iwg.time_new = iwg.time;
        % iwg.time_new(dup) = iwg.time_new(dup-1)+1./(24*60*60);
        %
        % figure; plot(serial2doys(iwg.time), iwg.Bs_B, '-b.',serial2doys(iwg.time_new(dup)), iwg.Bs_B(dup), 'ro');
        
        iwg_grid.time = [iwg.time(1):(1./(24*60*60)):iwg.time(end)]';
        [ainb, bina] = nearest(iwg.time,iwg_grid.time);
        fields = fieldnames(iwg);
        for f = 1:length(fields)
            field = fields{f};
            if ~strcmp(field,'time')&&~strcmp(field,'pname')&&~strcmp(field,'fname')
                iwg_grid.(field) = NaN(size(iwg_grid.time));
                iwg_grid.(field)(bina) = iwg.(field)(ainb);
            end
        end
        
        save([matdir, iwg.fname(1:10), 'iwg.mat'],'-struct','iwg');
        save([matdir, iwg.fname(1:10), 'iwg_grid.mat'],'-struct','iwg_grid');
    else
        iwg_grid = [];
        iwg = [];
    end
end

return
