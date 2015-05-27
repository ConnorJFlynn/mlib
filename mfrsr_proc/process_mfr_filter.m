function [filter] = process_mfr_filter(raw_filter);
%filter = process_mfr_filter(raw_filter);
% Requires a raw_filter structure with equal length .nm and .T
% raw_filter.nm is assumed monotonic and in nanometers
% Finds the filter peak and the region +/- 20 nm of this peak
% Identifies the lowest 1/6 values on either side of the peak 
% fits a best line to these points to represent a baseline for subtraction,
% and then normalizes the base-line subtracted curve to unity area.  The
% "normalize" function also reports the peak wavelength, the fwhm, the
% filter mid-line between the half-max points, and the filter
% centerline calculated as the "center of mass" trapz(nm, T .* nm)

[maxT,peak_ind] = max(raw_filter.T);
raw_filter.peak = raw_filter.nm(peak_ind);
lower_bound = max(find((raw_filter.nm<raw_filter.nm(peak_ind)-20)));
if isempty(lower_bound)
   lower_bound = 1;
end
lower_range = (lower_bound:lower_bound + ceil((peak_ind-lower_bound)/6));
%     [by_T, T_ind] = sort(raw_filter.ch{i}.T(lower_range));
%     lowest_of_low = T_ind(1:ceil(length(T_ind)/8));

upper_bound = min(find(raw_filter.nm>(raw_filter.nm(peak_ind)+20)));
if isempty(upper_bound)
   upper_bound = length(raw_filter.nm);
end
upper_range = (upper_bound-floor((upper_bound-peak_ind)/6):upper_bound);

%     [by_T, T_ind] = sort(raw_filter.ch{i}.T(upper_range));
%     lowest_of_upper = T_ind(1:ceil(length(T_ind)));

[raw_filter.base_P] = polyfit(raw_filter.nm([lower_range, upper_range]),raw_filter.T([lower_range, upper_range]),1);
[raw_filter.base_line] = polyval(raw_filter.base_P,raw_filter.nm(lower_bound:upper_bound));

filter.nominal = raw_filter.nominal;
filter.nm = raw_filter.nm(lower_bound:upper_bound);
raw_filter = rmfield(raw_filter, 'nominal');
filter.raw = raw_filter;
%filter.nm = raw_filter.nm(lower_bound:upper_bound);
%         nm = raw_filter.nm(lower_bound:upper_bound);
%
%         T_band = ones(size([lower_bound:upper_bound]));
%         T_band = normalize_filter(nm, T_band);
%filter.T = raw_filter.T(lower_bound:upper_bound)-raw_filter.base_line;
T = raw_filter.T(lower_bound:upper_bound)-raw_filter.base_line;
[filter.normed] = normalize_filter(filter.nm,T);
end