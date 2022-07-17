function out = pre_ASR_test_sbdart
% Trying to get T for various atmospheric constituents via SBDART:

%SBDART input values:
% Clear all components:
in_pth = getpath('sbdart','Select path to SBDART executable.')

clear sbd out qry
%SBDART Intro Example 1
qry.idatm=4;
qry.isat=0;
qry.wlinf = .25;
qry.wlsup = 1.0;
qry.wlinc = 0.005;
qry.iout = 1;

[out] = qry_sbdart(qry);
% Worked!  Plot looks good, matches documentation.

%SBDART Intro Example 2
clear qry
qry.idatm=4; 
qry.isat=0;
qry.wlinf=.55;
qry.wlsup=.55;
qry.isalb=0;
qry.iout=10;
qry.sza=30;
for albcon = [0:.2:1]
    for tcloud = [0,1,2,4,8,16,32,64];
        qry.albcon = albcon;
        qry.tcloud = tcloud;
        qry_sbdart(qry,'sbchk2.dat','>>');
    end
end
%Seemed to run fine but I never did parse the output file as presented in the docs

%SBDART Intro Example 3: Spectral output in Thermal IR

clear qry
qry.zcloud = 8;
qry.nre = 10;
qry.idatm = 4;
qry.sza = 95;
qry.wlinf = 4;
qry.wlsup = 20;
qry.wlinc = -.01;
qry.iout = 1;

for tcloud = [0,1,5]
    qry.tcloud = tcloud;
    qry_sbdart(qry,'sbchk3.dat','>>')
end


%%
%PPL
clear qry
% from Gouyong
qry.iout=21;
qry.NF=3;
qry.idatm=2;
qry.isat=16;
% qry.wlinf=0.615;
% qry.wlsup=0.615;
% qry.wlinc=.001;
qry.IAER=3;
qry.TBAER=0.3;
qry.RHAER=0.8;
qry.SAZA=180;
qry.SZA=70;
qry.CORINT='.true.';
% qry.zout = [0,0];
qry.PHI=[0,180];
UZEN =sort([0:5:95]); 
qry.UZEN = fliplr(180-setxor(UZEN,qry.SZA));
[out] = qry_sbdart(qry);


% edit and play...
clear qry
qry.iout=21;
qry.NF=3;
qry.idatm=2;
qry.isat=16;
% qry.wlinf=0.615;
% qry.wlsup=0.615;
% qry.wlinc=.001;
qry.IAER=3;
qry.TBAER=0.3;
qry.RHAER=0.8;
qry.SAZA=180;
qry.SZA=70;
qry.CORINT='.true.';
% qry.zout = [0,0];
qry.PHI=[0 180];
UZEN =sort([0:5:95]); 
qry.UZEN = fliplr(180-setxor(UZEN,qry.SZA));
[out] = qry_sbdart(qry);


%ALM
clear qry
% from Gouyong
qry.iout=21;
qry.NF=3;
qry.idatm=2;
% qry.wlinf=0.615;
% qry.wlsup=0.615;
qry.isat=16;
% qry.wlinc=.001;
qry.ISALB=4;
% qry.ZCLOUD=1;
qry.IAER=3;
qry.TBAER=0.3;
qry.RHAER=0.8;
qry.SAZA=180;
qry.SZA=75;
qry.NSTR=20;
qry.CORINT='.true.';
% qry.zout = [0,0];
qry.NPHI = 20
qry.PHI=[1 359];
UZEN =[15 30 45 60]; 
qry.UZEN = fliplr(180-setxor(UZEN,qry.SZA));
out = qry_sbdart(qry);

return 

qry.SZA=60;
qry.IOUT = 1; % WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
qry.NF = 3; % Modtran resolution 20 cm-1, 
% qry.NF = 1; % 5s solar spectrum, 5 nm res, 
qry.wlinf   =  0.30;
qry.wlsup   =  4.0;
qry.wlinc   =  0.01;
qry.idatm = 2; % mid-latitude summer
qry.idatm = 6; % US 62
qry.IAER = 2; % Urban aerosol

qry.XN2 = -1;qry.XO2 = -1;
qry.XRSC = 0; qry.tbaer =0; qry.UW = 0; qry.UO3 =0;qry.XO2 = 0; 
qry.XO4 = 0; qry.XCH4 =0; qry.XCO2 = 0; qry.XN2O = 0; qry.XCO= 0; 
qry.XNH3= 0; qry.XSO2= 0; qry.XNO= 0; qry.XHNO3= 0; qry.XNO2= 0; 
%% First generate subcomponents:
% Rayleigh
disp('Starting Rayleigh')
tic
qry.XRSC = 1; % 0 = no Rayleigh scattering

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with Rayleigh')
ray = sbd;
%
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('Rayleigh optical depth')

