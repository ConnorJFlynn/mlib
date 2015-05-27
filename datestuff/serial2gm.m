function tm = serial2gm(time)
% Converts supplied serial time into a gm_struct type with children
% time.year = 2003;
% time.month = 10;
% time.day = 17;  
% time.hour = 12;
% time.min = 30;
% time.sec = 30;
% time.UTC = -7;
[tm.year, tm.month, tm.day, tm.hour, tm.min, tm.sec] = datevec(time);
tm.UTC = 0;
return
