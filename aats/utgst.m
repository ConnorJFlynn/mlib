function GST=UTGST(day, month, year, UT);
% This function converts UT to Greenwich mean sideral time GST (Duffet chap. 12).
% Inputs maybe vectors
% Written 14.7.1995 by B. Schmid
JD=julian(day, month, year,0);
S = JD - 2451545.0;
T = S/36525.0;
T0= 6.697374558 + 2400.051336*T + 0.000025862*T.*T;
T0=rem(T0,24);
i=find(T0<0);
T0(i)=T0(i)+24;
GST = T0 + UT*1.002737909;
GST=rem(GST,24);
i=find(GST<0);
GST(i)=GST(i)+24;