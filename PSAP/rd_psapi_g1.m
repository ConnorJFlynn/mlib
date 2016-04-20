function [psapo_grid,psapo,psapi] = rd_psapi_g1(ins, spot_area, flow_cal)
% [psapo_grid,psapo,psapi] = rd_psapi_g1(ins);
% Parses a PSAP file from the G1 containing "I" packets
% Computes full-precision transmittances from the hex packets and raw
% absorption coefficients according to an assumed spot size of 17.5 mm^2
% and using the PSAP reported flows
% returns "psapo_grid", "psapo" containing the computed values at 4-sec intervals and
% also the contents of the input file as "psapi"
% this code also applies a calibration of the flow meter as
%   flow_reg = b0 + b1.*psap_flow_lpm;
%   b0=0.0918849066; b1=1.0544449255;
if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname_('*psap_raw.txt','aaf_psap');
end
if ~exist('spot_area','var')
    spot_area = 17.5; % default PSAP spot area in mm^2
end
if ~exist('flow_cal','var')||(length(flow_cal)~=2)
    b0=0.0918849066; b1=1.0544449255;
else
    b0=flow_cal(1); b1=flow_cal(2);
end
    

[psapi.pname,psapi.fname,ext] = fileparts(ins);
psapi.pname = [psapi.pname, filesep]; psapi.fname = [psapi.fname, ext];
matdir = [psapi.pname, '..',filesep,'mats',filesep];
if ~exist(matdir,'dir')
    mkdir(matdir);
    matdir = [matdir, filesep];
end
psapi_mat = [matdir, psapi.fname(1:10), 'psapi.mat'];
psapo_mat = [matdir, psapi.fname(1:10), 'psapo.mat'];
psapo_grid_mat = [matdir, psapi.fname(1:10), 'psapo_grid.mat'];

if exist(psapi_mat,'file')&&exist(psapo_mat,'file')&&exist(psapo_grid_mat,'file')
    disp('Loading mat files.')
    psapi = load([matdir, psapi.fname(1:10), 'psapi.mat']);
    psapo = load([matdir, filesep, psapi.fname(1:10), 'psapo.mat']);
    psapo_grid = load([matdir, filesep, psapi.fname(1:10), 'psapo_grid.mat']);
    
else
    disp('Loading and processing raw files.')
    
    
    
    % Much of the code below was written in anticipation of selection of multiple
    % files but not completely implemented.  Currently just processes one file.
    fid = fopen(ins);
    if fid>0
