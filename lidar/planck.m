function [radiant_intensity] = planck(T, lambda,bandwidth)
% [radiant_intensity] = planck(T, lambda,bandwidth);
% radiant intensity in watts per meters-squared per bandwidth
% T in Kelvin (scalar or vector, no matrix!)
% lambda in meters (scalar or vector, no matrix!)
% bandwidth in meters
if nargin<3
    bandwidth = 1;
end
if (~any(size(T)==1)) 
    disp(['T is badly dimensioned']);
    return
end

if (~any(size(lambda)==1)) 
    disp(['Lambda is badly dimensioned']);
    return
end

size_lambda = size(lambda);
if size_lambda(2) == 1
    lambda = lambda';
    size_lambda = size(lambda);
end

size_T = size(T);
if size_T(1) == 1 
    T = T';
    size_T = size(T);
end

lambda = ones(size_T) * lambda;
T = T * ones(size_lambda);

h = 6.626e-34 ; % J-s
c = 3e8 ; %m/s
k = 1.38e-23; %J/k
S_numer = 8 .* pi .* h .* (c.^2) ;
bose_exp = exp((h.*c)./(k.*lambda.*T)) -1;
S_denom = 4.*bose_exp .* lambda.^5;
radiant_intensity = S_numer ./ S_denom; % this is in units of watts per square meter per meter wavelength
radiant_intensity = radiant_intensity * bandwidth; %converts to watts per m^2 per nm

