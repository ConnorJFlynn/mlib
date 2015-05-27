
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


%This script will call run_lblrtm.m and compare with the
%IRIS-D measurement from GUAM 4/27/1970 from the Nimbus-4 platform

clear
tic
diary('screendump.out');
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

run_lblrtm_input.v1 = 350; %cm^-1
run_lblrtm_input.v2 = 1650; %cm^-1
run_lblrtm_input.observer_angle = 180; %nadir observation
dummy = load('masuda_emissivity');
run_lblrtm_input.surf_emis = dummy(:,1);
dummy = load('masuda_reflectivity');
run_lblrtm_input.surf_v = dummy(:,2);
run_lblrtm_input.t_surf = 301.2; %surface temperature (K)
run_lblrtm_input.surf_refl = dummy(:,1);
run_lblrtm_input.latitude = 32; %latitude of observation (degrees north)
run_lblrtm_input.model = 0;     %user-defined atmosphere
run_lblrtm_input.species_vec = ones(1,32);

dummy = load('./iris_example/iris.full_atm');
full_atm = zeros(length(dummy(:,1)),35);
full_atm(:,1) = dummy(:,4);
full_atm(:,2) = dummy(:,5);
full_atm(:,3) = dummy(:,6);
full_atm(:,4) = dummy(:,8)*1e6;
full_atm(:,5) = dummy(:,9)*1e6;
full_atm(:,6) = dummy(:,10)*1e6;
full_atm(:,7) = dummy(:,11)*1e6;
full_atm(:,8) = dummy(:,12)*1e6;
full_atm(:,9) = dummy(:,13)*1e6;
full_atm(:,10) = dummy(:,14)*1e6;
run_lblrtm_input.full_atm = full_atm;
run_lblrtm_input.pz_obs = 70; %altitude at observer location (km)
run_lblrtm_input.pz_surf = 0; %altitude at end target (km)
run_lblrtm_input.pz_levs = dummy(:,4);
ILS.ILS_use = -1;        %1 implies using instrument line shape (ILS)

run_lblrtm_input.ILS = ILS;
run_lblrtm_input.Flag_Vec = [0 0 0 1 0 0];
run_lblrtm_input.Flag_List = ...
    str2mat('Aerosol_Flag','LNFL_Flag','P_or_Z','Rad_or_Trans','RH_Flag','Temp_Flag');
run_lblrtm_input.Directory_List = str2mat('LBLRTM','LNFL','RADSUM','CHARTS');
[run_lblrtm_output] = run_lblrtm(run_lblrtm_input);
toc
[lblrtm_bt,lblrtm_chan] = ...
    convert_to_BT(run_lblrtm_output.radiance, ...
		  run_lblrtm_output.wavenumber);

%Compare IRIS measured spectrum to that output by lblrtm
dummy = load('./iris_example/iris_spectrum_042770.txt');
[iris_bt,iris_chan] = ...
    convert_to_BT(dummy(:,2),dummy(:,1));
iris_spectrum = dummy(:,2);

%Set lower and upper wavenumber for comparison
v_lower = min(iris_chan);
v_upper = max(iris_chan);

[dummy,lblrtm_start_chan] = min(abs(lblrtm_chan-v_lower));
[dummy,lblrtm_end_chan] = min(abs(lblrtm_chan-v_upper));

[dummy,iris_start_chan] = min(abs(iris_chan-v_lower));
[dummy,iris_end_chan] = min(abs(iris_chan-v_upper));

%Plotting routine
%Plotting routine
figure(1)
clf
subplot(211)
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     run_lblrtm_output.radiance(lblrtm_start_chan:lblrtm_end_chan)*1e7,'r');
hold on
plot(iris_chan(iris_start_chan:iris_end_chan), ...
     iris_spectrum(iris_start_chan:iris_end_chan),'k');
a = ylabel('Radiance (mW/m^2/sr/cm^-^1');
set(a,'FontSize',16);
a = xlabel('wavenumber (cm^-^1)');
set(a,'FontSize',16);
a = title('LBLRTM (red) IRIS-D (black) comparison for 04/27/1970 at Guam');
set(a,'FontSize',16);
ax = axis;
ax(1) = lblrtm_chan(lblrtm_start_chan);
ax(2) = lblrtm_chan(lblrtm_end_chan);
axis(ax);

subplot(212)
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     run_lblrtm_output.radiance(lblrtm_start_chan:lblrtm_end_chan)*1e7 - ...
     iris_spectrum(iris_start_chan:iris_end_chan),'r');
hold on
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     zeros(size(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan))),'k--');
a = xlabel('wavenumber (cm^-^1)');
set(a,'FontSize',16);
a = ylabel('\Delta radiance (mW/m^2/sr/cm^-^1)');
set(a,'FontSize',16);
a = title('LBLRTM-IRIS');
set(a,'FontSize',16);
ax = axis;
ax(1) = lblrtm_chan(lblrtm_start_chan);
ax(2) = lblrtm_chan(lblrtm_end_chan);
ax(3) = -10;
ax(4) = 10;
axis(ax);
orient landscape
print(1,'-dpsc','iris_rad_comparison_042770');
system('mv iris_rad_comparison_042770.ps figs');

figure(2)
clf
subplot(211)
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     lblrtm_bt(lblrtm_start_chan:lblrtm_end_chan),'r');
hold on
plot(iris_chan(iris_start_chan:iris_end_chan), ...
     iris_bt(iris_start_chan:iris_end_chan),'k');
a = ylabel('Brightness Temperature (K)');
set(a,'FontSize',16);
a = xlabel('wavenumber (cm^-^1)');
set(a,'FontSize',16);
a = title('LBLRTM (red) IRIS-D (black) comparison for 04/27/1970 at Guam');
set(a,'FontSize',16);
ax = axis;
ax(1) = lblrtm_chan(lblrtm_start_chan);
ax(2) = lblrtm_chan(lblrtm_end_chan);
axis(ax);

subplot(212)
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     lblrtm_bt(lblrtm_start_chan:lblrtm_end_chan) - ...
     iris_bt(iris_start_chan:iris_end_chan),'r');
hold on
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     zeros(size(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan))),'k--');
a = xlabel('wavenumber (cm^-^1)');
set(a,'FontSize',16);
a = ylabel('\Delta BT (K)');
set(a,'FontSize',16);
a = title('LBLRTM-IRIS');
set(a,'FontSize',16);
ax = axis;
ax(1) = lblrtm_chan(lblrtm_start_chan);
ax(2) = lblrtm_chan(lblrtm_end_chan);
ax(3) = -10;
ax(4) = 10;
axis(ax);
orient landscape
print(2,'-dpsc','iris_bt_comparison_042770');
system('mv iris_bt_comparison_042770.ps figs');
diary off
toc