figure; 
subplot(2,1,1);
semilogy(sbd.wl, (sbd.botdir ./ sbd.topdir), 'r-', sbd.wl, ((sbd.botdn-sbd.botdir) ./ sbd.topdir), 'b-')
legend('direct T', 'diffuse T')
subplot(2,1,2);
semilogy(sbd.wl, ((sbd.botdn-sbd.botdir) ./ sbd.topdir)./(sbd.botdir ./ sbd.topdir), 'k')
%
clear sbd out 

disp('Starting Aerosol')
tic
qry.XRSC = 0; % 0 = no Rayleigh scattering
qry.tbaer =.3;

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir).*cosd(qry.SZA), 'r-');
title('Aerosol optical depth')
%%

disp('done with Aerosol')
aero = sbd;
clear sbd out 
%

disp('Starting water vapor')
tic
qry.tbaer =0;
qry.UW = -1;

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with water vapor')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('water vapor "optical depth"')
%%

pwv = sbd;
clear sbd out 
%
disp('Starting Ozone')
tic
qry.UW = 0;
qry.UO3 =-1;

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with Ozone')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('Ozone optical depth')
%%

O3 = sbd;

% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1}; sbd.ffv = out{:,2}; sbd.topdn = out{:,3}; sbd.topup = out{:,4};
sbd.topdir = out{:,5}; sbd.botdn = out{:,6}; sbd.botup = out{:,7}; sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir); sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done ')
%  figure; 
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');

%%
title('Oxygen gas (and A-band) optical depth')


O2 = sbd;
clear sbd out 
%
disp('Starting Methane')
tic
qry.XO2 = 0;
qry.XO4 = 0;
qry.XCH4 = -1;
qry.XCO2 = 0;
qry.XN2O = 0; %: volume mixing ratio of N2O (PPM, default = 0.32 )
qry.XCO= 0; %: volume mixing ratio of CO (PPM, default = 0.15 )
qry.XNH3= 0; %: volume mixing ratio of NH3 (PPM, default = 5.0e-4)
qry.XSO2= 0; %: volume mixing ratio of SO2 (PPM, default = 3.0e-4)
qry.XNO= 0; %: volume mixing ratio of NO (PPM, default = 3.0e-4)
qry.XHNO3= 0; %: volume mixing ratio of HNO3 (PPM, default = 5.0e-5)
qry.XNO2= 0; %: volume mixing ratio of NO2 (PPM, default = 2.3e-5)

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with Methane')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('Methane optical depth')
%%

CH4 = sbd;
clear sbd out 
%
disp('Starting CO2')
tic
qry.XCH4 = 0;
qry.XCO2 = -1;
qry.XN2O = 0; %: volume mixing ratio of N2O (PPM, default = 0.32 )
qry.XCO= 0; %: volume mixing ratio of CO (PPM, default = 0.15 )
qry.XNH3= 0; %: volume mixing ratio of NH3 (PPM, default = 5.0e-4)
qry.XSO2= 0; %: volume mixing ratio of SO2 (PPM, default = 3.0e-4)
qry.XNO= 0; %: volume mixing ratio of NO (PPM, default = 3.0e-4)
qry.XHNO3= 0; %: volume mixing ratio of HNO3 (PPM, default = 5.0e-5)
qry.XNO2= 0; %: volume mixing ratio of NO2 (PPM, default = 2.3e-5)

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with CO2')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('CO2 optical depth')
%%

CO2 = sbd;
clear sbd out 
%
disp('Starting N2O')
tic
qry.XCO2 = 0;
qry.XN2O = -1; %: volume mixing ratio of N2O (PPM, default = 0.32 )
qry.XCO= 0; %: volume mixing ratio of CO (PPM, default = 0.15 )
qry.XNH3= 0; %: volume mixing ratio of NH3 (PPM, default = 5.0e-4)
qry.XSO2= 0; %: volume mixing ratio of SO2 (PPM, default = 3.0e-4)
qry.XNO= 0; %: volume mixing ratio of NO (PPM, default = 3.0e-4)
qry.XHNO3= 0; %: volume mixing ratio of HNO3 (PPM, default = 5.0e-5)
qry.XNO2= 00; %: volume mixing ratio of NO2 (PPM, default = 2.3e-5)

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with N2O')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('N2O optical depth')
%%

