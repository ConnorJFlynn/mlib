% Two things to try:
% 1. Create a new colormap from a provided X-Y mapping of data values to
% colors.  It will be of length (max(X)-min(X))./min(diff(X))
% 2. Alternatively, try assigning the colors to the matrix explicitly by re-creating
% a colorized version of the data.

% Both of these might be very similar techniques. Have to think carefully
% about how to interpolate between these points.  I think we want to insert
% 

% First add additional data points midway between  
% This will find the try to create a colormap of the smallest size
% necessary to accurately capture the spacing of the data points.  I think
% it will need to find the least common divisor of the diff(X) values to
% use as the step size.

%% 

custom_colormap(map,A)
%finds least common divisor in diff of Z.  Creates a new colormap running
%from Z(1) to Z(2) in steps of lcd.
Z = map(:,1);
C = map(:,2);

aq_cal_cb
X = 1e-4.*[1:10 10:5:80 100:100:1000];
colors =[];
map_len = (max(X)-min(X))./min(diff(X));
map_val = interp1([1:34],X,[1:map_len],'nearest','extrap');
map_col = colors(map_val,:)  