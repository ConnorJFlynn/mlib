function [Ba_V,ii_,k0,k1,h0,h1,s,ssa] = Virk_wi_ext(Tr,Ba_raw,Be,N)
% [Ba_V,ii,k0,k1,h0,h1,s,ssa] = Virk_wi_ext(Tr,Ba_raw,Be,N)
% Requires filter transmittance, total extinction coef, raw absorption
% coef, and "N" identifying the fit parameters to be used from Virkkula
% 2010 where N: 1=Blue(467nm), 2=Green(530nm), 3=Red(660nm), 4=wavelength averaged
% N may be specified as a single number (applying to all five correction parameters)
% or as a 5-element vector specified each individually
% Returns Ba_V: the Virkkula-corrected value
%           ii_: the number of iterations for convergence
%           k0, k1, h0, h1, s: fitting parameters used
%           ssa: the converged single-scattering albedo 

% Note: the wavelengths listed above are from Virkkula 2010.  Our
% wavelengths are actually 464, 529, and 648 nm based on Sedlacek
% spectral measurements

% Modified to use B_e (extinction) instead of scattering)

k0_ = [0.377, 0.358, 0.352, .362];
k1_ = [-0.64, -0.64, -0.674, -.651];
h0_ = [1.16, 1.17, 1.14, 1.159];
h1_ = [-0.63, -0.71, -0.72, -0.687];
s_ = [0.015, 0.017, 0.022, 0.018];

% dk0_pct = 100.*(k0_(1)-k0_(4))/ mean(k0_(1,4));
% dk1_pct = 100.*(k1_(1)-k1_(4))/ mean(k1_(1,4));
% dh0_pct = 100.*(h0_(1)-h0_(4))/ mean(h0_(1,4));
% dh1_pct = 100.*(h1_(1)-h1_(4))/ mean(h1_(1,4));


if length(N) ==5
   k0 = k0_(N(1));
   k1 = k1_(N(2));
   h0 = h0_(N(3));
   h1 = h1_(N(4));
   s = s_(N(5));
else
   k0 = k0_(N);
   k1 = k1_(N);
   h0 = h0_(N);
   h1 = h1_(N);
   s = s_(N);   
end

ssa = ones(size(Tr));
Ba_V = NaN(size(Tr));
ii_ = zeros(size(Tr));
stay = (Be>0)&(Ba_raw>0)&(ssa>0)&(ssa<=1.1)&(Tr<=1)&(Tr>=0.5);
% stay_ = (Be>0)&(Ba_raw>0)&(ssa>0)&(ssa<=1.1)&(Tr<=1)&(Tr>=0.5);
ii = 1;
ii_(stay) = ii;
ssa(stay) = (Be(stay)-Ba_raw(stay)) ./ Be(stay);

Ba_V(stay) = (k0 + k1 .* (h0+ h1.*ssa(stay)) .* log(Tr(stay))).*Ba_raw(stay) - s.*Be(stay).*ssa(stay);

% This iteration loop simultaneously executes for all times and only computes 
% those that haven't converged. Slick!
% stay_(stay) = abs(ssa(stay_)- (Be(stay_).*ssa(stay_))./Be(stay_)) >0.001;
stay(stay) = abs(ssa(stay)- (Be(stay).*ssa(stay))./(Be(stay).*ssa(stay)+Ba_V(stay))) >0.001;
% disp('Check to see if stay and stay_ are equivalent.  Should be!')
stays = sum(stay);
while ii<20 && stays>0
   ii = ii+ 1;
   ii_(stay) = ii;
   ssa(stay) = (Be(stay) -Ba_V(stay)) ./ Be(stay);
   Ba_V(stay) = (k0 + k1.*(h0+ h1.*ssa(stay)).*log(Tr(stay))).*Ba_raw(stay) - s.*Be(stay).*ssa(stay);
%    stay_(stay_) = abs(ssa(stay_)- (Be(stay_).*ssa(stay_))./Be(stay_)) >0.0001;
   stay(stay) = abs(ssa(stay)- (Be(stay).*ssa(stay))./(Be(stay).*ssa(stay)+Ba_V(stay))) >0.00001;
%    disp('Check to see if stay and stay_ are equivalent.  Should be!')
   stays = sum(stay);   
end

%    disp('Check to see if stay and stay_ are equivalent.  Should be!')

return