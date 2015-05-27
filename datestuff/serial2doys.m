function [doy] = serial2doys(serial);
%[doy1] = serial2doy(serial);
%Returns the day of year corresponding to the supplied serial date relative to the year of the first
% record in the file.  Assumes monotonic time.  Jan 1 = 1;
! This doesn't work when the day wrap is  not due to year roll-over
doy = serial2doy1(serial);
first = datevec(serial(1));
first = [first(1) 1 1  0 0 0];
doy_diff = diff(doy);
while any(doy_diff<0)
    wrap = find(doy_diff<0,1,'first')+1;
    wrap_y = datevec(serial(wrap)); wrap_y = [wrap_y(1), 1,1,0,0,0];
    doy(wrap:end) = serial2doy1(serial(wrap:end)) + round(etime(wrap_y,first)/(60*60*24));
    doy_diff = diff(doy);
end


