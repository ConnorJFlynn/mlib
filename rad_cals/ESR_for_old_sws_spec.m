% One-off code written for SWS. 
% This version was followed by ESR_for_spec_nm and gen_ESR_for_SAS
% functions
% read in spectral solar irradiance files, probably in wn
% convert in full glory to wl, either um or nm

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


% SWS 
%Assume 8 nm FWHM for UV/VIS and 12 nm for SWIR
sws_raw = read_sws_raw_pre2011_with_orig_InGaAs;
for pix = 1:length(sws_raw.Si_lambda)
   [P,sigma] = gaussian_fwhm(kur.nm,sws_raw.Si_lambda(pix),8);    P(isNaN(P))=0;
%    P(P<1e-6) = 0;
   PA = P./(sigma*sqrt(2*pi));
   sws_raw.Si_ETR_kur(pix) = trapz(flipud(kur.nm), flipud(kur.esr_nm.*PA));
   
   [P,sigma] = gaussian_fwhm(all_mod.nm,sws_raw.Si_lambda(pix),8);   P(isNaN(P))=0;
   
   PA = P./(sigma*sqrt(2*pi));
   sws_raw.Si_MCebKur(pix) = trapz((all_mod.nm), (all_mod.MCebKur.*PA));     
   sws_raw.Si_MChKur(pix) = trapz((all_mod.nm), (all_mod.MChKur.*PA));   
   sws_raw.Si_MNewKur(pix) = trapz((all_mod.nm), (all_mod.MNewKur.*PA));   
   sws_raw.Si_MODWherli_WMO(pix) = trapz((all_mod.nm), (all_mod.MODWherli_WMO.*PA));   
   sws_raw.Si_MoldKur(pix) = trapz((all_mod.nm), (all_mod.MoldKur.*PA));   
   sws_raw.Si_MthKur(pix) = trapz((all_mod.nm), (all_mod.MthKur.*PA));   
   
end

for pix = 1:length(sws_raw.In_lambda)
   [P,sigma] = gaussian_fwhm(kur.nm,sws_raw.In_lambda(pix),12);   P(isNaN(P))=0;
%    P(P<1e-6) = 0;
   PA = P./(sigma*sqrt(2*pi));
   sws_raw.In_ETR_kur(pix) = trapz(flipud(kur.nm), flipud(kur.esr_nm.*PA));

  [P,sigma] = gaussian_fwhm(all_mod.nm,sws_raw.In_lambda(pix),12);   P(isNaN(P))=0;
   PA = P./(sigma*sqrt(2*pi));
   sws_raw.In_MCebKur(pix) = trapz((all_mod.nm), (all_mod.MCebKur.*PA));   
   sws_raw.In_MChKur(pix) = trapz((all_mod.nm), (all_mod.MChKur.*PA));   
   sws_raw.In_MNewKur(pix) = trapz((all_mod.nm), (all_mod.MNewKur.*PA));   
   sws_raw.In_MODWherli_WMO(pix) = trapz((all_mod.nm), (all_mod.MODWherli_WMO.*PA));   
   sws_raw.In_MoldKur(pix) = trapz((all_mod.nm), (all_mod.MoldKur.*PA));   
   sws_raw.In_MthKur(pix) = trapz((all_mod.nm), (all_mod.MthKur.*PA));   
   
end

pct_diff = abs(100.*(sws_raw.Si_MNewKur-sws_raw.Si_ETR_kur)./sws_raw.Si_ETR_kur);
Si_out = fopen([kurucz_path, 'sws_solar_ESR.MNewKur.Si.20060101.20100701.txt'],'w'); %W.M-2.nm-1
fprintf(Si_out,'%s \n','% SWS solar source function for Si spectrometer');
fprintf(Si_out,'%s \n','% Modtran New Kurucz ESR convolved with 8 nm FWHM Gaussian in wavelength space');
fprintf(Si_out, '%s \t %s \t %s \n', 'wavelength_nm ,', 'ESR_W/(m^2*nm) , ', 'diff_pct');
A = [sws_raw.Si_lambda, sws_raw.Si_MNewKur',pct_diff']';
fprintf(Si_out,'%3.2f ,\t %2.8e ,\t %2.2f \n', A);
fclose(Si_out);

pct_diff = abs(100.*(sws_raw.In_MNewKur-sws_raw.In_ETR_kur)./sws_raw.In_ETR_kur);
In_out = fopen([kurucz_path, 'sws_solar_ESR.MNewKur.InGaAs.20060101.20100701.txt'],'w'); %W.M-2.nm-1
fprintf(In_out,'%s \n','% SWS solar source function for InGaAs spectrometer');
fprintf(Si_out,'%s \n','% Modtran New Kurucz ESR convolved with 12 nm FWHM Gaussian in wavelength space');
fprintf(In_out, '%s \t %s \t %s \n', 'wavelength_nm ,', 'ESR_W/(m^2*nm) , ', 'diff_pct');
A = [sws_raw.In_lambda, sws_raw.In_MNewKur',pct_diff']';
fprintf(In_out,'%3.2f ,\t %2.8e ,\t %2.2f \n', A);
fclose(In_out);





figure; ss(1) = subplot(2,1,1); plot(sws_raw.Si_lambda, sws_raw.Si_ETR_kur,'k-'); title('Kurucz ETR');
ss(2) = subplot(2,1,2);plot(sws_raw.Si_lambda, sws_raw.Si_MNewKur-sws_raw.Si_ETR_kur,'-');
legend('NewKur - Kur');linkaxes(ss,'x')
title('Difference from ETR Kur');


figure; nn(1) = subplot(2,1,1); plot(sws_raw.In_lambda, sws_raw.In_ETR_kur,'k-'); title('Kurucz ETR');
nn(2) = subplot(2,1,2);plot(sws_raw.In_lambda, sws_raw.In_MNewKur-sws_raw.In_ETR_kur,'-');
legend('NewKur');linkaxes(nn,'x')
title('Difference from ETR Kur');

figure; sn(1) = subplot(2,1,1); plot(sws_raw.Si_lambda, sws_raw.Si_ETR_kur,'k-',...
   sws_raw.In_lambda, sws_raw.In_ETR_kur,'k-'); title('Kurucz ETR');
sn(2) = subplot(2,1,2);plot(sws_raw.Si_lambda, 100.*(sws_raw.Si_MNewKur-sws_raw.Si_ETR_kur)./sws_raw.Si_ETR_kur,'b-');
legend('NewKur');
hold('on');plot(sws_raw.In_lambda, 100.*(sws_raw.In_MNewKur-sws_raw.In_ETR_kur)./sws_raw.In_ETR_kur,'b-');
linkaxes(sn,'x')
title('% Difference from ETR Kur');


