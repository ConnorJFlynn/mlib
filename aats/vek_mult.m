function vek_mult = vek_mult(x,y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Funktion vek_mult generiert eine Matrix welche den zeilenvektor y mit    %
% dem Kolonnenvektor x multipliziert                                       %
% d.h              x     y          vek_mult                               %
%                  1   1 2 3       1 2 3                                   %
%                  2           =   2 4 6                                   %
%                  3               3 6 9                                   %
%                                                                          %
%                   R. Peter, IAP, Oktober 1993                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[dummy,n] = size(y);
for i=1:n
 vek_mult(:,i)=x.*y(i);
end;