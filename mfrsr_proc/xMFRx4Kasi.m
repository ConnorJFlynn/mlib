function xMFRxKasi(mfr)
% xMFRxKas(mfr): Uses colocated MFRSR and NIMFR for Evgueni's CIP
if ~exist('mfr','var')
    mfr = getfullname('*mfrsr*.cdf','mfrsraod');
end
if ~isstruct(mfr)&&exist(mfr,'file')
    mfr = ancload(mfr);
end

nimfr = strrep(mfr.fname, 'mfrsr','nimfr')
if ~exist(nimfr,'file')
    [pname, fname, ext] = fileparts(mfr.fname);
     nimfr = getfullname('*nimfr*.cdf','nimfraod');
end
nimfr = ancload(nimfr);
[ainb, bina] = nearest(mfr.time, nimfr.time);
mfr = ancsift(mfr, mfr.dims.time, ainb);

fields = {'direct_normal_narrowband_filter1';...
    'direct_normal_narrowband_filter2';...
    'direct_normal_narrowband_filter3';...
    'direct_normal_narrowband_filter4';...
    'direct_normal_narrowband_filter5';...
    'direct_normal_narrowband_filter6';...
    'aerosol_optical_depth_filter1';...
    'aerosol_optical_depth_filter2';...
    'aerosol_optical_depth_filter3';...
    'aerosol_optical_depth_filter4';...
    'aerosol_optical_depth_filter5'};

for f = 1:length(fields)
    mfr.vars.(char(fields{f})).data =   nimfr.vars.(char(fields{f})).data(bina);
end

mfr.time = mfr.time + double(fix(mfr.vars.lon.data/15)./24);
mfr = ancsift(mfr, mfr.dims.time, mfr.time>=max(floor(mfr.time))&mfr.time<(max(floor(mfr.time))+1));


[zen, az, soldst, ha, dec, el, am] = sunae(mfr.vars.lat.data, mfr.vars.lon.data, mfr.time -...
 double(fix(mfr.vars.lon.data/15)./24));
noon = interp1(az,[1:length(az)],180,'nearest');
%%
% Only accept times when sun is above horizon and direct normal values are
% positive semi-definite.
% convert to LST
% LST= serial2Hh(mfr.time(day)) + mfr.vars.lon.data/15;
%  LST=rem(LST,24);
%  LST(LST<0) = LST(LST<0)+24;



day =  mfr.vars.cosine_solar_zenith_angle.data <=90 & ...
    mfr.vars.direct_normal_narrowband_filter1.data>=0 & ...
    mfr.vars.direct_normal_narrowband_filter2.data>=0 & ...
    mfr.vars.direct_normal_narrowband_filter3.data>=0 & ...
    mfr.vars.direct_normal_narrowband_filter4.data>=0 & ...
    mfr.vars.direct_normal_narrowband_filter5.data>=0 & ...
    mfr.vars.direct_normal_narrowband_filter6.data>=0 ;

% mfr = ancsift(mfr, mfr.dims.time, day);


% Flag aod_screen.
%%
[aero, eps, aero_eps, mad, abs_dev] = aod_screen(mfr.time, mfr.vars.aerosol_optical_depth_filter1.data);
%%
aero =aero & mfr.vars.angstrom_exponent.data> 0.5;
ang = mfr.vars.angstrom_exponent.data> -10;
% Plot these values to decide if screen is adequate

figure; 
plot(serial2doy(mfr.time(day)), ...
    [mfr.vars.aerosol_optical_depth_filter1.data(day);mfr.vars.aerosol_optical_depth_filter2.data(day);...
     mfr.vars.aerosol_optical_depth_filter3.data(day);mfr.vars.aerosol_optical_depth_filter4.data(day);...
     mfr.vars.aerosol_optical_depth_filter5.data(day)], 'k.',...
     serial2doy(mfr.time(day&aero)), ...
    [mfr.vars.aerosol_optical_depth_filter1.data(day&aero);mfr.vars.aerosol_optical_depth_filter2.data(day&aero);...
     mfr.vars.aerosol_optical_depth_filter3.data(day&aero);mfr.vars.aerosol_optical_depth_filter4.data(day&aero);...
     mfr.vars.aerosol_optical_depth_filter5.data(day&aero)], '.');
 a(1) = gca;
