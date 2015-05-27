function spec_ESR = ESR_for_spec_nm(spec,slit_fnt);
% spec = ESR_for_spec_nm(spec,slit_fnt);
% Generate ESR convolved to wavelength scale provided in supplied in spec
% slit_fnt may be a static value taken to be a Gaussian FWHM, a row vector
% taken to be the FWHM for each pixel, or a matrix of weights indicating 
% response of each pixel to each other pixel.

% We use New Kurucz from MODTRAN as our preferred source function at high
% precision but converted to a nm wavelength scale.
% Lacking solid uncertainties, we use the absolute percent difference between the
% MODTRAN New Korucz and kurucz_mW_m2_cm_1.

% This function followed the one-off script ESR_for_spec written for SWS

if ~exist('spec','var')
   spec = anc_load;
end
if ~exist('slit_fnt','var')
   slit_fnt = 3;
end

% Then for each pixel from a spectrometer, we'll compute the convolved
% solar source function in several ways in wl and wn space.

% First, we'll convolved in wl space.  
% Simplest, in wl space. For each pixel, compute trapz(source_nm, sol(source_nm),w(source_nm))
% where w 

all_mod_path = ['D:\case_studies\radiation_cals\ESR\AllMODEtr\'];
all_mod_file = 'AllMODEtr.txt';
% UNITS: W.M-2.nm-1
all_id = fopen([all_mod_path,all_mod_file],'r');
C = textscan(all_id,'%f %f %f %f %f %f %f %f %*[^\n]','delimiter','\t','EmptyValue',NaN, 'Headerlines',1);
all_mod.wn = C{1};
all_mod.nm = C{2};    %*(kur.wn.^2)./(1e7*1e3);
all_mod.cnvt_nm_to_wn = 1e7./(all_mod.wn.^2);
% convert ESR in wn to nm factor (wn.^2)./(1e7)
all_mod.MCebKur = C{3}; all_mod.MCebKur(isNaN(all_mod.MCebKur))=0;
all_mod.MChKur = C{4}; all_mod.MChKur(isNaN(all_mod.MChKur))=0;
all_mod.MNewKur = C{5}; all_mod.MNewKur(isNaN(all_mod.MNewKur))=0;
all_mod.MthKur = C{6}; all_mod.MthKur(isNaN(all_mod.MthKur))=0;
all_mod.MoldKur = C{7}; all_mod.MoldKur(isNaN(all_mod.MoldKur))=0;
all_mod.MODWherli_WMO = C{8}; all_mod.MODWherli_WMO(isNaN(all_mod.MODWherli_WMO))=0;


kurucz_path = ['D:\case_studies\radiation_cals\ESR\'];
kurucz_file = 'kurucz_mW_m2_cm_1.txt';
kurucz = load([kurucz_path, kurucz_file]);
figure; plot(kurucz(:,1), kurucz(:,2), 'b.',kurucz(:,1), kurucz(:,3), 'r-');
legend('kurucz','max esr');
xlabel('wn')
ylabel('mW/(m^2 cm)')


kur.wn = kurucz(:,1);
kur.nm = 1e7./kur.wn;
kur.cnvt_wn_to_nm = (kur.wn.^2)./(1e7);
kur.esr_wn = kurucz(:,2); kur.esr_wn(isNaN(kur.esr_wn)) = 0;
kur.esr_nm = kur.esr_wn.*kur.cnvt_wn_to_nm./(1e3);% convert from mW to W
kur.max_esr = kurucz(:,3);

spec_ESR.nm = spec.vdata.wavelength;
good_nm = kur.nm(~isNaN(kur.nm)&kur.nm>0);
sign1 = mean(diff(good_nm)); sign1 = sign1./abs(sign1);
good_nm = all_mod.nm(~isNaN(all_mod.nm)&all_mod.nm>0);
sign2 = mean(diff(good_nm)); sign2 = sign2./abs(sign2);


for pix = length(spec_ESR.nm):-1:1
   [P,sigma] = gaussian_fwhm(kur.nm, spec_ESR.nm(pix),slit_fnt);    P(isNaN(P))=0;
%    P(P<1e-6) = 0;
   PA = P./(sigma*sqrt(2*pi));
   spec_ESR.ETR_kur(pix) = sign1.*trapz(kur.nm, kur.esr_nm.*PA);   
   [P,sigma] = gaussian_fwhm(all_mod.nm,spec_ESR.nm(pix),slit_fnt);   P(isNaN(P))=0;   
   PA = P./(sigma*sqrt(2*pi));
   spec_ESR.MNewKur(pix) = sign2.*trapz((all_mod.nm), (all_mod.MNewKur.*PA));   
end


spec_ESR.pct_diff = abs(100.*(spec_ESR.MNewKur-spec_ESR.ETR_kur)./spec_ESR.ETR_kur);

return
