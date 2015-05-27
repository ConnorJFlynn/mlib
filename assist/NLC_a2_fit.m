function nlc_coefs = NLC_a1_fit
% This code is used to generate the NLC fitting parameters

emis = load('emis.mat');
% emis  = loadinto(['D:\case_studies\assist\compares\LRT_BB_Emiss_FullRes.mat']);
emis = repack_edgar(emis);

range = [200 2100];
range = [1237 2180];
Detector = 'A';

test_dir = getdir('','assist_nlc','Select NLC test directory');
% abbs = length(dir([test_dir,filesep,'ABB_*_A.igm']));
% hbbs = length(dir([test_dir,filesep,'HBB_*_A.igm']));
% ln2s = length(dir([test_dir,filesep,'LN2_*_A.igm']));

abbs = length(dir([test_dir,filesep,'ABB_*_B.igm']));
hbbs = length(dir([test_dir,filesep,'HBB_*_B.igm']));
ln2s = length(dir([test_dir,filesep,'LN2_*_B.igm']));


if abbs==hbbs && hbbs==ln2s
   
   Nb_of_Runs = abbs;
   
   a_2 = zeros(Nb_of_Runs, 1);
   T_ABB = zeros(Nb_of_Runs, 1);
   a_2_ = zeros(Nb_of_Runs, 1);
   for Run_number = 2:(Nb_of_Runs)
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
      
      clear DataCBB ForwardCBB ReverseCBB
      
      % First determine zpd from HBB
      [~,maxii_HF] = max(abs(IGM_H_F.y),[],2);
      [~,maxii_AF] = max(abs(IGM_A_F.y),[],2);
      [~,maxii_CF] = max(abs(IGM_C_F.y),[],2);
      zpd_shift_F = maxii_HF-length(IGM_H_F.x)./2 -1;
      zpd_shift_HF = maxii_HF-length(IGM_H_F.x)./2 -1;
      zpd_shift_AF = maxii_AF-length(IGM_A_F.x)./2 -1;
      zpd_shift_CF = maxii_CF-length(IGM_C_F.x)./2 -1;
      % Shift igms
      IGM_H_F.y =  sideshift(IGM_H_F.x, IGM_H_F.y, zpd_shift_F);
      IGM_A_F.y =  sideshift(IGM_A_F.x, IGM_A_F.y, zpd_shift_F);
      IGM_C_F.y =  sideshift(IGM_C_F.x, IGM_C_F.y, zpd_shift_F);
