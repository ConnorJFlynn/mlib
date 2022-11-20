function [Ba_V,ii_,k0,k1,h0,h1,s,ssa] = compute_Virkkula(Tr,Bs,Ba_raw,N,khs)
% [Ba_V,ii,k0,k1,h0,h1,s,ssa] = compute_Virkkula(Tr,Bs,Ba_raw,N,khs)
% Requires filter transmittance, total scattering coef, raw absorption
% coef, and "N" identifying the fit parameters to be used from Virkkula
% 2010 where N: 1=Blue(467nm), 2=Green(530nm), 3=Red(660nm), 4=wavelength averaged
% N may be specified as a single number (applying to all five correction parameters)
% or as a 5-element vector specified each individually
% Returns Ba_V: the Virkkula-corrected value
%           ii_: the number of iterations for convergence
%           k0, k1, h0, h1, s: fitting parameters used
%           ssa: the converged single-scattering albedo 
% 2022-11-20: Connor Flynn, modified to use Chakrabarty & Kumar modified values
% and to accept supplied values on the argument list. 

% Note: the wavelengths listed above are from Virkkula 2010.  Our
% wavelengths are actually 464, 529, and 648 nm based on Sedlacek
% spectral measurements


if isavar('khs')&&isstruct(khs)&&isfield(hks,'k0')&&isfield(hks,'k1')&&...
      isfield(hks,'h0')&&isfield(hks,'h1')&&isfield(hks,'s')
   k0_ = khs.k0; 
   k1_ = khs.k1; 
   h0_ = khs.h0; 
   h1_ = khs.h1; 
   s_ = khs.s; 
else
   
   k0_ = [0.377, 0.358, 0.352, .362];
   k1_ = [-0.64, -0.64, -0.674, -.651];
   h0_ = [1.16, 1.17, 1.14, 1.159];
   h1_ = [-0.63, -0.71, -0.72, -0.687];
   s_ = [0.015, 0.017, 0.022, 0.018];
% revised Charabarty, Kumar
   k0_ = [0.135, 0.159, 0.145];
   k1_ = [-0.86, -0.09, -0.062];
   h0_ = [13.018, 1.301, 21.364];
   h1_ = [-12.409, -0.312, -21.11];
   s_ = [0.015, 0.017, 0.022];


end
if length(k0_)==3, k0_(end+1) = mean(k0_); end;
if length(k1_)==3, k1_(end+1) = mean(k1_); end;
if length(h0_)==3, h0_(end+1) = mean(h0_); end;
if length(h1_)==3, h1_(end+1) = mean(h1_); end;
if length(s)==3, s(end+1) = mean(s); end;
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
stay = (Bs>0)&(Ba_raw>0)&(ssa>0)&(ssa<=1.1)&(Tr<=1)&(Tr>=0.5);
stays = sum(stay);
ii = 1;
ii_(stay) = ii;
ssa(stay) = Bs(stay) ./ (Bs(stay) + Ba_raw(stay));

Ba_V(stay) = (k0 + k1 .* (h0+ h1.*ssa(stay)) .* log(Tr(stay))).*Ba_raw(stay) - s.*Bs(stay);

% This iteration loop simultaneously executes for all times and only computes 
% those that haven't converged. Slick!
stay(stay) = abs(ssa(stay)- Bs(stay)./(Bs(stay)+Ba_V(stay))) >0.001;
stays = sum(stay); %This isn't necessary but is handy in "debug" mode to hover 
% over and see how many elements haven't converged.  
while ii<10
   ii = ii+ 1;
   ii_(stay) = ii;
   ssa(stay) = Bs(stay) ./ (Bs(stay) + Ba_V(stay));
   Ba_V(stay) = (k0 + k1.*(h0+ h1.*ssa(stay)).*log(Tr(stay))).*Ba_raw(stay) - s.*Bs(stay);
   stay(stay) = abs(ssa(stay)- Bs(stay)./(Bs(stay)+Ba_V(stay))) >0.0001;
   stays = sum(stay);   
end


return