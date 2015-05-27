function nlc_coefs = NLC_a2_NASTI
% This code is used to generate the NLC fitting parameters
% Identified a sign error in a2 in AERI paper, and possible sign implicit
% in the Vdc model. Now stepping back through, checking everything
% including emissivity for LN2 bath.
% This version modified by Andre' to handle csv files.
emis = load('emis.mat');
% emis  = loadinto(['D:\case_studies\assist\compares\LRT_BB_Emiss_FullRes.mat']);
emis = repack_edgar(emis);
% range below is merely for display purposes.  It selects the x-range over
% which the y-axis is auto-ranged.  By restricting this x-range to a
% region that is not too noisy the graph should scale well.
range = [200 2100];
sub_1 = [250,350];
sub_2 = [1160,1190];
sub_3 = [2100,2200];
sub_ = sub_1; % Select which subrange to use where amplitude of responsivity 
             % significantly greater than zero.  
Detector = 'A'; in_band = [800,1100]; % Select in-band region of desired detector
Detector = 'B'; in_band = [1400,1600]; % Select in-band region of desired detector


test_dir = getdir('','assist_nlc','Select NLC test directory');
% Did the following in order to be able to count runs in network directory.
% A simple dir with wildcard did not work.
test_dir_content = dir(test_dir);
% abbs = sum(cell2mat(regexp({test_dir_content.name}, 'ABB_[0-9]_A\.igm')));
% hbbs = sum(cell2mat(regexp({test_dir_content.name}, 'HBB_[0-9]_A\.igm')));
% ln2s = sum(cell2mat(regexp({test_dir_content.name}, 'LN2_[0-9]_A\.igm')));
abbs = sum(cell2mat(regexp({test_dir_content.name}, 'ABB_[0-9]_B\.igm')));
hbbs = sum(cell2mat(regexp({test_dir_content.name}, 'HBB_[0-9]_B\.igm')));
ln2s = sum(cell2mat(regexp({test_dir_content.name}, 'LN2_[0-9]_B\.igm')));


% h = waitbar(0,'Starting NLC Characterization...', 'Name', sprintf('NLC Characterization on %s...', test_dir));

% try
    if abbs==hbbs && hbbs==ln2s
        
        Nb_of_Runs = abbs;
        
        a_2 = zeros(Nb_of_Runs, 1);
        T_ABB = zeros(Nb_of_Runs, 1);
        a_2_ = zeros(Nb_of_Runs, 1);
        for Run_number = 1:Nb_of_Runs
            
%             waitbar(Run_number/Nb_of_Runs,h,sprintf('Running characterization on run %d/%d...',Run_number,Nb_of_Runs));
            
            display(['run number:', num2str(Run_number)])
            % NUMERIC =
            % xlsread('c:\matlab\work\myspreadsheet','sheet2','a2:j5')
            
            % Check for XLS HBB file existence, otherwise, attempt to open .csv.
            if exist([test_dir,'HBB_' num2str(Run_number) '_ANN.xls'], 'file') == 2
                s = xlsread([test_dir,'HBB_' num2str(Run_number) '_ANN.xls']);
                [ss,header] = xlsread([test_dir,'HBB_' num2str(Run_number) '_ANN.xls'],'Annotation','a2:cz2');
                HBB_col = strcmp(header,'Hot BB Mean');
                ABB_col=  strcmp(header,'Cold BB Mean');
                T_HBB(Run_number) = 273.15 + mean(s(:, HBB_col));
                s = xlsread([test_dir,'ABB_' num2str(Run_number) '_ANN.xls']);
                T_ABB(Run_number) = 273.15 + mean(s(:, ABB_col));
            elseif (exist([test_dir,'HBB_' num2str(Run_number) '_ANN.csv'], 'file') == 2)
                [HBB_col, ~] = annCsvReader([test_dir,'HBB_' num2str(Run_number) '_ANN.csv']);
                T_HBB(Run_number) = 273.15 + mean(HBB_col);
                [~, ABB_col] = annCsvReader([test_dir,'ABB_' num2str(Run_number) '_ANN.csv']);
                T_ABB(Run_number) = 273.15 + mean(ABB_col);
            else
                error('Cannot find ANN xls or csv file for this run. Aborting.');
            end
            
            T_CBB = 77;
            
            MaxNbScansCalib = -1;
            MaxNbScansScene = -1;
            
            fileName = [test_dir,'HBB_' num2str(Run_number) '_' Detector '.igm'];
            DataHBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
            [ForwardHBB, ReverseHBB] = SplitDirections(DataHBB);
            
            IGM_H_F.Header = ForwardHBB.Header;
            IGM_H_F.x = ForwardHBB.x;
            IGM_H_F.y = mean(ForwardHBB.y(1:end,:), 1);
            IGM_H_R.Header = ReverseHBB.Header;
            IGM_H_R.x = ReverseHBB.x;
            IGM_H_R.y = mean(ReverseHBB.y(1:end,:), 1);
            
            fileName = [test_dir,'ABB_' num2str(Run_number) '_' Detector '.igm'];
            DataABB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
            [ForwardABB, ReverseABB] = SplitDirections(DataABB);
            IGM_A_F.Header = ForwardABB.Header;
            IGM_A_F.x = ForwardABB.x;
            IGM_A_F.y = mean(ForwardABB.y, 1);
            IGM_A_R.Header = ReverseABB.Header;
            IGM_A_R.x = ReverseABB.x;
            IGM_A_R.y = mean(ReverseABB.y, 1);
            %          clear DataABB ForwardABB ReverseABB
            
            fileName = [test_dir,'LN2_' num2str(Run_number) '_' Detector '.igm'];
            DataCBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
            [ForwardCBB, ReverseCBB] = SplitDirections(DataCBB);
            IGM_C_F.Header = ForwardCBB.Header;
            IGM_C_F.x = ForwardCBB.x;
            IGM_C_F.y = mean(ForwardCBB.y, 1);
            IGM_C_R.Header = ForwardCBB.Header;
            IGM_C_R.x = ReverseCBB.x;
            IGM_C_R.y = mean(ReverseCBB.y, 1);
            
%             clear DataCBB ForwardCBB ReverseCBB
            
            % First determine zpd from HBB as location of first relative 
            % maxima after igm midline.  
            HBB_F = IGM_H_F.y; len = length(HBB_F);
            abs_BB = abs(HBB_F);
            relex = find( abs_BB(1:end-2)<abs_BB(2:end-1) & abs_BB(2:end-1)>abs_BB(3:end))+1;
            relex(relex<len./2) = []; relex = relex(1);
            zpd_shift = relex -len./2; 
            zpd_raw = HBB_F(relex); 
            zpd_new = fft(abs(ifft(HBB_F))); 
            zpd_new = abs(zpd_new(1).*zpd_raw)./zpd_raw;
            zpd_new = abs(zpd_new);

            zpd_shift_F = zpd_shift;