N2O = sbd;
%
clear sbd out 
%
disp('Starting NO2')
tic
qry.XCO2 = 0;
qry.XN2O = 0; %: volume mixing ratio of N2O (PPM, default = 0.32 )
qry.XCO= 0; %: volume mixing ratio of CO (PPM, default = 0.15 )
qry.XNH3= 0; %: volume mixing ratio of NH3 (PPM, default = 5.0e-4)
qry.XSO2= 0; %: volume mixing ratio of SO2 (PPM, default = 3.0e-4)
qry.XNO= 0; %: volume mixing ratio of NO (PPM, default = 3.0e-4)
qry.XHNO3= 0; %: volume mixing ratio of HNO3 (PPM, default = 5.0e-5)
qry.XNO2= 2.3e-1; %: volume mixing ratio of NO2 (PPM, default = 2.3e-5)

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with NO2')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('NO2 optical depth')
%%

NO2 = sbd;
%

qry.XRSC = 1; qry.tbaer =0.3; qry.UW = -1; qry.UO3 =-1;qry.XO2 = -1; 
qry.XO4 = 1; qry.XCH4 =-1; qry.XCO2 = -1; qry.XN2O = -1; qry.XCO= -1; 
qry.XNH3= -1; qry.XSO2= -1; qry.XNO= -1; qry.XHNO3= -1; qry.XNO2= -1; 
% First generate subcomponents:
Rayleigh
disp('Starting full deal')
tic
[qry_cell,out] = write_sbdart_input(qry,in_pth);
WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with full deal')
%
figure; 
subplot(2,1,1);
semilogy(log10(1000.*sbd.wl), sbd.botdir ./ sbd.topdir, 'k-', ...
   log10(1000.*sbd.wl), (sbd.botdn-sbd.botdir)./ sbd.topdir, 'r-');
set(gca,'xtick',log10([300,450,600,800,1100,1400,1700]));
set(gca,'xticklabel',num2str([300;450;600;800;1100;1400;1700]))
title('SBDART mid-latitude summer atmospheric transmittance')
ylabel({'transmittance','[unitless]'});
xlabel('wavelength [nm]');
legend('direct','diffuse')
xlim(log10([300, 1700])); ylim([1e-4,2]);
set(gca, 'xgrid','on', 'xminorgrid','off')
set(gca,'ygrid','on','yminorgrid','off')
set(gca, 'xgrid','on', 'xminorgrid','on')
set(gca, 'xgrid','on', 'xminorgrid','off')
title('mid-lat summer atmospheric transmittance (from SBDART)');
figpos = [-1415         425        1399         393];
axpos = [0.0936    0.1807    0.7655    0.6870];
set(gcf,'position',figpos); set(gca,'units','normalized','position',axpos)
%
figure; 
subplot(2,1,1);
semilogy(log10(1000.*sbd.wl), 1e-3.*sbd.botdir,'-k',...
  log10(1000.*sbd.wl) , sbd.botdn-sbd.botdir, 'r-');
mfr_x = [415,500,615,673,780,940];mfr_x = [mfr_x;mfr_x];
mfr_y = [1e-2.*ones([1,6]);1e4.*ones([1,6])];
mfr_ll = lines(mfr_x,mfr_y,'linestyle','dashed');

set(gca,'xtick',log10([300,450,600,800,1100,1400,1700]));
set(gca,'xticklabel',num2str([300;450;600;800;1100;1400;1700]))
title('Mid-lat summer direct and diffuse irradiance, SZA=0 (from SBDART)')
ylabel({'irradiance','[W/m^2]'});
xlabel('wavelength [nm]')
legend('direct','diffuse')
xlim(log10([300, 1700])); 
set(gca, 'xgrid','on', 'xminorgrid','off')
set(gca,'ygrid','on','yminorgrid','off')
set(gca, 'xgrid','on', 'xminorgrid','on')
set(gca, 'xgrid','on', 'xminorgrid','off')
set(gcf,'position',figpos); set(gca,'units','normalized','position',axpos)
%

N2O = sbd;

%

clear sbd out 
%
disp('Starting CO')
tic
qry.XN2O = 0; %: volume mixing ratio of N2O (PPM, default = 0.32 )
qry.XCO= -1; %: volume mixing ratio of CO (PPM, default = 0.15 )
qry.XNH3= 0; %: volume mixing ratio of NH3 (PPM, default = 5.0e-4)
qry.XSO2= 0; %: volume mixing ratio of SO2 (PPM, default = 3.0e-4)
qry.XNO= 0; %: volume mixing ratio of NO (PPM, default = 3.0e-4)
qry.XHNO3= 0; %: volume mixing ratio of HNO3 (PPM, default = 5.0e-5)
qry.XNO2= 0; %: volume mixing ratio of NO2 (PPM, default = 2.3e-5)

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with CO')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('CO optical depth')
%%

