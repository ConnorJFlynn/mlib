function [time_yr] = time_to_year_fraction(year,month,day,hours,minutes,s)

std_days_per_month=[31 28 31 30 31 30 31 31 30 31 30 31];
leap_days_per_month=[31 29 31 30 31 30 31 31 30 31 30 31];

for j=1:length(year)

	if(mod(year(j),4)>0)
 		time_yr(j)=year+ ...
			sum(std_days_per_month(1:month-1))/365+(day-1)/365+ ...
			hours/(24*365)+minutes/(60*24*365)+s/(60*60*24*365);

	else
		time_yr(j)=year+ ...
			sum(leap_days_per_month(1:month-1))/366+(day-1)/366+ ...
			hours/(24*366)+minutes/(60*24*366)+s/(60*60*24*365);
	end
		
end	
