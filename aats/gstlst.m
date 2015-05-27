function LST=GSTLST(GST, UT, geog_long);

% This procedure converts Greenwich mean sideral time GST
%  to local sideral time  LST at a particular place
% (Duffet chap. 15)}
% Written 14.7.1995 by B. Schmid

 LST= GST + geog_long/15;
 LST=rem(LST,24);
 i=find(LST<0);
 LST(i)=LST(i)+24;

