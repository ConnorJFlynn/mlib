function [Wavelength, SRwl] = Wavenumber2Wavelength(Wavenumber, Radiance);
% Returns the spectral radiance in W/(m^2 sr um) of the given spectral radiance in W/(m^2 sr cm^-1)
% Returns the wavelength in um of the given wavenumber in cm^-1
% Wavenumber may be a scalar or a vector
% Radiance in W/(m^2 sr cm^-1) must have the same size as Wavenumber 

% Fundamental constants.
c = 299792458;      % [m/s] Speed of light taken from http://physics.nist.gov/cuu/Constants/
k = 1.3806504e-23;  % [J/K] Boltzmann constant taken from http://physics.nist.gov/cuu/Constants/
h = 6.62606896e-34; % [J s] Planck constant taken from http://physics.nist.gov/cuu/Constants/

Wavenumber = abs(100*Wavenumber);   % Take absolute value and convert into SI units
Radiance =  0.01 * Radiance;        % Convert from W/(m^2 sr cm^-1) to W/(m^2 sr m^-1)

SRwl = Radiance .* Wavenumber.^2;   % [W/(m^2 sr m)]
SRwl = 1e-6 * SRwl;                 % [W/(m^2 sr um)]
Wavelength = 1 ./ Wavenumber;       % [m]
Wavelength = 1e6 * Wavelength;     % [um]
