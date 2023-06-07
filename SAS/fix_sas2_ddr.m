function he2 = fix_sas2_ddr(he, mfr)
% he2 = fix_sas2_ddr(he, mfr)
% fixes SAS direct_to_diffuse ratio to agree with MFRSR by rescaling and partioning the
% SAS measured direct and diffuse fields.  Have verified that this apportioning is
% wavelength independent.
% In progress after having identified an albebra error.  Don't use the "k"
% formulation. Instead use the one in comments with mu and Dd.

% This is a "special" version of this function for an SAS mat file I hacked together
% at the bottom of procsas_a0tob1_fsb from the a0 files to fix the diffuse field bug
he = load('C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\aodfit_be\sgp_2022\sasa0_corr_tint5_difh.mat');

if ~isavar('mfr')
    mfr = anc_bundle_files;
    mfr_ddr = [mfr.vdata.direct_diffuse_ratio_filter1;mfr.vdata.direct_diffuse_ratio_filter2;...
mfr.vdata.direct_diffuse_ratio_filter3;mfr.vdata.direct_diffuse_ratio_filter4;mfr.vdata.direct_diffuse_ratio_filter5];
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

sun_ = dirh_prime(2,:)>0 & (dirh_prime(2,:)./(dirh_prime(2,:)+dif_prime(2,:))) > .15; 
sun = double(sun_); sun(~sun_) = NaN; %Used to mask non-sun elements in plot

% ff is that fraction by which the direct component is under-represented
% and which is incorrectly attributed as additional diffuse signal.
% Compute ff for three wavelengths (for robustness) but apply equally at
% all wavelengths since this is a geometric effect attributable to the
% shadow on the diffuser which affects all wavelengths equally
% mu = 1./cos(sza)
% ff = (mu./Dd + 1)./(mu./Dd_prime +1); 
% dn = dn_prime./ff; dirh = dirh_prime./ff; dif = dif_prime - dirh.(1-ff)

mu = 1./cosd(he.sza); mu = (ones([5,1])*mu); % For convenience and readability
dn_prime = dirh_prime.*mu;
Dd_prime = dn_prime./dif_prime;% 
Dd = interp1(mfr.time, [mfr_ddr]', he.time,'linear')';
ff = (mu./Dd + 1)./(mu./Dd_prime +1); 
ff(:, he.oam<1 | he.oam>6) = NaN; 
ff_bar = nanmean(ff(2:4,:));

% figure; sb(1) = subplot(2,1,1); plot(sun.*he.time, ff(2:4,:),'-', sun.*he.time, ff_bar, 'k.'); dynamicDateTicks
%         sb(2) = subplot(2,1,2); plot(sun.*he.time, nanstd(ff(2:4,:)),'r-'); dynamicDateTicks
%         linkexes;
dn = dn_prime./ff; 
dirh = dirh_prime./ff; 
dif = dif_prime - dirh.*(1-ff);
bad  = dn<0 | dirh<0 | dif < 0 | ff < 0| ff>1 | dn./dif>40; 
ff(bad) = NaN;ff_bar = mean(ff(2:4,:));
dn = dn_prime./ff; 
dirh = dirh_prime./ff; 
dif = dif_prime - dirh.*(1-ff);
 figure; plot(mfr.time,mfr_ddr ,'-', sun.*he.time, dn./dif, 'k.'); dynamicDateTicks; %axis(v)
he2 = he; 
 he2.dirh = he.dirh./(ones(size(he.wl))*ff_bar);
 he2.dirn = he.dirh.*(ones(size(he.wl))*mu(1,:));
 he2.difh = he.difh - he2.dirh.*(1-ones(size(he.wl))*ff_bar);
 he2.ff = ff_bar;

end

save('C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\aodfit_be\sgp_2022\sasa0_corr_tint5_difh_ddr.mat', '-struct','he2');