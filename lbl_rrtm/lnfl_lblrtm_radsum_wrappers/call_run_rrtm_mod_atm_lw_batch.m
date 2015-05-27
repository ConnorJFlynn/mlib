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
%
%This script will call RRTM in batch-mode to calculate sensitivity to T, H2O, O3 for Tropical conditions
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
	    '/home/hermes_rd1/drf/lblrtm/rrtm/rrtm_sw/'); 	%location of rrtm_sw executable
run_rrtm_input.Directory_List = str2mat('LOCAL','RRTM_LW','RRTM_SW');
run_rrtm_input.executable_names = str2mat('no executable', ...
					    'rrtm_linux_v3.0',...
					    'rrtm_sw_linux_pgi_v2.5');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Don't edit below unless you are familiar with how the LBLRTM wrapper works

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
run_rrtm_input.channel = 0;

[run_rrtm_output] = run_rrtm_lw(run_rrtm_input);

%Batch call to RRTM
dir = get_directory(run_rrtm_input.Directory_Mat,run_rrtm_input.Directory_List,'LOCAL');
s = strcat(['rm ',dir,'INPUT_RRTM_LW*']);
system(s);
s = strcat(['rm ',dir,'OUTPUT_RRTM_LW*']);
fid_lw = fopen('rrtm_list_lw','w');
fprintf(fid_lw,'#!/bin/sh\n');
fid_lw2 = fopen('list_lw','w');

rrtm_dir = get_directory(run_rrtm_input.Directory_Mat,run_rrtm_input.Directory_List,'RRTM_LW');
s_pwd = pwd;
if get_flag(run_rrtm_input.Flag_Vec,...
	    run_rrtm_input.Flag_List,'LWC_Flag') == 1 | ...
      get_flag(run_rrtm_input.Flag_Vec, ...
	       run_rrtm_input.Flag_List,'IWC_Flag') == 1
  cloud_flag = 1;
else
  cloud_flag = 0;
end

for i=1:length(full_atm(:,1))
 
  %Temperature
  dummy = run_rrtm_input;
  dummy.full_atm(i,3) = dummy.full_atm(i,3)*1.01;
  dummy.filenumber     = 3*(i-1)+1;
  
  [run_rrtm_lw_output] = run_rrtm_lw_batch(dummy);
  s = strcat(['cp ',run_rrtm_lw_output.filename,...
	      '_',int2str(cloud_flag),' ',rrtm_dir,'INPUT_RRTM']);
  fprintf(fid_lw,'%s\n',s);
  s = strcat(['cd ',rrtm_dir]); 
  fprintf(fid_lw,'%s\n',s);
  s = './rrtm_linux_v3.0';
  fprintf(fid_lw,'%s\n',s);
  s = strcat(['cd ',s_pwd]); 
  fprintf(fid_lw,'%s\n',s);
  s = strcat(['mv ',rrtm_dir,'OUTPUT_RRTM ',dir,...
	      'OUTPUT_RRTM_LW',int2str(dummy.filenumber)]);
  fprintf(fid_lw,'%s\n',s);
  s = strcat('OUTPUT_RRTM_LW',int2str(dummy.filenumber));
  fprintf(fid_lw2,'%s\n',s);
  
  %Water vapor
  dummy = run_rrtm_input;
  dummy.full_atm(i,4) = dummy.full_atm(i,4)*1.01;
  dummy.filenumber     = 3*(i-1)+2;
  
  [run_rrtm_lw_output] = run_rrtm_lw_batch(dummy);
  s = strcat(['cp ',run_rrtm_lw_output.filename,...
	      '_',int2str(cloud_flag),' ',rrtm_dir,'INPUT_RRTM']);
  fprintf(fid_lw,'%s\n',s);
  s = strcat(['cd ',rrtm_dir]); 
  fprintf(fid_lw,'%s\n',s);
  s = './rrtm_linux_v3.0';
  fprintf(fid_lw,'%s\n',s);
  s = strcat(['cd ',s_pwd]); 
  fprintf(fid_lw,'%s\n',s);
  s = strcat(['mv ',rrtm_dir,'OUTPUT_RRTM ',dir,...
	      'OUTPUT_RRTM_LW',int2str(dummy.filenumber)]);
  fprintf(fid_lw,'%s\n',s);
  s = strcat('OUTPUT_RRTM_LW',int2str(dummy.filenumber));
  fprintf(fid_lw2,'%s\n',s);
  
  %ozone
  dummy = run_rrtm_input;
  dummy.full_atm(i,6) = dummy.full_atm(i,6)*1.01;
  dummy.filenumber     = 3*(i-1)+3;
  
  [run_rrtm_lw_output] = run_rrtm_lw_batch(dummy);
  s = strcat(['cp ',run_rrtm_lw_output.filename,...
	      '_',int2str(cloud_flag),' ',rrtm_dir,'INPUT_RRTM']);
  fprintf(fid_lw,'%s\n',s);
  s = strcat(['cd ',rrtm_dir]); 
  fprintf(fid_lw,'%s\n',s);
  s = './rrtm_linux_v3.0';
  fprintf(fid_lw,'%s\n',s);
  s = strcat(['cd ',s_pwd]); 
  fprintf(fid_lw,'%s\n',s);
  s = strcat(['mv ',rrtm_dir,'OUTPUT_RRTM ',dir,...
	      'OUTPUT_RRTM_LW',int2str(dummy.filenumber)]);
  fprintf(fid_lw,'%s\n',s);
  s = strcat('OUTPUT_RRTM_LW',int2str(dummy.filenumber));
  fprintf(fid_lw2,'%s\n',s);
