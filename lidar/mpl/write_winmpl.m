function [status,wmpl] = write_wmpl(mpl);
%status = write_wmpl(mpl);
% This function accepts an MPL structure outputting NASA wmpl format file

nbytes = 8048 ; %For normal 2001 30-meter bins out to 60 km
ntimes = length(mpl.time);
wmpl = zeros([nbytes,ntimes]);
bytestart = 1;
wmpl(bytestart + 0,:) = mpl.statics.unitSN;
wmpl(bytestart + 1,:) = (str2num(datestr(mpl.time, 10)))' - 1900; %year
wmpl(bytestart + 2,:) = (str2num(datestr(mpl.time, 5)))'; %month
wmpl(bytestart + 3,:) = (str2num(datestr(mpl.time, 7)))'; %day of month
frac_of_day = mpl.time - floor(mpl.time);
hours_of_day = (24*frac_of_day);
hh = floor(hours_of_day);
wmpl(bytestart + 4,:) = hh; %hour of day
minutes_of_hour = (hours_of_day - hh)*60;
mm = floor(minutes_of_hour);
wmpl(bytestart + 5,:) = mm; %minute of hour
seconds_of_minute = (minutes_of_hour - mm)*60;
ss = floor(seconds_of_minute);
wmpl(bytestart + 6,:) = ss; %seconds of minute
wmpl(bytestart + 7,:) = 0; %hundreths of seconds

four_byte = mpl.hk.shotsSummed;
ll_byte = mod(four_byte,256);
three_byte = floor(four_byte/256);
lh_byte = mod(three_byte,256);
two_byte = floor(three_byte/256);
hl_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
hh_byte = mod(one_byte,256);
wmpl(bytestart + 8,:) = hh_byte;
wmpl(bytestart + 9,:) = hl_byte;
wmpl(bytestart + 10,:) = lh_byte;
wmpl(bytestart + 11,:) = ll_byte;

two_byte = mpl.hk.PRF;
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 12,:) = h_byte;
wmpl(bytestart + 13,:) = l_byte;

two_byte = 1000*mpl.hk.energyMonitor;
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 14,:) = h_byte;
wmpl(bytestart + 15,:) = l_byte;

two_byte = 100*mpl.hk.detectorTemp;
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 16,:) = h_byte;
wmpl(bytestart + 17,:) = l_byte;

two_byte = zeros(size(mpl.hk.detectorTemp));
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 18,:) = h_byte;
wmpl(bytestart + 19,:) = l_byte;

two_byte = 100*mpl.hk.instrumentTemp;
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 20,:) = h_byte;
wmpl(bytestart + 21,:) = l_byte;

two_byte = 100*mpl.hk.laserTemp;
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 22,:) = h_byte;
wmpl(bytestart + 23,:) = l_byte;

two_byte = 10*1000*ones(size(mpl.hk.detectorTemp));
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 24,:) = h_byte;
wmpl(bytestart + 25,:) = l_byte;

two_byte = 5*1000*ones(size(mpl.hk.detectorTemp));
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 26,:) = h_byte;
wmpl(bytestart + 27,:) = l_byte;

two_byte = 15*1000*ones(size(mpl.hk.detectorTemp));
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 28,:) = h_byte;
wmpl(bytestart + 29,:) = l_byte;

two_byte = mpl.hk.cbh; % cbh already converted from km to meters
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 30,:) = h_byte;
wmpl(bytestart + 31,:) = l_byte;


four_byte = floor(1e8*mpl.hk.bg);
ll_byte = mod(four_byte,256);
three_byte = floor(four_byte/256);
lh_byte = mod(three_byte,256);
two_byte = floor(three_byte/256);
hl_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
hh_byte = mod(one_byte,256);
wmpl(bytestart + 32,:) = hh_byte;
wmpl(bytestart + 33,:) = hl_byte;
wmpl(bytestart + 34,:) = lh_byte;
wmpl(bytestart + 35,:) = ll_byte;

four_byte = 200*ones(size(mpl.hk.bg)); %bin size
ll_byte = mod(four_byte,256);
three_byte = floor(four_byte/256);
lh_byte = mod(three_byte,256);
two_byte = floor(three_byte/256);
hl_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
hh_byte = mod(one_byte,256);
wmpl(bytestart + 36,:) = hh_byte;
wmpl(bytestart + 37,:) = hl_byte;
wmpl(bytestart + 38,:) = lh_byte;
wmpl(bytestart + 39,:) = ll_byte;

%max_altitude in km
two_byte = 60*ones(size(mpl.hk.detectorTemp));
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 40,:) = h_byte;
wmpl(bytestart + 41,:) = l_byte;

%deadtime corrected 0 = false, 1 = true;
two_byte = zeros(size(mpl.hk.detectorTemp));
l_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
h_byte = mod(one_byte,256);
wmpl(bytestart + 42,:) = h_byte;
wmpl(bytestart + 43,:) = l_byte;


for bin = 1:length(mpl.range)
    bytestart = 45+4*(bin-1);
    four_byte = 1e8*mpl.rawcts(bin,:);
ll_byte = mod(four_byte,256);
three_byte = floor(four_byte/256);
lh_byte = mod(three_byte,256);
two_byte = floor(three_byte/256);
hl_byte = mod(two_byte,256);
one_byte = floor(two_byte/256);
hh_byte = mod(one_byte,256);
wmpl(bytestart + 0,:) = hh_byte;
wmpl(bytestart + 1,:) = hl_byte;
wmpl(bytestart + 2,:) = lh_byte;
wmpl(bytestart + 3,:) = ll_byte;
end

date_name = datestr(mpl.time(1), 30);
[date_part, time_part] = strtok(date_name,'T');
time_part(1) = [];
fname = [date_part, '.', time_part, '.mpl.00W'];

pname = [uigetdir, '\'];
fid = fopen([pname, fname], 'w');
count = fwrite(fid, wmpl, 'uint8')
status = fclose(fid);








