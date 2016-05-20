path_mpl    = '/Users/pavlos/Data/ARM/MPL_data/';
eval(['cd ', path_mpl]);
aaa_mpl     = dir('nsa30smplcmask1zwangC1.c1.*');

%%% Selected MPL file: nsa30smplcmask1zwangC1.c1.20111118.000005.cdf
%%% Selected Ceilometer file: nsaceilC1.b1.20111118.000002.nc

%%%%% Load the MPL data

ncid = netcdf.open([path_mpl, aaa_mpl.name],'nc_nowrite');
    
    varid = netcdf.inqVarID(ncid,'time');                              mpl_time = double(netcdf.getVar(ncid,varid,'double'));  
    varid = netcdf.inqVarID(ncid,'height');                            mpl_range = double(netcdf.getVar(ncid,varid,'single'))*1000+15;  % in m above ground to the center of the range gate
    varid = netcdf.inqVarID(ncid,'cloud_base');                       mpl_cloud_base = double(netcdf.getVar(ncid,varid,'single'))*1000;  
    varid = netcdf.inqVarID(ncid,'cloud_top');                        mpl_cloud_top = double(netcdf.getVar(ncid,varid,'single'))*1000;  
    varid = netcdf.inqVarID(ncid,'num_cloud_layers');                      mpl_num_cloud_layers = double(netcdf.getVar(ncid,varid,'single'));  
    varid = netcdf.inqVarID(ncid,'linear_depol_ratio');                 mpl_linear_depol_ratio = double(netcdf.getVar(ncid,varid,'single'));  
    varid = netcdf.inqVarID(ncid,'cloud_mask');                       mpl_cloud_mask = double(netcdf.getVar(ncid,varid,'single'));  
    varid = netcdf.inqVarID(ncid,'cloud_base_layer');                 mpl_cloud_base_layer = double(netcdf.getVar(ncid,varid,'single'))*1000;  
    varid = netcdf.inqVarID(ncid,'cloud_top_layer');                 mpl_cloud_top_layer = double(netcdf.getVar(ncid,varid,'single'))*1000;  
    varid = netcdf.inqVarID(ncid,'backscatter');                       mpl_backscatter = double(netcdf.getVar(ncid,varid,'single'));  
    varid = netcdf.inqVarID(ncid,'cloud_top_attenuation_flag');       mpl_cloud_top_attenuation_flag = double(netcdf.getVar(ncid,varid,'int32'));  
    varid = netcdf.inqVarID(ncid,'alt');                               mpl_alt = double(netcdf.getVar(ncid,varid,'single'));  
    varid = netcdf.inqVarID(ncid,'backscatter_snr');                               mpl_backscatter_snr = double(netcdf.getVar(ncid,varid,'single'));  
    varid = netcdf.inqVarID(ncid,'linear_depol_snr');                               mpl_linear_depol_snr = double(netcdf.getVar(ncid,varid,'single'));  

netcdf.close(ncid);

%%%% Load Ceilometer data
aaa_ceil     = dir('nsaceilC1.b1.*');
%%
%%%%% Load the Ceilometer data

ncid = netcdf.open([path_mpl, aaa_ceil.name],'nc_nowrite');

    varid = netcdf.inqVarID(ncid,'time');                              ceil_time = double(netcdf.getVar(ncid,varid,'double'));
    varid = netcdf.inqVarID(ncid,'range');                             ceil_range = double(netcdf.getVar(ncid,varid,'double'));
    varid = netcdf.inqVarID(ncid,'first_cbh');                         ceil_first_cbh = double(netcdf.getVar(ncid,varid,'double'));
    varid = netcdf.inqVarID(ncid,'backscatter');                       ceil_backscatter = netcdf.getVar(ncid,varid);
netcdf.close(ncid);


