%
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
%This script will call run_radsum.m for the McClatchey Tropical model
%atmosphere test cases

clear
system('rm screendump.out');
diary('screendump.out');
tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Edit these variables to point towards your installation directory for LBLRTM, LNFL,RADSUM, and CHARTS 
run_radsum_input.Directory_Mat = ...
    str2mat('/home/hermes_rd1/drf/scratch/lblrtm_v11/lblrtm/', ... %location of lblrtm executable
	    '/home/hermes_rd1/drf/lblrtm/lnfl/', ...   %location of lnfl executable
	    '/home/hermes_rd1/drf/lblrtm/radsum/',...  %location of radsum executable
	    '/home/hermes_rd1/drf/charts/');           %location of charts executable
run_radsum_input.Directory_List = str2mat('LBLRTM','LNFL','RADSUM','CHARTS');
run_radsum_input.executable_names = str2mat('lblrtm_v11.1_pgi_linux_pgf90_dbl', ...
					    'lnfl_v2.1_pgf90_pgi_linux_sgl',...
					    'radsum_v2.4_linux_pgi_f90_dbl',...
					    'charts_lblv8.sgl');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Don't edit below unless you are familiar with how the LBLRTM wrapper works

CO2_level = 380;
a = load('./mod_atm/TROPICAL.atm');

run_radsum_input.v1 = 50; %cm^-1 30
run_radsum_input.v2 = 2000; %cm^-1 2000
run_radsum_input.dv = 1; %cm^-1
run_radsum_input.observer_angle = 180; %zenith observation
run_radsum_input.t_surf = 288.2; %surface temperature (K)
run_radsum_input.latitude = 32; %latitude of observation (degrees north)
run_radsum_input.model = 0;     %Mid-Latitude Summer model atmosphere
run_radsum_input.species_vec = ones(1,32);
z_cutoff = 42;
run_radsum_input.full_atm = zeros(z_cutoff,35); %full atmosphere

full_atm = zeros(z_cutoff,35);
full_atm(:,1) = a(1:z_cutoff,1); %altitude (km)
full_atm(:,2) = a(1:z_cutoff,2); %pressure (mbar)
full_atm(:,3) = a(1:z_cutoff,3); %temperature (K)
full_atm(:,4) = a(1:z_cutoff,5); %water vapor (ppmv)
full_atm(:,5) = CO2_level*ones(size(a(1:z_cutoff,1))); %CO2 (ppmv)
full_atm(:,6) = a(1:z_cutoff,6); %O3 (ppmv)
full_atm(:,7) = a(1:z_cutoff,7); %N2O (ppmv)
full_atm(:,8) = a(1:z_cutoff,8); %CO (ppmv) 
full_atm(:,9) = a(1:z_cutoff,9); %CH4 (ppmv)
run_radsum_input.full_atm = full_atm;
run_radsum_input.pz_levs = a(1:z_cutoff,2); %pressure levels (mbar)
run_radsum_input.pz_obs = min(full_atm(:,2)); %pressure at observer location (mbar)
run_radsum_input.pz_surf = max(full_atm(:,2)); %pressure at end target (mbar)
ILS.ILS_use = 0;
run_radsum_input.ILS = ILS;
run_radsum_input.Flag_Vec = [0 0 1 1 0 0];
run_radsum_input.Flag_List = ...
      str2mat('Aerosol_Flag','LNFL_Flag','P_or_Z','Rad_or_Trans','RH_Flag','Temp_Flag');

[run_radsum_output] = run_radsum(run_radsum_input);

colormap hsv
figure(1)
clf
imagesc(run_radsum_output.wavenumber,flipud(full_atm(:,1)),run_radsum_output.spectral_heating_rate'*-1e3,[-15 90])
c = colorbar;
xlabel('wavenumber (cm^-^1)');
ylabel('altitude (km)');
title('TROPICAL Spectral Cooling Rate Profile');
d = get(c,'title');
set(d,'string','mK/day/cm^-^1');
set(gca,'ydir','normal');

diary off
toc
