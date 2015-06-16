% MPL fast/slow compare:
% read in fast and slow on Dec 9, 16:00 to determine afterpulse for both.

lidar = rd_sigma;

mpl = ancload(getfullname('*.cdf','mpl'));

% Then read in some other days of slow, process with existing code to look
% for interesting times.  
%%

mpl = loadinto('C:\case_studies\mpl_fastsw\slow_ap_raw.mat');
lidar = loadinto('C:\case_studies\mpl_fastsw\fast_ap_raw.mat');

% useful smoothing backsmooth(lidar.cop_ap,20)

%%
figure; plot(lidar.range(lidar.r.lte_20), lidar.cop_ap,'.')

%%

