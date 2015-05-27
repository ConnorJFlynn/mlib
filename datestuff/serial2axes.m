function [date_axes] = serial2axes(serial_date);
% [date_axes] = serial2axes(serial_date);
% This function accepts a serial date and returns a struct containing several date 
% formats useful in plotting.  
% Output date/time formats:
%   doy0: day of year with Jan 1 = 0;
%   Hh: modulus of serial date * 24
%   Yy: year and fraction of year 

Hh = 24*mod(serial_date,1);
if length(serial_date)>1
    [sorted,in_index]  = sort(serial_date);
    [Y M D h m s] = datevec(sorted([1,end]));
    doy0 = []; Yy = [];
    for thisyear = Y(1):Y(2)
        Jan1 = datenum(thisyear,1,1);
        Jan1_nextyear = datenum(thisyear+1,1,1);
        days_in_year = Jan1_nextyear - Jan1;
        inthisyear = find((serial_date>=Jan1)&(serial_date<(Jan1_nextyear)));
        if any(inthisyear)
            doy0_thisyear = serial_date(inthisyear) - Jan1;
            Yy_thisyear = thisyear + (doy0_thisyear)/days_in_year;
        end
        doy0 = [doy0, doy0_thisyear];
        Yy = [Yy, Yy_thisyear];
    end;
else
    [thisyear M D h m s] = datevec(serial_date);
    Jan1 = datenum(thisyear,1,1);
    Dec31 = datenum(thisyear+1,12,31);
    days_in_year = Dec31 + 1 - Jan1;
    doy0 = serial_date - Jan1;
    Yy = thisyear + (doy0)/days_in_year;
end;

date_axes.Hh = Hh;
date_axes.doy0 = doy0;
date_axes.Yy = Yy;
