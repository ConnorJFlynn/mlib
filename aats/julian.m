function JD=Julian(day,month,year,UT);
% This function calculates the Julian Date JD. Only valid after
%  15th Oct. 1582 (Duffet chap. 4). 
% Inputs (day, month,year,UT) maybe vectors.
% Written 14. 7.1995 by B. Schmid

  i=find((month == 1) | (month == 2));
    year(i) = year(i) -1;
    month(i)= month(i)+12;  
  A = fix(year/100);
  B = 2 - A + fix(A/4);
  C = fix(365.25*year);
  D = fix(30.6001*(month+1));
 JD= B + C + D + day + 1720994.5  + UT/24;





