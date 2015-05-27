function ap = auto_ap(mpl);
% ap = auto_ap(mpl);
% Returns a boolean flag of length(time) indicating true for profiles
% determined to be afterpulse.
% This routine is intended to be used with an MPL system having a
% sun-shutter that closes around solar noon.  Without this it doesn't work
% well.
if ~exist('mpl','var')
   %%   
   mpl = ancload(getfullname_('*.cdf','mpl_nc'));
   %%
   
end
% determine solar time from UTC and lon
%%
sol = mpl.time + double(floor(mpl.vars.lon.data/15))./24;
noonish = (serial2Hh(sol)>10)&(serial2Hh(sol)<14);
ap_times = (noonish&(mpl.vars.background_signal.data<1e-2));
w = ap_times;
w(ap_times) = madf(mpl.vars.background_signal.data(ap_times),4);
w(w) = madf(mpl.vars.background_signal.data(w),4);
ap = w;

% % figure;
% semilogy(serial2Hh(sol),mpl.vars.background_signal.data,'.-', ...
%    serial2Hh(sol(w)), mpl.vars.background_signal.data(w),'ro');
% ii_w = find(w);
% 
% %%
% % figure; 
% axs(1) = subplot(2,1,1); imagegap(serial2Hh(sol([ii_w(1)-10:ii_w(end)+10])), mpl.vars.range.data(1:50), real(log10(mpl.vars.detector_counts.data(1:50,[ii_w(1)-10:ii_w(end)+10]))));
% ax(2) = subplot(2,1,2); semilogy(serial2Hh(sol([ii_w(1)-10:ii_w(end)+10])),mpl.vars.background_signal.data([ii_w(1)-10:ii_w(end)+10]),'.-', ...
%    serial2Hh(sol(w)), mpl.vars.background_signal.data(w),'ro');
% linkaxes(ax,'x');
% 
% %%
% constraints, background < 1e-2, time is noonish


% 