%             figure; plot([1:len]-len./2 , HBB_F, 'r-', [1:len]-len./2 , sideshift([1:len], HBB_F,zpd_shift), 'b-') 
%             [~,maxii_HF] = max(abs(IGM_H_F.y),[],2); maxii_HF = mode(maxii_HF);
%             zpd_shift_F = maxii_HF-length(IGM_H_F.x)./2 -1;
%             zpd_shift_F = phase_shift_zpd(IGM_H_F.y);
            % Shift igms

            figure; 
            s(1) = subplot(2,1,1);
            plot(IGM_H_F.x, IGM_H_F.y,'-r', IGM_H_F.x, IGM_A_F.y,'-c',IGM_H_F.x, IGM_C_F.y,'-b');
            s(2) = subplot(2,1,2);
            plot(IGM_H_R.x, IGM_H_R.y,'-r', IGM_H_R.x, IGM_A_R.y,'-c',IGM_H_R.x, IGM_C_R.y,'-b');
            linkaxes(s,'xy'); 
            
            IGM_H_F.y =  sideshift(IGM_H_F.x, IGM_H_F.y, zpd_shift_F);
            IGM_A_F.y =  sideshift(IGM_A_F.x, IGM_A_F.y, zpd_shift_F);
            IGM_C_F.y =  sideshift(IGM_C_F.x, IGM_C_F.y, zpd_shift_F);
            IGM_H_F.x = fftshift(IGM_H_F.x);  IGM_H_F.y = fftshift(IGM_H_F.y);
            IGM_A_F.x = fftshift(IGM_A_F.x);  IGM_A_F.y = fftshift(IGM_A_F.y);
            IGM_C_F.x = fftshift(IGM_C_F.x);  IGM_C_F.y = fftshift(IGM_C_F.y);
            
            % and for Reverse
            HBB_R = IGM_H_R.y; len = length(HBB_R);
            abs_BB = abs(HBB_R);
            relex = find( abs_BB(1:end-2)<abs_BB(2:end-1) & abs_BB(2:end-1)>abs_BB(3:end))+1;
            relex(relex<len./2) = []; relex = relex(1);
            zpd_shift = relex -len./2; 
            zpd_raw = HBB_R(relex); 
            zpd_new = fft(abs(ifft(HBB_R))); 
            zpd_new = abs(zpd_new(1).*zpd_raw)./zpd_raw;

            zpd_shift_R = zpd_shift;            
            
