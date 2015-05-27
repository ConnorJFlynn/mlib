function [NESR] = EvaluateNESR(Radiance, wnMin, wnMax, Method);
% Returns the noise equivalent spectral radiance in W/(m^2 sr cm^-1) using the imaginary part of the calibrated radiance
% Radiance is a structure where Radiance.x are the wavenumbers and Radiance.y are the radiance values
% wnMin and wnMax define the wavenumber interval within which the NESR must be evaluated 
% Method = 0 for NESR given by peak-to-peak divided by 3.5 while Method = 1 for NESR given as the standard deviation

wavenumber = Radiance.x;
spectra = imag(Radiance.y);

kk = find(wavenumber > wnMin & wavenumber < wnMax);
switch Method
    case 0
        NESR = abs(max(spectra(:,kk),[],2) - min(spectra(:,kk),[],2))/6;
    case 1
        NESR = abs(std(spectra(:,kk),0,2));
    otherwise
        error('Unknown NESR method');
end
