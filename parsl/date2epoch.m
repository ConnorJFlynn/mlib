function epochtime = date2epoch(year,month,day,hour,minute,second)

%%% From Eugene Clothiaux's Time.Conversion code

DEFAULT_BEGINNING_YEAR = 1970;
SECONDSINFOURYEARS = 126230400;
SECONDSLEAPYEAR = 31622400;
SECONDSNOLEAPYEAR = 31536000;


%  /*-------------------------------------------------------------------------*/
%  /* The number of seconds in the current day.                               */
%  /*-------------------------------------------------------------------------*/

epochtime  = (day-1)*86400 + hour*3600 + minute*60 + second;

%  /*-------------------------------------------------------------------------*/
%  /* The number of seconds in the current month up to, but not including,    */
%  /* the current day.                                                        */
%  /*-------------------------------------------------------------------------*/

if (rem(year,4) == 0)
   imonth = [31 29 31 30 31 30 31 31 30 31 30 31];
else
   imonth = [31 28 31 30 31 30 31 31 30 31 30 31];   
end

for i = 1:(month-1)
   epochtime = epochtime + 86400*imonth(i);
end

% /*-------------------------------------------------------------------------*/
% /* Calculate the number of seconds from 1970 up to the closest year YEAR   */
% /* of the current year such that (YEAR-1970) is divisible by 4.  Add the   */
% /* result to the current tally of seconds since 1970.                      */
% /*-------------------------------------------------------------------------*/

fouryearblocks = floor((year - DEFAULT_BEGINNING_YEAR)/4);

epochtime = epochtime + fouryearblocks*SECONDSINFOURYEARS;

%  /*-------------------------------------------------------------------------*/
%  /* Skip the number of years in the 4 year blocks just calculated and add   */
%  /* the number of seconds in the remaining years (no more than 3) to the    */
%  /* current tally of seconds since 1970.                                    */
%  /*-------------------------------------------------------------------------*/

fouryearint = fouryearblocks*4;

for i = (DEFAULT_BEGINNING_YEAR+fouryearint):(year-1)
    if (rem(i,4) ==0) 
       epochtime = epochtime + SECONDSLEAPYEAR;
    else 
       epochtime = epochtime + SECONDSNOLEAPYEAR; 
    end
end

return;

