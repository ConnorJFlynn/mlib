function NLC_fit
close all
clear

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
   
   for Direction = {'R','F'}
      if exist('fig','var')&&ishandle(fig)
         close(fig);
      end
            fig = figure(2)
            hold on
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
         IGM_H.Header = ForwardHBB.Header;
         if strcmp(Direction,'F')
            IGM_H.x = ForwardHBB.x;
            IGM_H.y = mean(ForwardHBB.y, 1);
         else
            IGM_H.x = ReverseHBB.x;
            IGM_H.y = mean(ReverseHBB.y, 1);
         end
         clear DataHBB ForwardHBB ReverseHBB
         
         fileName = [test_dir,'ABB_' num2str(Run_number) '_' Detector '.igm'];
         DataABB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
         [ForwardABB, ReverseABB] = SplitDirections(DataABB);
         IGM_A.Header = ForwardABB.Header;
         if strcmp(Direction,'F')
            IGM_A.x = ForwardABB.x;
            IGM_A.y = mean(ForwardABB.y, 1);
         else
            IGM_A.x = ReverseABB.x;
            IGM_A.y = mean(ReverseABB.y, 1);
         end
         clear DataABB ForwardABB ReverseABB
         
         fileName = [test_dir,'LN2_' num2str(Run_number) '_' Detector '.igm'];
         DataCBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
         [ForwardCBB, ReverseCBB] = SplitDirections(DataCBB);
         IGM_C.Header = ForwardCBB.Header;
         if strcmp(Direction,'F')
            IGM_C.x = ForwardCBB.x;
            IGM_C.y = mean(ForwardCBB.y, 1);
         else
            IGM_C.x = ReverseCBB.x;
            IGM_C.y = mean(ReverseCBB.y, 1);
         end
         
         clear DataCBB ForwardCBB ReverseCBB
         %%
         
         %          figure(1)
         %          plot(IGM_H.x, abs(IGM_H.y),'.-', IGM_A.x, abs(IGM_A.y),'.-', IGM_C.x, abs(IGM_C.y),'.-')
         %          legend('Hot', 'Ambient', 'LN2');
         %%
         % First determine zpd from HBB
         zpd_shift_H = find_zpd_xcorr(IGM_H.y);
         zpd_shift_A = find_zpd_xcorr(IGM_A.y);
         zpd_shift_C = find_zpd_xcorr(IGM_C.y);
         
         [Hmaxv,Hmaxi] = max(abs(IGM_H.y));
         zpd_shift_H = Hmaxi-length(IGM_H.x)./2 -1;
         [Amaxv,Amaxi] = max(abs(IGM_A.y));
         zpd_shift_A = Amaxi-length(IGM_A.x)./2 -1;
         [Cmaxv,Cmaxi] = max(abs(IGM_C.y));
         zpd_shift_C = Cmaxi-length(IGM_C.x)./2 -1;
         
