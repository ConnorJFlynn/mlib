function [aod_fit, good_wl_] = rfit_aod_basis(wl, aod, wl_out, stdev_mult);
% [aod_fit, good_wl_] = rfit_aod_basis(wl, aod,wl_out, stdev_mult);
% Iteratively rejects outlier data values while repeatedly consolidating
% aod base vectors
% wl should be Mx1 or 1xM
% aod should be Mx1 or 1xM or MxN with M matchin wl
% wl_out should be Nx1 or 1xN
% stdev_mult default = 2.5, smaller is more stringent
% Fits supplied AOD as a combination of log_aod basis vectors at selected
% wavelengths and returns over extended

% 2020-11-26: v1.0, Connor added version control
version_set('1.0');
% TBD: augment to output Ks, Cn, PDF etc.  Important if we want to use this
% to identify "dust" for example, or identify/remove "425 bip"
if ~isavar('wl_out')
    stdev_mult = 2.5;
    wl_out = wl;
elseif ~isavar('stdev_mult')
   stdev_mult = 2.5;
end
if length(wl_out)==1 && length(stdev_mult)>1
    tmp = wl_out;
    wl_out = stdev_mult; stdev_mult = tmp; clear tmp;
end
if isempty(wl_out)
    wl_out = wl;
end
if isempty(stdev_mult)
    stdev_mult = 2.5;
end

good_wl = true(size(wl)); 
if ~any(wl>100)
    wl = wl*1000;
end

if ~any(wl_out>100)
    wl_out = 1000*wl_out;
end
aod_fit = NaN([size(aod,1),size(wl_out,2)]);
good_wl_ = false([size(aod,1),size(wl,2)]);
% good_wl = wl<950 | wl > 1100;
for t = size(aod,1):-1:1
good_wl = good_wl & aod(t,:)>0 & isfinite(aod(t,:)) & ~isnan(aod(t,:)) & ~isnan(wl) & isfinite(wl);
goods = sum(good_wl);
done = false;
% dev(good_wl) = log(aod(t,good_wl)./fit_aod_basis(wl(good_wl),aod(t,good_wl)));
% sdev = std(dev(good_wl));
% mad = max(abs(dev(good_wl)));
% done = mad<(stdev_mult*sdev);
% Not sure if it is a good idea to have fit_aod_basis inside this loop
%   It will be less efficient, and might result in the basis set changing
%   in conjunction with data values being excluded. This might be good but
%   also might be unstable
while ~done
    fit_aod = fit_aod_basis(wl(good_wl),aod(t,good_wl));
    dev(good_wl) = log(aod(t,good_wl)./ fit_aod);
    sdev = std(dev(good_wl));
    mad = max(abs(dev(good_wl)));
    good_wl(good_wl) = abs(dev(good_wl))<mad;
    goods = sum(good_wl);
    done = mad<(stdev_mult*sdev);
end
good_wl_(t,:) = good_wl;
aod_fit(t,:) = fit_aod_basis(wl(good_wl),aod(t,good_wl),wl_out);
end
% figure; plot(1000.*bins, PSD,'-o');
% xlabel('bin radius [um]');
return