%             [~,maxii_HR] = max(abs(IGM_H_R.y),[],2); maxii_HR = mode(maxii_HR);
%             
%             % Shift igms
%             zpd_shift_R = maxii_HR-length(IGM_H_R.x)./2 -1;
%             zpd_shift_R = phase_shift_zpd(IGM_H_R.y);
            IGM_H_R.y =  sideshift(IGM_H_R.x, IGM_H_R.y, zpd_shift_R);
            IGM_A_R.y =  sideshift(IGM_A_R.x, IGM_A_R.y, zpd_shift_R);
            IGM_C_R.y =  sideshift(IGM_C_R.x, IGM_C_R.y, zpd_shift_R);
            IGM_H_R.x = fftshift(IGM_H_R.x);  IGM_H_R.y = fftshift(IGM_H_R.y);
            IGM_A_R.x = fftshift(IGM_A_R.x);  IGM_A_R.y = fftshift(IGM_A_R.y);
            IGM_C_R.x = fftshift(IGM_C_R.x);  IGM_C_R.y = fftshift(IGM_C_R.y);
            
            %% Compute fft
            [SPC_H_F.x, SPC_H_F.y, SPC_H_F.Idc_pc] = RawIgm2RawSpc(IGM_H_F.x,IGM_H_F.y); 
            SPC_H_F.Idc_raw = IGM_H_F.y(1);
            [SPC_A_F.x, SPC_A_F.y, SPC_A_F.Idc_pc] = RawIgm2RawSpc(IGM_A_F.x,IGM_A_F.y); 
            SPC_A_F.Idc_raw = IGM_A_F.y(1);
            [SPC_C_F.x, SPC_C_F.y, SPC_C_F.Idc_pc] = RawIgm2RawSpc(IGM_C_F.x,IGM_C_F.y); 
            SPC_C_F.Idc_raw = IGM_C_F.y(1);
            % adjust emissivity of CBB
            ef = (.99./.999); % ef = (.982./.999);
            CalSet_HA_F = CreateCalibrationFromCXS_(SPC_H_F, T_HBB(Run_number), SPC_A_F, T_ABB(Run_number), T_ABB(Run_number),emis);
            emis_N2 = emis; emis_N2.y = emis_N2.y .*ef;
            CalSet_AC_F = CreateCalibrationFromCXS_(SPC_A_F, T_ABB(Run_number), SPC_C_F, T_CBB, T_ABB(Run_number),emis, emis_N2);
            diff_resp_F = CalSet_HA_F.Resp - CalSet_AC_F.Resp;
            % Ideally, these calibrations should be identical but due to
            % non-linearity there will be differences related to V_dc and a2
            % Absent measurement, Vdc is modeled in terms of zpd intensities as
            % Vdc = -{(2+f)*[-Ih+Ih_lab-Ic_lab]+I}/MF
            % Vdc = {(2+f)*[Ih - Ih_lab + Ic_lab] - Im}/MF; f = 1, MF = 0.7
            
            %
            MF  =0.7;
            f_back = 1;
            
          
            I_H_F_raw(Run_number) = SPC_H_F.Idc_raw;
            I_A_F_raw(Run_number) = SPC_A_F.Idc_raw;
            I_C_F_raw(Run_number) = SPC_C_F.Idc_raw;
            
            I_H_F_pc(Run_number) = SPC_H_F.Idc_pc;
            I_A_F_pc(Run_number) = SPC_A_F.Idc_pc;
            I_C_F_pc(Run_number) = SPC_C_F.Idc_pc;
            
            % Modeled DC offset (this could be replaced with ASSIST chA DC
            % Here is where I begin to flip the Vdc sign
            
            V_H_F_raw_p(Run_number) = (1/MF) *   ((2 + f_back)*(-I_H_F_raw(Run_number) + I_H_F_raw(Run_number) -I_C_F_raw(Run_number)) + I_H_F_raw(Run_number));
            V_A_F_raw_p(Run_number) = (1/MF) *   ((2 + f_back)*(-I_H_F_raw(Run_number) + I_H_F_raw(Run_number) -I_C_F_raw(Run_number)) + I_A_F_raw(Run_number));
            V_C_F_raw_p(Run_number) = (1/MF) *   ((2 + f_back)*(-I_H_F_raw(Run_number) + I_H_F_raw(Run_number) -I_C_F_raw(Run_number)) + I_C_F_raw(Run_number));

            V_H_F_raw_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_raw(Run_number) + I_H_F_raw(Run_number) -I_C_F_raw(Run_number)) + I_H_F_raw(Run_number));
            V_A_F_raw_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_raw(Run_number) + I_H_F_raw(Run_number) -I_C_F_raw(Run_number)) + I_A_F_raw(Run_number));
            V_C_F_raw_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_raw(Run_number) + I_H_F_raw(Run_number) -I_C_F_raw(Run_number)) + I_C_F_raw(Run_number));
            
            V_H_F_pc_p(Run_number) = (1/MF) * ((2 + f_back)*(-I_H_F_pc(Run_number) + I_H_F_pc(Run_number) -I_C_F_pc(Run_number)) + I_H_F_pc(Run_number));
            V_A_F_pc_p(Run_number) = (1/MF) * ((2 + f_back)*(-I_H_F_pc(Run_number) + I_H_F_pc(Run_number) -I_C_F_pc(Run_number)) + I_A_F_pc(Run_number));
            V_C_F_pc_p(Run_number) = (1/MF) * ((2 + f_back)*(-I_H_F_pc(Run_number) + I_H_F_pc(Run_number) -I_C_F_pc(Run_number)) + I_C_F_pc(Run_number));
            
            V_H_F_pc_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_pc(Run_number) + I_H_F_pc(Run_number) -I_C_F_pc(Run_number)) + I_H_F_pc(Run_number));
            V_A_F_pc_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_pc(Run_number) + I_H_F_pc(Run_number) -I_C_F_pc(Run_number)) + I_A_F_pc(Run_number));
            V_C_F_pc_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_pc(Run_number) + I_H_F_pc(Run_number) -I_C_F_pc(Run_number)) + I_C_F_pc(Run_number));

                                    
            %
            % The following is pure math, for the non-linearity expanded to the quadratic term.
            % Basically pure math but incorporates modeled V_DC
            IGM_H_O_F.Header = IGM_H_F.Header;
            IGM_H_O_F.x = IGM_H_F.x;
            IGM_H_O_F.y_raw_p = (IGM_H_F.y + V_H_F_raw_p(Run_number)).^2; % Form #1 of Eq1 in AERI part II
            IGM_H_O_F.y_raw_n = (IGM_H_F.y + V_H_F_raw_n(Run_number)).^2; % Form #1 of Eq1 in AERI part II
            IGM_H_O_F.y_pc_p = (IGM_H_F.y + V_H_F_pc_p(Run_number)).^2; % Form #1 of Eq1 in AERI part II
            IGM_H_O_F.y_pc_n = (IGM_H_F.y + V_H_F_pc_n(Run_number)).^2; % Form #1 of Eq1 in AERI part II
            
            IGM_A_O_F.Header = IGM_A_F.Header;
            IGM_A_O_F.x = IGM_A_F.x;
            IGM_A_O_F.y_raw_p = (IGM_A_F.y + V_A_F_raw_p(Run_number)).^2;
            IGM_A_O_F.y_raw_n = (IGM_A_F.y + V_A_F_raw_n(Run_number)).^2;
            IGM_A_O_F.y_pc_p = (IGM_A_F.y + V_A_F_pc_p(Run_number)).^2;
            IGM_A_O_F.y_pc_n = (IGM_A_F.y + V_A_F_pc_n(Run_number)).^2;
            
            IGM_C_O_F.Header = IGM_C_F.Header;
            IGM_C_O_F.x = IGM_C_F.x;
            IGM_C_O_F.y_raw_p = (IGM_C_F.y + V_C_F_raw_p(Run_number)).^2;
            IGM_C_O_F.y_raw_n = (IGM_C_F.y + V_C_F_raw_n(Run_number)).^2;
            IGM_C_O_F.y_pc_p = (IGM_C_F.y + V_C_F_pc_p(Run_number)).^2;
            IGM_C_O_F.y_pc_n = (IGM_C_F.y + V_C_F_pc_n(Run_number)).^2;
            
            [SPC_H_O_F.x,SPC_H_O_F.y_raw_p]  = RawIgm2RawSpc(IGM_H_O_F.x,IGM_H_O_F.y_raw_p);
            [SPC_A_O_F.x,SPC_A_O_F.y_raw_p]  = RawIgm2RawSpc(IGM_A_O_F.x,IGM_A_O_F.y_raw_p);
            [SPC_C_O_F.x,SPC_C_O_F.y_raw_p]  = RawIgm2RawSpc(IGM_C_O_F.x,IGM_C_O_F.y_raw_p);

            [SPC_H_O_F.x,SPC_H_O_F.y_raw_n] = RawIgm2RawSpc(IGM_H_O_F.x,IGM_H_O_F.y_raw_n);
            [SPC_A_O_F.x,SPC_A_O_F.y_raw_n] = RawIgm2RawSpc(IGM_A_O_F.x,IGM_A_O_F.y_raw_n);
            [SPC_C_O_F.x,SPC_C_O_F.y_raw_n] = RawIgm2RawSpc(IGM_C_O_F.x,IGM_C_O_F.y_raw_n);
                        
            [SPC_H_O_F.x,SPC_H_O_F.y_pc_p] = RawIgm2RawSpc(IGM_H_O_F.x,IGM_H_O_F.y_pc_p);
            [SPC_A_O_F.x,SPC_A_O_F.y_pc_p] = RawIgm2RawSpc(IGM_A_O_F.x,IGM_A_O_F.y_pc_p);
            [SPC_C_O_F.x,SPC_C_O_F.y_pc_p] = RawIgm2RawSpc(IGM_C_O_F.x,IGM_C_O_F.y_pc_p);

            [SPC_H_O_F.x,SPC_H_O_F.y_pc_n] = RawIgm2RawSpc(IGM_H_O_F.x,IGM_H_O_F.y_pc_n);
            [SPC_A_O_F.x,SPC_A_O_F.y_pc_n] = RawIgm2RawSpc(IGM_A_O_F.x,IGM_A_O_F.y_pc_n);
            [SPC_C_O_F.x,SPC_C_O_F.y_pc_n] = RawIgm2RawSpc(IGM_C_O_F.x,IGM_C_O_F.y_pc_n);

            
            % Fit to eqn 3 of AERI paper
            BB_x = SPC_H_O_F.x;
            em1 = interp1(emis.x, emis.y, BB_x, 'pchip','extrap');
            em2 = em1;
            em0 = em1.*ef;
            T_2 = T_HBB(Run_number);
            T_1 = T_ABB(Run_number);
            T_0 = T_CBB;
            T_mirror = T_1;
            BB_2 = em2.*Blackbody(BB_x, T_2)+(1-em2).*Blackbody(BB_x, T_mirror);
            BB_1 = em1.*Blackbody(BB_x, T_1)+(1-em1).*Blackbody(BB_x, T_mirror);
            BB_0 = em0.*Blackbody(BB_x, T_0)+(1-em0).*Blackbody(BB_x, T_mirror);
            
            Diff_Resp_fit_F.x = SPC_H_O_F.x;
            Diff_Resp_fit_F.y_raw_p = (SPC_H_O_F.y_raw_p - SPC_A_O_F.y_raw_p)./(BB_2 - BB_1) ...
                -(SPC_A_O_F.y_raw_p - SPC_C_O_F.y_raw_p)./(BB_1 - BB_0);
            Diff_Resp_fit_F.y_raw_n = (SPC_H_O_F.y_raw_n - SPC_A_O_F.y_raw_n)./(BB_2 - BB_1) ...
                -(SPC_A_O_F.y_raw_n - SPC_C_O_F.y_raw_n)./(BB_1 - BB_0);

             Diff_Resp_fit_F.y_pc_p = (SPC_H_O_F.y_pc_p - SPC_A_O_F.y_pc_p)./(BB_2 - BB_1) ...
                -(SPC_A_O_F.y_pc_p - SPC_C_O_F.y_pc_p)./(BB_1 - BB_0);
             
             Diff_Resp_fit_F.y_pc_n = (SPC_H_O_F.y_pc_n - SPC_A_O_F.y_pc_n)./(BB_2 - BB_1) ...
                -(SPC_A_O_F.y_pc_n - SPC_C_O_F.y_pc_n)./(BB_1 - BB_0);             
            
            a2_F_raw_p = -real(diff_resp_F) ./ real(Diff_Resp_fit_F.y_raw_p);
            a2_F_raw_n = -real(diff_resp_F) ./ real(Diff_Resp_fit_F.y_raw_n);
            a2_F_pc_p = -real(diff_resp_F) ./ real(Diff_Resp_fit_F.y_pc_p);
            a2_F_pc_n = -real(diff_resp_F) ./ real(Diff_Resp_fit_F.y_pc_n);
            

            %spectral range 1237 - 2180 cm-1.

            % Here is where the spectral range of your detector becomes
            % relevant.  You want to select a subrange that is outside
            % your spectral range but still shows significant non-zero
            % diff_resp value.  What we are doing is scaling the "fitted"
            % curve to match the height of the "measured" diff_resp over
            % this sub-range.  So don't pick a range where the diff_resp
            % crosses zero or your scaling will be unstable.
            
            %This first subrange uses values from the lowest wn scale
            %where the diff_resp begins to ramp way up, but it a bit noisy
            sub = (CalSet_HA_F.x>sub_(1)&CalSet_HA_F.x<sub_(2));

            
            A2_F_raw_p(Run_number) = mean(a2_F_raw_p(sub));
            A2_F_raw_n(Run_number) = mean(a2_F_raw_n(sub));
            A2_F_pc_p(Run_number) = mean(a2_F_pc_p(sub));
            A2_F_pc_n(Run_number) = mean(a2_F_pc_n(sub));
            
            % decide whether to use positive or _n based on which one
            % yields smallest absolute difference between meas and modeled
            % responsivity differences.
            inband = Diff_Resp_fit_F.x>=in_band(1) & Diff_Resp_fit_F.x<= in_band(2);
            pos = trapz(Diff_Resp_fit_F.x(inband), abs(diff_resp_F(inband) + A2_F_raw_p(Run_number) .* Diff_Resp_fit_F.y_raw_p(inband)));
            neg = trapz(Diff_Resp_fit_F.x(inband), abs(diff_resp_F(inband) + A2_F_raw_n(Run_number) .* Diff_Resp_fit_F.y_raw_n(inband)));
            if pos<neg
               A2_F_raw(Run_number) = A2_F_raw_p(Run_number);
               Diff_Resp_fit_F.y_raw = Diff_Resp_fit_F.y_raw_p;
               A2_F_pc(Run_number) = A2_F_pc_p(Run_number);
               Diff_Resp_fit_F.y_pc = Diff_Resp_fit_F.y_pc_p;
               dpol_F(Run_number) = 1;
               % Also record zpd_raw and zpd_pc 
            else
               A2_F_raw(Run_number) = A2_F_raw_n(Run_number);
               Diff_Resp_fit_F.y_raw = Diff_Resp_fit_F.y_raw_n;
               A2_F_pc(Run_number) = A2_F_pc_n(Run_number);
               Diff_Resp_fit_F.y_pc = Diff_Resp_fit_F.y_pc_n;
               dpol_F(Run_number) = -1;               
            end
            
            figure(51);
            plot(CalSet_AC_F.x, real(diff_resp_F)./1000, 'r.',CalSet_AC_F.x(sub), real(diff_resp_F(sub))./1000, 'c.')
            hold('on')
            %plot(CalSet_AC.x, imag(diff_gains), 'g-')
            %       lines = plot(Diff_Resp_fit.x, real(a_2(Run_number) * Diff_Resp_fit.y), 'r-', Diff_Resp_fit.x, real(a_2_(Run_number) * Diff_Resp_fit.y), 'k-')
            plot(Diff_Resp_fit_F.x, real(-A2_F_raw_p(Run_number) * real(Diff_Resp_fit_F.y_raw_p))./1000, 'b-',...
            Diff_Resp_fit_F.x, real(-A2_F_raw_n(Run_number) * real(Diff_Resp_fit_F.y_raw_n))./1000, 'r-',...
            Diff_Resp_fit_F.x, real(-A2_F_raw(Run_number) * real(Diff_Resp_fit_F.y_raw))./1000, 'k:');
            %plot(Diff_Resp_fit.x, imag(a_2(Run_number) * Diff_Resp_fit.y), 'c-')
            xlabel('Wavenumber [cm^{-1}]')
            ylabel('R^{HA}-R^{AC} [cts/(mW/(m^2 sr cm^{-1}))]')
            kk = find(Diff_Resp_fit_F.x >= range(1) & Diff_Resp_fit_F.x <= range(2));
            ymin = 0.9*min([real(diff_resp_F(kk))./1000 real(-A2_F_raw(Run_number) * Diff_Resp_fit_F.y_raw(kk))./1000]);
            ymax = 1.2*max([real(diff_resp_F(kk))./1000 real(-A2_F_raw(Run_number) * Diff_Resp_fit_F.y_raw(kk))./1000]);
            axis([200 2400 ymin ymax]);
            V = [IGM_H_F.Header.fdate.year,IGM_H_F.Header.fdate.month+1,IGM_H_F.Header.fdate.day+1];
            title({['Detector ',Detector,' raw ZPD'];...
                [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Forward, Run:',num2str(Run_number)]},'interp','none');
            %legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
            %       legend('Measured',sprintf('a2 = %2.3e',a_2(Run_number)),
            %       sprintf('(2nd) %2.3e',a_2_(Run_number)));
            lg = legend('Measured','fitted'); set(lg,'interp','none');
            hold('off');
            txt_str = {sprintf('MF factor = %0.1f',MF);...
                sprintf('LN2 emis factor = %0.3f',ef);...
                sprintf('a2_F_raw = %2.3e',mean(A2_F_raw(Run_number)));...
                sprintf('ZPD polarity = %1d',dpol_F(Run_number))};
            txt_51 = text(mean(xlim), mean(ylim),txt_str);
            set(txt_51,'unit','normalized','position',[.05,.95],'verticalalign','cap',...
                'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
                'fontname','Tahoma','fontweight','demi','backgroundcolor','w');
            
             figure(52);
            plot(CalSet_AC_F.x, real(diff_resp_F)./1000, 'r.',CalSet_AC_F.x(sub), real(diff_resp_F(sub))./1000, 'c.')
            hold('on')
            %plot(CalSet_AC.x, imag(diff_gains), 'g-')
            %       lines = plot(Diff_Resp_fit.x, real(a_2(Run_number) * Diff_Resp_fit.y), 'r-', Diff_Resp_fit.x, real(a_2_(Run_number) * Diff_Resp_fit.y), 'k-')
            plot(Diff_Resp_fit_F.x, real(-A2_F_pc_p(Run_number) * real(Diff_Resp_fit_F.y_pc_p))./1000, 'b-',...
            Diff_Resp_fit_F.x, real(-A2_F_pc_n(Run_number) * real(Diff_Resp_fit_F.y_pc_n))./1000, 'r-',...
            Diff_Resp_fit_F.x, real(-A2_F_pc(Run_number) * real(Diff_Resp_fit_F.y_pc))./1000, 'k:');
            %plot(Diff_Resp_fit.x, imag(a_2(Run_number) * Diff_Resp_fit.y), 'c-')
            xlabel('Wavenumber [cm^{-1}]')
            ylabel('R^{HA}-R^{AC} [cts/(mW/(m^2 sr cm^{-1}))]')
            kk = find(Diff_Resp_fit_F.x >= range(1) & Diff_Resp_fit_F.x <= range(2));
            ymin = 0.9*min([real(diff_resp_F(kk))./1000 real(-A2_F_pc(Run_number) * Diff_Resp_fit_F.y_pc(kk))./1000]);
            ymax = 1.2*max([real(diff_resp_F(kk))./1000 real(-A2_F_pc(Run_number) * Diff_Resp_fit_F.y_pc(kk))./1000]);
            axis([200 2400 ymin ymax]);
            V = [IGM_H_F.Header.fdate.year,IGM_H_F.Header.fdate.month+1,IGM_H_F.Header.fdate.day+1];
            title({['Detector ',Detector,' pc ZPD'];...
                [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Forward, Run:',num2str(Run_number)]},'interp','none');
            %legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
            %       legend('Measured',sprintf('a2 = %2.3e',a_2(Run_number)),
            %       sprintf('(2nd) %2.3e',a_2_(Run_number)));
            lg = legend('Measured','fitted'); set(lg,'interp','none');
            hold('off');
            txt_str = {sprintf('MF factor = %0.1f',MF);...
                sprintf('LN2 emis factor = %0.3f',ef);...
                sprintf('a2_F_pc = %2.3e',mean(A2_F_pc(Run_number)));...
                sprintf('ZPD polarity = %1d',dpol_F(Run_number))};
            txt_52 = text(mean(xlim), mean(ylim),txt_str);
            set(txt_52,'unit','normalized','position',[.05,.95],'verticalalign','cap',...
                'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
                'fontname','Tahoma','fontweight','demi','backgroundcolor','w');
            % Now do reverse scan...
            
            % Compute fft
            [SPC_H_R.x, SPC_H_R.y, SPC_H_R.Idc_pc] = RawIgm2RawSpc(IGM_H_R.x,IGM_H_R.y); SPC_H_R.Idc_raw = IGM_H_R.y(1);
            [SPC_A_R.x, SPC_A_R.y, SPC_A_R.Idc_pc] = RawIgm2RawSpc(IGM_A_R.x,IGM_A_R.y); SPC_A_R.Idc_raw = IGM_A_R.y(1);
            [SPC_C_R.x, SPC_C_R.y, SPC_C_R.Idc_pc] = RawIgm2RawSpc(IGM_C_R.x,IGM_C_R.y); SPC_C_R.Idc_raw = IGM_C_R.y(1);
            
            %       ef = (.985./.999);
            CalSet_HA_R = CreateCalibrationFromCXS_(SPC_H_R, T_HBB(Run_number), SPC_A_R, T_ABB(Run_number), T_ABB(Run_number),emis);
            emis_N2 = emis; emis_N2.y = emis_N2.y .*ef;
            CalSet_AC_R = CreateCalibrationFromCXS_(SPC_A_R, T_ABB(Run_number), SPC_C_R, T_CBB, T_ABB(Run_number),emis, emis_N2);
            diff_resp_R = CalSet_HA_R.Resp - CalSet_AC_R.Resp;
            % Ideally, these calibrations should be identical but due to
            % non-linearity there will be differences related to V_dc and a2
            % Absent measurement, Vdc is modeled in terms of zpd intensities as
            % Vdc = -{(2+f)*[-Ih+Ih_lab-Ic_lab]+I}/MF
            % Vdc = {(2+f)*[Ih - Ih_lab + Ic_lab] - Im}/MF; f = 1, MF = 0.7
            
            %
            
            I_H_R_raw(Run_number) = SPC_H_R.Idc_raw;
            I_A_R_raw(Run_number) = SPC_A_R.Idc_raw;
            I_C_R_raw(Run_number) = SPC_C_R.Idc_raw;
            
            I_H_R_pc(Run_number) = SPC_H_R.Idc_pc;
            I_A_R_pc(Run_number) = SPC_A_R.Idc_pc;
            I_C_R_pc(Run_number) = SPC_C_R.Idc_pc;
            
            % Modeled DC offset (this could be replaced with ASSIST chA DC
            % Here is where I begin to flip the Vdc sign
            dpolR = 1;
            V_H_R_raw_p(Run_number) = (1/MF) * ((2 + f_back)*(-I_H_R_raw(Run_number) + I_H_R_raw(Run_number) -I_C_R_raw(Run_number)) + I_H_R_raw(Run_number));
            V_A_R_raw_p(Run_number) = (1/MF) * ((2 + f_back)*(-I_H_R_raw(Run_number) + I_H_R_raw(Run_number) -I_C_R_raw(Run_number)) + I_A_R_raw(Run_number));
            V_C_R_raw_p(Run_number) = (1/MF) * ((2 + f_back)*(-I_H_R_raw(Run_number) + I_H_R_raw(Run_number) -I_C_R_raw(Run_number)) + I_C_R_raw(Run_number));
            
            V_H_R_pc_p(Run_number) = (1/MF) * ((2 + f_back)*(-I_H_R_pc(Run_number) + I_H_R_pc(Run_number) -I_C_R_pc(Run_number)) + I_H_R_pc(Run_number));
            V_A_R_pc_p(Run_number) = (1/MF) * ((2 + f_back)*(-I_H_R_pc(Run_number) + I_H_R_pc(Run_number) -I_C_R_pc(Run_number)) + I_A_R_pc(Run_number));
            V_C_R_pc_p(Run_number) = (1/MF) * ((2 + f_back)*(-I_H_R_pc(Run_number) + I_H_R_pc(Run_number) -I_C_R_pc(Run_number)) + I_C_R_pc(Run_number));
            
            V_H_R_raw_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_raw(Run_number) + I_H_R_raw(Run_number) -I_C_R_raw(Run_number)) + I_H_R_raw(Run_number));
            V_A_R_raw_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_raw(Run_number) + I_H_R_raw(Run_number) -I_C_R_raw(Run_number)) + I_A_R_raw(Run_number));
            V_C_R_raw_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_raw(Run_number) + I_H_R_raw(Run_number) -I_C_R_raw(Run_number)) + I_C_R_raw(Run_number));
            
            V_H_R_pc_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_pc(Run_number) + I_H_R_pc(Run_number) -I_C_R_pc(Run_number)) + I_H_R_pc(Run_number));
            V_A_R_pc_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_pc(Run_number) + I_H_R_pc(Run_number) -I_C_R_pc(Run_number)) + I_A_R_pc(Run_number));
            V_C_R_pc_n(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_pc(Run_number) + I_H_R_pc(Run_number) -I_C_R_pc(Run_number)) + I_C_R_pc(Run_number));
            
            
            
            %
            % The following is pure math, for the non-linearity expanded to the quadratic term.
            % Basically pure math but incorporates modeled V_DC
            IGM_H_O_R.Header = IGM_H_R.Header;
            IGM_H_O_R.x = IGM_H_R.x;
            IGM_H_O_R.y_raw_p = (IGM_H_R.y + V_H_R_raw_p(Run_number)).^2; % Form #1 of Eq1 in AERI part II
            IGM_H_O_R.y_pc_p = (IGM_H_R.y + V_H_R_pc_p(Run_number)).^2; % Form #1 of Eq1 in AERI part II
            IGM_H_O_R.y_raw_n = (IGM_H_R.y + V_H_R_raw_n(Run_number)).^2; % Form #1 of Eq1 in AERI part II
            IGM_H_O_R.y_pc_n = (IGM_H_R.y + V_H_R_pc_n(Run_number)).^2; % Form #1 of Eq1 in AERI part II

            
            IGM_A_O_R.Header = IGM_A_R.Header;
            IGM_A_O_R.x = IGM_A_R.x;
            IGM_A_O_R.y_raw_p = (IGM_A_R.y + V_A_R_raw_p(Run_number)).^2;
            IGM_A_O_R.y_pc_p = (IGM_A_R.y + V_A_R_pc_p(Run_number)).^2;
            IGM_A_O_R.y_raw_n = (IGM_A_R.y + V_A_R_raw_n(Run_number)).^2;
            IGM_A_O_R.y_pc_n = (IGM_A_R.y + V_A_R_pc_n(Run_number)).^2;

            
            IGM_C_O_R.Header = IGM_C_R.Header;
            IGM_C_O_R.x = IGM_C_R.x;
            IGM_C_O_R.y_raw_p = (IGM_C_R.y + V_C_R_raw_p(Run_number)).^2;
            IGM_C_O_R.y_pc_p = (IGM_C_R.y + V_C_R_pc_p(Run_number)).^2;
            IGM_C_O_R.y_raw_n = (IGM_C_R.y + V_C_R_raw_n(Run_number)).^2;
            IGM_C_O_R.y_pc_n = (IGM_C_R.y + V_C_R_pc_n(Run_number)).^2;

            
            [SPC_H_O_R.x,SPC_H_O_R.y_raw_p] = RawIgm2RawSpc(IGM_H_O_R.x,IGM_H_O_R.y_raw_p);
            [SPC_A_O_R.x,SPC_A_O_R.y_raw_p] = RawIgm2RawSpc(IGM_A_O_R.x,IGM_A_O_R.y_raw_p);
            [SPC_C_O_R.x,SPC_C_O_R.y_raw_p] = RawIgm2RawSpc(IGM_C_O_R.x,IGM_C_O_R.y_raw_p);
            [SPC_H_O_R.x,SPC_H_O_R.y_raw_n] = RawIgm2RawSpc(IGM_H_O_R.x,IGM_H_O_R.y_raw_n);
            [SPC_A_O_R.x,SPC_A_O_R.y_raw_n] = RawIgm2RawSpc(IGM_A_O_R.x,IGM_A_O_R.y_raw_n);
            [SPC_C_O_R.x,SPC_C_O_R.y_raw_n] = RawIgm2RawSpc(IGM_C_O_R.x,IGM_C_O_R.y_raw_n);
            
            [SPC_H_O_R.x,SPC_H_O_R.y_pc_p] = RawIgm2RawSpc(IGM_H_O_R.x,IGM_H_O_R.y_pc_p);
            [SPC_A_O_R.x,SPC_A_O_R.y_pc_p] = RawIgm2RawSpc(IGM_A_O_R.x,IGM_A_O_R.y_pc_p);
            [SPC_C_O_R.x,SPC_C_O_R.y_pc_p] = RawIgm2RawSpc(IGM_C_O_R.x,IGM_C_O_R.y_pc_p);
            [SPC_H_O_R.x,SPC_H_O_R.y_pc_n] = RawIgm2RawSpc(IGM_H_O_R.x,IGM_H_O_R.y_pc_n);
            [SPC_A_O_R.x,SPC_A_O_R.y_pc_n] = RawIgm2RawSpc(IGM_A_O_R.x,IGM_A_O_R.y_pc_n);
            [SPC_C_O_R.x,SPC_C_O_R.y_pc_n] = RawIgm2RawSpc(IGM_C_O_R.x,IGM_C_O_R.y_pc_n);
            
            
            % Fit to eqn 3 of AERI paper
            
            Diff_Resp_fit_R.x = SPC_H_O_R.x;
            Diff_Resp_fit_R.y_raw_p = (SPC_H_O_R.y_raw_p - SPC_A_O_R.y_raw_p)./(BB_2 - BB_1) ...
                -(SPC_A_O_R.y_raw_p - SPC_C_O_R.y_raw_p)./(BB_1 - BB_0);
            Diff_Resp_fit_R.y_raw_n = (SPC_H_O_R.y_raw_n - SPC_A_O_R.y_raw_n)./(BB_2 - BB_1) ...
                -(SPC_A_O_R.y_raw_n - SPC_C_O_R.y_raw_n)./(BB_1 - BB_0);             
            Diff_Resp_fit_R.y_pc_p = (SPC_H_O_R.y_pc_p - SPC_A_O_R.y_pc_p)./(BB_2 - BB_1) ...
                -(SPC_A_O_R.y_pc_p - SPC_C_O_R.y_pc_p)./(BB_1 - BB_0);
            Diff_Resp_fit_R.y_pc_n = (SPC_H_O_R.y_pc_n - SPC_A_O_R.y_pc_n)./(BB_2 - BB_1) ...
                -(SPC_A_O_R.y_pc_n - SPC_C_O_R.y_pc_n)./(BB_1 - BB_0);

             
            a2_R_raw_p = -real(diff_resp_R) ./ real(Diff_Resp_fit_R.y_raw_p);
            a2_R_raw_n = -real(diff_resp_R) ./ real(Diff_Resp_fit_R.y_raw_n);            
            a2_R_pc_p = -real(diff_resp_R) ./ real(Diff_Resp_fit_R.y_pc_p);
            a2_R_pc_n = -real(diff_resp_R) ./ real(Diff_Resp_fit_R.y_pc_n);
            
            A2_R_raw_p(Run_number) = mean(a2_R_raw_p(sub));
            A2_R_pc_p(Run_number) = mean(a2_R_pc_p(sub));
            A2_R_raw_n(Run_number) = mean(a2_R_raw_n(sub));
            A2_R_pc_n(Run_number) = mean(a2_R_pc_n(sub));
            
            pos = trapz(Diff_Resp_fit_R.x(inband), abs(diff_resp_R(inband) + A2_R_raw_p(Run_number) .* Diff_Resp_fit_R.y_raw_p(inband)));
            neg = trapz(Diff_Resp_fit_R.x(inband), abs(diff_resp_R(inband) + A2_R_raw_n(Run_number) .* Diff_Resp_fit_R.y_raw_n(inband)));
            if pos<neg
               A2_R_raw(Run_number) = A2_R_raw_p(Run_number);
               Diff_Resp_fit_R.y_raw = Diff_Resp_fit_R.y_raw_p;
               A2_R_pc(Run_number) = A2_R_pc_p(Run_number);
               Diff_Resp_fit_R.y_pc = Diff_Resp_fit_R.y_pc_p;
               dpol_R(Run_number) = 1;
               % Also record zpd_raw and zpd_pc 
            else
               A2_R_raw(Run_number) = A2_R_raw_n(Run_number);
               Diff_Resp_fit_R.y_raw = Diff_Resp_fit_R.y_raw_n;
               A2_R_pc(Run_number) = A2_R_pc_n(Run_number);
               Diff_Resp_fit_R.y_pc = Diff_Resp_fit_R.y_pc_n;
               dpol_R(Run_number) = -1;               
            end
            
            %
                    figure(53);
                    plot(CalSet_AC_R.x, real(diff_resp_R)./1000, 'r.',CalSet_AC_R.x(sub), real(diff_resp_R(sub))./1000, 'c.')
                    hold('on')
                    plot(Diff_Resp_fit_R.x, real(-A2_R_raw_p(Run_number) * real(Diff_Resp_fit_R.y_raw_p))./1000, 'b-',...
                       Diff_Resp_fit_R.x, real(-A2_R_raw_n(Run_number) * real(Diff_Resp_fit_R.y_raw_n))./1000, 'r-',...
                       Diff_Resp_fit_R.x, real(-A2_R_raw(Run_number) * real(Diff_Resp_fit_R.y_raw))./1000, 'k:');
                    xlabel('Wavenumber [cm^{-1}]')
                    ylabel('R^{HA}-R^{AC} [cts/(mW/(m^2 sr cm^{-1}))]')
                    kk = find(Diff_Resp_fit_R.x >= range(1) & Diff_Resp_fit_R.x <= range(2));
                    ymin = 0.9*min([real(diff_resp_R(kk))./1000 real(-A2_R_raw(Run_number) * Diff_Resp_fit_R.y_raw(kk))./1000]);
                    ymax = 1.2*max([real(diff_resp_R(kk))./1000 real(-A2_R_raw(Run_number) * Diff_Resp_fit_R.y_raw(kk))./1000]);
                    axis([200 2400 ymin ymax]);
                    V = [IGM_H_R.Header.fdate.year,IGM_H_R.Header.fdate.month+1,IGM_H_R.Header.fdate.day+1];
                    title({['Detector ',Detector, ' raw ZPD'];...
                        [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Reverse']},'interp','none');
                    lg = legend('Measured','fitted'); set(lg,'interp','none');
            
                    hold('off')
                    txt_str = {sprintf('MF factor = %0.1f',MF);...
                        sprintf('LN2 emis factor = %0.3f',ef);...
                        sprintf('a2_R_raw = %2.3e',mean(A2_R_raw(Run_number)));...
                        sprintf('ZPD polarity = %1d',dpol_R(Run_number))};
                    txt_53 = text(mean(xlim), mean(ylim),txt_str);
                    set(txt_53,'unit','normalized','position',[.05,.95],'verticalalign','cap',...
                        'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
                        'fontname','Tahoma','fontweight','demi','backgroundcolor','w');
                    %
                    figure(54);
                    plot(CalSet_AC_R.x, real(diff_resp_R)./1000, 'r.',CalSet_AC_R.x(sub), real(diff_resp_R(sub))./1000, 'c.')
                    hold('on')
                    plot(Diff_Resp_fit_R.x, real(-A2_R_pc_p(Run_number) * real(Diff_Resp_fit_R.y_pc_p))./1000, 'b-',...
                       Diff_Resp_fit_R.x, real(-A2_R_pc_n(Run_number) * real(Diff_Resp_fit_R.y_pc_n))./1000, 'r-',...
                       Diff_Resp_fit_R.x, real(-A2_R_pc(Run_number) * real(Diff_Resp_fit_R.y_pc))./1000, 'k:');
                    xlabel('Wavenumber [cm^{-1}]')
                    ylabel('R^{HA}-R^{AC} [cts/(mW/(m^2 sr cm^{-1}))]')
                    kk = find(Diff_Resp_fit_R.x >= range(1) & Diff_Resp_fit_R.x <= range(2));
                    ymin = 0.9*min([real(diff_resp_R(kk))./1000 real(-A2_R_pc(Run_number) * Diff_Resp_fit_R.y_pc(kk))./1000]);
                    ymax = 1.2*max([real(diff_resp_R(kk))./1000 real(-A2_R_pc(Run_number) * Diff_Resp_fit_R.y_pc(kk))./1000]);
                    axis([200 2400 ymin ymax]);
                    V = [IGM_H_R.Header.fdate.year,IGM_H_R.Header.fdate.month+1,IGM_H_R.Header.fdate.day+1];
                    title({['Detector ',Detector, ' pc ZPD'];...
                        [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Reverse']},'interp','none');
                    lg = legend('Measured','fitted'); set(lg,'interp','none');
            
                    hold('off')
                    txt_str = {sprintf('MF factor = %0.1f',MF);...
                        sprintf('LN2 emis factor = %0.3f',ef);...
                        sprintf('a2_R_pc = %2.3e',mean(A2_R_pc(Run_number)));...
                        sprintf('ZPD polarity = %1d',dpol_R(Run_number))};
                    txt_54 = text(mean(xlim), mean(ylim),txt_str);
                    set(txt_54,'unit','normalized','position',[.05,.95],'verticalalign','cap',...
                        'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
                        'fontname','Tahoma','fontweight','demi','backgroundcolor','w');
%             
            Run{Run_number}.I_H_F_raw = I_H_F_raw(Run_number);
            Run{Run_number}.I_A_F_raw = I_A_F_raw(Run_number);
            Run{Run_number}.I_C_F_raw = I_C_F_raw(Run_number);
%             Run{Run_number}.V_H_F_raw = V_H_F_raw(Run_number);
%             Run{Run_number}.V_A_F_raw = V_A_F_raw(Run_number);
%             Run{Run_number}.V_C_F_raw = V_C_F_raw(Run_number);
            Run{Run_number}.A2_F_raw = A2_F_raw(Run_number);
            Run{Run_number}.dpol_F = dpol_F(Run_number);
            
            Run{Run_number}.I_H_F_pc = I_H_F_pc(Run_number);
            Run{Run_number}.I_A_F_pc = I_A_F_pc(Run_number);
            Run{Run_number}.I_C_F_pc = I_C_F_pc(Run_number);
%             Run{Run_number}.V_H_F_pc = V_H_F_pc(Run_number);
%             Run{Run_number}.V_A_F_pc = V_A_F_pc(Run_number);
%             Run{Run_number}.V_C_F_pc = V_C_F_pc(Run_number);
            Run{Run_number}.A2_F_pc = A2_F_pc(Run_number);
            
            
            Run{Run_number}.I_H_R_raw = I_H_R_raw(Run_number);
            Run{Run_number}.I_A_R_raw = I_A_R_raw(Run_number);
            Run{Run_number}.I_C_R_raw = I_C_R_raw(Run_number);
%             Run{Run_number}.V_H_R_raw = V_H_R_raw(Run_number);
%             Run{Run_number}.V_A_R_raw = V_A_R_raw(Run_number);
%             Run{Run_number}.V_C_R_raw = V_C_R_raw(Run_number);
            Run{Run_number}.A2_R_raw = A2_R_raw(Run_number);
            Run{Run_number}.dpol_R = dpol_R(Run_number);
            
            Run{Run_number}.I_H_R_pc = I_H_R_pc(Run_number);
            Run{Run_number}.I_A_R_pc = I_A_R_pc(Run_number);
            Run{Run_number}.I_C_R_pc = I_C_R_pc(Run_number);
%             Run{Run_number}.V_H_R_pc = V_H_R_pc(Run_number);
%             Run{Run_number}.V_A_R_pc = V_A_R_pc(Run_number);
%             Run{Run_number}.V_C_R_pc = V_C_R_pc(Run_number);
            Run{Run_number}.A2_R_pc = A2_R_pc(Run_number);
            %%
%             figure; sb(1) = subplot(2,1,1);
%             plot(SPC_H_F.x, SPC_H_F.y,'r-',SPC_A_F.x, SPC_A_F.y,'-g',SPC_C_F.x, SPC_C_F.y,'b-');
%             title(['Run: ',num2str(Run_number)]);
%             sb(2) = subplot(2,1,2);
%             plot(SPC_H_F.x, SPC_H_R.y,'r-',SPC_A_R.x, SPC_A_R.y,'-g',SPC_C_F.x, SPC_C_R.y,'b-');
%             linkaxes(sb,'xy');
%             xlim([1000,2000]);
        end
        figure(51);
        txt_str = {sprintf('a2_F_raw = %2.3e\n',mean(A2_F_raw));...
            sprintf('I_H_F_raw(lab) = %2.3e',mean(I_H_F_raw));...
            sprintf('I_A_F_raw(lab) = %2.3e',mean(I_A_F_raw));...
            sprintf('I_C_F_raw(lab) = %2.3e',mean(I_C_F_raw));...
            sprintf('ZPD polarity = %1d', mean(dpol_F))};
        delete(txt_51);
        txt_51 = text(mean(xlim), mean(ylim),txt_str);
        set(txt_51,'unit','normalized','position',[.05,.9],'verticalalign','cap',...
            'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
            'fontname','Tahoma','fontweight','demi','backgroundcolor','w');
        
        %     figure(52);
        %     txt_str = {sprintf('a2_F_pc = %2.3e\n',mean(A2_F_pc));...
        %         sprintf('I_H_F_pc(lab) = %2.3e',mean(I_H_F_pc));...
        %         sprintf('I_A_F_pc(lab) = %2.3e',mean(I_A_F_pc));...
        %         sprintf('I_C_F_pc(lab) = %2.3e',mean(I_C_F_pc))};
        %     delete(txt_52);
        %     txt_52 = text(mean(xlim), mean(ylim),txt_str);
        %     set(txt_52,'unit','normalized','position',[.05,.9],'verticalalign','cap',...
        %         'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
        %         'fontname','Tahoma','fontweight','demi','backgroundcolor','w');
        %
        %     figure(53);
        %     txt_str = {sprintf('a2_R_raw = %2.3e\n',mean(A2_R_raw));...
        %         sprintf('I_H_R_raw(lab) = %2.3e',mean(I_H_R_raw));...
        %         sprintf('I_A_R_raw(lab) = %2.3e',mean(I_A_R_raw));...
        %         sprintf('I_C_R_raw(lab) = %2.3e',mean(I_C_R_raw))};
        %     delete(txt_53);
        %     txt_53 = text(mean(xlim), mean(ylim),txt_str);
        %     set(txt_53,'unit','normalized','position',[.05,.9],'verticalalign','cap',...
        %         'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
        %         'fontname','Tahoma','fontweight','demi','backgroundcolor','w');
        %
        %     figure(54);
        %     txt_str = {sprintf('a2_R_pc = %2.3e\n',mean(A2_R_pc));...
        %         sprintf('I_H_R_pc(lab) = %2.3e',mean(I_H_R_pc));...
        %         sprintf('I_A_R_pc(lab) = %2.3e',mean(I_A_R_pc));...
        %         sprintf('I_C_R_pc(lab) = %2.3e',mean(I_C_R_pc))};
        %     delete(txt_54);
        %     txt_54 = text(mean(xlim), mean(ylim),txt_str);
        %     set(txt_54,'unit','normalized','position',[.05,.9],'verticalalign','cap',...
        %         'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
        %         'fontname','Tahoma','fontweight','demi','backgroundcolor','w');
        %
        %    end
        %%
        %     nlc.a2 =  -(4.625e-08 + 4.837e-08)./2;
        % nlc.IHLAB = (-1.838e+05 -1.806e+05)./2;
        % nlc.ICLAB = (3.062e+05 +3.025e+05)./2;
        test_time = datenum(IGM_H_F.Header.fdate.year, IGM_H_F.Header.fdate.month,IGM_H_F.Header.fdate.day, IGM_H_F.Header.fdate.hour, IGM_H_F.Header.fdate.minute,0);
        nlc_pc.type = 'phase-corrected';
        nlc_pc.time = test_time;
        nlc_pc.time_str = datestr(nlc_pc.time, 'yyyymmdd_HHMM');
        nlc_pc.a2_F = mean(A2_F_pc);
        nlc_pc.IHLAB_F = mean(I_H_F_pc);
        nlc_pc.ICLAB_F = mean(I_C_F_pc);
        nlc_pc.a2_R = mean(A2_R_pc);
        nlc_pc.IHLAB_R = mean(I_H_R_pc);
        nlc_pc.ICLAB_R = mean(I_C_R_pc);
        nlc_pc.a2 = (nlc_pc.a2_F + nlc_pc.a2_R)./2;
        nlc_pc.IHLAB = (nlc_pc.IHLAB_F + nlc_pc.IHLAB_R)./2;
        nlc_pc.ICLAB = (nlc_pc.ICLAB_F + nlc_pc.ICLAB_R)./2;
        
        nlc_raw.type = 'phase-corrected';
        nlc_raw.time = test_time;
        nlc_raw.time_str = datestr(nlc_raw.time, 'yyyymmdd_HHMM');
        nlc_raw.a2_F = mean(A2_F_raw);
        nlc_raw.IHLAB_F = mean(I_H_F_raw);
        nlc_raw.ICLAB_F = mean(I_C_F_raw);
        nlc_raw.a2_R = mean(A2_R_raw);
        nlc_raw.IHLAB_R = mean(I_H_R_raw);
        nlc_raw.ICLAB_R = mean(I_C_R_raw);
        nlc_raw.a2 = (nlc_raw.a2_F + nlc_raw.a2_R)./2;
        nlc_raw.IHLAB = (nlc_raw.IHLAB_F + nlc_raw.IHLAB_R)./2;
        nlc_raw.ICLAB = (nlc_raw.ICLAB_F + nlc_raw.ICLAB_R)./2;
        
        %     save([test_dir,filesep,'nlc_pc.',nlc_pc.time_str,'.mat'],'-struct','nlc_pc');
        %     save([test_dir,filesep,'nlc_raw.',nlc_raw.time_str,'.mat'],'-struct','nlc_raw');
        %     saveas(51, [test_dir,filesep,'nlc_F_raw.',nlc_raw.time_str,'.png']);
        %     saveas(52, [test_dir,filesep,'nlc_F_PC.',nlc_raw.time_str,'.png']);
        %     saveas(53, [test_dir,filesep,'nlc_R_raw.',nlc_raw.time_str,'.png']);
        %     saveas(54, [test_dir,filesep,'nlc_R_PC.',nlc_raw.time_str,'.png']);
        saveas(51, [test_dir,filesep,'nlc_F_raw.',nlc_raw.time_str,'.png']);
        saveas(51, [test_dir,filesep,'nlc_F_raw.',nlc_raw.time_str,'.pdf']);
        nlc_coefs = nlc_raw;
        
        %%
        figure(3)
        plot(1:Nb_of_Runs, A2_F_raw, '-*',1:Nb_of_Runs, A2_R_raw, '-o')
        xlabel('Run number')
        legend('Forward raw','Reverse raw')
        ylabel('Non-linearity correction parameter a_2')
        %%
    else
        disp(['Different numbers of ABB, HBB, and LN2 igm files.  Aborting!']);
    end
    
% catch
%     (err);
% end
close(h);
return
%%