%       IGM_H_F.y =  sideshift(IGM_H_F.x, IGM_H_F.y, zpd_shift_HF );
%       IGM_A_F.y =  sideshift(IGM_A_F.x, IGM_A_F.y, zpd_shift_AF );
%       IGM_C_F.y =  sideshift(IGM_C_F.x, IGM_C_F.y, zpd_shift_CF );
      
      IGM_H_F.x = fftshift(IGM_H_F.x);  IGM_H_F.y = fftshift(IGM_H_F.y);
      IGM_A_F.x = fftshift(IGM_A_F.x);  IGM_A_F.y = fftshift(IGM_A_F.y);
      IGM_C_F.x = fftshift(IGM_C_F.x);  IGM_C_F.y = fftshift(IGM_C_F.y);
      
      % Compute fft
      [SPC_H_F.x, SPC_H_F.y, SPC_H_F.Idc_pc] = RawIgm2RawSpc(IGM_H_F.x,IGM_H_F.y); SPC_H_F.Idc_raw = IGM_H_F.y(1);
      [SPC_A_F.x, SPC_A_F.y, SPC_A_F.Idc_pc] = RawIgm2RawSpc(IGM_A_F.x,IGM_A_F.y); SPC_A_F.Idc_raw = IGM_A_F.y(1);
      [SPC_C_F.x, SPC_C_F.y, SPC_C_F.Idc_pc] = RawIgm2RawSpc(IGM_C_F.x,IGM_C_F.y); SPC_C_F.Idc_raw = IGM_C_F.y(1);

      CalSet_HA_F = CreateCalibrationFromCXS_(SPC_H_F, T_HBB(Run_number), SPC_A_F, T_ABB(Run_number), T_ABB(Run_number),emis);
      CalSet_AC_F = CreateCalibrationFromCXS_(SPC_A_F, T_ABB(Run_number), SPC_C_F, T_CBB, T_ABB(Run_number),emis);
      diff_resp_F = CalSet_HA_F.Resp - CalSet_AC_F.Resp;
      % Ideally, these calibrations should be identical but due to
      % non-linearity there will be differences related to V_dc and a2
      % Absent measurement, Vdc is modeled in terms of zpd intensities as
      % Vdc = -{(2+f)*[-Ih+Ih_lab-Ic_lab]+I}/MF
      % Vdc = {(2+f)*[Ih - Ih_lab + Ic_lab] - Im}/MF; f = 1, MF = 0.7
      
      %%
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
      
      V_H_F_raw(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_raw(Run_number) + I_H_F_raw(Run_number) -I_C_F_raw(Run_number)) + I_H_F_raw(Run_number));
      V_A_F_raw(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_raw(Run_number) + I_H_F_raw(Run_number) -I_C_F_raw(Run_number)) + I_A_F_raw(Run_number));
      V_C_F_raw(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_raw(Run_number) + I_H_F_raw(Run_number) -I_C_F_raw(Run_number)) + I_C_F_raw(Run_number));
      
      V_H_F_pc(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_pc(Run_number) + I_H_F_pc(Run_number) -I_C_F_pc(Run_number)) + I_H_F_pc(Run_number));
      V_A_F_pc(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_pc(Run_number) + I_H_F_pc(Run_number) -I_C_F_pc(Run_number)) + I_A_F_pc(Run_number));
      V_C_F_pc(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_F_pc(Run_number) + I_H_F_pc(Run_number) -I_C_F_pc(Run_number)) + I_C_F_pc(Run_number));
      
      
      
      %%
      % The following is pure math, for the non-linearity expanded to the quadratic term.
      % Basically pure math but incorporates modeled V_DC
      IGM_H_O_F.Header = IGM_H_F.Header;
      IGM_H_O_F.x = IGM_H_F.x;
      IGM_H_O_F.y_raw = (IGM_H_F.y + V_H_F_raw(Run_number)).^2; % Form #1 of Eq1 in AERI part II
      IGM_H_O_F.y_pc = (IGM_H_F.y + V_H_F_pc(Run_number)).^2; % Form #1 of Eq1 in AERI part II
      
      IGM_A_O_F.Header = IGM_A_F.Header;
      IGM_A_O_F.x = IGM_A_F.x;
      IGM_A_O_F.y_raw = (IGM_A_F.y + V_A_F_raw(Run_number)).^2;
      IGM_A_O_F.y_pc = (IGM_A_F.y + V_A_F_pc(Run_number)).^2;
      
      IGM_C_O_F.Header = IGM_C_F.Header;
      IGM_C_O_F.x = IGM_C_F.x;
      IGM_C_O_F.y_raw = (IGM_C_F.y + V_C_F_raw(Run_number)).^2;
      IGM_C_O_F.y_pc = (IGM_C_F.y + V_C_F_pc(Run_number)).^2;
      
      [SPC_H_O_F.x,SPC_H_O_F.y_raw] = RawIgm2RawSpc(IGM_H_O_F.x,IGM_H_O_F.y_raw);
      [SPC_A_O_F.x,SPC_A_O_F.y_raw] = RawIgm2RawSpc(IGM_A_O_F.x,IGM_A_O_F.y_raw);
      [SPC_C_O_F.x,SPC_C_O_F.y_raw] = RawIgm2RawSpc(IGM_C_O_F.x,IGM_C_O_F.y_raw);
      
      [SPC_H_O_F.x,SPC_H_O_F.y_pc] = RawIgm2RawSpc(IGM_H_O_F.x,IGM_H_O_F.y_pc);
      [SPC_A_O_F.x,SPC_A_O_F.y_pc] = RawIgm2RawSpc(IGM_A_O_F.x,IGM_A_O_F.y_pc);
      [SPC_C_O_F.x,SPC_C_O_F.y_pc] = RawIgm2RawSpc(IGM_C_O_F.x,IGM_C_O_F.y_pc);
      
      
      % Fit to eqn 3 of AERI paper
      BB_x = SPC_H_O_F.x;
      em1 = interp1(emis.x, emis.y, BB_x, 'pchip','extrap');
      em2 = em1;
      em0 = 1.*em1;
      T_2 = T_HBB(Run_number);
      T_1 = T_ABB(Run_number);
      T_0 = T_CBB;
      T_mirror = T_1;
      BB_2 = em1.*Blackbody(BB_x, T_2)+(1-em1).*Blackbody(BB_x, T_mirror);
      BB_1 = em2.*Blackbody(BB_x, T_1)+(1-em2).*Blackbody(BB_x, T_mirror);
      BB_0 = em0.*Blackbody(BB_x, T_0)+(1-em0).*Blackbody(BB_x, T_mirror);
      
      Diff_Resp_fit_F.x = SPC_H_O_F.x;
      Diff_Resp_fit_F.y_raw = (SPC_H_O_F.y_raw - SPC_A_O_F.y_raw)./(BB_2 - BB_1) ...
         -(SPC_A_O_F.y_raw - SPC_C_O_F.y_raw)./(BB_1 - BB_0);
      Diff_Resp_fit_F.y_pc = (SPC_H_O_F.y_pc - SPC_A_O_F.y_pc)./(BB_2 - BB_1) ...
         -(SPC_A_O_F.y_pc - SPC_C_O_F.y_pc)./(BB_1 - BB_0);
      
      a2_F_raw = -real(diff_resp_F) ./ real(Diff_Resp_fit_F.y_raw);
      a2_F_pc = -real(diff_resp_F) ./ real(Diff_Resp_fit_F.y_pc);
      
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
            sub1 = (CalSet_HA_F.x>250&CalSet_HA_F.x<300);
            %This second subrange is below the spectral ranHge of the
            %detector and in the vicinity of a little "negative" bump.  
            %It has good statistics and is probably still free of
            %contamination by actual signal. Note that it doesn't matter
            %whether we scale over a region where resp_diff is positive or
            %negative.  We just want it to be substantial.
            sub2 = (CalSet_HA_F.x>1160&CalSet_HA_F.x<1190);
            % Here is a subrange from above the responsivity.  Note that I
            % had to go well above in order to get to a regions where
            % diff_resp was not near-zero.
            sub3 = (CalSet_HA_F.x>2800&CalSet_HA_F.x<3000);
            
            % I think this third subrange from the higher end is too noisy.
            sub = sub1;
      
      A2_F_raw(Run_number) = mean(a2_F_raw(sub));
      A2_F_pc(Run_number) = mean(a2_F_pc(sub));
      
      %%
      figure(51);
      plot(CalSet_AC_F.x, real(diff_resp_F)./1000, 'r.',CalSet_AC_F.x(sub), real(diff_resp_F(sub))./1000, 'c.')
      hold('on')
      %plot(CalSet_AC.x, imag(diff_gains), 'g-')
      %       lines = plot(Diff_Resp_fit.x, real(a_2(Run_number) * Diff_Resp_fit.y), 'r-', Diff_Resp_fit.x, real(a_2_(Run_number) * Diff_Resp_fit.y), 'k-')
      plot(Diff_Resp_fit_F.x, real(-A2_F_raw(Run_number) * real(Diff_Resp_fit_F.y_raw))./1000, '-');
      %plot(Diff_Resp_fit.x, imag(a_2(Run_number) * Diff_Resp_fit.y), 'c-')
      xlabel('Wavenumber [cm^{-1}]')
      ylabel('R^{HA}-R^{AC} [cts/(mW/(m^2 sr cm^{-1}))]')
      kk = find(Diff_Resp_fit_F.x >= range(1) & Diff_Resp_fit_F.x <= range(2));
      ymin = 0.9*min([real(diff_resp_F(kk))./1000 real(-A2_F_raw(Run_number) * Diff_Resp_fit_F.y_raw(kk))./1000]);
      ymax = 1.2*max([real(diff_resp_F(kk))./1000 real(-A2_F_raw(Run_number) * Diff_Resp_fit_F.y_raw(kk))./1000]);
      axis([200 2400 ymin ymax]);
      V = [IGM_H_F.Header.fdate.year,IGM_H_F.Header.fdate.month+1,IGM_H_F.Header.fdate.day+1];
      title({'Re(Resp_HA)- Re(Resp_AC) for raw ZPD';...
         [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Forward, Run:',num2str(Run_number)]},'interp','none');
      %legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
      %       legend('Measured',sprintf('a2 = %2.3e',a_2(Run_number)),
      %       sprintf('(2nd) %2.3e',a_2_(Run_number)));
      lg = legend('Measured','fitted'); set(lg,'interp','none');
      hold('off')
      
      figure(52);
      plot(CalSet_AC_F.x, real(diff_resp_F)./1000, 'r.',CalSet_AC_F.x(sub), real(diff_resp_F(sub))./1000, 'c.')
      hold('on')
      %plot(CalSet_AC.x, imag(diff_gains), 'g-')
      %       lines = plot(Diff_Resp_fit.x, real(a_2(Run_number) * Diff_Resp_fit.y), 'r-', Diff_Resp_fit.x, real(a_2_(Run_number) * Diff_Resp_fit.y), 'k-')
      plot(Diff_Resp_fit_F.x, real(-A2_F_pc(Run_number) * real(Diff_Resp_fit_F.y_pc))./1000, '-');
      %plot(Diff_Resp_fit.x, imag(a_2(Run_number) * Diff_Resp_fit.y), 'c-')
      xlabel('Wavenumber [cm^{-1}]')
      ylabel('R^{HA}-R^{AC} [cts/(mW/(m^2 sr cm^{-1}))]')
      kk = find(Diff_Resp_fit_F.x >= range(1) & Diff_Resp_fit_F.x <= range(2));
      ymin = 0.9*min([real(diff_resp_F(kk))./1000 real(-A2_F_pc(Run_number) * Diff_Resp_fit_F.y_pc(kk))./1000]);
      ymax = 1.2*max([real(diff_resp_F(kk))./1000 real(-A2_F_pc(Run_number) * Diff_Resp_fit_F.y_pc(kk))./1000]);
      axis([200 2400 ymin ymax]);
      V = [IGM_H_F.Header.fdate.year,IGM_H_F.Header.fdate.month+1,IGM_H_F.Header.fdate.day+1];
      title({'Re(Resp_HA)- Re(Resp_AC) for pc ZPD';...
         [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Forward, Run:',num2str(Run_number)]},'interp','none');
      %legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
      %       legend('Measured',sprintf('a2 = %2.3e',a_2(Run_number)),
      %       sprintf('(2nd) %2.3e',a_2_(Run_number)));
      lg = legend('Measured','fitted'); set(lg,'interp','none');
      hold('off')
      
      %%
      % Now do reverse scan...
      % First determine zpd from HBB
      [~,maxii_HR] = max(abs(IGM_H_R.y),[],2); maxii_HR = mode(maxii_HR);
      [~,maxii_AR] = max(abs(IGM_A_R.y),[],2); maxii_AR = mode(maxii_AR);
      [~,maxii_CR] = max(abs(IGM_C_R.y),[],2); maxii_CR = mode(maxii_CR);      
      % Shift igms
      zpd_shift_R = maxii_HR-length(IGM_H_R.x)./2 -1;
      zpd_shift_HR = maxii_HR-length(IGM_H_R.x)./2 -1;
      zpd_shift_AR = maxii_AR-length(IGM_H_R.x)./2 -1;
      zpd_shift_CR = maxii_CR-length(IGM_H_R.x)./2 -1;

      IGM_H_R.y =  sideshift(IGM_H_R.x, IGM_H_R.y, zpd_shift_R);
      IGM_A_R.y =  sideshift(IGM_A_R.x, IGM_A_R.y, zpd_shift_R);
      IGM_C_R.y =  sideshift(IGM_C_R.x, IGM_C_R.y, zpd_shift_R);            
%       IGM_H_R.y =  sideshift(IGM_H_R.x, IGM_H_R.y, zpd_shift_HR);
%       IGM_A_R.y =  sideshift(IGM_A_R.x, IGM_A_R.y, zpd_shift_AR);
%       IGM_C_R.y =  sideshift(IGM_C_R.x, IGM_C_R.y, zpd_shift_CR);
      IGM_H_R.x = fftshift(IGM_H_R.x);  IGM_H_R.y = fftshift(IGM_H_R.y);
      IGM_A_R.x = fftshift(IGM_A_R.x);  IGM_A_R.y = fftshift(IGM_A_R.y);
      IGM_C_R.x = fftshift(IGM_C_R.x);  IGM_C_R.y = fftshift(IGM_C_R.y);
      
      % Compute fft
      [SPC_H_R.x, SPC_H_R.y, SPC_H_R.Idc_pc] = RawIgm2RawSpc(IGM_H_R.x,IGM_H_R.y); SPC_H_R.Idc_raw = IGM_H_R.y(1);
      [SPC_A_R.x, SPC_A_R.y, SPC_A_R.Idc_pc] = RawIgm2RawSpc(IGM_A_R.x,IGM_A_R.y); SPC_A_R.Idc_raw = IGM_A_R.y(1);
      [SPC_C_R.x, SPC_C_R.y, SPC_C_R.Idc_pc] = RawIgm2RawSpc(IGM_C_R.x,IGM_C_R.y); SPC_C_R.Idc_raw = IGM_C_R.y(1);
      

      figure; sb(1) = subplot(2,1,1);
      plot(SPC_H_F.x, real(SPC_H_F.y),'r-',SPC_A_F.x, real(SPC_A_F.y),'-g',SPC_C_F.x, real(SPC_C_F.y),'b-');
      title(['real(spc) Run: ',num2str(Run_number)]);
      sb(2) = subplot(2,1,2);
      plot(SPC_H_F.x, real(SPC_H_R.y),'r-',SPC_A_R.x, real(SPC_A_R.y),'-g',SPC_C_F.x, real(SPC_C_R.y),'b-');
      linkaxes(sb,'xy');
      xlim([1000,2000]);
      
      figure; sb(1) = subplot(2,1,1);
      plot(SPC_H_F.x, imag(SPC_H_F.y),'r-',SPC_A_F.x, imag(SPC_A_F.y),'-g',SPC_C_F.x, imag(SPC_C_F.y),'b-');
      title(['imag(spc) Run: ',num2str(Run_number)]);
      sb(2) = subplot(2,1,2);
      plot(SPC_H_F.x, imag(SPC_H_R.y),'r-',SPC_A_R.x, imag(SPC_A_R.y),'-g',SPC_C_F.x, imag(SPC_C_R.y),'b-');
      linkaxes(sb,'xy');
      xlim([1000,2000]);
      

      CalSet_HA_R = CreateCalibrationFromCXS_(SPC_H_R, T_HBB(Run_number), SPC_A_R, T_ABB(Run_number), T_ABB(Run_number),emis);
      CalSet_AC_R = CreateCalibrationFromCXS_(SPC_A_R, T_ABB(Run_number), SPC_C_R, T_CBB, T_ABB(Run_number),emis);
      diff_resp_R = CalSet_HA_R.Resp - CalSet_AC_R.Resp;
      % Ideally, these calibrations should be identical but due to
      % non-linearity there will be differences related to V_dc and a2
      % Absent measurement, Vdc is modeled in terms of zpd intensities as
      % Vdc = -{(2+f)*[-Ih+Ih_lab-Ic_lab]+I}/MF
      % Vdc = {(2+f)*[Ih - Ih_lab + Ic_lab] - Im}/MF; f = 1, MF = 0.7
      
      %%
      MF  =0.7;
      f_back = 1;
      
      I_H_R_raw(Run_number) = SPC_H_R.Idc_raw;
      I_A_R_raw(Run_number) = SPC_A_R.Idc_raw;
      I_C_R_raw(Run_number) = SPC_C_R.Idc_raw;
      
      I_H_R_pc(Run_number) = SPC_H_R.Idc_pc;
      I_A_R_pc(Run_number) = SPC_A_R.Idc_pc;
      I_C_R_pc(Run_number) = SPC_C_R.Idc_pc;
      
      % Modeled DC offset (this could be replaced with ASSIST chA DC
      % Here is where I begin to flip the Vdc sign
      
      V_H_R_raw(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_raw(Run_number) + I_H_R_raw(Run_number) -I_C_R_raw(Run_number)) + I_H_R_raw(Run_number));
      V_A_R_raw(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_raw(Run_number) + I_H_R_raw(Run_number) -I_C_R_raw(Run_number)) + I_A_R_raw(Run_number));
      V_C_R_raw(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_raw(Run_number) + I_H_R_raw(Run_number) -I_C_R_raw(Run_number)) + I_C_R_raw(Run_number));
      
      V_H_R_pc(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_pc(Run_number) + I_H_R_pc(Run_number) -I_C_R_pc(Run_number)) + I_H_R_pc(Run_number));
      V_A_R_pc(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_pc(Run_number) + I_H_R_pc(Run_number) -I_C_R_pc(Run_number)) + I_A_R_pc(Run_number));
      V_C_R_pc(Run_number) = (-1/MF) * ((2 + f_back)*(-I_H_R_pc(Run_number) + I_H_R_pc(Run_number) -I_C_R_pc(Run_number)) + I_C_R_pc(Run_number));
      
      
      
      %%
      % The following is pure math, for the non-linearity expanded to the quadratic term.
      % Basically pure math but incorporates modeled V_DC
      IGM_H_O_R.Header = IGM_H_R.Header;
      IGM_H_O_R.x = IGM_H_R.x;
      IGM_H_O_R.y_raw = (IGM_H_R.y + V_H_R_raw(Run_number)).^2; % Form #1 of Eq1 in AERI part II
      IGM_H_O_R.y_pc = (IGM_H_R.y + V_H_R_pc(Run_number)).^2; % Form #1 of Eq1 in AERI part II
      
      IGM_A_O_R.Header = IGM_A_R.Header;
      IGM_A_O_R.x = IGM_A_R.x;
      IGM_A_O_R.y_raw = (IGM_A_R.y + V_A_R_raw(Run_number)).^2;
      IGM_A_O_R.y_pc = (IGM_A_R.y + V_A_R_pc(Run_number)).^2;
      
      IGM_C_O_R.Header = IGM_C_R.Header;
      IGM_C_O_R.x = IGM_C_R.x;
      IGM_C_O_R.y_raw = (IGM_C_R.y + V_C_R_raw(Run_number)).^2;
      IGM_C_O_R.y_pc = (IGM_C_R.y + V_C_R_pc(Run_number)).^2;
      
      [SPC_H_O_R.x,SPC_H_O_R.y_raw] = RawIgm2RawSpc(IGM_H_O_R.x,IGM_H_O_R.y_raw);
      [SPC_A_O_R.x,SPC_A_O_R.y_raw] = RawIgm2RawSpc(IGM_A_O_R.x,IGM_A_O_R.y_raw);
      [SPC_C_O_R.x,SPC_C_O_R.y_raw] = RawIgm2RawSpc(IGM_C_O_R.x,IGM_C_O_R.y_raw);
      
      [SPC_H_O_R.x,SPC_H_O_R.y_pc] = RawIgm2RawSpc(IGM_H_O_R.x,IGM_H_O_R.y_pc);
      [SPC_A_O_R.x,SPC_A_O_R.y_pc] = RawIgm2RawSpc(IGM_A_O_R.x,IGM_A_O_R.y_pc);
      [SPC_C_O_R.x,SPC_C_O_R.y_pc] = RawIgm2RawSpc(IGM_C_O_R.x,IGM_C_O_R.y_pc);
      
      
      % Fit to eqn 3 of AERI paper
      
      Diff_Resp_fit_R.x = SPC_H_O_R.x;
      Diff_Resp_fit_R.y_raw = (SPC_H_O_R.y_raw - SPC_A_O_R.y_raw)./(BB_2 - BB_1) ...
         -(SPC_A_O_R.y_raw - SPC_C_O_R.y_raw)./(BB_1 - BB_0);
      Diff_Resp_fit_R.y_pc = (SPC_H_O_R.y_pc - SPC_A_O_R.y_pc)./(BB_2 - BB_1) ...
         -(SPC_A_O_R.y_pc - SPC_C_O_R.y_pc)./(BB_1 - BB_0);
      
      a2_R_raw = -real(diff_resp_R) ./ real(Diff_Resp_fit_R.y_raw);
      a2_R_pc = -real(diff_resp_R) ./ real(Diff_Resp_fit_R.y_pc);
            
      A2_R_raw(Run_number) = mean(a2_R_raw(sub));
      A2_R_pc(Run_number) = mean(a2_R_pc(sub));
      
      figure(53);
      plot(CalSet_AC_R.x, real(diff_resp_R)./1000, 'r.',CalSet_AC_R.x(sub), real(diff_resp_R(sub))./1000, 'c.')
      hold('on')
      %plot(CalSet_AC.x, imag(diff_gains), 'g-')
      %       lines = plot(Diff_Resp_fit.x, real(a_2(Run_number) * Diff_Resp_fit.y), 'r-', Diff_Resp_fit.x, real(a_2_(Run_number) * Diff_Resp_fit.y), 'k-')
      plot(Diff_Resp_fit_R.x, real(-A2_R_raw(Run_number) * real(Diff_Resp_fit_R.y_raw))./1000, '-');
      %plot(Diff_Resp_fit.x, imag(a_2(Run_number) * Diff_Resp_fit.y), 'c-')
      xlabel('Wavenumber [cm^{-1}]')
      ylabel('R^{HA}-R^{AC} [cts/(mW/(m^2 sr cm^{-1}))]')
      kk = find(Diff_Resp_fit_R.x >= range(1) & Diff_Resp_fit_R.x <= range(2));
      ymin = 0.9*min([real(diff_resp_R(kk))./1000 real(-A2_R_raw(Run_number) * Diff_Resp_fit_R.y_raw(kk))./1000]);
      ymax = 1.2*max([real(diff_resp_R(kk))./1000 real(-A2_R_raw(Run_number) * Diff_Resp_fit_R.y_raw(kk))./1000]);
      axis([200 2400 ymin ymax]);
      V = [IGM_H_R.Header.fdate.year,IGM_H_R.Header.fdate.month+1,IGM_H_R.Header.fdate.day+1];
      title({'Re(Resp_HA)- Re(Resp_AC) for raw ZPD';...
         [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Reverse, Run:',num2str(Run_number)]},'interp','none');
      %legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
      %       legend('Measured',sprintf('a2 = %2.3e',a_2(Run_number)),
      %       sprintf('(2nd) %2.3e',a_2_(Run_number)));
      lg = legend('Measured','fitted'); set(lg,'interp','none');
      hold('off')
      
      figure(54);
      plot(CalSet_AC_R.x, real(diff_resp_R)./1000, 'r.',CalSet_AC_R.x(sub), real(diff_resp_R(sub))./1000, 'c.')
      hold('on')
      %plot(CalSet_AC.x, imag(diff_gains), 'g-')
      %       lines = plot(Diff_Resp_fit.x, real(a_2(Run_number) * Diff_Resp_fit.y), 'r-', Diff_Resp_fit.x, real(a_2_(Run_number) * Diff_Resp_fit.y), 'k-')
      plot(Diff_Resp_fit_R.x, real(-A2_R_pc(Run_number) * real(Diff_Resp_fit_R.y_pc))./1000, '-');
      %plot(Diff_Resp_fit.x, imag(a_2(Run_number) * Diff_Resp_fit.y), 'c-')
      xlabel('Wavenumber [cm^{-1}]')
      ylabel('R^{HA}-R^{AC} [cts/(mW/(m^2 sr cm^{-1}))]')
      kk = find(Diff_Resp_fit_R.x >= range(1) & Diff_Resp_fit_R.x <= range(2));
      ymin = 0.9*min([real(diff_resp_R(kk))./1000 real(-A2_R_pc(Run_number) * Diff_Resp_fit_R.y_pc(kk))./1000]);
      ymax = 1.2*max([real(diff_resp_R(kk))./1000 real(-A2_R_pc(Run_number) * Diff_Resp_fit_R.y_pc(kk))./1000]);
      axis([200 2400 ymin ymax]);
      V = [IGM_H_R.Header.fdate.year,IGM_H_R.Header.fdate.month+1,IGM_H_R.Header.fdate.day+1];
      title({'Re(Resp_HA)- Re(Resp_AC) for pc ZPD';...
         [datestr(datenum(V),'yyyy-mm-dd'),', Scan direction: Reverse, Run:',num2str(Run_number)]},'interp','none');
      %legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
      %       legend('Measured',sprintf('a2 = %2.3e',a_2(Run_number)),
      %       sprintf('(2nd) %2.3e',a_2_(Run_number)));
      lg = legend('Measured','fitted'); set(lg,'interp','none');
      hold('off')
      
      Run{Run_number}.I_H_F_raw = I_H_F_raw(Run_number);
      Run{Run_number}.I_A_F_raw = I_A_F_raw(Run_number);
      Run{Run_number}.I_C_F_raw = I_C_F_raw(Run_number);
      Run{Run_number}.V_H_F_raw = V_H_F_raw(Run_number);
      Run{Run_number}.V_A_F_raw = V_A_F_raw(Run_number);
      Run{Run_number}.V_C_F_raw = V_C_F_raw(Run_number);
      Run{Run_number}.A2_F_raw = A2_F_raw(Run_number);
      
      Run{Run_number}.I_H_F_pc = I_H_F_pc(Run_number);
      Run{Run_number}.I_A_F_pc = I_A_F_pc(Run_number);
      Run{Run_number}.I_C_F_pc = I_C_F_pc(Run_number);
      Run{Run_number}.V_H_F_pc = V_H_F_pc(Run_number);
      Run{Run_number}.V_A_F_pc = V_A_F_pc(Run_number);
      Run{Run_number}.V_C_F_pc = V_C_F_pc(Run_number);
      Run{Run_number}.A2_F_pc = A2_F_pc(Run_number);
      
      
      Run{Run_number}.I_H_R_raw = I_H_R_raw(Run_number);
      Run{Run_number}.I_A_R_raw = I_A_R_raw(Run_number);
      Run{Run_number}.I_C_R_raw = I_C_R_raw(Run_number);
      Run{Run_number}.V_H_R_raw = V_H_R_raw(Run_number);
      Run{Run_number}.V_A_R_raw = V_A_R_raw(Run_number);
      Run{Run_number}.V_C_R_raw = V_C_R_raw(Run_number);
      Run{Run_number}.A2_R_raw = A2_R_raw(Run_number);
      
      Run{Run_number}.I_H_R_pc = I_H_R_pc(Run_number);
      Run{Run_number}.I_A_R_pc = I_A_R_pc(Run_number);
      Run{Run_number}.I_C_R_pc = I_C_R_pc(Run_number);
      Run{Run_number}.V_H_R_pc = V_H_R_pc(Run_number);
      Run{Run_number}.V_A_R_pc = V_A_R_pc(Run_number);
      Run{Run_number}.V_C_R_pc = V_C_R_pc(Run_number);
      Run{Run_number}.A2_R_pc = A2_R_pc(Run_number);
      
   end
    figure(51); 
    txt_str = {sprintf('a2_F_raw = %2.3e\n',mean(A2_F_raw));...
       sprintf('I_H_F_raw(lab) = %2.3e',mean(I_H_F_raw));...
       sprintf('I_A_F_raw(lab) = %2.3e',mean(I_A_F_raw));...
       sprintf('I_C_F_raw(lab) = %2.3e',mean(I_C_F_raw))};
    txt = text(mean(xlim), mean(ylim),txt_str);
    set(txt,'unit','normalized','position',[.05,.9],'verticalalign','cap',...
       'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
       'fontname','Tahoma','fontweight','demi','backgroundcolor','w');

    figure(52); 
    txt_str = {sprintf('a2_F_pc = %2.3e\n',mean(A2_F_pc));...
       sprintf('I_H_F_pc(lab) = %2.3e',mean(I_H_F_pc));...
       sprintf('I_A_F_pc(lab) = %2.3e',mean(I_A_F_pc));...
       sprintf('I_C_F_pc(lab) = %2.3e',mean(I_C_F_pc))};
    txt = text(mean(xlim), mean(ylim),txt_str);
    set(txt,'unit','normalized','position',[.05,.9],'verticalalign','cap',...
       'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
       'fontname','Tahoma','fontweight','demi','backgroundcolor','w');
    
    figure(53);
    txt_str = {sprintf('a2_R_raw = %2.3e\n',mean(A2_R_raw));...
       sprintf('I_H_R_raw(lab) = %2.3e',mean(I_H_R_raw));...
       sprintf('I_A_R_raw(lab) = %2.3e',mean(I_A_R_raw));...
       sprintf('I_C_R_raw(lab) = %2.3e',mean(I_C_R_raw))};
    txt = text(mean(xlim), mean(ylim),txt_str);
    set(txt,'unit','normalized','position',[.05,.9],'verticalalign','cap',...
       'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
       'fontname','Tahoma','fontweight','demi','backgroundcolor','w');
    
    figure(54); 
    txt_str = {sprintf('a2_R_pc = %2.3e\n',mean(A2_R_pc));...
       sprintf('I_H_R_pc(lab) = %2.3e',mean(I_H_R_pc));...
       sprintf('I_A_R_pc(lab) = %2.3e',mean(I_A_R_pc));...
       sprintf('I_C_R_pc(lab) = %2.3e',mean(I_C_R_pc))};
    txt = text(mean(xlim), mean(ylim),txt_str);
    set(txt,'unit','normalized','position',[.05,.9],'verticalalign','cap',...
       'edgecolor',[0,.7,0],'color',[0,0,.5], 'interp','none','fontsize',10,...
       'fontname','Tahoma','fontweight','demi','backgroundcolor','w');    
    
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

save([test_dir,filesep,'nlc_pc.',nlc_pc.time_str,'.mat'],'-struct','nlc_pc');
save([test_dir,filesep,'nlc_raw.',nlc_raw.time_str,'.mat'],'-struct','nlc_raw');


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

return
%% 
