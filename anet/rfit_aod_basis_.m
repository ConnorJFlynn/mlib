function [aod_fit, good_wl, Ks, out_modes] = rfit_aod_basis(wl, aod, wl_out, stdev_mult);
% aod_fit = rfit_aod_basis(wl, aod,wl_out);
% wl should be Mx1 or 1xM
% aod should be Mx1 or 1xM or MxN with M matchin wl
% wl_out should be Nx1 or 1xN
% Fits supplied AOD as a combination of log_aod basis vectors at selected
% wavelengths and returns over extended
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
good_wl = wl<950 | wl > 1100;
good_wl = good_wl & aod>0 & isfinite(aod) & ~isnan(aod) & ~isnan(wl) & isfinite(wl);
goods = sum(good_wl);
done = false;
logaod = log(aod);
dev(good_wl) = log(aod(good_wl)./fit_aod_basis(wl(good_wl),aod(good_wl)));
sdev = std(dev(good_wl));
mad = max(abs(dev(good_wl)));
done = mad<(stdev_mult*sdev);
% Not sure if it is a good idea to have fit_aod_basis inside this loopl
%   It will be less efficient, and might result in the basis set changing
%   in conjunction with data values being excluded. This might be good but
%   also might be unstable
while ~done
    dev(good_wl) = log(aod(good_wl)./fit_aod_basis(wl(good_wl),aod(good_wl)));
    sdev = std(dev(good_wl));
    mad = max(abs(dev(good_wl)));
    good_wl(good_wl) = abs(dev(good_wl))<mad;
    goods = sum(good_wl);
    done = mad<(stdev_mult*sdev);
end
[aod_fit, Ks,out_modes] = fit_aod_basis(wl(good_wl),aod(good_wl),wl_out);
% figure; plot(1000.*bins, PSD,'-o');
% xlabel('bin radius [um]');
return