function [Ba_V,ii_,k0,k1,h0,h1,s,Be_V] = Virk_wi_ssa(Tr,Ba_raw,ssa,N)
% [Ba_V,ii,k0,k1,h0,h1,s,ssa] = Virk_wi_ssa(Tr,Ba_raw,ssa,N)
% Requires filter transmittance, raw absorption, ssa
% and "N" identifying the fit parameters to be used from Virkkula
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
if ~isavar('N')||isempty(N)
    N = 4;
end
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

% ssa_ = ssa>=0 & ssa<=1.1;
% coa = 1 - ssa(ssa_); 
coa = 1 - ssa; 
coa_ = coa>-0.1 & coa<=1;

Ba_V = NaN(size(Tr));
Be_V = NaN(size(Tr));

Be_V(coa_) = Ba_raw(coa_)./coa(coa_);
ii_ = zeros(size(Tr));
stay = coa_&(Be_V>0)&(Ba_raw>0)&(ssa>0)&(ssa<=1.1)&(Tr<=1)&(Tr>=0.5);
ii = 1;
ii_(stay) = ii;

Be_V(stay) = Ba_raw(stay)./coa(stay);

Ba_V(stay) = (k0 + k1 .* (h0+ h1.*ssa(stay)) .* log(Tr(stay))).*Ba_raw(stay) - s.*Be_V(stay).*ssa(stay);

% This iteration loop simultaneously executes for all times and only computes 
% those that haven't converged. Slick!
% stay_(stay) = abs(ssa(stay_)- (Be_V(stay_).*ssa(stay_))./Be_V(stay_)) >0.001;
stay(stay) = abs(ssa(stay)- (Be_V(stay).*ssa(stay))./(Be_V(stay).*ssa(stay)+Ba_V(stay))) >0.001;
% disp('Check to see if stay and stay_ are equivalent.  Should Be_V!')
stays = sum(stay);
while ii<20 & stays > 0
   ii = ii+ 1;
   ii_(stay) = ii;

%    ssa(stay) = (Be_V(stay) -Ba_V(stay)) ./ Be_V(stay);
   Be_V(stay) = Ba_V(stay)./coa(stay);
   Ba_V(stay) = (k0 + k1.*(h0+ h1.*ssa(stay)).*log(Tr(stay))).*Ba_raw(stay) - s.*Be_V(stay).*ssa(stay);
%    stay_(stay_) = abs(ssa(stay_)- (Be_V(stay_).*ssa(stay_))./Be_V(stay_)) >0.0001;
   stay(stay) = abs(ssa(stay)- (Be_V(stay).*ssa(stay))./(Be_V(stay).*ssa(stay)+Ba_V(stay))) >0.0001;
   stays = sum(stay);
%    disp('Check to see if stay and stay_ are equivalent.  Should Be_V!') 
end

%    disp('Check to see if stay and stay_ are equivalent.  Should Be_V!')

return