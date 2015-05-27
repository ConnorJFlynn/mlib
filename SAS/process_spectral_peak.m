function peak = process_spectral_peak(nm, spec);
%peak = process_spectral_peak(nm, spec);
% Accepts wavelength and spectral trace 
% nm is assumed monotonic and in nanometers
% Finds the filter peak and identifies the lowest 1/10 values on both sides 
% of the peak fits a best line to these points to represent a baseline for subtraction,
% and then normalizes the base-line subtracted curve to unity area.  The
% "normalize" function also reports the peak wavelength, the fwhm, the
% filter mid-line between the half-max points, and the filter
% centerline calculated as the "center of mass" trapz(nm, T .* nm)

peak.nm = nm;
peak.spec = spec;

[maxT,peak_ind] = max(spec);
% peak.nm_peak = nm(peak_ind);
lower_nm_i = find(nm<nm(peak_ind));
[spec_low,low_ij] = sort(spec(lower_nm_i)); 
n_low = sum(spec_low<(0.025*maxT));
n_low = max([n_low,5]);

upper_nm_i = find(nm>nm(peak_ind));
[spec_hi,hi_ij] = sort(spec(upper_nm_i)); 
n_hi = sum(spec_hi<(0.025*maxT));
n_hi = max([n_hi,5]);

peak.nm_base_i = [lower_nm_i(low_ij(1:n_low)) upper_nm_i(hi_ij(1:n_hi))];
baseline.nm = [nm(lower_nm_i(low_ij(1:n_low))) nm(upper_nm_i(hi_ij(1:n_hi)))];
baseline.spec = [spec(lower_nm_i(low_ij(1:n_low))) spec(upper_nm_i(hi_ij(1:n_hi)))];
[P, S] = polyfit(nm(peak.nm_base_i), spec(peak.nm_base_i),1);
% hold('on'); plot(baseline.nm, baseline.spec, 'ko',nm, polyval(P, nm,S),'r-');


% peak.baseline = baseline;
peak.baseline_fit = polyval(P, nm,S);
peak.spec_sans_base = spec - peak.baseline_fit;

[spec_peak,peak_ij] = sort(spec); spec_peak = fliplr(spec_peak); peak_ij = fliplr(peak_ij);
n_peak = sum(spec >= (.15*maxT));
n_peak = max([n_peak,5]);

peak.nm_fit_i = peak_ij(1:n_peak);
[~,gaus.mu,~,gaus.fwhm,gaus.peak]=mygaussfit(nm(peak.nm_fit_i),peak.spec_sans_base(peak.nm_fit_i),0);
peak.mu = gaus.mu;
peak.fwhm = gaus.fwhm;
peak.gaus = gaus;

end