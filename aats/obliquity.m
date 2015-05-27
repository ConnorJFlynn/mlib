 function epsilon=obliquity(jd);
% This procedure calculates obliquity of the ecliptic 
% Written 14.7.1995 by B. Schmid
% T  { Julian centuries since epoch 2000 jan. 1.5 }
  epsilon= 23.439292;
  T= (jd - 2451545.0)/36525;
  delta_epsilon= (46.815*T+0.0006*T.*T-0.00181*T.*T.*T)/3600;
  epsilon= epsilon - delta_epsilon;





