function [Tf]=frost_point(Td);
%[Frost_point_temp]=frost_point(dew_point_temp)
%Td and Tf in deg

%global log_es

%compute saturation vapor pressure over water 

if length(Td)==1
% T = temperature on Kelvin scale
% SVP = saturation vapor pressure according to Goff & Gratch Equation (1946)
% SVP in Pascal
T=Td;
Ts = 373.15;    % standard temperature at steam point on Kelvin scale (Goff, 1965)
Ps = 101324.6;  % standard atmospheric pressure at steam point (Pascal)
log10SVP = -7.90298*(Ts./T - 1) + 5.02808*log10(Ts./T) -1.3816e-7*(10.^(11.344*(1 ...
						  - T./Ts)) - 1) + 8.1328e-3*(10.^(3.49149*(1 - Ts./T)) - 1) + log10(Ps);
 fprintf('saturation vapor pressure over water Goff-Gratch= %g Pascal', ...
	 10.^log10SVP(1))
 fprintf('   = %g mb \n',(10.^log10SVP(1))/100)
end


log_es=-0.58002206e4./Td +1.3914993 -0.48640239e-1*Td +0.41764768e-4*Td.^2 ...
       -0.14452093e-7*Td.^3 + 0.65459673e1*log(Td); 

if length(Td)==1
  fprintf('saturation vapor pressure over water Hyland-Wexler= %g Pa', ...
	exp(log_es(1)))
  fprintf('  =%g mb\n',exp(log_es(1))/100)
end

%find frost point temp
[na,nb]=size(Td);
warning off MATLAB:fzero:UndeterminedSyntax
for i=1:na
  for j=1:nb
    if Td(i,j)<273.15
       Tf(i,j)=fzero(@fp,Td(i,j),[],log_es(i,j));
    else
       Tf(i,j)=NaN;
    end
  end   
  
end

if length(Td)==1
  x=Td;
  log_esi=-0.56745359e4./x + 6.39225247 -0.96778430e-2*x ...
		+0.62215701e-6*x.^2 +0.20747825e-8*x.^3 -0.94840240e-12*x.^4 ...
		+0.41635019e1*log(x);

 fprintf('Saturation vapor pressure over ice, Hyland-Wexler= %g Pa',...
	exp(log_esi(1)))
 fprintf('   =%g mb\n',exp(log_esi(1))/100)
end

function g=fp(x,log_es);
%global log_es
g=log_es - (-0.56745359e4/x + 6.39225247 -0.96778430e-2*x ...
		+0.62215701e-6*x.^2 +0.2074825e-8*x.^3 -0.94840240e-12*x.^4 ...
		+0.41635019e1*log(x));