% assist.chA.y(assist.logi.F,:) =  sideshift(assist.chA.x, assist.chA.y(assist.logi.F,:), chA_zpd_shift_F);
%          

         
         % Shift igms
         IGM_H.y =  sideshift(IGM_H.x,IGM_H.y, zpd_shift_H);
         IGM_A.y =  sideshift(IGM_A.x,IGM_A.y, zpd_shift_H);
         IGM_C.y =  sideshift(IGM_C.x,IGM_C.y, zpd_shift_H);
         
         % Compute fft
         [SPC_H.x,SPC_H.y] = ShiftIgm2RawSpc(IGM_H.x,IGM_H.y);
         [SPC_A.x,SPC_A.y] = ShiftIgm2RawSpc(IGM_A.x,IGM_A.y);
         [SPC_C.x,SPC_C.y] = ShiftIgm2RawSpc(IGM_C.x,IGM_C.y);
         
         %%
         I_H = IGM_H.y;
         [~, I] = max(abs(I_H - mean(I_H)));
         I_H = I_H(I);
         I_A = IGM_A.y;
         [~, I] = max(abs(I_A - mean(I_A)));
         I_A = I_A(I);
         I_C = IGM_C.y;
         [~, I] = max(abs(I_C - mean(I_C)));
         I_C = I_C(I);
         
         MF  =0.7;
         f_back = 1;
         
         V_H = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_H);
         V_A = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_A);
         V_C = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_C);
         
         % V_H = -(1/MF) * (3*(- I_C) + I_H); %= (3I_C - I_H)/MF
         % V_A = -(1/MF) * (3*(- I_C) + I_A);%= (3I_C - I_A)/MF
         % V_C = -(1/MF) * (3*(- I_C) + I_C); % = (2I_C)/MF ;
         
         
         IGM_H_O.Header = IGM_H.Header;
         IGM_H_O.x = IGM_H.x;
         IGM_H_O.y = (IGM_H.y + V_H).^2;
         IGM_A_O.Header = IGM_A.Header;
         IGM_A_O.x = IGM_A.x;
         IGM_A_O.y = (IGM_A.y + V_A).^2;
         IGM_C_O.Header = IGM_C.Header;
         IGM_C_O.x = IGM_C.x;
         IGM_C_O.y = (IGM_C.y + V_C).^2;
         
         [SPC_H_O.x,SPC_H_O.y] = ShiftIgm2RawSpc(IGM_H_O.x,IGM_H_O.y);
         [SPC_A_O.x,SPC_A_O.y] = ShiftIgm2RawSpc(IGM_A_O.x,IGM_A_O.y);
         [SPC_C_O.x,SPC_C_O.y] = ShiftIgm2RawSpc(IGM_C_O.x,IGM_C_O.y);
         
         % SPC_H_O.y = SPC_H_O.y/length(SPC_H_O.x);
         % SPC_A_O.y = SPC_A_O.y/length(SPC_A_O.x);
         % SPC_C_O.y = SPC_C_O.y/length(SPC_C_O.x);
         
         Diff_R_fit.x = SPC_H_O.x;
         Diff_R_fit.y = (SPC_H_O.y - SPC_A_O.y)./(Blackbody(SPC_H_O.x, T_HBB(Run_number)) - Blackbody(SPC_H_O.x, T_ABB(Run_number)))...
            -(SPC_A_O.y - SPC_C_O.y)./(Blackbody(SPC_H_O.x, T_ABB(Run_number)) - Blackbody(SPC_H_O.x, T_CBB));
         
         % fileName = [test_dir,'HBB_' num2str(Run_number) '_' Detector '.igm'];
         % DataHBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
         % [ForwardHBB, ReverseHBB] = SplitDirections(DataHBB);
         %
         % clear DataHBB
         %
         % fileName = [test_dir,'ABB_' num2str(Run_number) '_' Detector '.igm'];
         % DataABB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
         % [ForwardABB, ReverseABB] = SplitDirections(DataABB);
         %
         clear DataABB
         %%
         
         CalSet_HA = CreateCalibrationFromCXS_(SPC_H, T_HBB(Run_number), SPC_A, T_ABB(Run_number));
         %%
         
         % This is actually responsivity, not gain. CJF
         % CalSet_HA.Gain = CalSet_HA.Gain/length(ForwardHBB.x);
         
         % clear ForwardHBB ForwardABB ReverseHBB ReverseABB
         
         % fileName = [test_dir,'ABB_' num2str(Run_number) '_' Detector '.igm'];
         % DataABB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
         % [ForwardABB, ReverseABB] = SplitDirections(DataABB);
         %
         % % clear DataABB
         %
         % fileName = [test_dir,'LN2_' num2str(Run_number) '_' Detector '.igm'];
         % DataCBB = ReadEdgarFile(fileName, 1, MaxNbScansCalib);
         % [ForwardCBB, ReverseCBB] = SplitDirections(DataCBB);
         
         % clear DataCBB
         
         CalSet_AC = CreateCalibrationFromCXS_(SPC_C, T_CBB, SPC_A, T_ABB(Run_number));
         
         % This is actually responsivity, not gain. CJF
         % CalSet_AC.Gain = CalSet_AC.Gain/length(ForwardABB.x);
         
         % clear ForwardCBB ForwardABB ReverseCBB ReverseABB
         
         % In the paper, it is mentioned that the a_2 parameter is chosen such that
         % the real part of the gain evaluated using the LN2 and ABB equals the real
         % part of the gain evaluated using the HBB and ABB. Therefore, Option 1
         % below should be the right way to evaluate a_2. However, we obtain a
         % better fit between the model and the evaluation of the difference between
         % the gains when we use Option 2.
         %%
