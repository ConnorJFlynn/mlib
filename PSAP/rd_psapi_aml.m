function [psapo,psapi] = rd_psapi_aml(ins, spot_area, flow_cal)
% [psapro,psapri] = rd_psapr_aml(ins);
% Parses a PSAP file from the AML test  containing "I" or "O" packets
% This is a bit tricky since commas are used to delimit, status is a
% string, and we want the quoted string provided by the PSAP.
% To resolve this I used two reads; one to parse the initial
% comma-separated block and another for the the double-quoted original string

% The processing of the "I" and "O" packets is a bit complicated with the
% PSAP 4-second measurement sequence so MOD statements are used to identify
% the packets for B, G, R, and dark, as well as the normalization history

if ~exist('ins','var') || ~exist(ins,'file')
    ins = getfullname('psap_.csv','psap_pnl');
end
if ~exist('spot_area','var')
    spot_area = 17.81; % default PSAP spot area in mm^2
end

    b0 = 0; b1 = 1;
[psapi.pname,psapi.fname,ext] = fileparts(ins);
psapi.pname = [psapi.pname, filesep]; psapi.fname = [psapi.fname, ext];
    disp('Loading and processing raw files.')
       % yyyy,mm,dd,HH,MM,SS.fff,doy.fff, secs,B_r, B_g, B_b, Tr_r, Tr_g, Tr_b, flow_lpm, flow_mv,Avg_time, status_flag, string,"09,8722c07707,811393009f,453d50,5b,0.770"
    % 2016,09,02,20,11,15.81,246.841146,160902201109,.0,1.8,3.2,1.000,1.000,1.000,1.009,1807,2,0083,"09,8722c07707,811393009f,453d50,5b,0.770"
    % Much of the code below was written in anticipation of selection of multiple
    % files but not completely implemented.  Currently just processes one file.
    fid = fopen(ins);
    if fid>0
        [A] = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %*[^\n] %*[\n]','delimiter',',');
        status_flag = hex2dec(A{18});
         fseek(fid,0,-1);
          [AA] = textscan(fid,'%s %s','delimiter','"'); 
          BB= AA{2};
          fclose(fid);
          if length(A{1})==length(BB)
              V = [A{1},A{2},A{3},A{4},A{5},A{6}];
              data_block(:,1) = datenum(V);
              for col = 2:12
                  data_block(:,col)= A{col+5};
              end
              data_block(:,13) = status_flag;
              rows = length(BB);
          end
          for N = rows:-1:1
              blah = textscan(BB{N},'%2d,%s'); % parse the leading seconds from the serial string into the dataLblock
              data_block(N,14) = blah{1};
              str = blah{2}; str = str{1};
              endstr{N} = str; 
          end
    end
% If identical endstr for successive elements then the M300 DAQ is stuck or
% something so delete duplicates
        for N = rows:-1:2
            if strcmp(endstr{N},endstr{N-1})
                endstr{N} = [];
                data_block(N,:) = [];
            end
        end
        % Handle day roll-over
        in_time = data_block(:,1);
        while any(diff(in_time)<-.5)
            mark = find(diff(in_time)<-.5, 1,'first');
            in_time(mark+1:end) = in_time(mark+1:end) +1;
        end
        psapi.time = in_time;
        dmp = {'doy','N_secs','Ba_B','Ba_G','Ba_R','Tr_B','Tr_G','Tr_R','mass_flow_last','mass_flow_mv','N_avg','status','SS'};
        for d = 1:length(dmp)
            psapi.(dmp{d}) = data_block(:,d+1);
        end
        psapi.ender = endstr';
        
%         psapi.psap_time = datenum(psapi.psap_timestr,'yymmddHHMMSS');
%         M300_diff = [1;24*60*60*diff(psapi.time)]-1;
%         bad_M300_times = M300_diff<=-.01 | abs(M300_diff)>.1;
%         %    good_PSAP_times = [1; diff(PSAP_time')>0 & diff(PSAP_time')<0.1];
%         %    bad_M300_times = bad_M300_times & good_PSAP_times;
%         if any(bad_M300_times)
%             psapi.time(bad_M300_times) = interp1(psapi.psap_time(~bad_M300_times), psapi.time(~bad_M300_times),psapi.psap_time(bad_M300_times),'linear');
%         end

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

       % parse mod4 ==0  This if for darks and for history
        mod0 = find(mod(psapi.SS,4)==0&psapi.SS~=0);
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
        
