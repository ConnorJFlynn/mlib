%Computes aerosol extinction profiles, by differentiating dtau_a/dz

warning off MATLAB:divideByZero
%Result_File='OFF'
Result_File='ON'

%target=[31.585,-24.972]; %long, lat Skukuza
%target=[32.925,-25.975]; %long, lat Inhaca Spiral
target=[-97.48,36.60]; %long, lat ARM SGP CF

%target=[0,0]; %long, lat 
dist_to_target=inf; %in km

rng=distance(ones(1,length(geog_lat))*target(2),ones(1,length(geog_long))*target(1),geog_lat,geog_long);
rng=deg2km(rng);
L_dist=rng<=dist_to_target;

%H2O_smoothing_para= 0.99998
%h2o_profile

 H2O_smoothing_para= 0.95
 deltaz=0.020; %for binning in km
 h2o_profile_ave

% %h2o_profile_lin

%ext_profile
%ext_profile_lin

deltaz=0.020; %for binning in km
%  aero_smoothing_para=0.95
%  ext_profile_ave

%  aero_smoothing_para_high=0.99
%  aero_smoothing_para_low=0.9
%  z_break=2.5;
%  ext_profile_ave2
