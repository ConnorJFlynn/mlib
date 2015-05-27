if (julian(day, month,year,12) == julian(24,8,2008,12))
                press=ones(n,1)*681;
                O3_col_start=.272; %.2671, .2771 from Brewer for 8/25
            elseif (julian(day, month,year,12) == julian(26,8,2008,12))
                press=ones(n,1)*681;
                O3_col_start=.277;  %guess
            elseif (julian(day, month,year,12) == julian(27,8,2008,12))
                press=ones(n,1)*681;
                O3_col_start=.278; %273.2,283.0
            elseif (julian(day, month,year,12) == julian(28,8,2008,12))
                press=ones(n,1)*681;
                O3_col_start=.2732;
            elseif (julian(day, month,year,12) == julian(29,8,2008,12)) & (julian(day, month,year,12) <= julian(2,9,2008,12))
                press=ones(n,1)*681;
                O3_col_start=.277; %guess
            elseif (julian(day, month,year,12) >= julian(23,9,2011,12)) & (julian(day, month,year,12) <= julian(25,9,2011,12))
                press=ones(n,1)*681;
                O3_col_start=.258; %259DU zenith; 258DU direct sun 09/23/2011; same for 09/24 and 09/25
            elseif (julian(day, month,year,12) >= julian(26,9,2011,12)) & (julian(day, month,year,12) <= julian(29,9,2011,12))
                press=ones(n,1)*681;
                O3_col_start=.262; %09/26/2011
            elseif (julian(day,month,year,12) == julian(25,5,2012,12))
                press=ones(n,1)*681;
                O3_col_start=.285;
            elseif (julian(day,month,year,12) == julian(26,5,2012,12)) | (julian(day,month,year,12) == julian(27,5,2012,12))
                press=ones(n,1)*680.5;
                O3_col_start=.285;
            elseif (julian(day,month,year,12) == julian(28,5,2012,12))
                press=ones(n,1)*681.3;
                O3_col_start=.285;
            elseif (julian(day,month,year,12) == julian(29,5,2012,12))
                press=ones(n,1)*681.3;
                O3_col_start=.281;
            elseif (julian(day,month,year,12) == julian(30,5,2012,12))
                press=ones(n,1)*681.3;
                O3_col_start=.281;
            elseif (julian(day,month,year,12) == julian(31,5,2012,12))
                press=ones(n,1)*681.3;
                O3_col_start=.284;
            elseif (julian(day, month,year,12) >= julian(14,12,2012,12)) & (julian(day, month,year,12) <= julian(16,12,2012,12))
                press=ones(n,1)*681;
                O3_col_start=.243;  %MLO Dobson spectrophotometer reading for 12 Dec 2012...may be too high for these days
            elseif (julian(day,month,year,12) == julian(17,12,2012,12))
                press=ones(n,1)*681.3;
                O3_col_start=.229;  %MLO Dobson spectrophotometer reading for 17 Dec 2012
            elseif (julian(day,month,year,12) == julian(18,12,2012,12))
                press=ones(n,1)*681.3;
                O3_col_start=.229;
            elseif (julian(day,month,year,12) == julian(19,12,2012,12))
                press=ones(n,1)*680.3;
                O3_col_start=.233;
            elseif (julian(day,month,year,12) == julian(06,07,2013,12))
                press=ones(n,1)*680.3;
                O3_col_start=.265;  %guess
            elseif (julian(day,month,year,12) == julian(08,07,2013,12)) | (julian(day,month,year,12) == julian(07,07,2013,12))
                press=ones(n,1)*679.0;
                O3_col_start=.272;  %MLO Dobson spectrophotometer reading on 7/8
            elseif (julian(day,month,year,12) == julian(09,07,2013,12))
                press=ones(n,1)*680.0;
                O3_col_start=.267;  %MLO Dobson spectrophotometer reading
            elseif (julian(day,month,year,12) >= julian(10,07,2013,12)&& julian(day,month,year,12) <=julian(12,07,2013,12))
                press=ones(n,1)*682.0;
                O3_col_start=.265;  %MLO Dobson spectrophotometer reading
            elseif (julian(day,month,year,12) >= julian(25,07,2013,12)) & (julian(day,month,year,12) <= julian(07,08,2013,12))
                %Palmdale
                press=ones(n,1)*925;  %guess
                O3_col_start=.300;  %guess...needs to be updated
            elseif (julian(day,month,year,12) >= julian(08,08,2013,12))
                %Houston
                press=ones(n,1)*1013;  %guess
                O3_col_start=.300;  %guess...needs to be updated
            end