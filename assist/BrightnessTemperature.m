function BT = BrightnessTemperature(Wavenumber, Radiance);
% Returns the brightness temperature in K for a given spectral radiance in W/(m^2 sr cm^-1)
% Wavenumber may be a scalar or a vector
% Radiance in W/(m^2 sr cm^-1) must have the same size as Wavenumber 
% Reference taken from http://www.ssec.wisc.edu/~paulv/Fortran90/Radiance/Planck_Functions/Introduction.html

% Fundamental constants.
c = 299792458;      % [m/s] Speed of light taken from http://physics.nist.gov/cuu/Constants/
k = 1.3806504e-23;  % [J/K] Boltzmann constant taken from http://physics.nist.gov/cuu/Constants/
h = 6.62606896e-34; % [J s] Planck constant taken from http://physics.nist.gov/cuu/Constants/

Wavenumber = abs(100*Wavenumber);   % Take absolute value and convert into SI units

Radiance = 0.001 * Radiance; % Convert from mW(m^2 sr cm^-1) to W/(m^2 sr cm^-1) ;
Radiance =  0.01 * Radiance;        % Convert from W/(m^2 sr cm^-1) to W/(m^2 sr m^-1)
if size(Wavenumber,1)==1 && size(Radiance,1)~=1
   Wavenumber = ones([size(Radiance,1),1])*Wavenumber;
elseif size(Wavenumber,2) ==1 && size(Radiance,2)~=1
   Wavenumber = Wavenumber * ones([1,size(Radiance,2)]); 
end
c1 = 2*h*c^2;
c2 = h*c/k;
BT =  c2 .* Wavenumber ./ log((c1 .* Wavenumber.^3) ./ Radiance + 1);   % [K]
% BT(Radiance<=0) = -BT(Radiance<=0);
% BT(Radiance<0) = NaN;

% BT =  c2 * (ones([size(Radiance,1),1])*Wavenumber) ./ log(c1 * (ones([size(Radiance,1),1])*(Wavenumber.^3)) ./ Radiance + 1);   % [K]