CO = sbd;
clear sbd out 
%
%
disp('Starting NH3')
tic
qry.XCO= 0; %: volume mixing ratio of CO (PPM, default = 0.15 )
qry.XNH3= -1; %: volume mixing ratio of NH3 (PPM, default = 5.0e-4)
qry.XSO2= 0; %: volume mixing ratio of SO2 (PPM, default = 3.0e-4)
qry.XNO= 0; %: volume mixing ratio of NO (PPM, default = 3.0e-4)
qry.XHNO3= 0; %: volume mixing ratio of HNO3 (PPM, default = 5.0e-5)
qry.XNO2= 0; %: volume mixing ratio of NO2 (PPM, default = 2.3e-5)

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with NH3')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('NH3 optical depth')
%%

NH3 = sbd;
clear sbd out 
%
%
disp('Starting SO2')
tic
qry.XNH3= 0; %: volume mixing ratio of NH3 (PPM, default = 5.0e-4)
qry.XSO2= -1; %: volume mixing ratio of SO2 (PPM, default = 3.0e-4)
qry.XNO= 0; %: volume mixing ratio of NO (PPM, default = 3.0e-4)
qry.XHNO3= 0; %: volume mixing ratio of HNO3 (PPM, default = 5.0e-5)
qry.XNO2= 0; %: volume mixing ratio of NO2 (PPM, default = 2.3e-5)

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with SO2')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('SO2 optical depth')
%%

SO2 = sbd;
clear sbd out 
%
%
disp('Starting NO')
tic
qry.XSO2= 0; %: volume mixing ratio of SO2 (PPM, default = 3.0e-4)
qry.XNO= -1; %: volume mixing ratio of NO (PPM, default = 3.0e-4)
qry.XHNO3= 0; %: volume mixing ratio of HNO3 (PPM, default = 5.0e-5)
qry.XNO2= 0; %: volume mixing ratio of NO2 (PPM, default = 2.3e-5)

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with NO')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('NO optical depth')
%%

NO = sbd;
clear sbd out 
%
%
disp('Starting HNO3')
tic
qry.XNO= 0; %: volume mixing ratio of NO (PPM, default = 3.0e-4)
qry.XHNO3= -1; %: volume mixing ratio of HNO3 (PPM, default = 5.0e-5)
qry.XNO2= 0; %: volume mixing ratio of NO2 (PPM, default = 2.3e-5)

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with HNO3')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('HNO3 optical depth')
%%

HNO3 = sbd;
clear sbd out 
%
disp('Starting NO2')
tic
qry.XHNO3= 0; %: volume mixing ratio of HNO3 (PPM, default = 5.0e-5)
qry.XNO2= -1; %: volume mixing ratio of NO2 (PPM, default = 2.3e-5)

[qry_cell,out] = write_sbdart_input(qry,in_pth);
% WL,FFV,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR
sbd.wl = out{:,1};
sbd.ffv = out{:,2};
sbd.topdn = out{:,3};
sbd.topup = out{:,4};
sbd.topdir = out{:,5};
sbd.botdn = out{:,6};
sbd.botup = out{:,7};
sbd.botdir = out{:,8};
sbd.T_dir = (sbd.botdir ./ sbd.topdir);
sbd.T_dif = ((sbd.botdn-sbd.botdir) ./ sbd.topdir);
sbd.tau = -log(sbd.T_dir);
toc
disp('done with NO2')
figure; 
% subplot(2,1,1);
semilogy(sbd.wl, -log(sbd.botdir ./ sbd.topdir), 'r-');
title('NO2 optical depth')
%%

NO2 = sbd;
clear sbd out 

%%
figure; 
% subplot(2,1,1);
plots_ppt;
semilogy(log10(1000.*ray.wl), [ray.tau,aero.tau,pwv.tau, O3.tau, O2.tau, CH4.tau, CO2.tau ], '-', ...
   log10(1000.*ray.wl), sum([ray.tau,aero.tau,pwv.tau, O3.tau, O2.tau, CH4.tau, CO2.tau],2), 'k-');
