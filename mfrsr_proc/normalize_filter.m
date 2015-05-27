function [props] = normalize_filter(nm, T);
% This function normalizes a curve to unity area and then it
% computes the center weight, peak location, FWHM, and midline
area = trapz(nm, T);
T = T/area; % Normalize to unity area;
% if nargout > 1
    [maxT,peak_ind] = max(T);
    ind = peak_ind;
    while(T(ind)>(maxT/2))&ind>2
        ind = ind -1;
    end
    low_half = polyval(polyfit(T(ind:ind+1),nm(ind:ind+1),1),maxT/2);

    ind = peak_ind;
    while(T(ind)>(maxT/2))&(ind<(length(nm)-1))
        ind = ind +1;
    end
    high_half = polyval(polyfit(T(ind-1:ind),nm(ind-1:ind),1),maxT/2);
%     props.nm = nm;
    props.T = T;
    props.FWHM = high_half - low_half;
    props.midline = (high_half + low_half)/2;
    props.maxT_nm = nm(peak_ind);
    props.cw = trapz(nm, T .* nm);
% end

