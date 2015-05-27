function nlc_coefs = NLC_FandR_fit_abs_Vdc
% This code is used to generate the NLC fitting parameters 
% V_C_F, V_H_F, V_A_F, V_C_R, V_H_R, V_A_R and the A_2 factor.
% This is implemented for two forms, one using the actual ifg intensity at ZPD
% And another via Dave Turner which uses the ifg corresponding to the
% absolute of the complex spectra.  Both are carried through for later
% comparison.  The older approach using the actual raw ifg intensity is
% captured in fields ending in _raw.  

% 2014_12_15: It is possible that we have a sign difference with respect to
% Vdc and the splitter detector vis-a-vis the sandwich detector.  This
% version assumes the form in the AERI paper #2.
range = [200 2100];
Detector = 'A';

test_dir = getdir('','assist_nlc','Select NLC test directory');
abbs = length(dir([test_dir,filesep,'ABB_*_A.igm']));
hbbs = length(dir([test_dir,filesep,'HBB_*_A.igm']));
ln2s = length(dir([test_dir,filesep,'LN2_*_A.igm']));

if abbs==hbbs && hbbs==ln2s
    
    Nb_of_Runs = abbs;
    
    a_2 = zeros(Nb_of_Runs, 1);
    T_ABB = zeros(Nb_of_Runs, 1);
    a_2_ = zeros(Nb_of_Runs, 1);
    for Run_number = Nb_of_Runs:-1:1
        display(['run number:', num2str(Run_number)])
        % NUMERIC =
        % xlsread('c:\matlab\work\myspreadsheet','sheet2','a2:j5')
        
        s = xlsread([test_dir,'HBB_' num2str(Run_number) '_ANN.xls']);
        [~,header] = xlsread([test_dir,'HBB_' num2str(Run_number) '_ANN.xls'],'Annotation','a2:cz2');
        HBB_col = strcmp(header,'Hot BB Mean');
        ABB_col=  strcmp(header,'Cold BB Mean');
        
        T_HBB(Run_number) = 273.15 + mean(s(:, HBB_col));
        s = xlsread([test_dir,'ABB_' num2str(Run_number) '_ANN.xls']);
        T_ABB(Run_number) = 273.15 + mean(s(:, ABB_col));
        T_CBB = 77;
        
        MaxNbScansCalib = -1;
        MaxNbScansScene = -1;
        
        fileName = [test_dir,'HBB_' num2str(Run_number) '_' Detector '.igm'];
        DataHBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
        [ForwardHBB, ReverseHBB] = SplitDirections(DataHBB);
        
        IGM_H_F.Header = ForwardHBB.Header;
        IGM_H_F.x = ForwardHBB.x;
        IGM_H_F.y = mean(ForwardHBB.y, 1);
        IGM_H_R.Header = ReverseHBB.Header;
        IGM_H_R.x = ReverseHBB.x;
        IGM_H_R.y = mean(ReverseHBB.y, 1);
        
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
        
        %          clear DataCBB ForwardCBB ReverseCBB
        
        % First determine zpd from HBB
        
        %          [IGM_H_F.y, IGM_H_F.Idc] = lead_zpd(IGM_H_F.y, IGM_H_F.x);
        zpd_shift_H_F = find_zpd_xcorr(IGM_H_F.y);
        zpd_shift_A_F = find_zpd_xcorr(IGM_A_F.y);
        zpd_shift_C_F = find_zpd_xcorr(IGM_C_F.y);
        %
        % Shift igms
        IGM_H_F.y =  sideshift(IGM_H_F.x,IGM_H_F.y, zpd_shift_H_F);
        IGM_A_F.y =  sideshift(IGM_A_F.x,IGM_A_F.y, zpd_shift_H_F);
        IGM_C_F.y =  sideshift(IGM_C_F.x,IGM_C_F.y, zpd_shift_H_F);
        
        % Compute fft
        [SPC_H_F.x,SPC_H_F.y,SPC_H_F.Idc,SPC_H_F.Idc_raw] = ShiftIgm2RawSpc(IGM_H_F.x,IGM_H_F.y);
        [SPC_A_F.x,SPC_A_F.y,SPC_A_F.Idc,SPC_A_F.Idc_raw] = ShiftIgm2RawSpc(IGM_A_F.x,IGM_A_F.y);
        [SPC_C_F.x,SPC_C_F.y,SPC_C_F.Idc,SPC_C_F.Idc_raw] = ShiftIgm2RawSpc(IGM_C_F.x,IGM_C_F.y);
        
        CalSet_HA_F = CreateCalibrationFromCXS_(SPC_H_F, T_HBB(Run_number), SPC_A_F, T_ABB(Run_number));
        CalSet_AC_F = CreateCalibrationFromCXS_(SPC_A_F, T_ABB(Run_number),SPC_C_F, T_CBB);  
        diff_resp_F = CalSet_HA_F.Resp - CalSet_AC_F.Resp;
        % Ideally, these calibrations should be identical but due to
        % non-linearity there will be differences.
        % V_H = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_H);
        % V_A = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_A);
        % V_C = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_C);
        %          nlc_h = (1+2.*a_2(Run_number).*V_H);
        %          nlc_a = (1+2.*a_2(Run_number).*V_A);
        %          nlc_c = (1+2.*a_2(Run_number).*V_C);
        
        %%
        MF  =0.7;
        f_back = 1;
        
        I_H_F = SPC_H_F.Idc; % ala D Turner
        I_A_F = SPC_A_F.Idc; % ala D Turner
        I_C_F = SPC_C_F.Idc; % ala D Turner
        I_H_F_raw = SPC_H_F.Idc_raw; 
        I_A_F_raw = SPC_A_F.Idc_raw; 
        I_C_F_raw = SPC_C_F.Idc_raw; 
        
        % Modeled DC offset (this could be replaced with ASSIST chA DC
        V_F = (-1/MF) * ((2 + f_back)*(-I_C_F));
        V_H_F = (-1/MF) * ((2 + f_back)*(-I_H_F + I_H_F -I_C_F) + I_H_F);
        V_A_F = (-1/MF) * ((2 + f_back)*(-I_H_F + I_H_F -I_C_F) + I_A_F);
        V_C_F = (-1/MF) * ((2 + f_back)*(-I_H_F + I_H_F -I_C_F) + I_C_F);
        V_F_raw = (-1/MF) * ((2 + f_back)*(-I_C_F_raw));
        V_H_F_raw = (-1/MF) * ((2 + f_back)*(-I_H_F_raw + I_H_F_raw -I_C_F_raw) + I_H_F_raw);
        V_A_F_raw = (-1/MF) * ((2 + f_back)*(-I_H_F_raw + I_H_F_raw -I_C_F_raw) + I_A_F_raw);
        V_C_F_raw = (-1/MF) * ((2 + f_back)*(-I_H_F_raw + I_H_F_raw -I_C_F_raw) + I_C_F_raw);        
        
        %%
        % The following is pure math, for the non-linearity expanded to the quadratic term.
        % Basically pure math but incorporates modeled V_DC
        IGM_H_O_F.Header = IGM_H_F.Header;
        IGM_H_O_F.x = IGM_H_F.x;
        IGM_H_O_F.y = (IGM_H_F.y + V_H_F).^2; % this should be the full "true" igm
        IGM_H_O_F.y_raw = (IGM_H_F.y + V_H_F_raw).^2; % this should be the full "true" igm
        IGM_H_O_F.y2 = (IGM_H_F.y).^2; % this is only the I^2 portion 
        IGM_A_O_F.Header = IGM_A_F.Header;
        IGM_A_O_F.x = IGM_A_F.x;
        IGM_A_O_F.y = (IGM_A_F.y + V_A_F).^2;
        IGM_A_O_F.y_raw = (IGM_A_F.y + V_A_F_raw).^2;
        IGM_A_O_F.y2 = (IGM_A_F.y).^2;
        IGM_C_O_F.Header = IGM_C_F.Header;
        IGM_C_O_F.x = IGM_C_F.x;
        IGM_C_O_F.y = (IGM_C_F.y + V_C_F).^2;
        IGM_C_O_F.y_raw = (IGM_C_F.y + V_C_F_raw).^2;
        IGM_C_O_F.y2 = (IGM_C_F.y).^2;
        
        [SPC_H_O_F.x,SPC_H_O_F.y] = ShiftIgm2RawSpc(IGM_H_O_F.x,IGM_H_O_F.y);
        [SPC_A_O_F.x,SPC_A_O_F.y] = ShiftIgm2RawSpc(IGM_A_O_F.x,IGM_A_O_F.y);
        [SPC_C_O_F.x,SPC_C_O_F.y] = ShiftIgm2RawSpc(IGM_C_O_F.x,IGM_C_O_F.y);
        [SPC_H_O_F.x,SPC_H_O_F.y_raw] = ShiftIgm2RawSpc(IGM_H_O_F.x,IGM_H_O_F.y_raw);
        [SPC_A_O_F.x,SPC_A_O_F.y_raw] = ShiftIgm2RawSpc(IGM_A_O_F.x,IGM_A_O_F.y_raw);
        [SPC_C_O_F.x,SPC_C_O_F.y_raw] = ShiftIgm2RawSpc(IGM_C_O_F.x,IGM_C_O_F.y_raw);
        [~,SPC_H_O_F.y2] = ShiftIgm2RawSpc(IGM_H_O_F.x,IGM_H_O_F.y2);
        [~,SPC_A_O_F.y2] = ShiftIgm2RawSpc(IGM_A_O_F.x,IGM_A_O_F.y2);
        [~,SPC_C_O_F.y2] = ShiftIgm2RawSpc(IGM_C_O_F.x,IGM_C_O_F.y2);
        
% Looking at alternative to computing A2 based on fact that true spectra
% should have zero out of band signal, forcing the linear and quadratic
% components to cancel.  Seems to work, but no advantage over SSEC approach
        %         A_2_new = -SPC_H_F.y ./(2.*SPC_H_F.Idc +  SPC_H_O_F.y2);
%         figure; plot(SPC_H_F.x(2:end), A_2_new(2:end),'-');
%         legend('A_2 new');
%         xlim(range);
        % Fit to eqn 3 of AERI paper
        Diff_Resp_fit_F.x = SPC_H_O_F.x;
        Diff_Resp_fit_F.y = (SPC_H_O_F.y - SPC_A_O_F.y)./...
            (Blackbody(SPC_H_O_F.x, T_HBB(Run_number)) - Blackbody(SPC_H_O_F.x, T_ABB(Run_number)))...
            -(SPC_A_O_F.y - SPC_C_O_F.y)./...
            (Blackbody(SPC_H_O_F.x, T_ABB(Run_number)) - Blackbody(SPC_H_O_F.x, T_CBB));
        Diff_Resp_fit_F.y_raw = (SPC_H_O_F.y_raw - SPC_A_O_F.y_raw)./...
            (Blackbody(SPC_H_O_F.x, T_HBB(Run_number)) - Blackbody(SPC_H_O_F.x, T_ABB(Run_number)))...
            -(SPC_A_O_F.y_raw - SPC_C_O_F.y_raw)./...
            (Blackbody(SPC_H_O_F.x, T_ABB(Run_number)) - Blackbody(SPC_H_O_F.x, T_CBB));
                                
%         kk = find(Diff_Resp_fit_F.x >= 260 & Diff_Resp_fit_F.x <= 360);
%         sub1 = (CalSet_HA_F.x>320&CalSet_HA_F.x<470);
        sub2 = (CalSet_HA_F.x>1850&CalSet_HA_F.x<2450);
%         sub = sub1 | sub2;
        % Option 1 - Ratio of real parts
%         a_2_tmp_F = real(CalSet_HA_F.Resp - CalSet_AC_F.Resp) ./ real(Diff_Resp_fit_F.y);
%         % Option 2 - Real part of ratio
%         a_2_tmp_F_ = real((CalSet_HA_F.Resp - CalSet_AC_F.Resp) ./ Diff_Resp_fit_F.y);
%         a_2_tmp_F__ = abs(CalSet_HA_F.Resp - CalSet_AC_F.Resp) ./ abs(Diff_Resp_fit_F.y);
%         a_2_tmp_F__ = a_2_tmp_F__ .* abs(a_2_tmp_F)./a_2_tmp_F;
        
        %computing A_2 using FT of I^2 
        a_3_tmp_F = real(CalSet_HA_F.Resp - CalSet_AC_F.Resp) ./ real(Diff_Resp_fit_F.y);
        a_3_tmp_F_raw = real(CalSet_HA_F.Resp - CalSet_AC_F.Resp) ./ real(Diff_Resp_fit_F.y_raw);
        % Option 2 - Real part of ratio
%         a_3_tmp_F_ = real((CalSet_HA_F.Resp - CalSet_AC_F.Resp) ./ Diff_Resp_fit_F.y2);
%         a_3_tmp_F__ = abs(CalSet_HA_F.Resp - CalSet_AC_F.Resp) ./ abs(Diff_Resp_fit_F.y2);
%         a_3_tmp_F__ = a_3_tmp_F__ .* abs(a_3_tmp_F)./a_3_tmp_F;
%         figure; plot(CalSet_HA_F.x, a_2_tmp_F, 'r.',CalSet_HA_F.x, a_2_tmp_F_, 'b.',CalSet_HA_F.x, a_2_tmp_F__, 'k.' )
%         legend('ratio of real parts','real of ratio', 'ratio of magnitudes')
        
        % k, 1, 2, 3 denote different ranges used to compute an average A2.
        % underbars denote whether A2 is computed from ratio of reals, real
        % of ratio, or ratio of magnitudes
%         a_2_F_k(Run_number) = mean(a_2_tmp_F(kk));
%         a_2_F_k_(Run_number) = mean(a_2_tmp_F_(kk));
%         a_2_F_k__(Run_number) = mean(a_2_tmp_F__(kk));
%         a_2_F_1(Run_number) = mean(a_2_tmp_F(sub1));
%         a_2_F_1_(Run_number) = mean(a_2_tmp_F_(sub1));
%         a_2_F_1__(Run_number) = mean(a_2_tmp_F__(sub1));
%         a_2_F_2(Run_number) = mean(a_2_tmp_F(sub2));
%         a_2_F_2_(Run_number) = mean(a_2_tmp_F_(sub2));
%         a_2_F_2__(Run_number) = mean(a_2_tmp_F__(sub2));
%         a_2_F_3(Run_number) = mean(a_2_tmp_F(sub));
%         a_2_F_3_(Run_number) = mean(a_2_tmp_F_(sub));
%         a_2_F_3__(Run_number) = mean(a_2_tmp_F__(sub));

%         a_3_F_k = mean(a_3_tmp_F(kk));
%         a_3_F_k_ = mean(a_3_tmp_F_(kk));
%         a_3_F_k__ = mean(a_3_tmp_F__(kk));
%         a_3_F_1 = mean(a_3_tmp_F(sub1));
%         a_3_F_1_ = mean(a_3_tmp_F_(sub1));
%         a_3_F_1__ = mean(a_3_tmp_F__(sub1));
        a_3_F_2(Run_number) = mean(a_3_tmp_F(sub2));
                a_3_F_2_raw(Run_number) = mean(a_3_tmp_F_raw(sub2));
%         a_3_F_2(Run_number) = mean(a_3_tmp_F(sub2));
%         a_3_F_2_ = mean(a_3_tmp_F_(sub2));
%         a_3_F_2__ = mean(a_3_tmp_F__(sub2));
%         a_3_F_3 = mean(a_3_tmp_F(sub));
%         a_3_F_3_ = mean(a_3_tmp_F_(sub));
%         a_3_F_3__ = mean(a_3_tmp_F__(sub));
        %%
%  As = [a_2_F_k(4) a_2_F_k_(4) a_2_F_k__(4) a_2_F_1(4) a_2_F_1_(4) a_2_F_1__(4) a_2_F_2(4) a_2_F_2_(4) a_2_F_2__(4) a_2_F_3(4) a_2_F_3_(4) a_2_F_3__(4);
%         a_3_F_k a_3_F_k_ a_3_F_k__ a_3_F_1 a_3_F_1_ a_3_F_1__ a_3_F_2 a_3_F_2_ a_3_F_2__ a_3_F_3 a_3_F_3_ a_3_F_3__]'
%         figure; 

a2_F(Run_number) = a_3_F_2(Run_number);
a2_F_raw(Run_number) = a_3_F_2_raw(Run_number);

Run{Run_number}.I_H_F_raw = I_H_F_raw;
Run{Run_number}.I_A_F_raw = I_A_F_raw;
Run{Run_number}.I_C_F_raw = I_C_F_raw;
Run{Run_number}.V_H_F_raw = V_H_F_raw;
Run{Run_number}.V_A_F_raw = V_A_F_raw;
Run{Run_number}.V_C_F_raw = V_C_F_raw;
Run{Run_number}.a2_F_raw = a2_F_raw(Run_number);

Run{Run_number}.I_H_F = I_H_F;
Run{Run_number}.I_A_F = I_A_F;
Run{Run_number}.I_C_F = I_C_F;
Run{Run_number}.V_H_F = V_H_F;
Run{Run_number}.V_A_F = V_A_F;
Run{Run_number}.V_C_F = V_C_F;
Run{Run_number}.a2_F = a2_F(Run_number);







%         plot(CalSet_HA_F.x, real([CalSet_HA_F.Resp; CalSet_AC_F.Resp]),'-');
%         legend('HA Resp','AC Resp');
%         title('Forward scans')
%         sx(2) = subplot(2,1,2);
%         plot(CalSet_HA_F.x, real([Diff_Resp_fit_F.y]),'-');
%         legend('Diff R fit');
%         linkaxes(sx,'x');
%         zoom('on');
        %%
                figure(50);
        plot(CalSet_AC_F.x, real(diff_resp_F), 'r.')
        hold('on')
        %plot(CalSet_AC.x, imag(diff_gains), 'g-')
        %       lines = plot(Diff_Resp_fit.x, real(a_2(Run_number) * Diff_Resp_fit.y), 'r-', Diff_Resp_fit.x, real(a_2_(Run_number) * Diff_Resp_fit.y), 'k-')
        plot(Diff_Resp_fit_F.x, real(a2_F(Run_number) * Diff_Resp_fit_F.y), '-',...
            Diff_Resp_fit_F.x, real(a2_F_raw(Run_number) * Diff_Resp_fit_F.y_raw), '-');
        %plot(Diff_Resp_fit.x, imag(a_2(Run_number) * Diff_Resp_fit.y), 'c-')
        xlabel('Wavenumber [cm^{-1}]')
        ylabel('R^{HA} - R^{AC} [Counts/(W/(m^2 sr cm^{-1}))]')
        kk = find(Diff_Resp_fit_F.x >= range(1) & Diff_Resp_fit_F.x <= range(2));
        ymin = 1.2*min([real(diff_resp_F(kk)) imag(diff_resp_F(kk)) ...
            real(a2_F(Run_number) * Diff_Resp_fit_F.y(kk)) ...
            imag(a2_F(Run_number) * Diff_Resp_fit_F.y(kk))]);
        ymax = 1.2*max([real(diff_resp_F(kk)) imag(diff_resp_F(kk)) ...
            real(a2_F(Run_number) * Diff_Resp_fit_F.y(kk)) ...
            imag(a2_F(Run_number) * Diff_Resp_fit_F.y(kk))]);
        axis([320 2400 ymin ymax]);
        V = [IGM_H_F.Header.fdate.year,IGM_H_F.Header.fdate.month+1,IGM_H_F.Header.fdate.day+1];
        title({['Diff between Re(Hot_Resp/Amb_resp)- Re(Amb_resp/LN2_resp)'];
            [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Forward']},'interp','none');
        %legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
        %       legend('Measured',sprintf('a2 = %2.3e',a_2(Run_number)),
        %       sprintf('(2nd) %2.3e',a_2_(Run_number)));
        lg = legend('Measured','fitted','fitted_raw_zpd'); set(lg,'interp','none');
        
%         figure
%         plot(CalSet_HA_F.x, 1e-3*abs(CalSet_HA_F.Resp), 'b-')
%         xlabel('Wavenumber [cm^{-1}]')
%         ylabel('|R^{HA}| [Counts/(mW/(m^2 sr cm^{-1}))]')
%         mm = find(Diff_Resp_fit_F.x >= range(1) & Diff_Resp_fit_F.x <= range(2));
%         axis([range(1) range(2) 0 1.2e-3*max(abs(CalSet_HA_F.Resp(mm)))])
        %%
        % Now do reverse scan...
        zpd_shift_H_R = find_zpd_xcorr(IGM_H_R.y);
        zpd_shift_A_R = find_zpd_xcorr(IGM_A_R.y);
        zpd_shift_C_R = find_zpd_xcorr(IGM_C_R.y);

        IGM_H_R.y =  sideshift(IGM_H_R.x,IGM_H_R.y, zpd_shift_H_R);
        IGM_A_R.y =  sideshift(IGM_A_R.x,IGM_A_R.y, zpd_shift_H_R);
        IGM_C_R.y =  sideshift(IGM_C_R.x,IGM_C_R.y, zpd_shift_H_R);

        [SPC_H_R.x,SPC_H_R.y,SPC_H_R.Idc,SPC_H_R.Idc_raw] = ShiftIgm2RawSpc(IGM_H_R.x,IGM_H_R.y);
        [SPC_A_R.x,SPC_A_R.y,SPC_A_R.Idc,SPC_A_R.Idc_raw] = ShiftIgm2RawSpc(IGM_A_R.x,IGM_A_R.y);
        [SPC_C_R.x,SPC_C_R.y,SPC_C_R.Idc,SPC_C_R.Idc_raw] = ShiftIgm2RawSpc(IGM_C_R.x,IGM_C_R.y);
        
        CalSet_HA_R = CreateCalibrationFromCXS_(SPC_H_R, T_HBB(Run_number), SPC_A_R, T_ABB(Run_number));
        CalSet_AC_R = CreateCalibrationFromCXS_(SPC_A_R, T_ABB(Run_number),SPC_C_R, T_CBB);  
        diff_resp_R = CalSet_HA_R.Resp - CalSet_AC_R.Resp;
        %%
        MF  =0.7;
        f_back = 1;

        I_H_R = SPC_H_R.Idc; % ala D Turner
        I_A_R = SPC_A_R.Idc; % ala D Turner
        I_C_R = SPC_C_R.Idc; % ala D Turner
        I_H_R_raw = SPC_H_R.Idc_raw; % ala D Turner
        I_A_R_raw = SPC_A_R.Idc_raw; % ala D Turner
        I_C_R_raw = SPC_C_R.Idc_raw; % ala D Turner
        
        % Modeled DC offset (this could be replaced with ASSIST chA DC
        V_R = (-1/MF) * ((2 + f_back)*(-I_C_R));
        V_H_R = (-1/MF) * ((2 + f_back)*(-I_H_R + I_H_R -I_C_R) + I_H_R);
        V_A_R = (-1/MF) * ((2 + f_back)*(-I_H_R + I_H_R -I_C_R) + I_A_R);
        V_C_R = (-1/MF) * ((2 + f_back)*(-I_H_R + I_H_R -I_C_R) + I_C_R);
        
        V_R_raw = (-1/MF) * ((2 + f_back)*(-I_C_R_raw));
        V_H_R_raw = (-1/MF) * ((2 + f_back)*(-I_H_R_raw + I_H_R_raw -I_C_R_raw) + I_H_R_raw);
        V_A_R_raw = (-1/MF) * ((2 + f_back)*(-I_H_R_raw + I_H_R_raw -I_C_R_raw) + I_A_R_raw);
        V_C_R_raw = (-1/MF) * ((2 + f_back)*(-I_H_R_raw + I_H_R_raw -I_C_R_raw) + I_C_R_raw);        

        IGM_H_O_R.Header = IGM_H_R.Header;
        IGM_H_O_R.x = IGM_H_R.x;
        IGM_H_O_R.y = (IGM_H_R.y + V_H_R).^2; % this should be the full "true" igm
        IGM_H_O_R.y_raw = (IGM_H_R.y + V_H_R_raw).^2; % this should be the full "true" igm
        IGM_H_O_R.y2 = (IGM_H_R.y).^2; % this is only the I^2 portion 
        IGM_A_O_R.Header = IGM_A_R.Header;
        IGM_A_O_R.x = IGM_A_R.x;
        IGM_A_O_R.y = (IGM_A_R.y + V_A_R).^2;
        IGM_A_O_R.y_raw = (IGM_A_R.y + V_A_R_raw).^2;
        IGM_A_O_R.y2 = (IGM_A_R.y).^2;
        IGM_C_O_R.Header = IGM_C_R.Header;
        IGM_C_O_R.x = IGM_C_R.x;
        IGM_C_O_R.y = (IGM_C_R.y + V_C_R).^2;
        IGM_C_O_R.y_raw = (IGM_C_R.y + V_C_R_raw).^2;
        IGM_C_O_R.y2 = (IGM_C_R.y).^2;
        
        [SPC_H_O_R.x,SPC_H_O_R.y] = ShiftIgm2RawSpc(IGM_H_O_R.x,IGM_H_O_R.y);
        [SPC_A_O_R.x,SPC_A_O_R.y] = ShiftIgm2RawSpc(IGM_A_O_R.x,IGM_A_O_R.y);
        [SPC_C_O_R.x,SPC_C_O_R.y] = ShiftIgm2RawSpc(IGM_C_O_R.x,IGM_C_O_R.y);
        [SPC_H_O_R.x,SPC_H_O_R.y_raw] = ShiftIgm2RawSpc(IGM_H_O_R.x,IGM_H_O_R.y_raw);
        [SPC_A_O_R.x,SPC_A_O_R.y_raw] = ShiftIgm2RawSpc(IGM_A_O_R.x,IGM_A_O_R.y_raw);
        [SPC_C_O_R.x,SPC_C_O_R.y_raw] = ShiftIgm2RawSpc(IGM_C_O_R.x,IGM_C_O_R.y_raw);
        [~,SPC_H_O_R.y2] = ShiftIgm2RawSpc(IGM_H_O_R.x,IGM_H_O_R.y2);
        [~,SPC_A_O_R.y2] = ShiftIgm2RawSpc(IGM_A_O_R.x,IGM_A_O_R.y2);
        [~,SPC_C_O_R.y2] = ShiftIgm2RawSpc(IGM_C_O_R.x,IGM_C_O_R.y2);

        
        Diff_Resp_fit_R.x = SPC_H_O_R.x;
        Diff_Resp_fit_R.y = (SPC_H_O_R.y - SPC_A_O_R.y)./...
            (Blackbody(SPC_H_O_R.x, T_HBB(Run_number)) - Blackbody(SPC_H_O_R.x, T_ABB(Run_number)))...
            -(SPC_A_O_R.y - SPC_C_O_R.y)./...
            (Blackbody(SPC_H_O_R.x, T_ABB(Run_number)) - Blackbody(SPC_H_O_R.x, T_CBB));
        Diff_Resp_fit_R.y_raw = (SPC_H_O_R.y_raw - SPC_A_O_R.y_raw)./...
            (Blackbody(SPC_H_O_R.x, T_HBB(Run_number)) - Blackbody(SPC_H_O_R.x, T_ABB(Run_number)))...
            -(SPC_A_O_R.y_raw - SPC_C_O_R.y_raw)./...
            (Blackbody(SPC_H_O_R.x, T_ABB(Run_number)) - Blackbody(SPC_H_O_R.x, T_CBB));        

        a_3_tmp_R = real(CalSet_HA_R.Resp - CalSet_AC_R.Resp) ./ real(Diff_Resp_fit_R.y);
        a_3_R_2(Run_number) = mean(a_3_tmp_R(sub2));
a2_R(Run_number) = a_3_R_2(Run_number);
        a_3_tmp_R_raw = real(CalSet_HA_R.Resp - CalSet_AC_R.Resp) ./ real(Diff_Resp_fit_R.y_raw);
        a_3_R_2_raw(Run_number) = mean(a_3_tmp_R_raw(sub2));
a2_R_raw(Run_number) = a_3_R_2_raw(Run_number);


Run{Run_number}.I_H_R_raw = I_H_R_raw;
Run{Run_number}.I_A_R_raw = I_A_R_raw;
Run{Run_number}.I_C_R_raw = I_C_R_raw;
Run{Run_number}.V_H_R_raw = V_H_R_raw;
Run{Run_number}.V_A_R_raw = V_A_R_raw;
Run{Run_number}.V_C_R_raw = V_C_R_raw;
Run{Run_number}.a2_R_raw = a2_R_raw(Run_number);

Run{Run_number}.I_H_R = I_H_R;
Run{Run_number}.I_A_R = I_A_R;
Run{Run_number}.I_C_R = I_C_R;
Run{Run_number}.V_H_R = V_H_R;
Run{Run_number}.V_A_R = V_A_R;
Run{Run_number}.V_C_R = V_C_R;
Run{Run_number}.a2_R = a2_R(Run_number);

%         figure(51);
%         plot(CalSet_AC_R.x, real(diff_resp_R), 'r.')
%         hold('on')
%         %plot(CalSet_AC.x, imag(diff_gains), 'g-')
%         %       lines = plot(Diff_Resp_fit.x, real(a_2(Run_number) * Diff_Resp_fit.y), 'r-', Diff_Resp_fit.x, real(a_2_(Run_number) * Diff_Resp_fit.y), 'k-')
%         plot(Diff_Resp_fit_R.x, real(a2_R(Run_number) * Diff_Resp_fit_R.y), '-');
%         %plot(Diff_Resp_fit.x, imag(a_2(Run_number) * Diff_Resp_fit.y), 'c-')
%         xlabel('Wavenumber [cm^{-1}]')
%         ylabel('R^{HA} - R^{AC} [Counts/(W/(m^2 sr cm^{-1}))]')
%         kk = find(Diff_Resp_fit_R.x >= range(1) & Diff_Resp_fit_R.x <= range(2));
%         ymin = 1.2*min([real(diff_resp_R(kk)) imag(diff_resp_R(kk)) ...
%             real(a2_R(Run_number) * Diff_Resp_fit_R.y(kk)) ...
%             imag(a2_R(Run_number) * Diff_Resp_fit_R.y(kk))]);
%         ymax = 1.2*max([real(diff_resp_R(kk)) imag(diff_resp_R(kk)) ...
%             real(a2_R(Run_number) * Diff_Resp_fit_R.y(kk)) ...
%             imag(a2_R(Run_number) * Diff_Resp_fit_R.y(kk))]);
%         axis([320 2400 ymin ymax]);
%         V = [IGM_H_R.Header.fdate.year,IGM_H_R.Header.fdate.month+1,IGM_H_R.Header.fdate.day+1];
%         title({['Diff between Re(Hot_Resp/Amb_resp)- Re(Amb_resp/LN2_resp) Forward scans'];
%             [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Forward']},'interp','none');
%         legend('Measured','fitted');

        figure(55);
        plot(CalSet_AC_R.x, real(diff_resp_R), 'r.')
        hold('on')
        %plot(CalSet_AC.x, imag(diff_gains), 'g-')
        %       lines = plot(Diff_Resp_fit.x, real(a_2(Run_number) * Diff_Resp_fit.y), 'r-', Diff_Resp_fit.x, real(a_2_(Run_number) * Diff_Resp_fit.y), 'k-')
        plot(Diff_Resp_fit_R.x, real(a2_R(Run_number) * Diff_Resp_fit_R.y), '-',...
            Diff_Resp_fit_R.x, real(a2_R_raw(Run_number) * Diff_Resp_fit_R.y_raw), '-');
        %plot(Diff_Resp_fit.x, imag(a_2(Run_number) * Diff_Resp_fit.y), 'c-')
        xlabel('Wavenumber [cm^{-1}]')
        ylabel('R^{HA} - R^{AC} [Counts/(W/(m^2 sr cm^{-1}))]')
        kk = find(Diff_Resp_fit_R.x >= range(1) & Diff_Resp_fit_R.x <= range(2));
        ymin = 1.2*min([real(diff_resp_R(kk)) imag(diff_resp_R(kk)) ...
            real(a2_R(Run_number) * Diff_Resp_fit_R.y(kk)) ...
            imag(a2_R(Run_number) * Diff_Resp_fit_R.y(kk))]);
        ymax = 1.2*max([real(diff_resp_R(kk)) imag(diff_resp_R(kk)) ...
            real(a2_R(Run_number) * Diff_Resp_fit_R.y(kk)) ...
            imag(a2_R(Run_number) * Diff_Resp_fit_R.y(kk))]);
        axis([320 2400 ymin ymax]);
        V = [IGM_H_R.Header.fdate.year,IGM_H_R.Header.fdate.month+1,IGM_H_R.Header.fdate.day+1];
        title({['Diff between Re(Hot_Resp/Amb_resp)- Re(Amb_resp/LN2_resp)'];
            [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Reverse']},'interp','none');
        %legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
        %       legend('Measured',sprintf('a2 = %2.3e',a_2(Run_number)),
        %       sprintf('(2nd) %2.3e',a_2_(Run_number)));
        lg = legend('Measured','fitted','fit_raw_zpd'); set(lg,'interp','none');
%         figure
%         plot(CalSet_HA_R.x, 1e-3*abs(CalSet_HA_R.Resp), 'b-')
%         xlabel('Wavenumber [cm^{-1}]')
%         ylabel('|R^{HA}| [Counts/(mW/(m^2 sr cm^{-1}))]')
%         mm = find(Diff_Resp_fit_R.x >= range(1) & Diff_Resp_fit_R.x <= range(2));
%         axis([range(1) range(2) 0 1.2e-3*max(abs(CalSet_HA_R.Resp(mm)))])
    end
    figure(50);
    
    txt_str = {[sprintf('a2 = %2.3e \n',a2_F)]; sprintf('Mean = %2.3e',mean(a2_F))};
    txt = text(mean(xlim), mean(ylim),txt_str);
    set(txt,'unit','normalized','position',[.1,.8],'edgecolor',[0,.7,0],'color',[0,.7,0]);
    txt_str = {[sprintf('a2_raw = %2.3e \n',a2_F_raw)]; sprintf('Mean = %2.3e',mean(a2_F_raw))};
    txt = text(mean(xlim), mean(ylim),txt_str);
    set(txt,'unit','normalized','position',[.7,.1],'edgecolor',[0,.7,0],'color',[0,.7,0], 'interp','none');
    figure(55);
%     txt = text(mean(xlim), mean(ylim),sprintf('a2 = %2.3e \n',a2_R));
    txt_str = {[sprintf('a2 = %2.3e \n',a2_R)]; sprintf('Mean = %2.3e',mean(a2_R))};
    txt = text(mean(xlim), mean(ylim),txt_str);
    set(txt,'unit','normalized','position',[.1,.8],'edgecolor',[0,.7,0],'color',[0,.7,0]);
    txt_str = {[sprintf('a2_raw = %2.3e \n',a2_R_raw)]; sprintf('Mean = %2.3e',mean(a2_R_raw))};
    txt = text(mean(xlim), mean(ylim),txt_str);
    set(txt,'unit','normalized','position',[.7,.1],'edgecolor',[0,.7,0],'color',[0,.7,0],'interp','none');
    %    saveas(2,[test_dir,'NLC_fit.',datestr(V,'yyyymmdd'),'.',char(Direction),'.png']);   
    %    end
    %%
    figure(3)
    plot(1:Nb_of_Runs, a2_F, '-*',1:Nb_of_Runs, a2_R, '-o',1:Nb_of_Runs, a2_F_raw, '-*',1:Nb_of_Runs, a2_R_raw, '-o')
    xlabel('Run number')
    legend('Forward','Reverse','Forward raw','Reverse raw')
    ylabel('Non-linearity correction parameter a_2')
    %%
else
    disp(['Different numbers of ABB, HBB, and LN2 igm files.  Aborting!']);
end

sprintf('%6.6f',(+Run{1}.I_H_F_raw+Run{1}.I_H_R_raw+Run{2}.I_H_F_raw+Run{2}.I_H_R_raw+Run{3}.I_H_F_raw+Run{3}.I_H_R_raw+Run{4}.I_H_F_raw+Run{4}.I_H_R_raw)./8)
sprintf('%6.6f',(+Run{1}.I_H_F+Run{1}.I_H_R+Run{2}.I_H_F+Run{2}.I_H_R+Run{3}.I_H_F+Run{3}.I_H_R+Run{4}.I_H_F+Run{4}.I_H_R)./8)

sprintf('%6.6f',(+Run{1}.I_C_F_raw+Run{1}.I_C_R_raw+Run{2}.I_C_F_raw+Run{2}.I_C_R_raw+Run{3}.I_C_F_raw+Run{3}.I_C_R_raw+Run{4}.I_C_F_raw+Run{4}.I_C_R_raw)./8)
sprintf('%6.6f',(+Run{1}.I_C_F+Run{1}.I_C_R+Run{2}.I_C_F+Run{2}.I_C_R+Run{3}.I_C_F+Run{3}.I_C_R+Run{4}.I_C_F+Run{4}.I_C_R)./8)

sprintf('%6.6f',(+Run{1}.I_A_F_raw+Run{1}.I_A_R_raw+Run{2}.I_A_F_raw+Run{2}.I_A_R_raw+Run{3}.I_A_F_raw+Run{3}.I_A_R_raw+Run{4}.I_A_F_raw+Run{4}.I_A_R_raw)./8)
sprintf('%6.6f',(+Run{1}.I_A_F+Run{1}.I_A_R+Run{2}.I_A_F+Run{2}.I_A_R+Run{3}.I_A_F+Run{3}.I_A_R+Run{4}.I_A_F+Run{4}.I_A_R)./8)
return
%% 