%         [psapi.pname,psapi.fname,ext] = fileparts(ins);
%         psapi.pname = [psapi.pname, filesep]; psapi.fname = [psapi.fname, ext];
        psapo_grid = psapi; psapo = psapi;
        
        % 22:12:12.53,150604130603   -2.9   -2.3   -6.4 1.000 1.000 1.000  .000  .100   2 0092 "03,007dbea296,00773aa880,02e310,00"
        this = fgetl(fid);
        % skip records until " is found for the end string eg "03,007dbea296,00773aa880,02e310,00"
        while isempty(strfind(this,'"'))&&~feof(fid)
            %%
            b4 = ftell(fid); % "before"
            this = fgetl(fid);
            %%
        end
        fseek(fid,b4,-1);  % rewind to the point "before" the line read above
        done_reading = false;
        while ~done_reading
            % This should read the entire file
            [A, pos] = textscan(fid,'%s %f %f %f %f %f %f %f %f %d %d %s %*[^\n] %*[\n]');
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
        TS = A{1};DS = datenum(psapi.fname(1:8),'yyyymmdd');
        psapi.time = datenum(TS,'HH:MM:SS.FFF')-datenum('00:00:00','HH:MM:SS') + DS;
        % Handle day roll-over
        while any(diff(psapi.time)<0)
            mark = find(diff(psapi.time)<0);
            psapi.time(mark+1:end) = psapi.time(mark+1:end) +1;
        end
        psapi.Ba_B = A{2}; psapi.Ba_G = A{3}; psapi.Ba_R = A{4};
        psapi.Tr_B = A{5}; psapi.Tr_G = A{6}; psapi.Tr_R = A{7};
        psapi.mass_flow_last= A{8}; psapi.mass_flow_mv = A{9};
        % flow_reg = b0 + b1.*psap_flow_lpm;
        b0=0.0918849066; b1=1.0544449255;
    
        psapi.N_secs = A{10}; psapi.status = A{11};
        psapi.endstr = A{12};
        psapi.endstr = strrep(psapi.endstr,'"','');
        % We'll want to cycle through these fields to clean up bad records when found
        dmp = {'time','N_secs','status','Ba_B','Ba_G','Ba_R','Tr_B','Tr_G','Tr_R','endstr','mass_flow_last','mass_flow_mv'};
        for N = length(psapi.time):-1:2
            if strcmp(psapi.endstr{N},psapi.endstr{N-1})||length(TS{N})~=24
                TS(N) = [];
                for d = dmp
                    psapi.(char(d))(N) = [];
                end
                %          psapi.time(N) = []; psapi.N_secs(N) = [];psapi.status(N) = [];
                %          psapi.Ba_B(N) = [];psapi.Ba_G(N) = [];psapi.Ba_R(N) = [];
                %          psapi.Tr_B(N) = []; psapi.Tr_G(N) = [];psapi.Tr_R(N) = [];
                %          psapi.endstr(N) = []; psapi.mass_flow_last(N)= [];psapi.mass_flow_mv(N) = [];
            end
        end
        for N = length(psapi.time):-1:1
            TSstr = TS{N};
            psapi.psap_timestr(N,:) = TSstr(13:end);
            endstr = psapi.endstr{N};
            blah = textscan(endstr,'%2d,%s');
            psapi.SS(N) = blah{1};
            psapi.ender(N) = blah{2};
        end
        psapi.SS = psapi.SS'; psapi.ender = psapi.ender';
        %    N = 1;
        %    TSstr = TS{N};
        %    psapi.psap_timestr(N,:) = TSstr(13:end);
        %    endstr = psapi.endstr{N};
        %    blah = textscan(endstr,'%2d,%s');
        %    psapi.SS(N) = blah{1};
        %    psapi.ender(N) = blah{2};
        
        psapi.psap_time = datenum(psapi.psap_timestr,'yymmddHHMMSS');
        M300_diff = [1;24*60*60*diff(psapi.time)]-1;
        bad_M300_times = M300_diff<=-.01 | abs(M300_diff)>.1;
        %    good_PSAP_times = [1; diff(PSAP_time')>0 & diff(PSAP_time')<0.1];
        %    bad_M300_times = bad_M300_times & good_PSAP_times;
        if any(bad_M300_times)
            psapi.time(bad_M300_times) = interp1(psapi.psap_time(~bad_M300_times), psapi.time(~bad_M300_times),psapi.psap_time(bad_M300_times),'linear');
        end
        % parse mod4 ==0
        mod0 = find(mod(psapi.SS,4)==0&psapi.SS~=0);
        current_boxcar_index = NaN(size(psapi.time));
        boxcar_flow = current_boxcar_index;
        % The following statements are just pre-declaring variables...
        boxcar_secs = boxcar_flow;
        dark_sig = boxcar_flow;
        dark_ref = boxcar_flow;
        adc_gain = boxcar_flow;
        N_boxcars = boxcar_flow;
        over_ranges = boxcar_flow;
        blue_sig_boxcar = boxcar_flow;
        blue_sig = boxcar_flow;
        blue_ref_boxcar = boxcar_flow;
        blue_ref = boxcar_flow;
        green_sig_boxcar = boxcar_flow;
        green_sig = boxcar_flow;
        green_ref_boxcar = boxcar_flow;
        green_ref = boxcar_flow;
        red_sig_boxcar = boxcar_flow;
        red_sig = boxcar_flow;
        red_ref_boxcar = boxcar_flow;
        red_ref = boxcar_flow;
        reset_last = boxcar_flow;
        reset_2nd = reset_last;
        blue_sig_ref_ratio = boxcar_flow;
        green_sig_ref_ratio = boxcar_flow;
        red_sig_ref_ratio = boxcar_flow;
        
        % Previous filter reset times...
        for m = 1:length(mod0)
            %       disp(m)
            ender = psapi.ender{mod0(m)};
            %  'fa,00572bea,0bfa,fffffa,ffffff,02'
            B = textscan(ender,'%s %s %s %s %s %s %[^\n]','delimiter',',');
            current_boxcar_index(mod0(m)) = hex2nm(B{1});
            boxcar_flow(mod0(m))= hex2nm(B{2}); boxcar_secs(mod0(m))= hex2nm(B{3});
            dark_sig(mod0(m))= hex2nm(B{4}); dark_ref(mod0(m))= hex2nm(B{5}); adc_gain(mod0(m))= hex2nm(B{6});
            if psapi.SS(mod0(m))==4
                reset_last(mod0(m)) = datenum(B{7},'yymmddHHMMSS');
            elseif psapi.SS(mod0(m))==8
                reset_2nd(mod0(m)) = datenum(B{7},'yymmddHHMMSS');
            elseif psapi.SS(mod0(m))==12
                reset_3rd(mod0(m)) = datenum(B{7},'yymmddHHMMSS');
            end
        end
        
        % Blue signals...
        mod1 =  find(mod(psapi.SS,4)==1);
        for m = 1:length(mod1)
            ender = psapi.ender{mod1(m)};
            %  'fa,00572bea,0bfa,fffffa,ffffff,02'
            B = textscan(ender,'%s %s %s %s %[^\n]','delimiter',',');
            blue_sig_boxcar(mod1(m)) = hex2nm(B{1});blue_ref_boxcar(mod1(m)) = hex2nm(B{2});
            N_boxcars(mod1(m))= hex2nm(B{3}); over_ranges(mod1(m))= hex2nm(B{4});
            if psapi.SS(mod1(m))==5
                sr = B{5};
                blue_sig_ref_ratio(mod1(m)) = sscanf(sr{1},'%f');
            end
        end
        % Compute signal at full precision from hex strings
        blue_sig(mod1(2:end)) = blue_sig_boxcar(mod1(2:end))-blue_sig_boxcar(mod1(1:end-1)) - 256.*(N_boxcars(mod1(2:end))-N_boxcars(mod1(1:end-1)));
        blue_ref(mod1(2:end)) = blue_ref_boxcar(mod1(2:end))-blue_ref_boxcar(mod1(1:end-1)) - 256.*(N_boxcars(mod1(2:end))-N_boxcars(mod1(1:end-1)));
        roll = false(size(N_boxcars));
        roll(mod1(2:end)) = (N_boxcars(mod1(2:end))-N_boxcars(mod1(1:end-1)))<0;
        blue_sig(roll) = blue_sig(roll) - 2.^32;
        blue_ref(roll) = blue_ref(roll) - 2.^32;
        
        % Green signals...
        mod2 =  find(mod(psapi.SS,4)==2);
        for m = 1:length(mod2)
            ender = psapi.ender{mod2(m)};
            %  'fa,00572bea,0bfa,fffffa,ffffff,02'
            B = textscan(ender,'%s %s %s %s %[^\n]','delimiter',',');
            green_sig_boxcar(mod2(m)) =  hex2nm(B{1});green_ref_boxcar(mod2(m)) =  hex2nm(B{2});
            N_boxcars(mod2(m))= hex2nm(B{3}); over_ranges(mod2(m))= hex2nm(B{4});
            if psapi.SS(mod2(m))==6
                sr = B{5};
                green_sig_ref_ratio(mod2(m)) = sscanf(sr{1},'%f');
            end
        end
        roll = false(size(N_boxcars));
        roll(mod2(2:end)) = (N_boxcars(mod2(2:end))-N_boxcars(mod2(1:end-1)))<0;
        % Compute signal at full precision from hex strings
        green_sig(mod2(2:end)) = green_sig_boxcar(mod2(2:end))-green_sig_boxcar(mod2(1:end-1)) - 256.*(N_boxcars(mod2(2:end))-N_boxcars(mod2(1:end-1)));
        green_ref(mod2(2:end)) = green_ref_boxcar(mod2(2:end))-green_ref_boxcar(mod2(1:end-1)) - 256.*(N_boxcars(mod2(2:end))-N_boxcars(mod2(1:end-1)));
        green_sig(roll) = green_sig(roll) - 2.^32;
        green_ref(roll) = green_ref(roll) - 2.^32;
        
        % Red signals...
        mod3 =  find(mod(psapi.SS,4)==3);
        for m = 1:length(mod3)
            ender = psapi.ender{mod3(m)};
            %  'fa,00572bea,0bfa,fffffa,ffffff,02'
            B = textscan(ender,'%s %s %s %s %[^\n]','delimiter',',');
            red_sig_boxcar(mod3(m)) = hex2nm(B{1}); red_ref_boxcar(mod3(m)) = hex2nm(B{2});
            N_boxcars(mod3(m))= hex2nm(B{3}); over_ranges(mod3(m))= hex2nm(B{4});
            if psapi.SS(mod3(m))==7
                sr = B{5};
                red_sig_ref_ratio(mod3(m)) = sscanf(sr{1},'%f');
            end
            
        end
        % Compute signal at full precision from hex strings
        red_sig(mod3(2:end)) = red_sig_boxcar(mod3(2:end))-red_sig_boxcar(mod3(1:end-1)) - 256.*(N_boxcars(mod3(2:end))-N_boxcars(mod3(1:end-1)));
        red_ref(mod3(2:end)) = red_ref_boxcar(mod3(2:end))-red_ref_boxcar(mod3(1:end-1)) - 256.*(N_boxcars(mod3(2:end))-N_boxcars(mod3(1:end-1)));
        
        % Catch boxcar rollover
        roll = false(size(N_boxcars));
        roll(mod3(2:end)) = (N_boxcars(mod3(2:end))-N_boxcars(mod3(1:end-1)))<0;
        red_sig(roll) = red_sig(roll) - 2.^32;
        red_ref(roll) = red_ref(roll) - 2.^32;
        
    end
    
    % Okay, done reading the file.
    % %    disp('Eliminating darks, blue, green, and red refs and sigs <= 0')
    % bad = dark_sig<0 | dark_ref<0 | N_boxcars<=0 | blue_sig<=0 | green_sig<=0 | red_sig<=0 ...
    %    | blue_ref<=0 | green_ref<=0 | red_ref<=0;
    %          TS(bad) = [];
    %          for d = dmp
    % %             psapi.(char(d))(bad) = []; % this may be a bug.  Not sure dmp is defined correctly
    %          end
    
    
    % All screening is done. Now keep only records that make a complete set
    % with darks, R, G, B
    dark_ii = find(~isNaN(dark_sig)); dark_ii(dark_ii>(length(psapi.time)-3)) = [];
    good = mod(psapi.SS(dark_ii+1),4)==1 &mod(psapi.SS(dark_ii+2),4)==2 &mod(psapi.SS(dark_ii+3),4)==3;
    dark_ii = dark_ii(good);
    blue_ii = dark_ii+1; blue_ii(blue_ii>length(psapi.time)) = [];
    green_ii = dark_ii+2; green_ii(green_ii>length(psapi.time)) = [];
    red_ii = dark_ii+3; red_ii(red_ii>length(psapi.time)) = [];
    
    % Build an output file with one record per complete input set
    psapo.time = psapi.time(dark_ii);
    psapo.Ba_B = psapi.Ba_B(blue_ii); psapo.Ba_G = psapi.Ba_G(green_ii); psapo.Ba_R = psapi.Ba_R(red_ii);
    
    % Front panel transmittances only good to 3 decimals, insufficient for
    % Ba coef calculation.
    psapo.Tr_B = psapi.Tr_B(blue_ii); psapo.Tr_G = psapi.Tr_G(green_ii); psapo.Tr_R = psapi.Tr_R(red_ii);
    psapo.mass_flow_last = psapi.mass_flow_last(dark_ii);
    psapo.current_boxcar_index = current_boxcar_index(dark_ii);
    psapo.boxcar_flow = current_boxcar_index(dark_ii);
    psapo.boxcar_secs = boxcar_secs(dark_ii);
    psapo.dark_sig = dark_sig(dark_ii);
    psapo.dark_ref = dark_ref(dark_ii);
    psapo.adc_gain = adc_gain(dark_ii);
    
    psapo.blue_sig = blue_sig(blue_ii);
    psapo.blue_ref = blue_ref(blue_ii);
    psapo.green_sig = green_sig(green_ii);
    psapo.green_ref = green_ref(green_ii);
    psapo.red_sig = red_sig(red_ii);
    psapo.red_ref = red_ref(red_ii);
    
    psapo.blue_sig_boxcar = blue_sig_boxcar(blue_ii);
    psapo.blue_ref_boxcar = blue_ref_boxcar(blue_ii);
    psapo.green_sig_boxcar = green_sig_boxcar(green_ii);
    psapo.green_ref_boxcar = green_ref_boxcar(green_ii);
    psapo.red_sig_boxcar = red_sig_boxcar(red_ii);
    psapo.red_ref_boxcar = red_ref_boxcar(red_ii);
    psapo.N_boxcars = N_boxcars(blue_ii);
    
    psapo.blue_sig_ref_ratio = blue_sig_ref_ratio(blue_ii);
    psapo.green_sig_ref_ratio = green_sig_ref_ratio(green_ii);
    psapo.red_sig_ref_ratio = red_sig_ref_ratio(red_ii);
    
    blueNaN =isNaN(psapo.blue_sig_ref_ratio);
    psapo.blue_sig_ref_ratio(blueNaN) = interp1(find(~blueNaN),psapo.blue_sig_ref_ratio(~blueNaN), find(blueNaN),'nearest','extrap');
    grnNaN =isNaN(psapo.green_sig_ref_ratio);
    psapo.green_sig_ref_ratio(grnNaN) = interp1(find(~grnNaN),psapo.green_sig_ref_ratio(~grnNaN), find(grnNaN),'nearest','extrap');
    redNaN =isNaN(psapo.red_sig_ref_ratio);
    psapo.red_sig_ref_ratio(redNaN) = interp1(find(~redNaN),psapo.red_sig_ref_ratio(~redNaN), find(redNaN),'nearest','extrap');
    psapo.endstr = psapi.endstr(dark_ii);
    % figure; plot(psapo.time, (psapo.blue_sig./psapo.blue_ref)./psapo.blue_sig_ref_ratio, 'b.', psapo.time, psapo.Tr_B,'k.');
    % figure; plot(psapo.time, (psapo.green_sig./psapo.green_ref)./psapo.green_sig_ref_ratio, 'g.', psapo.time, psapo.Tr_G,'k.');
    % figure; plot(psapo.time, (psapo.red_sig./psapo.red_ref)./psapo.red_sig_ref_ratio, 'r.', psapo.time, psapo.Tr_R,'k.');
    % some spurious values
    % green_sig = psapo.green_sig_boxcar(2:end)-psapo.green_sig_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
    % green_ref = psapo.green_ref_boxcar(2:end)-psapo.green_ref_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
    % figure; plot(psapo.time(2:end), (psapo.green_sig(2:end)./psapo.green_ref(2:end))./psapo.green_sig_ref_ratio(2:end)-(green_sig./green_ref)./psapo.green_sig_ref_ratio(2:end), 'r.');
    
    % green_sig = psapo.green_sig_boxcar(2:end)-psapo.green_sig_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
    % green_ref = psapo.green_ref_boxcar(2:end)-psapo.green_ref_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
    % figure; plot(psapo.time, (psapo.green_sig./psapo.green_ref)./psapo.green_sig_ref_ratio, 'g.', psapo.time, psapo.Tr_G,'k.',...
    %    psapo.time(2:end), (green_sig./green_ref)./psapo.green_sig_ref_ratio(2:end), 'r.');
    
    % Compute transmittances at full precision, and normalize by last PSAP reported signal ratio
    psapo.trans_B = (psapo.blue_sig./psapo.blue_ref)./psapo.blue_sig_ref_ratio;
    psapo.trans_G = (psapo.green_sig./psapo.green_ref)./psapo.green_sig_ref_ratio;
    psapo.trans_R = (psapo.red_sig./psapo.red_ref)./psapo.red_sig_ref_ratio;
    % green_sig = psapo.green_sig_boxcar(2:end)-psapo.green_sig_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
    % green_ref = psapo.green_ref_boxcar(2:end)-psapo.green_ref_boxcar(1:end-1) - 256.*(psapo.N_boxcars(2:end)-psapo.N_boxcars(1:end-1));
    % figure; plot(psapo.time, (psapo.green_sig./psapo.green_ref)./psapo.green_sig_ref_ratio, 'g.', psapo.time, psapo.Tr_G,'k.',...
    %    psapo.time(2:end), (green_sig./green_ref)./psapo.green_sig_ref_ratio(2:end), 'r.');
    % figure; plot(psapo.time, [psapo.trans_B,psapo.trans_G,psapo.trans_R],'.')
    
    % Now test Tr smoothing and compare to 2-s and 60-s averaged result.
    % Gridding was implemented to avoid crazy smoothed transmittances at edges.
    % Not necessary if time series is contiguous
    dark_times = psapo.time;
    psapo_grid.time = [psapo.time(1):[4./(24*60*60)]:psapo.time(end)]';
    [ainb, bina] = nearest(psapo.time,psapo_grid.time);
    fields = fieldnames(psapo);
    for f = 1:length(fields)
        field = fields{f};
        if ~(strcmp(field,'time')||strcmp(field,'endstr')||strcmp(field,'pname')||strcmp(field,'fname'))
            psapo_grid.(field) = NaN(size(psapo_grid.time));
            psapo_grid.(field)(bina) = psapo.(field)(ainb);
        end
    end
    psapo_grid.endstr = cell(size(psapo_grid.time));
    psapo_grid.endstr(bina) = psapo.endstr(ainb);
    
    %   flow_reg = b0 + b1.*psap_flow_lpm;
