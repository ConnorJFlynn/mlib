% First, without deadtime correction.
function status = gruvli_twpice;
% Use solar noon covered times for AP.  Try just making a long term
% average. If necessary, smooth additionally.

% Next, subtract AP 

% Now, ringing correction...
% Look at day time, pre-bg subtracted.  Look for periodicity, try a
% smoothing window of this width to determine "ring-free avg".  Try a fourier filter for this freq.

% Ultimately, need to form a ratio of the ring-free with the ringed and
% then use this ratio on the non-averaged data to produce ring-free
% profiles.

% Then apply range squared.
% Look for bloody clouds.

lidar_dir = [uigetdir, '\'];
lidar_file = dir([lidar_dir, '\*.nc'])
for f = 1:length(lidar_dir)
    disp(lidar_file(f).name)
    status = fix_gruvli_time([lidar_dir, lidar_file(f).name]);
end

ap_A = mean(lidar_03h.vars.detector_A_532nm.data(:,86:end)')';
imagesc([1:length(lidar_03h.time(1:84))], lidar_03h.vars.range.data, ... 
    lidar_03h.vars.detector_A_532nm.data(:,1:84)-ap_A*ones([1,84])); axis('xy');
