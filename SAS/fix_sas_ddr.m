function he_fix = fix_sas_ddr(he, mfr)
% he = fix_sas_ddr(he, mfr)
% fixes SAS direct_to_diffuse ratio to agree with MFRSR by rescaling and partioning the
% SAS measured direct and diffuse fields.  Have verified that this portioning is
% wavelength independent.
if ~isavar('mfr')
    mfr = anc_bundle_files;
end
if isfield(he,'wl')
    wl = he.wl;
    pixel = interp1(he.wl, [1:length(he.wl)],[415,500,615,673,870],'nearest'); %this pixel is near the maximum solar brightness
elseif isfield(he,'vdata')&&isfield(he.vdata,'wavelength')
    wl = he.vdata.wavelength;
    pixel = interp1(he.vdata.wavelength, [1:length(he.vdata.wavelength)],[415,500,615,673,870],'nearest'); %this pixel is near the maximum solar brightness
end
dirh = he.dirh_raw_new(:,pixel); difh = he.difh_raw_new(:,pixel);

sun_ = dirh(:,2)>0 & (dirh(:,2)./(dirh(:,2)+difh(:,2))) > .15;
sun = double(sun_); sun(~sun_) = NaN;

k = mfr.vdata.direct_diffuse_ratio_filter1./mfr.vdata.airmass;
k = interp1(mfr.time, k, he.time, 'linear')';
k(~sun_) = NaN;
ff = (k(sun_).*(difh(sun_,1)./dirh(sun_,1))-1)./(k(sun_)+1);

k = mfr.vdata.direct_diffuse_ratio_filter2./mfr.vdata.airmass;
k = interp1(mfr.time, k, he.time, 'linear')';
k(~sun_) = NaN;
ff(:,2) = (k(sun_).*(difh(sun_,2)./dirh(sun_,2))-1)./(k(sun_)+1);

k = mfr.vdata.direct_diffuse_ratio_filter3./mfr.vdata.airmass;
k = interp1(mfr.time, k, he.time, 'linear')';
k(~sun_) = NaN;
ff(:,3) = (k(sun_).*(difh(sun_,3)./dirh(sun_,3))-1)./(k(sun_)+1);

dirh_new = dirh(sun_,:) .*(1+ mean(ff,2)*ones(size(pixel)));
difh_new = difh(sun_,:) - dirh(sun_,:).*(mean(ff,2)*ones(size(pixel)));
am = interp1(mfr.time, mfr.vdata.airmass, he.time, 'linear')';
DDR_new = (dirh_new./difh_new).*(am(sun_)*ones(size(pixel)));

ff = mean(ff,2); ff(ff<-0.1) = NaN;
baddifdir = (difh(sun_,:)./dirh(sun_,:))<= ff; baddifdir=any(baddifdir,2);
ff(baddifdir) = NaN;
he_fix.time = he.time;
he_fix.ff = ff;
he_fix.dirh_fix = he.dirh_raw_new;
he_fix.dirh_fix(sun_,:) = he.dirh_raw_new(sun_,:) .*(1+ mean(ff,2)*ones(size(wl)));
he_fix.dirh_fix(~sun_,:) = NaN;

he_fix.difh_fix = he.difh_raw_new;
he_fix.difh_fix(sun_,:) = he.difh_raw_new(sun_,:) - he.dirh_raw_new(sun_,:).*(mean(ff,2)*ones(size(wl)));
he_fix.difh_fix(~sun_,:) = NaN;

DNDR_orig = he.dirh_raw_new./he.difh_raw_new;
DNDR_orig = DNDR_orig.*(am*ones(size(wl)));

he_fix.DNDR_fix = he_fix.dirh_fix./he_fix.difh_fix;
he_fix.DNDR_fix(sun_,:) = he_fix.DNDR_fix(sun_,:).*(am(sun_)*ones(size(wl)));

figure; 
ax(1) = subplot(2,1,1); 
plot(he.time, DNDR_orig(:,pixel(1)), 'k.', he_fix.time(sun_), he_fix.DNDR_fix(sun_,pixel(1)),'.',mfr.time, mfr.vdata.direct_diffuse_ratio_filter1, '-');
dynamicDateTicks; legend('orig ddr','fixed ddr','mfr ddr');
ax(2) = subplot(2,1,2);
plot(he.time, he.dirh_raw_new(:,pixel(1)), 'k.', he_fix.time(sun_), he_fix.dirh_fix(sun_,pixel(1)),'.',mfr.time, 400.*mfr.vdata.direct_horizontal_narrowband_filter1, '-');
 legend('orig dirh','fixed dirh','mfr dirh'); 
 dynamicDateTicks; logy;linkaxes(ax,'x'); axis(ax(1),v)

% figure; plot(he_fix.time(sun_), he_fix.difh_fix(sun_,pixel(2)),'-o');
% figure; plot(he_fix.time(sun_), he_fix.difh_fix(sun_,pixel(1)).*am,'-'); dynamicDateTicks; xlim(v(1:2))    
% figure; plot(he_fix.time(sun_), ff,'r-' ); xlim(v(1:2)); dynamicDateTicks;


% Decide whether and how to flag or mask unacceptable f (flag f<0 and
% f>=dif/dirh 

end