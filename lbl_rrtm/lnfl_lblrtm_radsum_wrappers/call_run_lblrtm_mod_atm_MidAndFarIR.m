%(C) Dan Feldman 2009, all rights retained
%    Disclaimer of Warranty. DANIEL FELDMAN PROVIDES THE SOFTWARE AND THE SERVICES "AS IS" WITHOUT WARRANTY 
%    OF ANY KIND EITHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
%    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. ALL RISK OF QUALITY AND PERFORMANCE OF THE 
%    SOFTWARE OR SERVICES REMAINS WITH YOU. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL PART OF THIS AGREEMENT.
%
%    Limitation of Remedies. IN NO EVENT WILL DANIEL FELDMAN, DISTRIBUTORS, DIRECTORS OR AGENTS BE LIABLE 
%    FOR ANY INDIRECT DAMAGES OR OTHER RELIEF ARISING OUT OF YOUR USE OR INABILITY TO USE THE SOFTWARE OR 
%    SERVICES INCLUDING, BY WAY OF ILLUSTRATION AND NOT LIMITATION, LOST PROFITS, LOST BUSINESS OR LOST  
%    OPPORTUNITY, OR ANY INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL OR EXEMPLARY DAMAGES,  
%    INCLUDING LEGAL FEES, ARISING OUT OF SUCH USE OR INABILITY TO USE THE PROGRAM, EVEN IF DANIEL FELDMAN 
%    OR AN AUTHORIZED LICENSOR DEALER, DISTRIBUTOR OR SUPPLIER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES, 
%    OR FOR ANY CLAIM BY ANY OTHER PARTY. BECAUSE SOME STATES OR JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR THE  
%    LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES, IN SUCH STATES OR JURISDICTIONS, 
%    DANIEL FELDMAN'S LIABILITY SHALL BE LIMITED TO THE EXTENT PERMITTED BY LAW.
%
%    Daniel Feldman's Liability. Daniel Feldman assumes no liability hereunder for, 
%    and shall have no obligation to defend you or to pay costs, damages or attorney's fees for, 
%    any claim based upon: (i) any method or process in which the Software or Services may be used by you; 
%    (ii) any results of using the Software or Services; 
%    (iii) any use of other than a current unaltered release of the Software; or 
%    (iv) the combination, operation or use of any of the Software or Services furnished hereunder 
%    with other programs or data if such infringement would have been avoided by the combination, 
%    operation, or use of the Software or Services with other programs or data. 
%
%    If you do not agree to these terms, discontinue use of this software immediately.
%    Daniel Feldman is not affiliated with AER, Inc.
%
%This script will call run_lblrtm.m
%for model atmospheres and cover the mid- and far-infrared
clear
system('rm screendump.out');
diary('screendump.out');
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Edit these variables to point towards your installation directory for LBLRTM, LNFL,RADSUM, and CHARTS 
run_lblrtm_input.Directory_Mat = ...
    str2mat('/home/hermes_rd1/drf/scratch/lblrtm_v11/lblrtm/', ... %location of lblrtm executable
	    '/home/hermes_rd1/drf/lblrtm/lnfl/', ...   %location of lnfl executable
	    '/home/hermes_rd1/drf/lblrtm/radsum/',...  %location of radsum executable
	    '/home/hermes_rd1/drf/charts/');           %location of charts executable
run_lblrtm_input.Directory_List = str2mat('LBLRTM','LNFL','RADSUM','CHARTS');
run_lblrtm_input.executable_names = str2mat('lblrtm_v11.1_pgi_linux_pgf90_dbl', ...
					    'lnfl_v2.1_pgf90_pgi_linux_sgl',...
					    'radsum_v2.4_linux_pgi_f90_dbl',...
					    'charts_lblv8.sgl');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Don't edit below unless you are familiar with how the LBLRTM wrapper works

CO2_level = 380;
a = load('./mod_atm/USSTD.atm');

run_lblrtm_input.v1 = 50; %cm^-1
run_lblrtm_input.v2 = 2000; %cm^-1
run_lblrtm_input.observer_angle = 180; %nadir observation
run_lblrtm_input.pz_obs = 70; %pressure at observer location (km)
run_lblrtm_input.pz_surf = 0; %pressure at end target (km)
run_lblrtm_input.t_surf = a(1,3); %surface temperature (K)
run_lblrtm_input.latitude = 32; %latitude of observation (degrees north)
run_lblrtm_input.model = 0;     %user-defined atmosphere
run_lblrtm_input.surf_v = [0 3500];
run_lblrtm_input.surf_emis = [1 1];
run_lblrtm_input.surf_refl = [0 0];

