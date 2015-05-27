if (julian(day, month,year,12) == julian(27,8,2012,12))
                press=ones(n,1)*1013;
                O3_col_start=.290;  %from OMI for Ames lat,lon for 8/27
elseif (julian(day, month,year,12) == julian(28,8,2012,12))
                 press=ones(n,1)*1013;
                O3_col_start=.286;  %interpolated from OMI for Ames lat,lon for 8/27 and 8/29
elseif (julian(day, month,year,12) == julian(29,8,2012,12))
                 press=ones(n,1)*1013;
                O3_col_start=.283;  %from OMI for Ames lat,lon for 8/29
elseif (julian(day, month,year,12) == julian(30,8,2012,12))
                 press=ones(n,1)*1013;
                O3_col_start=.288; %from OMI for Ames lat,lon for 8/30
else  
                press=ones(n,1)*1013;
                O3_col_start=.290; %default
end