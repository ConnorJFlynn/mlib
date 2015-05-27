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
%This script will call run_radsum.m
clear
system('rm screendump.out');
diary('screendump.out');
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Edit these variables to point towards your installation directory for LBLRTM, LNFL,RADSUM, and CHARTS 
run_rrtm_input.Directory_Mat = ...
    str2mat('./scratch/', ...   %location to store temporary files
	    '/home/hermes_rd1/drf/lblrtm/rrtm/rrtm_lw/', ...    %location of rrtm_lw executable
	    '/home/hermes_rd1/drf/lblrtm/rrtm/rrtm_sw/rrtm_sw/'); 	%location of rrtm_sw executable
run_rrtm_input.Directory_List = str2mat('LOCAL','RRTM_LW','RRTM_SW');
run_rrtm_input.executable_names = str2mat('no executable', ...
					    'rrtm_linux_v3.0',...
					    'rrtm_sw_linux_pgi_v2.5');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Don't edit below unless you are familiar with how the LBLRTM wrapper works

a = load('./mod_atm/MLS.atm');
dummy = load('masuda_emissivity');
emissivity = dummy(:,1);
surf_v = dummy(:,2);
dummy = load('masuda_reflectivity');
reflectivity = dummy(:,2);

run_rrtm_input.observer_angle = 180; %zenith observation
run_rrtm_input.Latitude = 0; %latitude of observation (degrees north)
run_rrtm_input.Solar_Zenith = 60;
run_rrtm_input.Julian_Day = 1;
run_rrtm_input.model = 0;     %user-defined model atmosphere
run_rrtm_input.surf_v = surf_v;
run_rrtm_input.surf_emis = emissivity;
run_rrtm_input.surf_refl = reflectivity;
run_rrtm_input.species_vec = zeros(1,32);
run_rrtm_input.species_vec(1:32) = 1; %first 8 hitran species
run_rrtm_input.Flag_List = ...
    str2mat('Aerosol_Flag','Batch_Flag','Erase_Flag','IWC_Flag','LWC_Flag', ...
            'P_or_Z','Rad_or_Trans','RH_Flag','Temp_Flag');

z_cutoff = 42;
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
run_rrtm_input.t_surf = full_atm(1,3);
run_rrtm_input.species_vec = zeros(1,32);
run_rrtm_input.species_vec(1:32) = 1; %first 8 hitran species
run_rrtm_input.pz_obs = min(full_atm(:,2)); %pressure at observer location (mbar)
run_rrtm_input.pz_surf = max(full_atm(:,2)); %pressure at end target (mbar)

clear LWC_struct IWC_struct
IWC_struct.num_clouds = 0;
LWC_struct.num_clouds = 0;

run_rrtm_input.pz_levs = full_atm(:,2);
run_rrtm_input.Flag_Vec = [0 0 1 0 0 1 1 0 0];
run_rrtm_input.IWC_struct = IWC_struct;
run_rrtm_input.LWC_struct = LWC_struct;
run_rrtm_input.channel = 99;

[run_rrtm_lw_output] = run_rrtm_lw(run_rrtm_input);

run_rrtm_input.channel = 98;
[run_rrtm_sw_output] = run_rrtm_sw(run_rrtm_input);

diary off
toc

figure(1)
clf
plot(run_rrtm_lw_output.spectral_heating_rate(1,:),flipud(full_atm(:,1)),'r','linewidth',1.1)
set(gca,'xtick',[-15:5:25],'fontsize',16);
xlabel('Heating Rate (K/day)');
ylabel('Altitude (km)');
title('MLS Model Atmosphere Heating Rates');
hold on
plot(run_rrtm_sw_output.spectral_heating_rate(:,1),flipud(full_atm(:,1)),'k','linewidth',1.1)
a = legend('LW','SW');
set(a,'fontsize',16);
orient landscape


print(1,'-dpsc','rrtm_lw_sw_htr_clr');
system('ps2pdf rrtm_lw_sw_htr_clr.ps');
delete('rrtm_lw_sw_htr_clr.ps');
