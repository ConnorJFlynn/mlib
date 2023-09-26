function he = fix_sas_ddr(he, mfr)
% he = fix_sas_ddr(he, mfr)
% fixes SAS direct_to_diffuse ratio to agree with MFRSR by rescaling and partioning the
% SAS measured direct and diffuse fields.  Have verified that this aportioning is
% wavelength independent.
% In progress after having identified an albebra error.  Don't use the "k"
% formulation. Instead use the one in comments with mu and Dd.

if ~isavar('mfr')
    mfr = anc_bundle_files;
end
if isfield(he,'wl') % Then it is not a netcdf file
    wl = he.wl;
    pixel = interp1(he.wl, [1:length(he.wl)],[415,500,615,673,870],'nearest'); %this pixel is near the maximum solar brightness
elseif isfield(he,'vdata')&&isfield(he.vdata,'wavelength') % then it is (probably) sashemfr.b1 or aod?
    wl = he.vdata.wavelength;
    pixel = interp1(he.vdata.wavelength, [1:length(he.vdata.wavelength)],[415,500,615,673,870],'nearest'); %this pixel is near the maximum solar brightness    
elseif isfield(he,'vdata')&&isfield(he.vdata,'wavelength_vis') % then it is sashevis file.
    wl = he.vdata.wavelength_vis;
    pixel = interp1(he.vdata.wavelength_vis, [1:length(he.vdata.wavelength_vis)],[415,500,615,673,870],'nearest'); %this pixel is near the maximum solar brightness
end

if isfield(he.vdata, 'direct_horizontal_415nm')
   dirh = [he.vdata.direct_horizontal_415nm;he.vdata.direct_horizontal_500nm; he.vdata.direct_horizontal_615nm; he.vdata.direct_horizontal_673nm; he.vdata.direct_horizontal_870nm];
   difh = [he.vdata.diffuse_hemisp_415nm;he.vdata.diffuse_hemisp_500nm; he.vdata.diffuse_hemisp_615nm; he.vdata.diffuse_hemisp_673nm; he.vdata.diffuse_hemisp_870nm];
else
   dirh = he.vdata.direct_normal_transmittance.*(ones(size(he.vdata.wavelength))*he.vdata.cosine_correction);
   difh = [he.vdata.diffuse_transmittance];
end
sun_ = dirh(2,:)>0 & (dirh(2,:)./(dirh(2,:)+difh(2,:))) > .15;
sun = double(sun_); sun(~sun_) = NaN; %Used to mask non-sun elements in plot

% ff is that fraction by which the direct component is under-represented
% and which is incorrectly attributed as additional diffuse signal.
% Compute ff for three wavelengths (for robustness) but apply equally at
% all wavelengths since this is a geometric effect attributable to the
% shadow on the diffuser which affects all wavelengths equally
% mu = 1./cos(sza)
% ff = (mu./Dd + 1)./(mu./Dd_prime +1); 
% dn = dn_prime./ff; dirh = dirh_prime./ff; dif = dif_prime - dirh.(1-ff)

