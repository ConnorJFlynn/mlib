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
%This script will call run_charts.m
%for model atmospheres, refer to Moncet et al 1997 for a description of CHARTS.  It is basically LBLRTM with scattering

clear
system('rm screendump.out');
diary('screendump.out');
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Edit these variables to point towards your installation directory for LBLRTM, LNFL,RADSUM, and CHARTS 
run_charts_input.Directory_Mat = ...
    str2mat('/home/hermes_rd1/drf/scratch/lblrtm_v11/lblrtm/', ... %location of lblrtm executable
	    '/home/hermes_rd1/drf/lblrtm/lnfl/', ...   %location of lnfl executable
	    '/home/hermes_rd1/drf/lblrtm/radsum/',...  %location of radsum executable
	    '/home/hermes_rd1/drf/charts/');           %location of charts executable
run_charts_input.Directory_List = str2mat('LBLRTM','LNFL','RADSUM','CHARTS');
run_charts_input.executable_names = str2mat('lblrtm_v11.1_pgi_linux_pgf90_dbl', ...
					    'lnfl_v2.1_pgf90_pgi_linux_sgl',...
					    'radsum_v2.4_linux_pgi_f90_dbl',...
					    'charts_lblv8.sgl');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Don't edit below unless you are familiar with how the LBLRTM wrapper works

CO2_level = 360;
a = load('./mod_atm/TROPICAL.atm');

run_charts_input.v1 = 500; %cm^-1
run_charts_input.v2 = 800; %cm^-1
run_charts_input.dv = 1; %cm^-1
run_charts_input.observer_angle = 180; %zenith observation
run_charts_input.pz_obs = 70; %pressure at observer location (mbar)
run_charts_input.pz_surf = 0; %pressure at end target (mbar)
run_charts_input.t_surf = a(1,3); %surface temperature (K)
run_charts_input.latitude = 32; %latitude of observation (degrees north)
run_charts_input.model = 0;     %Mid-Latitude Summer model atmosphere
run_charts_input.surf_v = [0 3500];
run_charts_input.surf_emis = [1 1];
run_charts_input.surf_refl = [0 0];

z_cutoff = 42;
full_atm = zeros(z_cutoff,35);
full_atm(:,1) = a(1:z_cutoff,1);
full_atm(:,2) = a(1:z_cutoff,2);
full_atm(:,3) = a(1:z_cutoff,3);
full_atm(:,4) = a(1:z_cutoff,5);
full_atm(:,5) = CO2_level*ones(size(a(1:z_cutoff,1)));
full_atm(:,6) = a(1:z_cutoff,6);
full_atm(:,7) = a(1:z_cutoff,7);
full_atm(:,8) = a(1:z_cutoff,8);
full_atm(:,9) = a(1:z_cutoff,9);
run_charts_input.full_atm = full_atm;
run_charts_input.species_vec = zeros(1,32);
run_charts_input.species_vec(1:32) = 1; %first 8 hitran species
ILS.ILS_use = 0;
run_charts_input.pz_levs = a(1:z_cutoff,1);
run_charts_input.ILS = ILS;
run_charts_input.Flag_Vec = [0 0 0 1 0 0 0];
run_charts_input.Flag_List = ...
    str2mat('Aerosol_Flag','LNFL_Flag','P_or_Z', ...
	    'Rad_or_Trans','RH_Flag','Solar_Flag','Temp_Flag');
%run_charts_input.cloud_level
%run_charts_input.level_type
%run_charts_input.scale_factor
%run_charts_input.omega
%run_charts_input.asym

blah = 1;
if blah == 1
  [run_lblrtm_output] = run_lblrtm(run_charts_input);
  rad_mat = zeros(length(run_lblrtm_output.wavenumber),z_cutoff)
  rad_mat(:,1) = run_lblrtm_output.radiance;
  for i=2:z_cutoff
    dummy = run_charts_input;
    dummy.pz_obs = full_atm(z_cutoff+1-i,2);
    
    dummy2 = run_lblrtm(dummy);
    rad_mat(1:length(dummy2.radiance),i) = dummy2.radiance;
  end
  save
  keyboard
else
  load
end
[run_charts_output] = run_charts(run_charts_input);

diary off
toc