end


%Make system call for batched RRTM runs
fclose(fid_lw);
fclose(fid_lw2);
system('chmod 755 rrtm_list_lw');
system('cp rrtm_list_lw call_rrtm');
system('./call_rrtm');

%Read outputs
dummy_lw = fopen('list_lw','r');

for i=1:length(full_atm(:,1))
  
  s = fscanf(dummy_lw,'%s',1);
  fgetl(dummy_lw);
  read_rrtm_input.filename = strcat(dir,s);
  read_rrtm_input.channel = run_rrtm_input.channel;
  read_rrtm_input.full_atm = run_rrtm_input.full_atm;
  [read_rrtm_output] = read_rrtm_lw(read_rrtm_input);  
  dThetaDot_dT(i,:) = (read_rrtm_output.spectral_heating_rate - ...
		       run_rrtm_output.spectral_heating_rate)/(full_atm(i,3)*0.01);

  s = fscanf(dummy_lw,'%s',1);
  fgetl(dummy_lw);
  read_rrtm_input.filename = strcat(dir,s);
  read_rrtm_input.channel = run_rrtm_input.channel;
  read_rrtm_input.full_atm = run_rrtm_input.full_atm;
  [read_rrtm_output] = read_rrtm_lw(read_rrtm_input);  
  dThetaDot_dH2O(i,:) = (read_rrtm_output.spectral_heating_rate - ...
		       run_rrtm_output.spectral_heating_rate)/(full_atm(i,4)*0.01);
  
  
  s = fscanf(dummy_lw,'%s',1);
  fgetl(dummy_lw);
  read_rrtm_input.filename = strcat(dir,s);
  read_rrtm_input.channel = run_rrtm_input.channel;
  read_rrtm_input.full_atm = run_rrtm_input.full_atm;
  [read_rrtm_output] = read_rrtm_lw(read_rrtm_input);  
  dThetaDot_dO3(i,:) = (read_rrtm_output.spectral_heating_rate - ...
		       run_rrtm_output.spectral_heating_rate)/(full_atm(i,6)*0.01);
end
fclose(dummy_lw);


%Erase temporary files
delete('rrtm_list_lw');
delete('list_lw');
delete('call_rrtm');
s = strcat(['rm ',dir,'INPUT_RRTM* ',dir,'OUTPUT_RRTM*']);
system(s);

figure(1)
clf
plot(dThetaDot_dT,flipud(run_rrtm_input.full_atm(:,2)));
ylabel('Pressure (mbar)');
set(gca,'ydir','reverse')
set(gca,'yscale','log');
ylim([1 1000])
xlabel('\theta\prime T sensitivity (\DeltaK/day/K)');

figure(2)
clf
plot(dThetaDot_dH2O,flipud(run_rrtm_input.full_atm(:,2)));
ylabel('Pressure (mbar)');
set(gca,'ydir','reverse')
set(gca,'yscale','log');
ylim([1 1000])
xlabel('\theta\prime H_2O sensitivity (\DeltaK/day/ppmv)');

figure(3)
clf
plot(dThetaDot_dO3,flipud(run_rrtm_input.full_atm(:,2)));
ylabel('Pressure (mbar)');
set(gca,'ydir','reverse')
set(gca,'yscale','log');
ylim([1 1000])
xlabel('\theta\prime O_3 sensitivity (\DeltaK/day/ppmv)');


toc
diary off
toc