mu = 1./he.vdata.cosine_solar_zenith_angle; mu = ones([5,1])*mu;
dn_prime = [he.vdata.direct_normal_415nm;he.vdata.direct_normal_500nm;he.vdata.direct_normal_615nm];
dn_prime = [dn_prime; he.vdata.direct_normal_673nm;he.vdata.direct_normal_870nm];
dirh_prime = [he.vdata.direct_horizontal_415nm;he.vdata.direct_horizontal_500nm;he.vdata.direct_horizontal_615nm];
dirh_prime = [dirh_prime;he.vdata.direct_horizontal_673nm;he.vdata.direct_horizontal_870nm];
dif_prime = [he.vdata.diffuse_hemisp_415nm;he.vdata.diffuse_hemisp_500nm;he.vdata.diffuse_hemisp_615nm];
dif_prime = [dif_prime;he.vdata.diffuse_hemisp_673nm;he.vdata.diffuse_hemisp_870nm];
Dd_prime = [he.vdata.direct_normal_415nm./he.vdata.diffuse_hemisp_415nm;he.vdata.direct_normal_500nm./he.vdata.diffuse_hemisp_500nm];
Dd_prime = [Dd_prime;he.vdata.direct_normal_615nm./he.vdata.diffuse_hemisp_615nm;he.vdata.direct_normal_673nm./he.vdata.diffuse_hemisp_673nm];
Dd_prime = [Dd_prime;he.vdata.direct_normal_870nm./he.vdata.diffuse_hemisp_870nm];
Dd = interp1(mfr.time, [mfr.vdata.direct_diffuse_ratio_filter1;mfr.vdata.direct_diffuse_ratio_filter2;...
mfr.vdata.direct_diffuse_ratio_filter3;mfr.vdata.direct_diffuse_ratio_filter4;mfr.vdata.direct_diffuse_ratio_filter5]', he.time,'linear')';
ff = (mu./Dd + 1)./(mu./Dd_prime +1); 
ff(:, he.vdata.airmass<1 | he.vdata.airmass>6) = NaN;
dn = dn_prime./ff; dirh = dirh_prime./ff; dif = dif_prime - dirh.*(1-ff);
bad  = dn<0 | dirh<0 | dif < 0 | ff < 0| ff>1 | dn./dif>40; ff(bad) = NaN;
dn = dn_prime./ff; dirh = dirh_prime./ff; dif = dif_prime - dirh.*(1-ff);
he.vdata.direct_horizontal_415nm = dirh(1,:);he.vdata.direct_normal_415nm = dn(1,:); he.vdata.diffuse_hemisp_415nm = dif(1,:);
he.vdata.direct_horizontal_500nm = dirh(2,:);he.vdata.direct_normal_500nm = dn(2,:); he.vdata.diffuse_hemisp_500nm = dif(2,:);
he.vdata.direct_horizontal_615nm = dirh(3,:);he.vdata.direct_normal_615nm = dn(3,:); he.vdata.diffuse_hemisp_615nm = dif(3,:);
he.vdata.direct_horizontal_673nm = dirh(4,:);he.vdata.direct_normal_673nm = dn(4,:); he.vdata.diffuse_hemisp_673nm = dif(4,:);
he.vdata.direct_horizontal_870nm = dirh(5,:);he.vdata.direct_normal_870nm = dn(5,:); he.vdata.diffuse_hemisp_870nm = dif(5,:);


% Used average ff and confirmed graphically that it looks good for pixel
% dirh_new = dirh(sun_,:) .*(1+ mean(ff,2)*ones(size(pixel)));
% difh_new = difh(sun_,:) - dirh(sun_,:).*(mean(ff,2)*ones(size(pixel)));
% am = interp1(mfr.time, mfr.vdata.airmass, he.time, 'linear')';
% DDR_new = (dirh_new./difh_new).*(am(sun_)*ones(size(pixel)));

% physically, ff >= 0 (statistically allow >= -0.1 )and also >= difh/dirh ratio % why this second part?
% dirh = he.vdata.dirh_raw_fsb(:,pixel); difh = he.vdata.difh_raw_fsb(:,pixel);
% ff = mean(ff,1); ff(ff<-0.1) = NaN;
% baddifdir = (difh(:,sun_)./dirh(:,sun_))<= (ones([5,1])*ff); 
% baddifdir=any(baddifdir,1);
% ff(baddifdir) = NaN;
% Intend to create new field ff in he, and output re-scaled direct and
% diffuse and DNDR components in place.  

% he.ncdef.vars.shading_error = he.ncdef.vars.airmass;
% he.vdata.shading_error = zeros(size(he.vdata.airmass));
% he.vdata.shading_error(sun_) = ff;
% he.vatts.shading_error = he.vatts.airmass; 
% he.vatts.shading_error.long_name = 'Shading error as a fraction of direct component misplaced'; 
% he.vatts.integration_time.units = '1'; 
% 
% he.ncdef.vars.dirh_ffixed = he.ncdef.vars.dirh_raw_fsb;
% he.vdata.dirh_ffixed = he.vdata.dirh_raw_fsb;
% he.vdata.dirh_ffixed(:,sun_) = he.vdata.dirh_raw_fsb(:,sun_) .*(1+ ones(size(he.vdata.wavelength))*ff);
% he.vatts.dirh_ffixed = he.vatts.dirh_raw_fsb; 
% he.vatts.dirh_ffixed.long_name = 'Direct horiz., FSB max-min method, fixed to MFRSR DDR'; 
% he.vatts.dirh_ffixed.units = '1/ms'; 
% 
% he.ncdef.vars.difh_ffixed = he.ncdef.vars.difh_raw_fsb;
% % he_fix.difh_fix(sun_,:) = he.difh_raw_new(sun_,:) - he.dirh_raw_new(sun_,:).*(mean(ff,2)*ones(size(wl)));
% he.vdata.difh_ffixed = he.vdata.difh_raw_fsb;
% he.vdata.difh_ffixed(:,sun_) = he.vdata.difh_raw_fsb(:,sun_) - ...
%     he.vdata.dirh_raw_fsb(:,sun_).*(ones(size(he.vdata.wavelength))*ff); 
% he.vatts.difh_ffixed.long_name = 'Diffuse hemisp., FSB max-min method, fixed to MFRSR DDR'; 
% he.vatts.difh_ffixed.units = '1/ms'; 
%  
% he.ncdef.vars.DNDR_raw = he.ncdef.vars.difh_raw_fsb;
% he.vdata.DNDR_raw = (ones(size(he.vdata.wavelength))*he.vdata.airmass).* he.vdata.dirh_raw_fsb./he.vdata.difh_raw_fsb;
% he.vatts.DNDR_raw = he.vatts.difh_raw_fsb; 
% he.vatts.DNDR_raw.long_name = 'Direct Normal to Diffuse Hemis Ratio: dirn/difh_raw'; 
% he.vatts.DNDR_raw.units = '1'; 
% 
% he.ncdef.vars.DNDR_ffixed = he.ncdef.vars.difh_ffixed;
% he.vdata.DNDR_ffixed = (ones(size(he.vdata.wavelength))*he.vdata.airmass).* he.vdata.dirh_ffixed./he.vdata.difh_ffixed;
% he.vatts.DNDR_ffixed = he.vatts.difh_raw_fsb; 
% he.vatts.DNDR_ffixed.long_name = 'Direct Normal to Diffuse Hemisp Ratio: dirn_ffixed/difh_ffixed'; 
% he.vatts.DNDR_ffixed.units = '1'; 




end