od_ax = gca;
set(od_ax,'xtick',log10([300,450,600,800,1100,1400,1700]));
set(od_ax,'xticklabel',num2str([300;450;600;800;1100;1400;1700]))
title('SBDART mid-latitude summer atmospheric composition in optical depth')
ylabel('ln(1/T) "Optical Thickness"');
xlabel('wavelength [nm]')
legend('Rayleigh','aerosol','H_2O vapor','O_3','O_2 and O_4','CH_4','CO_2','Total');
xlim(log10([300, 1700])); ylim([1e-3,2])
%%
sbd_midlat_Iout10.wl = sbd.wl;
sbd_midlat_Iout10.topdn = sbd.topdn;
sbd_midlat_Iout10.od_total = sum([ray.tau,aero.tau,pwv.tau, O3.tau, O2.tau, CH4.tau, CO2.tau],2);
sbd_midlat_Iout10.T_dir_total = prod([ray.T_dir,aero.T_dir,pwv.T_dir, O3.T_dir, O2.T_dir, CH4.T_dir, CO2.T_dir],2);
sbd_midlat_Iout10.T_diff_total = prod([ray.T_dif,aero.T_dif,pwv.T_dif, O3.T_dif, O2.T_dif, CH4.T_dif, CO2.T_dif],2);
sbd_midlat_Iout10.ray = ray;
sbd_midlat_Iout10.aero = aero;
sbd_midlat_Iout10.pwv = pwv;
sbd_midlat_Iout10.O3 = O3;
sbd_midlat_Iout10.O2 = O2;
sbd_midlat_Iout10.CH4 = CH4;
sbd_midlat_Iout10.CO2 = CO2;
save('C:\Connor.Flynn\presents\ARM\ASR_STM\SBDART_midlat_summer.mat','sbd_midlat_Iout10')
%%


figure; 
subplot(2,1,1);
semilogy(sbd.wl, (sbd_midlat_Iout10.T_dir_total), 'r-', sbd.wl, sbd_midlat_Iout10.T_diff_total, 'b-')
legend('direct T', 'diffuse T')
subplot(2,1,2);
semilogy(sbd.wl, (sbd_midlat_Iout10.T_diff_total)./(sbd_midlat_Iout10.T_dir_total), 'k')
%%
%%

%DEFAULT INPUTS:
%
%   idatm   =  4           amix    =  0.0         isat    =  0         
%   wlinf   =  0.550       wlsup   =  0.550       wlinc   =  0.0       
%   sza     =  0.0         csza    =  -1.0        solfac  =  1.0       
%   nf      =  2           iday    =  0           time    =  16.0      
%   alat    =  -64.7670    alon    =  -64.0670    zpres   =  -1.0      
%   pbar    =  -1.0        sclh2o  =  -1.0        uw      =  -1.0      
%   uo3     =  -1.0        o3trp   =  -1.0        ztrp    =  0.0       
%   xrsc    =  1.0         xn2     =  -1.0        xo2     =  -1.0      
%   xco2    =  -1.0        xch4    =  -1.0        xn2o    =  -1.0      
%   xco     =  -1.0        xno2    =  -1.0        xso2    =  -1.0      
%   xnh3    =  -1.0        xno     =  -1.0        xhno3   =  -1.0      
%   xo4     =  1.0         isalb   =  0           albcon  =  0.0       
%   sc      =  1.0,3*0.0   zcloud  =  5*0.0       tcloud  =  5*0.0     
%   lwp     =  5*0.0       nre     =  5*8.0       rhcld   =  -1.0      
%   krhclr  =  0           jaer    =  5*0         zaer    =  5*0.0     
%   taerst  =  5*0.0       iaer    =  0           vis     =  23.0      
%   rhaer   =  -1.0        wlbaer  =  47*0.0      tbaer   =  47*0.0    
%   abaer   =  -1.0        wbaer   =  47*0.950    gbaer   =  47*0.70   
%   pmaer   =  940*0.0     zbaer   =  50*-1.0     dbaer   =  50*-1.0   
%   nothrm  =  -1          nosct   =  0           kdist   =  3         
%   zgrid1  =  0.0         zgrid2  =  30.0        ngrid   =  50        
%   zout    =  0.0,100.0   iout    =  10          deltam  =  t         
%   lamber  =  t           ibcnd   =  0           saza    =  180.0     
%   prnt    =  7*f         ipth    =  1           fisot   =  0.0       
%   temis   =  0.0         nstr    =  4           nzen    =  0         
%   uzen    =  20*-1.0     vzen    = 20*90        nphi    =  0         
%   phi     =  20*-1.0     imomc   =  3           imoma   =  3         
%   ttemp   =  -1.0        btemp   =  -1.0        spowder =  f         
%   idb     =  20*0
%  