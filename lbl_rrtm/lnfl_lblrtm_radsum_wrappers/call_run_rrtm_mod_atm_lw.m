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
%This script will call run_radsum.m for model atmosphere calculation
clear

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Edit these variables to point towards your installation directory for LBLRTM, LNFL,RADSUM, and CHARTS 
run_rrtm_input.Directory_Mat = ...
    str2mat('./scratch/', ...   %location to store temporary files
	    '/home/hermes_rd1/drf/lblrtm/rrtm/rrtm_lw/', ...    %location of rrtm_lw executable
	    '/home/hermes_rd1/drf/lblrtm/rrtm/rrtm_sw/'); 	%location of rrtm_sw executable
run_rrtm_input.Directory_List = str2mat('LOCAL','RRTM_LW','RRTM_SW');
run_rrtm_input.executable_names = str2mat('no executable', ...
					    'rrtm_linux_v3.0',...
					    'rrtm_sw_linux_pgi_v2.5');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Don't edit below unless you are familiar with how the LBLRTM/RRTM wrappers works


system('rm screendump.out');
diary('screendump.out');
tic

a = load('./mod_atm/TROPICAL.atm');

run_rrtm_input.observer_angle = 180; %zenith observation
run_rrtm_input.pz_obs = 0.012; %pressure at observer location (mbar)
run_rrtm_input.pz_surf = 1013; %pressure at end target (mbar)
run_rrtm_input.t_surf = a(1,3); %surface temperature (K)
run_rrtm_input.latitude = 32; %latitude of observation (degrees north)
run_rrtm_input.model = 0;     %Mid-Latitude Summer model atmosphere
run_rrtm_input.surf_v = [0 3500];
run_rrtm_input.surf_emis = [1 1];
run_rrtm_input.surf_refl = [0 0];

z_cutoff = 39;
full_atm = zeros(z_cutoff,35);
full_atm(:,1) = a(1:z_cutoff,1);
full_atm(:,2) = a(1:z_cutoff,2);
full_atm(:,3) = a(1:z_cutoff,3);
full_atm(:,4) = a(1:z_cutoff,5);
full_atm(:,5) = 380*ones(size(a(1:z_cutoff,1)));
full_atm(:,6) = a(1:z_cutoff,6);
full_atm(:,7) = a(1:z_cutoff,7);
full_atm(:,8) = a(1:z_cutoff,8);
full_atm(:,9) = a(1:z_cutoff,9);
run_rrtm_input.full_atm = full_atm;
run_rrtm_input.species_vec = zeros(1,32);
run_rrtm_input.species_vec(1:32) = 1; %first 8 hitran species
ILS.ILS_use = 0;
run_rrtm_input.pz_levs = a(1:z_cutoff,2);
run_rrtm_input.ILS = ILS;
run_rrtm_input.Flag_Vec = [1 0 0 1 1 0 0];
run_rrtm_input.Flag_List = ...
    str2mat('Erase_Flag','IWC_Flag','LWC_Flag','P_or_Z','Rad_or_Trans','RH_Flag','Temp_Flag');
run_rrtm_input.Latitude = 0;
run_rrtm_input.Julian_Day = 1;
run_rrtm_input.Solar_Zenith = 70;

clear LWC_struct IWC_struct
IWC_struct.num_clouds = 0;
LWC_struct.num_clouds = 0;

run_rrtm_input.IWC_struct = IWC_struct;
run_rrtm_input.LWC_struct = LWC_struct;
run_rrtm_input.channel = 99;

[run_rrtm_output] = run_rrtm_lw(run_rrtm_input);

diary off
toc

figure(1)
clf
plot(run_rrtm_output.spectral_heating_rate(1,:),flipud(full_atm(:,1)),'k')
xlabel('Heating Rate (K/day)');
ylabel('Altitude (km)');
title('Tropical Model Atmosphere Heating Rate');
