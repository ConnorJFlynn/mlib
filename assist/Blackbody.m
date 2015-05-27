function BB = Blackbody(Wavenumber, Temperature);
% Returns the radiance of a blackbody in mW/(m^2 sr cm^-1)
% Wavenumber may be a scalar or a vector
% Temperature must be a scalar
% Reference taken from http://www.ssec.wisc.edu/~paulv/Fortran90/Radiance/Planck_Functions/Introduction.html

% Fundamental constants.
c = 299792458;      % [m/s] Speed of light taken from http://physics.nist.gov/cuu/Constants/
% k = 1.3806504e-23;  % [J/K] Boltzmann constant taken from http://physics.nist.gov/cuu/Constants/
k = 1.3806488e-23;   % Wikipedia, The 2010 CODATA Recommended Values of the Fundamental Physical Constants
h = 6.62606896e-34; % [J s] Planck constant taken from http://physics.nist.gov/cuu/Constants/
h = 6.62606957e-34; 
if Temperature < 0
    error('Negative temperature')
end
T = size(Temperature);
Temperature = Temperature*ones(size(Wavenumber));

Wavenumber = abs(100*Wavenumber);   % Take absolute value and convert into SI units
Wavenumber = ones(T)*Wavenumber;
c1 = 2*h*c^2;% [J m^2 / s] = [W m^2] = 
c2 = h*c/k; % [J s m/s K/J] = [K m]
BB =  c1 * Wavenumber.^3 ./ (exp(c2 * Wavenumber ./ Temperature) - 1); % = [W m^2 * [1/cm]^3] = [W/m]
% BB =  c1 * (ones(size(Temperature))*Wavenumber).^3 ./ (exp(c2 * (ones(size(Temperature))*Wavenumber) ./ (Temperature*ones(size(Wavenumber)))) - 1);
BB =  100 * BB; % Convert from W/(m^2 sr m^-1) to W/(m^2 sr cm^-1)
BB = 1000 * BB; % Convert from W/(m^2 sr cm^-1) to mW(m^2 sr cm^-1);

BB((Wavenumber == 0)) = 0;
