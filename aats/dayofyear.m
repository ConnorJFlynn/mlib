function DOY=DayOfYear(day,month,year);



% this procedure computes day of year

% Written 14.7.1995 by B. Schmid

JD            =julian(day, month, year,12);

JD_beg_of_year=julian(0  , 1    , year,12);

DOY= JD-JD_beg_of_year;





 

