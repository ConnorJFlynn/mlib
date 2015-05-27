function angle=ATAN2beat (x,y);

% This function calculates arcus tangens in the correct quadrant.
%  Value between 0 <= value < 360. (Duffet p. 37) }
% Written 14.7.1995 by B. Schmid

angle= atan(y./x)*180/pi;
 i=find(x < 0);angle(i) = angle(i)+180;
 i=find(x > 0 & y<0 );angle(i) = angle(i)+360;