%%%%% Ceilometer Calibration
Lidar_cal_coeff = 1.31;
%%%% Calibrated lidar backscatter (still attenuated, beta-prime in O'Connor
ceil_bscat_corr = Lidar_cal_coeff*ceil_bscat;

%%%%% DONE WITH CEILOMETER CALIBRATION %%%%%%%


%%%%% Find when ceilometer and MPL detect no clouds
%%%%% Need to use MPL time coordinate...
%%%%% So, interpolate the ceilometer data on mpl_time
mpl_cloud_mask(mpl_cloud_mask==-9999)=0;
time_mpl_cloud_mask = sum(mpl_cloud_mask);

ceil_first_cbh(ceil_first_cbh==-9999)=NaN;
ceil_first_cbh_on_mpl = interp1(ceil_time,ceil_first_cbh,mpl_time);

kk = find(isnan(ceil_first_cbh_on_mpl)==1 & time_mpl_cloud_mask'==0);

%%%%% Cloud Free MPL profile


dz = max(diff(mpl_range)); %%% MPL gate spacing in m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Simulate Rayleigh scattering from atmospheric molecules %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lambda = 532e-9; %%% lidar wavelength in m
%%%% Estimate Standard Atmosphere
[rho,a,T,P,nu,h]=atmos(mpl_range,'tOffset', 0,'altType','geometric');
%%%% Estimate Rayleigh scattering 
beta_m_no_att  = 2.938*10^-32*(10^-2*P./T)*(1/lambda^4.0117)*10^3; %%%% in km^-1 sr^-1
%%% alternative from Wang et 2001
%beta_m_no_att2 = 5.45e-28*(550/532)^4*(P*10^2./(T*1.381e-23))*1e-6*1e5*25; %%%% in km-1 sr^-1
%% Atmospheric molecules have no extinction (S_m=0), so not tau_m estimation
S_m = 8*pi/3; %%%% for pure Rayleigh scattering
sigma_m  = beta_m_no_att*S_m; %%% but we neglect it...too small

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Average Aerosol Extinction Profile %%% Spinhirne, 1993
%%%% Use as aerosol profile model, the one proposed by Spinhirne
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sigma_0 = 0.025; %%% km^-1
a       = 0.4;      b       = 1.6; %%% km
ap      = 0.2981;     bp      = 2.5; %%% km
f       = 1.5e-7; %%% km^-1
sigma_a = sigma_0*(1+a)^2*exp(mpl_range/(b*10^3))./(a+exp(mpl_range/(b*10^3))).^2 + ...
    f*(1+ap)^2*exp(mpl_range/(bp*10^3))./(a+exp(mpl_range/(bp*10^3))).^2;
sigma_a(mpl_range<1000)=0.05; %%% boundary layer aerosols
%%%% Use actual tau_a from Cimel Sunphotometer 
%%%% Use the value at 500 nm wavelength (very close to 532 nm of MPL
%%%%% Let's assume a value
tau_a_cimel = 0.1;
%%%% Use this value to normalize the model from Spinhirne
for i = 1:length(mpl_range);
    tau_a_spinhirne(i)  = sigma_a(i)*dz*10^-3; %%%% non dimensional
end
%%% Total tau of the Spinhirne model:
tau_a_spinhirne_all = sum(tau_a_spinhirne);
Norm_coeff = tau_a_cimel/tau_a_spinhirne_all;
%%% Multiple model with the constant to make the aerosol tau equal to CIMEL
sigma_a = Norm_coeff*sigma_a;
S_a = 30; %%% this is the lidar ratio for the aerosols
beta_a_no_att = sigma_a/S_a;  %%%% in km^-1 sr^-1

%%%% Example of cloud extinction profile %%%%
sigma_c(1:length(mpl_range))=10^-10; %%% extremly small %%%%
sigma_c(mpl_range>=8000 & mpl_range <=10000)=0.1; %%%% km^-1
S_c = 10; %%% this is the lidar ratio for the cloud (sr)
beta_c_no_att = sigma_c/S_c;  %%%% in km^-1 sr^-1

%%% We should ignore the test cloud for our study (Calibration, since we 
%%% avoid cloudy profiles %%%%

beta_c_no_att(1:length(mpl_range)) = 0;

%%%%%

for i = 1:length(mpl_range);
    b_true(i)           = beta_m_no_att(i)+beta_a_no_att(i)+beta_c_no_att(i)'; %%% in km^(-1) sr-1
    tau_true(i)         = (beta_a_no_att(i)*S_a*dz+beta_c_no_att(i)'*S_c*dz)*10^-3; %%% non dimensional
    b_obs(i)            = b_true(i)*exp(-2*sum(tau_true(1:i))); %%%% km^-1 sr^-1
end


%%%%%%% Extract calibration constant %%%%%
%%%%%%% Use heights above 15 km %%%%%%%%%%
 
Counts_X    = mean((mpl_backscatter(mpl_range>15000,kk)')).*(mpl_range(mpl_range>15000)/1000).^2'; %%%% counts/ms
Rayleigh_Y  = b_obs(mpl_range>15000)*10^-3;   %%% m^-1 sr^-1 

figure(2)
plot(Counts_X(Counts_X>0), Rayleigh_Y(Counts_X>0))
hold on
Pfit = polyfit(Counts_X(Counts_X>0),Rayleigh_Y(Counts_X>0),1);
plot(Counts_X(Counts_X>0),polyval(Pfit,Counts_X(Counts_X>0)),'r');
xlabel('MPL (Counts/ms)');
ylabel('MPL (m^{-1} sr^{-1})');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% This is the calibrated MPL in m^-1 sr^-1
mpl_backscatter_msr = mpl_backscatter*Pfit(1)+Pfit(2);
%%%% IS THIS CORRECT??
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