figure; 
a(2) = subplot(2,1,1); plot(serial2doy(mfr.time(ang)), mfr.vars.angstrom_exponent.data(ang), '-o');
a(3) = subplot(2,1,2); plot(serial2doy(mfr.time), real(log10(eps)),'-x');
linkaxes(a,'x');

%%
% When aod screen looks good, set non good AOD to missing.  Also set
% existing missing to desired output values.
miss = mfr.vars.aerosol_optical_depth_filter1.data<0;
mfr.vars.aerosol_optical_depth_filter1.data(miss|~day|~aero) = -9.9;
miss = mfr.vars.aerosol_optical_depth_filter2.data<0;
mfr.vars.aerosol_optical_depth_filter2.data(miss|~day|~aero) = -9.9;
miss = mfr.vars.aerosol_optical_depth_filter3.data<0;
mfr.vars.aerosol_optical_depth_filter3.data(miss|~day|~aero) = -9.9;
miss = mfr.vars.aerosol_optical_depth_filter4.data<0;
mfr.vars.aerosol_optical_depth_filter4.data(miss|~day|~aero) = -9.9;
miss = mfr.vars.aerosol_optical_depth_filter5.data<0;
mfr.vars.aerosol_optical_depth_filter5.data(miss|~day|~aero) = -9.9;
miss = mfr.vars.angstrom_exponent.data<-9;
mfr.vars.angstrom_exponent.data(miss|~day|~aero) = -9.9;

% + (mfr.vars.lon.data/15)./24
aod_out = [serial2Hh(mfr.time); serial2doy(mfr.time);...
    mfr.vars.cosine_solar_zenith_angle.data;...
    mfr.vars.aerosol_optical_depth_filter1.data;mfr.vars.aerosol_optical_depth_filter2.data;...
mfr.vars.aerosol_optical_depth_filter3.data;mfr.vars.aerosol_optical_depth_filter4.data;...
mfr.vars.aerosol_optical_depth_filter5.data;-9.9.*ones(size(mfr.vars.angstrom_exponent.data));...
mfr.vars.angstrom_exponent.data;-9.9.*ones(size(mfr.vars.angstrom_exponent.data));...
az;-9.0.*ones(size(mfr.vars.angstrom_exponent.data))];
[pname, ~, ~] = fileparts(nimfr.fname);
fname = [datestr(mfr.time(noon),'yyyymmdd'),'.xmfrx.txt'];
fid_out = fopen([pname, filesep, fname],'w');
% [' %2d %4d-%02d-%02d %5d %5.1f %6.3f %6.1f %6.1f %6.1f ']
format_str = '%10.5f %10.5f %10.6f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.3f %10.3f %8.1f %7.2f\n';
fprintf(fid_out,strrep(format_str,' ',''),aod_out);
fclose(fid_out);
   %%
% Set DIRN missing to 0
miss = mfr.vars.direct_normal_narrowband_filter1.data<0;
mfr.vars.direct_normal_narrowband_filter1.data(miss|~day) = 0;
miss = mfr.vars.direct_normal_narrowband_filter2.data<0;
mfr.vars.direct_normal_narrowband_filter2.data(miss|~day) = 0;
miss = mfr.vars.direct_normal_narrowband_filter3.data<0;
mfr.vars.direct_normal_narrowband_filter3.data(miss|~day) = 0;
miss = mfr.vars.direct_normal_narrowband_filter4.data<0;
mfr.vars.direct_normal_narrowband_filter4.data(miss|~day) = 0;
miss = mfr.vars.direct_normal_narrowband_filter5.data<0;
mfr.vars.direct_normal_narrowband_filter5.data(miss|~day) = 0;
miss = mfr.vars.direct_normal_narrowband_filter6.data<0;
mfr.vars.direct_normal_narrowband_filter6.data(miss|~day) = 0;


dirn_out = [serial2Hh(mfr.time); mfr.vars.cosine_solar_zenith_angle.data;...
    mfr.vars.direct_normal_narrowband_filter1.data;mfr.vars.direct_normal_narrowband_filter2.data;...
mfr.vars.direct_normal_narrowband_filter3.data;mfr.vars.direct_normal_narrowband_filter4.data;...
mfr.vars.direct_normal_narrowband_filter5.data;mfr.vars.direct_normal_narrowband_filter6.data];