z_cutoff = 42;
full_atm = zeros(z_cutoff,35);  %variable #rows, 35 columns
full_atm(:,1) = a(1:z_cutoff,1); %altitude (km)
full_atm(:,2) = a(1:z_cutoff,2); %pressure (mbar)
full_atm(:,3) = a(1:z_cutoff,3); %temperature (K)
full_atm(:,4) = a(1:z_cutoff,5); %H2O (ppmv)
full_atm(:,5) = CO2_level*ones(size(a(1:z_cutoff,1))); %CO2
full_atm(:,6) = a(1:z_cutoff,6); %O3
full_atm(:,7) = a(1:z_cutoff,7); %N2O
full_atm(:,8) = a(1:z_cutoff,8); %CO
full_atm(:,9) = a(1:z_cutoff,9); %CH4
run_lblrtm_input.full_atm = full_atm;
run_lblrtm_input.species_vec(1:32) = 1; %first 8 hitran species
run_lblrtm_input.pz_levs = a(1:z_cutoff,1); %km
ILS.ILS_use = 1;
ILS.HWHM = 0.5;    %half-width at half-maximum of ILS
ILS.V1   = run_lblrtm_input.v1;    %beginning wavenumber for instrument output
ILS.V2   = run_lblrtm_input.v2;  %ending wavenumber for instrument output
ILS.JFN  = 0;     %boxcar function 
run_lblrtm_input.ILS = ILS;
run_lblrtm_input.Flag_Vec = [0 0 0 1 0 0];
run_lblrtm_input.Flag_List = ...
    str2mat('Aerosol_Flag','LNFL_Flag','P_or_Z', ...
	    'Rad_or_Trans','RH_Flag','Temp_Flag');
run_lblrtm_input.Directory_List = str2mat('LBLRTM','LNFL','RADSUM','CHARTS');

[run_lblrtm_output] = run_lblrtm(run_lblrtm_input);


run_lblrtm_input.v1 = 2000; %cm^-1
run_lblrtm_input.v2 = 2700; %cm^-1
ILS.V1   = run_lblrtm_input.v1;    %beginning wavenumber for instrument output
ILS.V2   = run_lblrtm_input.v2;  %ending wavenumber for instrument output
ILS.JFN  = 0;     %boxcar function 
run_lblrtm_input.ILS = ILS;

[run_lblrtm_output2] = run_lblrtm(run_lblrtm_input);



%b = planck(a(1,3),run_lblrtm_output.wavenumber)*0.01;
%figure(1)
%clf
%plot(1e4./run_lblrtm_output.wavenumber,1e7*(b-run_lblrtm_output.radiance),'k','LineWidth',1.2)
%set(gca,'xtick',[5 10 20 50 100 200],'FontSize',16);
%set(gca,'xlim',[4 300]);
%set(gca,'xscale','log')
%ylabel('\DeltaRadiance (mW/cm^2/sr/cm^-^1)');
%xlabel('wavelength (\mum)');
%title('Greenhouse Factor BB_T_S_u_r_f - Radiance_T_O_A');
%orient landscape 

%print(1,'-dpsc','trp_greenhouse_factor');
%system('ps2pdf trp_greenhouse_factor.ps');
%delete('trp_greenhouse_factor.ps');

run_lblrtm_output.wavenumber = [run_lblrtm_output.wavenumber' run_lblrtm_output2.wavenumber'];
run_lblrtm_output.radiance = [run_lblrtm_output.radiance' run_lblrtm_output2.radiance'];


figure(1)
clf
plot(run_lblrtm_output.wavenumber,1e7*run_lblrtm_output.radiance,'k','LineWidth',1.1);
set(gca,'xtick',[0:200:2700],'fontsize',16);
set(gca,'xlim',[0 2700]);
xlabel('wavenumber (cm^-^1)');
ylabel('Radiance (mW/m^2/sr/cm^-^1)');
title('High-Resolution Spectrum for 1976 US Standard Atmosphere (Anderson et al, 1986)');
orient landscape

print(1,'-dpsc','usstd_highres_spectrum');
system('ps2pdf usstd_highres_spectrum.ps');
delete('usstd_highres_spectrum.ps');
system('mv usstd_highres_spectrum.pdf ./figs');

figure(1)
clf
[bt,dummy] = convert_to_BT(run_lblrtm_output.radiance,run_lblrtm_output.wavenumber);
plot(run_lblrtm_output.wavenumber,bt,'k','LineWidth',1.1);
set(gca,'xtick',[0:200:2700],'fontsize',16);
set(gca,'xlim',[0 2700]);
xlabel('wavenumber (cm^-^1)');
ylabel('Brightness Temperature (K)');
title('High-Resolution Spectrum for 1976 US Standard Atmosphere (Anderson et al, 1986)');
orient landscape

print(1,'-dpsc','usstd_highres_spectrum_bt');
system('ps2pdf usstd_highres_spectrum_bt.ps');
delete('usstd_highres_spectrum_bt.ps');
system('mv usstd_highres_spectrum_bt.pdf ./figs');
