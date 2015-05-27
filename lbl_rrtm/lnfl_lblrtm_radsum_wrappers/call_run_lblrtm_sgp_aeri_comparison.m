
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
%This script will call run_lblrtm.m to produce a spectra that
%utilizes the atmosphere measured by a radiosonde at the ARM
%Southern Great Plains site on 07/22/2001, 0522 GMT

clear
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


dummy = load('./sgp_example/sgp_aeri.full_atm');
pz_levs = [0.320     0.360     0.400     0.500     0.600     0.700 ...
	  0.800     0.900     1.000     1.200     1.400     1.600 ...
	  1.800     2.000     2.200     2.400     2.600     2.800 ...
	  3.000     3.200     3.400     3.600     3.800     4.000 ...
	  4.500     5.000     5.500     6.000     6.500     7.000 ...
	  7.500     8.000     8.500     9.000     9.500    10.000 ...
	  11.000    12.000    13.000    14.000    15.000   16.500 ...
	  18.000    20.000    24.000    28.000    32.000   36.000 ...
	  40.000]; %atmospheric levels (km)

run_lblrtm_input.v1 = 450; %cm^-1
run_lblrtm_input.v2 = 1800; %cm^-1
run_lblrtm_input.observer_angle = 0; %observation looking at zenith
run_lblrtm_input.pz_obs = 0.32; %altitude at observer location (km)
run_lblrtm_input.pz_surf = 40; %altitude at end target (km)
run_lblrtm_input.t_surf = 0; %surface temperature (K)
run_lblrtm_input.surf_v = [400:3000]; %grid for listing surface
                                      %emissivity and reflectivity
run_lblrtm_input.surf_emis = 0.95*ones(size(run_lblrtm_input.surf_v));
run_lblrtm_input.surf_refl = 0.05*ones(size(run_lblrtm_input.surf_v));
run_lblrtm_input.latitude = 32; %latitude of observation (degrees north)
run_lblrtm_input.model = 0;     %Mid-Latitude Summer model atmosphere
run_lblrtm_input.species_vec = ones(1,32); %include first 32 hitran
                                           %species
run_lblrtm_input.full_atm = dummy; %full atmosphere
run_lblrtm_input.pz_levs = pz_levs;

ILS.ILS_use = 1;
ILS.HWHM = 0.482147;
ILS.V1   = 500.46878;
ILS.V2   = 1750.19383;
ILS.JFN  = -4;
ILS.DELTAOD = 1.03702766;
run_lblrtm_input.ILS = ILS;
run_lblrtm_input.Flag_Vec = [0 0 0 1 0 0];
run_lblrtm_input.Flag_List = ...
    str2mat('Aerosol_Flag','LNFL_Flag','P_or_Z','Rad_or_Trans','RH_Flag','Temp_Flag');
run_lblrtm_input.Directory_List = str2mat('LBLRTM','LNFL','RADSUM','CHARTS');
[run_lblrtm_output] = run_lblrtm(run_lblrtm_input);

[lblrtm_bt,lblrtm_chan] = ...
    convert_to_BT(run_lblrtm_output.radiance, ...
		  run_lblrtm_output.wavenumber);

%Compare AERI measured spectrum to that output by lblrtm
dummy = load('./sgp_example/sgp_aeri_20010722_0522Z.txt');
[aeri_bt,aeri_chan] = ...
    convert_to_BT(dummy(:,2),dummy(:,1));

%Set lower and upper wavenumber for comparison
v_lower = 600;
v_upper = 1400;

[dummy,lblrtm_start_chan] = min(abs(lblrtm_chan-v_lower));
[dummy,lblrtm_end_chan] = min(abs(lblrtm_chan-v_upper));

[dummy,aeri_start_chan] = min(abs(aeri_chan-v_lower));
[dummy,aeri_end_chan] = min(abs(aeri_chan-v_upper));

%Plotting routine
figure(1)
clf
subplot(211)
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     lblrtm_bt(lblrtm_start_chan:lblrtm_end_chan),'r');
hold on
plot(aeri_chan(aeri_start_chan:aeri_end_chan), ...
     aeri_bt(aeri_start_chan:aeri_end_chan),'k');
a = ylabel('Brightness Temperature (K)');
set(a,'FontSize',16);
a = xlabel('wavenumber (cm^-^1)');
set(a,'FontSize',16);
a = title('LBLRTM (red) AERI (black) comparison for 07/22/2001 0522Z at ARM SGP');
set(a,'FontSize',16);
ax = axis;
ax(1) = lblrtm_chan(lblrtm_start_chan);
ax(2) = lblrtm_chan(lblrtm_end_chan);
axis(ax);

subplot(212)
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     lblrtm_bt(lblrtm_start_chan:lblrtm_end_chan) - ...
     aeri_bt(aeri_start_chan:aeri_end_chan),'r');
hold on
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     zeros(size(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan))),'k--');
a = xlabel('wavenumber (cm^-^1)');
set(a,'FontSize',16);
a = ylabel('\Delta BT (K)');
set(a,'FontSize',16);
a = title('LBLRTM-AERI');
set(a,'FontSize',16);
ax = axis;
ax(1) = lblrtm_chan(lblrtm_start_chan);
ax(2) = lblrtm_chan(lblrtm_end_chan);
ax(3) = -3;
ax(4) = 3;
axis(ax);
orient landscape

toc