%     b0=0.0918849066; b1=1.0544449255;
    psapo.mass_flow_last = b0 + b1.*psapo.mass_flow_last;    

    [psapo.Ba_B_sm, psapo.trans_B_sm] = smooth_Tr_Bab(psapo.time, psapo.mass_flow_last, psapo.trans_B,8,spot_area );
    [psapo_grid.Ba_B_sm, psapo_grid.trans_B_sm] = smooth_Tr_Bab(psapo_grid.time, psapo_grid.mass_flow_last, psapo_grid.trans_B,8,spot_area );
    
    [psapo.Ba_G_sm, psapo.trans_G_sm] = smooth_Tr_Bab(psapo.time, psapo.mass_flow_last, psapo.trans_G,8,spot_area );
    [psapo_grid.Ba_G_sm, psapo_grid.trans_G_sm] = smooth_Tr_Bab(psapo_grid.time, psapo_grid.mass_flow_last, psapo_grid.trans_G,8,spot_area );
    
    [psapo.Ba_R_sm, psapo.trans_R_sm] = smooth_Tr_Bab(psapo.time, psapo.mass_flow_last, psapo.trans_R,8,spot_area );
    [psapo_grid.Ba_R_sm, psapo_grid.trans_R_sm] = smooth_Tr_Bab(psapo_grid.time, psapo_grid.mass_flow_last, psapo_grid.trans_R,8,spot_area );
    
    % Transpose to force orientation matching time vector.
    psapo.Ba_B_sm = psapo.Ba_B_sm'; psapo.Ba_G_sm = psapo.Ba_G_sm'; psapo.Ba_R_sm = psapo.Ba_R_sm';
    psapo.trans_B_sm = psapo.trans_B_sm'; psapo.trans_G_sm = psapo.trans_G_sm'; psapo.trans_R_sm= psapo.trans_R_sm';
    
    psapo_grid.Ba_B_sm = psapo_grid.Ba_B_sm'; psapo_grid.Ba_G_sm = psapo_grid.Ba_G_sm';
    psapo_grid.Ba_R_sm = psapo_grid.Ba_R_sm'; psapo_grid.trans_B_sm = psapo_grid.trans_B_sm';
    psapo_grid.trans_G_sm = psapo_grid.trans_G_sm'; psapo_grid.trans_R_sm= psapo_grid.trans_R_sm';

    k1=1.317; ko=0.866;
    psapo_grid.Ba_B_sm_Weiss = psapo_grid.Ba_B_sm./(k1.*psapo_grid.trans_B_sm + ko);
    psapo_grid.Ba_G_sm_Weiss = psapo_grid.Ba_G_sm./(k1.*psapo_grid.trans_G_sm + ko);
    psapo_grid.Ba_R_sm_Weiss = psapo_grid.Ba_R_sm./(k1.*psapo_grid.trans_R_sm + ko);
    
    % figure; plot(psapo.time, [psapo.trans_B,psapo.trans_G,psapo.trans_R],'.',...
    %    psapo.time, [psapo.trans_B_sm,psapo.trans_G_sm,psapo.trans_R_sm],'-');dynamicDateTicks
    % legend('Tr_B raw','Tr B raw','Tr R raw','Tr B smooth', 'Tr G smooth', 'Tr R smooth');
    
    % figure;
    % plot(psapo_grid.time, [psapo_grid.trans_B,psapo_grid.trans_G,psapo_grid.trans_R],'.',...
    %    psapo_grid.time, [psapo_grid.trans_B_sm,psapo_grid.trans_G_sm,psapo_grid.trans_R_sm],'-');dynamicDateTicks
    % legend('Tr_B raw','Tr B raw','Tr R raw','Tr B smooth', 'Tr G smooth', 'Tr R smooth');
    
    % ax(3) = gca;
    % % These are absorption coefs when smoothed to 4x8=32s in transmittance space via smooth_Tr_Bab
    % figure; plot(psapo_grid.time, [psapo_grid.Ba_B_sm_Weiss,psapo_grid.Ba_G_sm_Weiss, psapo_grid.Ba_R_sm_Weiss],'-');
    % % plot(psapo_grid.time, [psapo_grid.Ba_B_sm,psapo_grid.Ba_G_sm, psapo_grid.Ba_R_sm],'-');
    % ax(1) = gca;
    % hold('on');
    % % These are the original 2-second absorption coefficients reported by the
    % % PSAP but smoothed to 2x15=30s in absorbance
    % plot(psapi.time + (15./(24*60*60)), [smooth(psapi.Ba_B,60),smooth(psapi.Ba_G,60), smooth(psapi.Ba_R,60)],'o'); hold('off');
    % % plot(psapo_grid.time, [smooth(psapo_grid.Ba_B,15),smooth(psapo_grid.Ba_G,15), smooth(psapo_grid.Ba_R,15)],'.');hold('off')
    % legend('Ba B 32s in T','Ba G 32s in T', 'Ba R 32s in T', 'Ba B 60s in Ba','Ba G 60s in Ba', 'Ba R 60s in Ba');
    % title(['Absorption coeffs ',strtok(psapi.fname,'.')]);
    % dynamicDateTicks;
    %
    % figure; plot(psapo.time, psapo.mass_flow_last, '-x');ax(2) = gca;  dynamicDateTicks;
    % % plot(psapo_grid.time, psapo_grid.mass_flow_last, '-x');ax(2) = gca;  dynamicDateTicks;
    % legend('mass flow'); title(['Mass flow ',strtok(psapi.fname,'.')]);
    
    % figure; plot((psapo.time), [psapo.blue_ref, psapo.green_ref,psapo.red_ref] ,'.-'); dynamicDateTicks; ax(4) = gca;
    % legend('blue ref','green ref','red ref')
    %
    % figure; plot((psapo.time), [psapo.blue_sig, psapo.green_sig,psapo.red_sig] ,'-'); dynamicDateTicks; ax(5) = gca;
    % legend('blue sig','green sig','red sig')
    % linkaxes(ax,'x');
    
    save([matdir, psapi.fname(1:10), 'psapi.mat'],'-struct','psapi');
    save([matdir, psapi.fname(1:10), 'psapo.mat'],'-struct','psapo');
    save([matdir, psapi.fname(1:10), 'psapo_grid.mat'],'-struct','psapo_grid');
end

return