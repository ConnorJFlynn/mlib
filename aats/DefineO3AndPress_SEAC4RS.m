%DefineO3AndPress_SEAC4RS.m
if  (julian(day,month,year,12) >= julian(25,07,2013,12)) & (julian(day,month,year,12) <= julian(07,08,2013,12))
    %Palmdale
    press=ones(n,1)*925;  %guess
    O3_col_start=.300;  %guess...needs to be updated
    NO2_col=5.4e15;     %nolec/cm2 guess
elseif (julian(day,month,year,12) >= julian(08,08,2013,12))
    %Houston
    press=ones(n,1)*1013;  %guess
    O3_col_start=.300;  %guess...needs to be updated
    NO2_col=5.4e15;     %molec/cm2 guess
end
