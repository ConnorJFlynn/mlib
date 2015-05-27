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
%This script will call run_lblrtm_jacobian.m and compare with the
%the call of LBLRTM for a model atmosphere file

clear
tic
diary('screendump.out');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Edit these variables to point towards your installation directory for LBLRTM, LNFL,RADSUM, and CHARTS 
run_lblrtm_jacobian_input.Directory_Mat = ...
    str2mat('/home/hermes_rd1/drf/scratch/lblrtm_v11/lblrtm/', ... %location of lblrtm executable
	    '/home/hermes_rd1/drf/lblrtm/lnfl/', ...   %location of lnfl executable
	    '/home/hermes_rd1/drf/lblrtm/radsum/',...  %location of radsum executable
	    '/home/hermes_rd1/drf/charts/', ...           %location of charts executable
	    './scratch/');
run_lblrtm_jacobian_input.Directory_List = str2mat('LBLRTM','LNFL','RADSUM','CHARTS','LOCAL');
run_lblrtm_jacobian_input.executable_names = str2mat('lblrtm_v11.1_pgi_linux_pgf90_dbl', ...
					    'lnfl_v2.1_pgf90_pgi_linux_sgl',...
					    'radsum_v2.4_linux_pgi_f90_dbl',...
					    'charts_lblv8.sgl', ...
                                            'no executable');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Don't edit below unless you are familiar with how the LBLRTM wrapper works

CO2_level = 380;
a = load('./mod_atm/USSTD.atm');

run_lblrtm_jacobian_input.v1 = 500; %cm^-1
run_lblrtm_jacobian_input.v2 =  900; %cm^-1
run_lblrtm_jacobian_input.observer_angle = 180; %nadir observation
dummy = load('masuda_emissivity');
run_lblrtm_jacobian_input.surf_emis = dummy(:,1);
dummy = load('masuda_reflectivity');
run_lblrtm_jacobian_input.surf_v = dummy(:,2);
run_lblrtm_jacobian_input.surf_refl = dummy(:,1);
run_lblrtm_jacobian_input.latitude = 32; %latitude of observation (degrees north)
run_lblrtm_jacobian_input.model = 0;     %user-defined atmosphere
run_lblrtm_jacobian_input.species_vec = ones(1,32);

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
run_lblrtm_jacobian_input.full_atm = full_atm;
run_lblrtm_jacobian_input.t_surf = full_atm(1,3); %surface temperature (K)

run_lblrtm_jacobian_input.pz_obs = min(full_atm(:,2)); %altitude at observer location (km)
run_lblrtm_jacobian_input.pz_surf = max(full_atm(:,2)); %altitude at end target (km)
run_lblrtm_jacobian_input.pz_levs = full_atm(:,2);
ILS.ILS_use = 1;
ILS.HWHM = 0.5;    %half-width at half-maximum of ILS
ILS.V1   = run_lblrtm_jacobian_input.v1;    %beginning wavenumber for instrument output
ILS.V2   = run_lblrtm_jacobian_input.v2;  %ending wavenumber for instrument output
ILS.JFN  = 0;     %boxcar function 

run_lblrtm_jacobian_input.ILS = ILS;
run_lblrtm_jacobian_input.Flag_Vec = [0 0 1 1 0 0];
run_lblrtm_jacobian_input.Flag_List = ...
    str2mat('Aerosol_Flag','LNFL_Flag','P_or_Z','Rad_or_Trans','RH_Flag','Temp_Flag');


blah = 0;
if blah == 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initial run
[run_lblrtm_output] = run_lblrtm(run_lblrtm_jacobian_input);

K_T = zeros(length(run_lblrtm_output.wavenumber),length(full_atm(:,1)));
K_H2O = zeros(length(run_lblrtm_output.wavenumber),length(full_atm(:,1)));

%Calculate finite-difference derivative wrt Temperature:
for i=1:length(full_atm(:,1))
  dummy = run_lblrtm_jacobian_input;
  dummy.full_atm(i,3) = dummy.full_atm(i,3)*1.01;
  dummy2 = run_lblrtm(dummy);
   
  for j=1:length(dummy2.wavenumber)
    K_T(j,i) = (dummy2.radiance(j)-run_lblrtm_output.radiance(j))/ ...
	(full_atm(i,3)*0.01);
  end
  %[2*i-1 length(full_atm(:,1)*2]
  dummy = run_lblrtm_jacobian_input;
  dummy.full_atm(i,4) = dummy.full_atm(i,4)*1.01;
  dummy2 = run_lblrtm(dummy);
  
  for j=1:length(dummy2.wavenumber)
    K_H2O(j,i) = (dummy2.radiance(j)-run_lblrtm_output.radiance(j))/(0.01);
  end
  [2*i length(full_atm(:,1))*2]
end
end

%First do a calculation for optical depthh

run_lblrtm_jacobian_input.jacobian_species = 0; %temperature profile
[run_lblrtm_jacobian_output] = run_lblrtm_jacobian(run_lblrtm_jacobian_input);
toc
save lblrtm_jacobian_save_file

%Process K according to ILS

%[lblrtm_bt,lblrtm_chan] = ...
%    convert_to_BT(run_lblrtm_jacobian_output.radiance, ...
%		  run_lblrtm_jacobian_output.wavenumber);

%Plotting routine
iris_chan = [400.471:1.39052:1600.671];
[X,Y] = meshgrid(iris_chan,run_lblrtm_jacobian_input.pz_levs);
contourf(X,Y,K_T',64);
shading flat
a = xlabel('wavenumber (cm^-^1)');
set(a,'FontSize',16);
a = ylabel('Pressure (mbar)');
set(a,'FontSize',16);
a = title('Finite-Difference Temperature Jacobian');
set(a,'FontSize',16);
c = colorbar;
d = get(c,'title');
set(d,'string','W/cm^2/sr/cm^-^1/K');
orient landscape
print(1,'-dpsc','iris_K_T_finite_diff_guam_042770');



diary off
toc