%     end
    
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
    bad_status = bitand(uint16(psapi.status),uint16(hex2dec('FF00')))>0;
    dark_ii = find(~isNaN(dark_sig)); dark_ii(dark_ii>(length(psapi.time)-3)) = [];
    good = mod(psapi.SS(dark_ii+1),4)==1 &mod(psapi.SS(dark_ii+2),4)==2 &mod(psapi.SS(dark_ii+3),4)==3;
    good = good & dark_sig(dark_ii)>0 & dark_ref(dark_ii)>0 & blue_sig(dark_ii+1)>0 & blue_ref(dark_ii+1)>0 & ...
           green_sig(dark_ii+2)>0 & green_ref(dark_ii+2)>0 & red_sig(dark_ii+3)>0 & red_ref(dark_ii+3)>0 & ...
           ~bad_status(dark_ii)&~bad_status(dark_ii+1)&~bad_status(dark_ii+2)&~bad_status(dark_ii+3);

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
    psapo.mass_flow_last = psapi.mass_flow_last(dark_ii); mass_flow_last =psapo.mass_flow_last;
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
    psapo.endstr = psapi.ender(dark_ii);
    
    % Compute transmittances at full precision, and normalize by last PSAP reported signal ratio
    psapo.trans_B = (psapo.blue_sig./psapo.blue_ref)./psapo.blue_sig_ref_ratio;
    psapo.trans_G = (psapo.green_sig./psapo.green_ref)./psapo.green_sig_ref_ratio;
    psapo.trans_R = (psapo.red_sig./psapo.red_ref)./psapo.red_sig_ref_ratio;

    dark_times = psapo.time;

    psapo.mass_flow_last = b0 + b1.*psapo.mass_flow_last; 
    
    ss = 16;
    dt = ss./(24*60*60); % 16-second half-width, 32-second full-width
    psapo.flow_sm = sliding_polyfit(psapo.time, psapo.mass_flow_last, dt);
    [psapo.Ba_B_sm, psapo.trans_B_sm] = smooth_Tr_Bab(psapo.time, psapo.flow_sm, psapo.trans_B,ss,spot_area );
    [psapo.Ba_G_sm, psapo.trans_G_sm] = smooth_Tr_Bab(psapo.time, psapo.flow_sm, psapo.trans_G,ss,spot_area );
    [psapo.Ba_R_sm, psapo.trans_R_sm] = smooth_Tr_Bab(psapo.time, psapo.flow_sm, psapo.trans_R,ss,spot_area );

    figure; plot(psapo.time, [psapo.trans_B,psapo.trans_G,psapo.trans_R],'.',...
       psapo.time, [psapo.trans_B_sm,psapo.trans_G_sm,psapo.trans_R_sm],'-');dynamicDateTicks
    legend('Tr_B raw','Tr B raw','Tr R raw','Tr B smooth', 'Tr G smooth', 'Tr R smooth');
    
    ax(3) = gca;
    % These are absorption coefs when smoothed to 4x8=32s in transmittance space via smooth_Tr_Bab
    figure; plot(psapo.time, [psapo.Ba_B_sm, psapo.Ba_G_sm, psapo.Ba_R_sm],'-');
    ax(1) = gca;
    hold('on');
    % These are the original 2-second absorption coefficients reported by the
    % PSAP but smoothed to 2x15=30s in absorbance
    plot(psapi.time + (15./(24*60*60)), [smooth(psapi.Ba_B,15),smooth(psapi.Ba_G,15), smooth(psapi.Ba_R,15)],'o'); hold('off')
    legend('Ba B 32s in T','Ba G 32s in T', 'Ba R 32s in T', 'Ba B 60s in Ba','Ba G 60s in Ba', 'Ba R 60s in Ba'); 

    title(['Absorption coeffs ',strtok(psapi.fname,'.')]);
    dynamicDateTicks;
    
%     figure; plot(psapo.time, psapo.mass_flow_last, '-x');ax(2) = gca;  dynamicDateTicks;
%     % plot(psapo_grid.time, psapo_grid.mass_flow_last, '-x');ax(2) = gca;  dynamicDateTicks;
%     legend('mass flow'); title(['Mass flow ',strtok(psapi.fname,'.')]);
%     
%     figure; plot((psapo.time), [psapo.blue_ref, psapo.green_ref,psapo.red_ref] ,'.-'); dynamicDateTicks; ax(4) = gca;
%     legend('blue ref','green ref','red ref')
%     
%     figure; plot((psapo.time), [psapo.blue_sig, psapo.green_sig,psapo.red_sig] ,'-'); dynamicDateTicks; ax(5) = gca;
%     legend('blue sig','green sig','red sig')
    linkaxes(ax,'x');
%     
%     save([matdir, psapi.fname(1:10), 'psapi.mat'],'-struct','psapi');
%     save([matdir, psapi.fname(1:10), 'psapo.mat'],'-struct','psapo');

return