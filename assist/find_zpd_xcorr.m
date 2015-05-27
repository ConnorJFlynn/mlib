function zpd_shift = find_zpd_xcorr(unflipped,win)
% zpd_shift = find_zpd_xcorr(unflipped,win)
% Finds zpd as point with greatest cross-correlation with mirror image
% Returns ZPD shift as an offset that the unflipped ifg must be shifted by
% to place the ZPD at the center.

if ~exist('win','var')||win<2
   win = 100;
end
cen= length(unflipped)./2;
unflipped = unflipped(cen-win:cen+win);
flipped = fliplr(unflipped);
% [R,lags] = xcorr(unflipped,flipped,100);
% [~,ind] = max(R); 
% zpd_shift = ceil(lags(ind)./2)+1; % The 1 puts the peak just to the right 
% % of "0" when the x-axis runs from [-length/2+1:length/2] like [-3:4]
% %%
[R_,lags_] = xcorr(flipped,unflipped,100);
[~,ind_]= max(abs(R_));
zpd_shift = floor(lags_(ind_)./2)-1;

% figure; 
% s(1) = subplot(2,1,1);
% plot(lags, unflipped./max(abs(unflipped)),'k-',lags,flipped./max(abs(flipped)),'b-');
% s(2) = subplot(2,1,2);
% plot(lags./2, R./max(abs(R)), 'ro-',lags_./2, R_./max(abs(R_)), 'go-');
% linkaxes(s,'x')

%%
