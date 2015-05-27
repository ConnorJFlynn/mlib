function [epoch] = serial2epoch(serial);

sec_per_day = 24*60*60;
epoch_serial_num = datenum(1970,1,1);
epoch = sec_per_day * (serial - epoch_serial_num); 