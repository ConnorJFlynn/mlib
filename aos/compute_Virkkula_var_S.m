function [Ba_V,ii_,k0,k1,h0,h1,s] = compute_Virkkula_var_S(Tr,Bs,Ba_raw,N)
% [Ba_V,ii,k0,k1,h0,h1,s] = compute_Virkkula_var_S(Tr,Bs,Ba_raw,N)
% N: 1=Blue(467nm), 2=Green(530nm), 3=Red(660nm)
% This is a test using wavelength independent filter-loading corrections
% combined with wavelength dependent scattering corrections.

% averaged values of h0,h1,k0,k1 but wavelength specific value of s
k0_ = [.362, .362, .362, .362];
k1_ = [-0.651, -0.651, -0.651, -.651];
h0_ = [1.159, 1.159, 1.159, 1.159];
h1_ = [-0.687, -0.687, -0.687, -0.687];
s_ = [0.015, 0.017, 0.022, 0.018];

k0 = k0_(N); 
k1 = k1_(N); 
h0 = h0_(N); 
h1 = h1_(N); 
s = s_(N);

ssa = ones(size(Tr));
Ba_V = NaN(size(Tr));
ii_ = zeros(size(Tr));
stay = (Bs>0)&(Ba_raw>0)&(ssa>0)&(ssa<=1.1)&(Tr<=1)&(Tr>=0.5);
stays = sum(stay);
ii = 1;
ii_(stay) = ii;
ssa(stay) = Bs(stay) ./ (Bs(stay) + Ba_raw(stay));

Ba_V(stay) = (k0 + k1 .* (h0+ h1.*ssa(stay)) .* log(Tr(stay))).*Ba_raw(stay) - s.*Bs(stay);

stay(stay) = abs(ssa(stay)- Bs(stay)./(Bs(stay)+Ba_V(stay))) >0.001;
stays = sum(stay);
while ii<10
   ii = ii+ 1;
   ii_(stay) = ii;
   ssa(stay) = Bs(stay) ./ (Bs(stay) + Ba_V(stay));
   Ba_V(stay) = (k0 + k1.*(h0+ h1.*ssa(stay)).*log(Tr(stay))).*Ba_raw(stay) - s.*Bs(stay);
   stay(stay) = abs(ssa(stay)- Bs(stay)./(Bs(stay)+Ba_V(stay))) >0.0001;
   stays = sum(stay);   
end


return