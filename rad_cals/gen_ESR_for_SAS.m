function spec_ESR = gen_ESR_for_SAS(spec,slit_fnt);
% spec_ESR = gen_ESR_for_SAS(spec,slit_fnt);
% This function followed the one-off script ESR_for_spec written for SWS

if ~exist('spec','var')
   spec = anc_load;
end
if ~exist('slit_fnt','var')
   slit_fnt = 3;
end

% I have analyzed spectra of a mercury-argon discharge lamp collected with the 
% AMF SASZe vis spectrometer.  For each well-isolated line I subtracted a local 
% baseline and fit a Gaussian profile to the observed peak.  The attached plot 
% shows the FWHM for 14 lines distributed over the range of the CCD pixels.  
% They show a mean value of 1.77 nm and a stddev of 0.04 nm.  
if max(spec.vdata.wavelength)> 1500
   slit_fnt = 6;
else
   slit_fnt = 1.77; %
end
spec_ESR = ESR_for_spec_nm(spec,slit_fnt);
figure; s(1) = subplot(2,1,1); 
plot(spec.vdata.wavelength, spec.vdata.solar_spectrum,'.g-', spec_ESR.nm, spec_ESR.ETR_kur,'-k');
legend('Gueymard','Kurucz')
s(2) = subplot(2,1,2); 
plot(spec.vdata.wavelength, 100.*(spec.vdata.solar_spectrum'-spec_ESR.ETR_kur)./spec_ESR.ETR_kur,'-r.');
linkaxes(s,'x');
xlabel('wavenlength [nm]');
legend('Gueymard','Kurucz')



% spec = ESR_for_spec_nm(spec,slit_fnt);
% Generate ESR convolved to wavelength scale provided in supplied in spec
% slit_fnt may be a static value taken to be a Gaussian FWHM, a row vector
% taken to be the FWHM for each pixel, or a matrix of weights indicating 
% response of each pixel to each other pixel.

% We use New Kurucz from MODTRAN as our preferred source function at high
% precision but converted to a nm wavelength scale.
% Lacking solid uncertainties, we use the absolute percent difference between the
% MODTRAN New Korucz and kurucz_mW_m2_cm_1.

return
