function [profile, tau, atm_trans] = topdown_atten(range, T, P, wavelength, alpha_a, beta_a, top)
%(range, T, P,wavelength, alpha_a, beta_a);
%[profile, tau] = topdown_atten(range, alpha, beta, top)
% Provided with range (km), extinction (alpha 1/km), and backscatter coef (beta)
% this function returns an attenuated backscatter profile and optical depth profile.

if ~exist('wavelength','var')
   lambda = 532e-9;
else
   lambda = wavelength;
end
if ~exist('alpha_a','var')
   alpha_a = zeros(size(T));
end
if ~exist('beta_a','var')
   beta_a = zeros(size(T));
end

if nargin >= 4
    lambda = wavelength;
else 
    lambda = 523e-9; %meter
end

   if max(P)>2000 %Pressure is probably in Pa
      P = P/100; % Convert Pa to mB
   elseif max(P)>50 && max(P)<200 %Pressure probably in kPa, convert to mB
      P = 10*P;
   elseif max(P)<10 %Pressure is probably in Barr
      P = 1000 * P;
   end

%First convert range to km if necessary
if (max(range)>100)
    range = range / 1000;
end;

%Call ray_a_b(T,P) for Rayleigh alpha and beta.
[alpha_R, beta_R] = ray_a_b(T,P,lambda);
%Then add whatever alpha and beta profiles to the above as desired.
alpha = alpha_R + alpha_a;
beta = beta_R + beta_a;

if ~exist('top','var')
   [top,top_bin] = max(range);
else
   top_bin = max(find(range<=top));
end

dist = top - range;
tau = zeros(size(range));
atm_trans = ones(size(range));
NaNs = isNaN(alpha);
alpha(NaNs) = 0;
tau(top_bin:-1:1) = cumtrapz(dist(top_bin:-1:1), alpha(top_bin:-1:1));

atm_trans = exp(-1.*tau);
profile = beta .* (atm_trans.^2);
% profile = zeros(size(range));
% profile(top_bin:-1:1) = beta(top_bin:-1:1) .* exp(-2*tau(top_bin:-1:1));
% profile = beta .* exp(-2*tau);
return





