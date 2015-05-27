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
%CAMEX measurement from NASA flight 93-169 on 09/29/1993 from
%Wallops Island (this is the example from the AER website)

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

%atmospheric levels (km)
pz_levs = [0.000     0.468     1.038     1.490     2.051     3.048 ...
	   4.027     5.033     6.023     6.962     7.861     8.865 ...
	   9.412    10.026    10.654    11.319     12.062    12.911 ...
	   13.865    14.277    15.238    16.356    17.037    17.758 ...
           18.555    19.536    19.970];

run_lblrtm_input.v1 = 500; %cm^-1
run_lblrtm_input.v2 = 1174; %cm^-1
run_lblrtm_input.observer_angle = 180; %nadir observation
run_lblrtm_input.pz_obs = 19.97; %altitude at observer location (km)
run_lblrtm_input.pz_surf = 0; %altitude at end target (km)
run_lblrtm_input.t_surf = 293.3; %surface temperature (K)
run_lblrtm_input.surf_v = [400:3000];
dummy = load('./camex_example/camex_emissivity');
run_lblrtm_input.surf_emis = dummy(:,1);
dummy = load('./camex_example/camex_reflectivity');
run_lblrtm_input.surf_refl = dummy(:,1);;
run_lblrtm_input.latitude = 32; %latitude of observation (degrees north)
run_lblrtm_input.model = 0;     %Mid-Latitude Summer model atmosphere
run_lblrtm_input.species_vec = ones(1,32);
dummy = load('./camex_example/camex.full_atm');
run_lblrtm_input.full_atm = dummy; %full atmosphere
run_lblrtm_input.pz_levs = pz_levs;

ILS.ILS_use = 1;        %1 implies using instrument line shape (ILS)
ILS.HWHM = 0.275512;    %half-width at half-maximum of ILS
ILS.V1   = 600.0577;    %beginning wavenumber for instrument output
ILS.V2   = 1074.76489;  %ending wavenumber for instrument output
ILS.JFN  = -4;          %scanning function type (for FTS, set to -4
                        %=> sinc function)
ILS.DELTAOD = 1.550731; %maximum optical path difference, for FTS only

run_lblrtm_input.ILS = ILS;
run_lblrtm_input.Flag_Vec = [0 0 0 1 0 0];
run_lblrtm_input.Flag_List = ...
    str2mat('Aerosol_Flag','LNFL_Flag','P_or_Z','Rad_or_Trans','RH_Flag','Temp_Flag');

[run_lblrtm_output] = run_lblrtm(run_lblrtm_input);

[lblrtm_bt,lblrtm_chan] = ...
    convert_to_BT(run_lblrtm_output.radiance, ...
		  run_lblrtm_output.wavenumber);

%Compare CAMEX measured spectrum to that output by lblrtm
dummy = load('./camex_example/camex_19930922_00Z.txt');
[camex_bt,camex_chan] = ...
    convert_to_BT(dummy(:,2)*1000,dummy(:,1));

%Set lower and upper wavenumber for comparison
v_lower = min(lblrtm_chan);
v_upper = max(lblrtm_chan);

[dummy,lblrtm_start_chan] = min(abs(lblrtm_chan-v_lower));
[dummy,lblrtm_end_chan] = min(abs(lblrtm_chan-v_upper));

[dummy,camex_start_chan] = min(abs(camex_chan-v_lower));
[dummy,camex_end_chan] = min(abs(camex_chan-v_upper));

%Plotting routine
figure(1)
clf
subplot(211)
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     lblrtm_bt(lblrtm_start_chan:lblrtm_end_chan),'r');
hold on
plot(camex_chan(camex_start_chan:camex_end_chan), ...
     camex_bt(camex_start_chan:camex_end_chan),'k');
a = ylabel('Brightness Temperature (K)');
set(a,'FontSize',16);
a = xlabel('wavenumber (cm^-^1)');
set(a,'FontSize',16);
a = title('LBLRTM (red) CAMEX (black) comparison for 07/22/2001 0522Z at ARM SGP');
set(a,'FontSize',16);
ax = axis;
ax(1) = lblrtm_chan(lblrtm_start_chan);
ax(2) = lblrtm_chan(lblrtm_end_chan);
axis(ax);

subplot(212)
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     lblrtm_bt(lblrtm_start_chan:lblrtm_end_chan) - ...
     camex_bt(camex_start_chan:camex_end_chan),'r');
hold on
plot(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan), ...
     zeros(size(lblrtm_chan(lblrtm_start_chan:lblrtm_end_chan))),'k--');
a = xlabel('wavenumber (cm^-^1)');
set(a,'FontSize',16);
a = ylabel('\Delta BT (K)');
set(a,'FontSize',16);
a = title('LBLRTM-CAMEX');
set(a,'FontSize',16);
ax = axis;
ax(1) = lblrtm_chan(lblrtm_start_chan);
ax(2) = lblrtm_chan(lblrtm_end_chan);
ax(3) = -3;
ax(4) = 3;
axis(ax);
orient landscape

toc