fname = ['cos_normal_',datestr(mfr.time(1),'yyyymmdd'),'.xmfrx.txt'];
fid_out = fopen([pname, filesep, fname],'w');
format_str = '%12.5f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f %12.6f \n';
fprintf(fid_out,strrep(format_str,' ',''),dirn_out);
fclose(fid_out);

%%
if isfield(mfr.vars,'diffuse_hemisp_narrowband_filter1')
    % Similarly, set diffuse hemisp missing to 0
    miss = mfr.vars.diffuse_hemisp_narrowband_filter1.data<0;
    mfr.vars.diffuse_hemisp_narrowband_filter1.data(miss|~day) = 0;
    miss = mfr.vars.diffuse_hemisp_narrowband_filter2.data<0;
    mfr.vars.diffuse_hemisp_narrowband_filter2.data(miss|~day) = 0;
    miss = mfr.vars.diffuse_hemisp_narrowband_filter3.data<0;
    mfr.vars.diffuse_hemisp_narrowband_filter3.data(miss|~day) = 0;
    miss = mfr.vars.diffuse_hemisp_narrowband_filter4.data<0;
    mfr.vars.diffuse_hemisp_narrowband_filter4.data(miss|~day) = 0;
    miss = mfr.vars.diffuse_hemisp_narrowband_filter5.data<0;
    mfr.vars.diffuse_hemisp_narrowband_filter5.data(miss|~day) = 0;
    miss = mfr.vars.diffuse_hemisp_narrowband_filter6.data<0;
    mfr.vars.diffuse_hemisp_narrowband_filter6.data(miss|~day) = 0;
    
    difu_out = [serial2Hh(mfr.time); ...
        mfr.vars.diffuse_hemisp_narrowband_filter1.data;mfr.vars.diffuse_hemisp_narrowband_filter2.data;...
        mfr.vars.diffuse_hemisp_narrowband_filter3.data;mfr.vars.diffuse_hemisp_narrowband_filter4.data;...
        mfr.vars.diffuse_hemisp_narrowband_filter5.data;mfr.vars.diffuse_hemisp_narrowband_filter5.data];
    fname = ['diffuse_',datestr(mfr.time(1),'yyyymmdd'),'.xmfrx.txt'];
    fid_out = fopen([pname, filesep, fname],'w');
    format_str = '%12.5f %12.4f %12.4f %12.4f %12.4f %12.4f %12.4f \n';
    fprintf(fid_out,strrep(format_str,' ',''),difu_out);
    fclose(fid_out);
end
%%
% figure; plot(aod(:,1), 
%%
% Generate AOD output: 
%    Hh      doy        csza     aod415   aod500  aod615  aod676  aod870  aod940                  saz    CF
%    0.01120 151.00047 -0.487800 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000  -9.900  -9.900   359.7   -9.00
%    0.01672 151.00070 -0.487800 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000  -9.900  -9.900   359.8   -9.00
%    0.02224 151.00093 -0.487800 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000  -9.900  -9.900   359.9   -9.00
%    0.02776 151.00116 -0.487800 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000  -9.900  -9.900   360.0   -9.00
%    0.03328 151.00139 -0.487800 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000  -9.900  -9.900     0.1   -9.00
%    0.03880 151.00162 -0.487800 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000  -9.900  -9.900     0.2   -9.00
%    0.04456 151.00186 -0.487800 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000  -9.900  -9.900     0.3   -9.00
%    0.05008 151.00209 -0.487800 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000 -9.9000  -9.900  -9.900     0.3   -9.00
% [1,:] fractional hour decimal with five trailing digits
% [2,:] Julian day with fractional day, five trailing digits
% [3,:] cosine(SZA), six trailing digits
% [4:9,:] aod, missing -9.9
% [10,:]; angstrom, missing -9.9
% [11,:] PWV, missing -9.9
% [12,:] SAZ
% [13,:] CF, missing -9.0


%% Cosine normal file
%  Hh csza dir1 dir2 dir3 dir4 dir5 dir6
%    0.01120    -0.487800   dirn1 dirn2 dirn3 dirn4 dirn5 dirn6
% [1,:] Hh
% [2,:] csza
% [3:8,:] dirn

%% Diffuse file
%  13.43896    0.8073    0.8782    0.7570    0.7034    0.4855    0.1421
%% Hh dif1 dif2 dif3 dif4 dif5 dif6
% [1,:] Hh
% [2:7,:] difh
%%
return