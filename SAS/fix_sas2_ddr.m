function he2 = fix_sas2_ddr(he, mfr)
% he2 = fix_sas2_ddr(he, mfr)
% fixes SAS direct_to_diffuse ratio to agree with MFRSR by rescaling and partioning the
% SAS measured direct and diffuse fields.  Have verified that this aportioning is
% wavelength independent.
% In progress after having identified an albebra error.  Don't use the "k"
% formulation. Instead use the one in comments with mu and Dd.

% This is a "special" version of this function for an SAS mat file I hacked together
% from the a0 files to fix the diffuse field bug

if ~isavar('mfr')
    mfr = anc_bundle_files;
end
if isfield(he,'wl') % Then it is not a netcdf file
    wl = he.wl;
    pixel = interp1(he.wl, [1:length(he.wl)],[415,500,615,673,870],'nearest'); %this pixel is near the maximum solar brightness
elseif isfield(he,'vdata')&&isfield(he.vdata,'wavelength') % then it is (probably) sashemfr.b1
    wl = he.vdata.wavelength;
    pixel = interp1(he.vdata.wavelength, [1:length(he.vdata.wavelength)],[415,500,615,673,870],'nearest'); %this pixel is near the maximum solar brightness    
elseif isfield(he,'vdata')&&isfield(he.vdata,'wavelength_vis') % then it is sashevis file.
    wl = he.vdata.wavelength_vis;
    pixel = interp1(he.vdata.wavelength_vis, [1:length(he.vdata.wavelength_vis)],[415,500,615,673,870],'nearest'); %this pixel is near the maximum solar brightness
end

dirh_prime = [he.dirh(pixel,:)];
dif_prime = [he.difh(pixel,:)];

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

mu = 1./cosd(he.sza); mu = ones([5,1])*mu;
dn_prime = dirh_prime.*mu;
Dd_prime = dn_prime./dif_prime;
Dd = interp1(mfr.time, [mfr.vdata.direct_diffuse_ratio_filter1;mfr.vdata.direct_diffuse_ratio_filter2;...
mfr.vdata.direct_diffuse_ratio_filter3;mfr.vdata.direct_diffuse_ratio_filter4;mfr.vdata.direct_diffuse_ratio_filter5]', he.time,'linear')';
ff = (mu./Dd + 1)./(mu./Dd_prime +1); 
ff(:, he.oam<1 | he.oam>6) = NaN; 
ff_bar = mean(ff(2:4,:));

dn = dn_prime./ff; 
dirh = dirh_prime./ff; 
dif = dif_prime - dirh.*(1-ff);
bad  = dn<0 | dirh<0 | dif < 0 | ff < 0| ff>1 | dn./dif>40; 
ff(bad) = NaN;ff_bar = mean(ff(2:4,:));
dn = dn_prime./ff; 
dirh = dirh_prime./ff; 
dif = dif_prime - dirh.*(1-ff);

he2 = he; 
 he2.dirh = he.dirh./(ones(size(he.wl))*ff_bar);
 he2.dirn = he.dirh.*(ones(size(he.wl))*mu(1,:));
 he2.difh = he.difh - he2.dirh.*(1-ones(size(he.wl))*ff_bar);
 he2.ff = ff_bar;
figure; plot(he2.time(he2.oam>.5&he2.oam<4), he2.oam(he2.oam>.5&he2.oam<4),'r.'); dynamicDateTicks;
% Used average ff and confirmed graphically that it looks good for pixel
% dirh_new = dirh(sun_,:) .*(1+ mean(ff,2)*ones(size(pixel)));
% difh_new = difh(sun_,:) - dirh(sun_,:).*(m[ttean(ff,2)*ones(size(pixel)));
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