%          figure; 
%          sx(1) = subplot(2,1,1);
%          plot(CalSet_HA.x, real([CalSet_HA.Resp; CalSet_AC.Resp]),'-');
%          legend('HA Resp','AC Resp');
%          sx(2) = subplot(2,1,2);
%          plot(CalSet_HA.x, real([Diff_R_fit.y]),'-');
%          legend('Diff R fit');
%          linkaxes(sx,'x');
%          zoom('on');
         
         %%
         sub = (CalSet_HA.x>320&CalSet_HA.x<480) | (CalSet_HA.x>1850&CalSet_HA.x<2400);

         % Option 1 - Ratio or real parts
         a_2_tmp = real(CalSet_HA.Resp - CalSet_AC.Resp) ./ real(Diff_R_fit.y);
         % Option 2 - Real part of ratio
         a_2_tmp_ = real((CalSet_HA.Resp - CalSet_AC.Resp) ./ Diff_R_fit.y);
         
         switch upper(Detector)
            case('A')
               range = [200 2000];
               kk = find(Diff_R_fit.x >= 200 & Diff_R_fit.x <= 460);
            case('B')
               range = [200 3500];
               kk = find(Diff_R_fit.x >= 200 & Diff_R_fit.x <= 460);
            case('C')
               range = [200 5000];
               kk = find(Diff_R_fit.x >= 200 & Diff_R_fit.x <= 460);
            otherwise
               range = [200 3000];
               kk = find(Diff_R_fit.x >= 200 & Diff_R_fit.x <= 460);
         end
         
         a_2(Run_number) = mean(a_2_tmp(kk));
         a_2_(Run_number) = mean(a_2_tmp_(kk));
         a_2(Run_number) = mean(a_2_tmp(sub));
         a_2_(Run_number) = mean(a_2_tmp_(sub));
         
         % V_H = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_H);
         % V_A = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_A);
         % V_C = -(1/MF) * ((2 + f_back)*(-I_H + I_H - I_C) + I_C);
         %          nlc_h = (1+2.*a_2(Run_number).*V_H);
         %          nlc_a = (1+2.*a_2(Run_number).*V_A);
         %          nlc_c = (1+2.*a_2(Run_number).*V_C);
         
         diff_resp = CalSet_HA.Resp - CalSet_AC.Resp;
         

      plot(CalSet_AC.x, real(diff_resp), 'r.')

      %plot(CalSet_AC.x, imag(diff_gains), 'g-')
%       lines = plot(Diff_R_fit.x, real(a_2(Run_number) * Diff_R_fit.y), 'r-', Diff_R_fit.x, real(a_2_(Run_number) * Diff_R_fit.y), 'k-')
      plot(Diff_R_fit.x, real(a_2(Run_number) * Diff_R_fit.y), '-');
      %plot(Diff_R_fit.x, imag(a_2(Run_number) * Diff_R_fit.y), 'c-')
      xlabel('Wavenumber [cm^{-1}]')
      ylabel('R^{HA} - R^{AC} [Counts/(W/(m^2 sr cm^{-1}))]')
      kk = find(Diff_R_fit.x >= range(1) & Diff_R_fit.x <= range(2));
      ymin = 1.2*min([real(diff_resp(kk)) imag(diff_resp(kk)) ...
         real(a_2(Run_number) * Diff_R_fit.y(kk)) ...
         imag(a_2(Run_number) * Diff_R_fit.y(kk))]);
      ymax = 1.2*max([real(diff_resp(kk)) imag(diff_resp(kk)) ...
         real(a_2(Run_number) * Diff_R_fit.y(kk)) ...
         imag(a_2(Run_number) * Diff_R_fit.y(kk))]);
      axis([320 2400 ymin ymax]);
      V = [IGM_H.Header.fdate.year,IGM_H.Header.fdate.month+1,IGM_H.Header.fdate.day+1,1,1,1];
      title({['Diff between Re(Hot_Resp/Amb_resp)- Re(Amb_resp/LN2_resp)'];
         [datestr(V,'yyyy-mm-dd'),', Scan direction:',char(Direction)]},'interp','none');
      %legend('Real Measured', 'Imaginary Measured', 'Real Model fit', 'Imaginary Model fit')
%       legend('Measured',sprintf('a2 = %2.3e',a_2(Run_number)),
%       sprintf('(2nd) %2.3e',a_2_(Run_number)));
      legend('Measured','fitted');
         % figure
         % plot(CalSet_HA.x, 1e-3*abs(CalSet_HA.Resp), 'b-')
         % xlabel('Wavenumber [cm^{-1}]')
         % ylabel('|R^{HA}| [Counts/(mW/(m^2 sr cm^{-1}))]')
         % kk = find(Diff_R_fit.x >= range(1) & Diff_R_fit.x <= range(2));
         % axis([range(1) range(2) 0 1.2e-3*max(abs(CalSet_HA.Resp(kk)))])
         
      end
      txt = text(mean(xlim), mean(ylim),sprintf('a2 = %2.3e \n',a_2));
      set(txt,'unit','normalized','position',[.1,.8],'edgecolor',[0,.7,0],'color',[0,.7,0]);

      saveas(2,[test_dir,'NLC_fit.',datestr(V,'yyyymmdd'),'.',char(Direction),'.png']);
      
   end
   figure(3)
   plot(1:Nb_of_Runs, a_2, '*')
   xlabel('Run number')
   ylabel('Non-linearity correction parameter a_2')
   
   figure(4)
   plot(1:Nb_of_Runs, T_ABB, 'r^')
   hold on
   plot(1:Nb_of_Runs, T_HBB, 'go')
   xlabel('Run number')
   ylabel('Blackbody temperature [K]')
   legend('Ambient', 'Hot');
else
   disp(['Different numbers of ABB, HBB, and LN2 igm files.  Aborting!']);
end
return
