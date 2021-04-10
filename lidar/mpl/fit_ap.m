function ap_out = fit_ap(range, ap, max_alt, blind);
% This function attempts to fit a supplied afterpulse curve from the MPL in
% order to yield a less-noisy afterpulse subtraction.  It uses "fit_it" over
% defined subranges and overlap_smooth combine these piecewise results.


% The idea here was to use "fit_it" to determine a fit that would
% consider both the constant offset from dark counts and the
% quasi-exponential behavior of the afterpulse. And to compute this fit
% over different sub-ranges, eventually forming a smoothed combination.
% This is working but not sure it is worth the effort since the
% constant term is much larger than the expected dark counts such that
% subtracting it leads to negative afterpulse at near ranges.

% Might be just as well off using piecewise polyfits.
% Actually the fit using fit_it look MUCH better.
% Which further motivites me to implement the overlap function which
% will compute a weighted average of two supplied vectors over an
% overlapping region. Probably support multiple weight profiles
% including linear and sinusoid (cos^2 + sin^2)

if ~isavar('max_alt')
   max_alt = 60;
end
if ~isavar('blind')
   blind = 0.075; % blind within 75 meters of laser flash
end
flash = abs(range)< blind;
ap(flash) = NaN;

range_orig = range;
range = mod(range,max_alt); % same as range(range<0) = range(range<0) + max_alt;
range_orig = range;
[range,ii] = sort(range); ap = ap(ii);
%     figure; plot(range, ap, 'o-'); logy

lte_fit = range>0 & range<=2;
eq = {'1';'log(X).^2';'log(X).^4';'log(X).^6'};
low_range = range>0.075 & range < .4 & ~isnan(ap);
[K_low] = fit_it(range(low_range),ap(low_range),eq);
low_fit = eval_eq(range(low_range),K_low,eq);

eq = {'1';'log10(X)';'log10(X).^2'};
mid_range = range>.3&range<20;
[K_mid] = fit_it(range(mid_range),ap(mid_range),eq);
mid_fit = eval_eq(range(mid_range),K_mid,eq);

eq = {'1'; 'log(X)';'log(X).^3'};
hi_range = range>10&range<60&~isnan(ap);
[K_hi] = fit_it(range(hi_range),ap(hi_range),eq);
hi_fit = eval_eq(range(hi_range),K_hi,eq);
min_hi = 0.8.*min(hi_fit);

% Subtract min_hi to reduce resdidual quasi-constant term.
ap_fit = ap-min_hi;
[X_out, Y_out] = overlap_smooth(range(low_range), low_fit-min_hi, range(mid_range), (mid_fit)-min_hi);
rr = interp1(range, [1:length(range)],X_out,'nearest');
ap_fit(rr) = Y_out;
[X_out, Y_out] = overlap_smooth(X_out, Y_out, range(hi_range), (hi_fit)-min_hi);
rr = interp1(range, [1:length(range)],X_out,'nearest');
ap_fit(rr) = Y_out;

%     figure; plot(range(low_range), low_fit-min_hi,'o',range(mid_range), mid_fit-min_hi, 'x', ...
%        range(hi_range), hi_fit-min_hi, '+',X_out,Y_out,'k*',range, ap_out,'+-'); logx; logy
% if ~isgraphics(22)
%    figure_(22); plot(range, ap, '.',range, ap_fit +min_hi, 'o'); logx; logy
%    xlabel('range'); ylabel('counts'); legend('measurement','fit'); title('Afterpulse')
% end
bg_ = range>50 & range<59;
notnan = ~isnan(ap_fit);
ap_bg = meannonan(ap_fit(bg_));
if ~all(ap_fit(notnan & range<40)>ap_bg)
   warning('Afterpulse profile show minimum before background range!')
end
ap_out.range = range; ap_out.ap_fit = ap_fit;
r_i = [1:length(range)];
i_r = r_i(ii);
[~, jj] = sort(i_r);
ap_out.range = range(jj); ap_out.ap_fit = ap_fit(jj);

return