%angwt_scat(m, x, theta, dtheta, wtvecs) returns integrated, weighted scattering 
% theta and dtheta are in radians
% Optional arguments for coating, which is turned on only if both 
%  are provided:
%     'm_coating'   refractive index of coating
%     'ycoat'      size parameter for coating

function mieret = angwt_scat(m, x, theta, dtheta, wtvecs, varargin)
% Modified Jul 2013 to fix weight vector; also changed this function
%   to handle both coated and uncoated

% check for coating
mc = varg_val(varargin, 'm_coating', 0);
ycoat = varg_val(varargin, 'ycoat', 0);
iscoat = (mc ~= 0 & ycoat > x);

% calculate scattering terms: puts them in a 2xn array
for i = 1:length(theta);
   if ~iscoat
      smag(:,i)=Mie_S12(m,x,cos(theta(i)));
   else
      smag(:,i)=Miecoated_S12(m, mc,x, ycoat, cos(theta(i)));
   end
end

ssq = sum(abs(smag).^2)';           % S1^2 + S2^2

% loop through weights in list
for i=1:length(wtvecs)
    wts = wtvecs{i};
    mieret(i) = sum(ssq .* wts .* dtheta);
end

if iscoat
   mieret = mieret/(ycoat^2);
else
   mieret = mieret/(x^2);
end
return

