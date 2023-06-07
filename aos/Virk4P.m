function [Ba_1, Ba_2, Ba_3, Z1, Z2, Z3] = Virk4P(Tr,Ba_raw, Be, Bs, ssa, N)
% [Ba_V,ii,k0,k1,h0,h1,s,ssa] = Virk4P(Tr,Ba_raw,Be,N)
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
% CJF: work in progress related to Li retrieval.
% First reimplement with 4 params.
% Next, put in auto-handling of Ext or Sca
% Next, re-implement along the lines of Li_Bap with multivariate linear
% expression
% Then see about retrieving coefs along with or after 

if isavar('Be')&&~isempty(Be)&&isempty(ssa)
   ssa = (Be-Ba_raw)./Be;
end
if isavar('Bs')&&~isempty(Bs)&&isempty(Be) % Only populate ssa from Bs if Be is empty
   Be = Bs + Ba_raw;
   ssa = Bs./(Bs+Ba_raw);    
end
if isavar('ssa')&&~isempty(ssa)&&isempty(Be)&&isempty(Ba)
   coa = 1-ssa;
   Be = Ba_raw./coa;
   Bs = Be-Ba_raw;
end

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

m1 = k0+s;
m2 = k1.*h0;
m3 = k1.*h1;


Ba_1 = NaN(size(Tr));Ba_2 = Ba_1; Ba_3 = Ba_1;
ii_ = zeros(size(Tr));
stay1 = (Ba_raw>0)&(ssa>0)&(ssa<=1.1)&(Tr<=1)&(Tr>=0.5);
stay2 = stay1;
stay3 = stay2;

ii = 1;
ii_(stay1) = ii;
% ssa(stay1) = (Be(stay1)-Ba_raw(stay1)) ./ Be(stay1);

X = Ba_raw; Y = log(Tr); Z3 = ssa; Z1 = 1-Ba_raw./Be; Z2 = Bs./(Bs+Ba_raw);

% Ba_V(stay) = (k0 + k1 .* (h0+ h1.*ssa(stay)) .* log(Tr(stay))).*Ba_raw(stay) - s.*Be(stay).*ssa(stay);

Ba_1(stay1) = X(stay1).*(k0 + m2 .* Y(stay1) + m3.*Y(stay1).*Z1(stay1)) - s.*Be(stay1).*Z1(stay1);
Ba_2(stay2) = X(stay2).*(k0 + m2 .* Y(stay2) + m3.*Y(stay2).*Z2(stay2)) - s.*Bs(stay2);
Ba_3(stay3) = X(stay3).*(m1 + m2 .* Y(stay3) + m3.*Y(stay3).*Z3(stay3)) - s.*X(stay3)./(1-Z3(stay3));

% This iteration loop simultaneously executes for all times and only computes 
% those that haven't converged. Slick!

stay1(stay1) = abs(Z1(stay1)- (Be(stay1).*Z1(stay1))./(Be(stay1).*Z1(stay1)+Ba_1(stay1))) >0.001;
stay2(stay2) = abs(Z2(stay2)- (Bs(stay2))./(Bs(stay2)+Ba_2(stay2))) >0.001;
stay3(stay3) = abs(Z3(stay3)- (Be(stay3)- Ba_3(stay3))./Be(stay3)) > 0.001;

% disp('Check to see if stay and stay_ are equivalent.  Should be!')
stays = sum(stay1)+sum(stay2)+sum(stay3);
while ii<20 && stays>0
   ii = ii+ 1;
   ii_1(stay1) = ii; ii_2(stay2) = ii; ii_3(stay3) = ii;
   Z1(stay1) = (Be(stay1) - Ba_1(stay1))./Be(stay1);
   Z2(stay2) = Bs(stay2)./(Bs(stay2)+Ba_2(stay2));
   Z3_ = max(min(Bs(stay3)./(Bs(stay3)+Ba_3(stay3)),.995),0);
   Z3(stay3) = Z3_;
   % Z3_(stay3) = (Be(stay3) - Ba_3(stay3))./Be(stay3); all(Z3(stay3)==Z3_(stay3))
   % Check by manually evaluating above line
   Ba_1(stay1) = X(stay1).*(k0 + m2 .* Y(stay1) + m3.*Y(stay1).*Z1(stay1)) - s.*Be(stay1).*Z1(stay1);
   Ba_2(stay2) = X(stay2).*(k0 + m2 .* Y(stay2) + m3.*Y(stay2).*Z2(stay2)) - s.*Bs(stay2);
%    Ba_3(stay3) = X(stay3).*(m1 + m2 .* Y(stay3) + m3.*Y(stay3).*Z3(stay3)) - s.*X(stay3)./(1-Z3(stay3));
   Ba_3(stay3) = X(stay3).*(m1 + m2 .* Y(stay3) + m3.*Y(stay3).*Z3(stay3) - s./(1-Z3(stay3)));
%    Ba_3(stay3)./X(stay3) = (m1 + m2 .* Y(stay3) + m3.*Y(stay3).*Z3(stay3) - s./(1-Z3(stay3)));
if sum(stay1)<length(stay1)
   V = [ones([1,sum(~stay1)]);Y(~stay1);Z1(~stay1); 1./(1-Z1(~stay1))];% eliminate lnTr dependence of crossterm
   % from help: B/A = (A'\B')'
   Gn = (Ba_1(~stay1)./X(~stay1))/V;
    Ba_1(stay1) = X(stay1).*(k0 + m2 .* Y(stay1) - m3.*Z1(stay1)) - s.*Be(stay1).*Z1(stay1);
    Ba_1(stay1) = X(stay1).*(Gn(1) + Gn(2) .* Y(stay1) + Gn(3).*Z1(stay1)) - Gn(4).*Be(stay1).*Z1(stay1);
end


   stay1(stay1) = abs(Z1(stay1)- (Be(stay1).*Z1(stay1))./(Be(stay1).*Z1(stay1)+Ba_1(stay1))) >0.001;
   stay2(stay2) = abs(Z2(stay2)- (Bs(stay2))./(Bs(stay2)+Ba_2(stay2))) >0.001;
   stay3(stay3) = abs(Z3(stay3)- (Be(stay3)- Ba_3(stay3))./Be(stay3)) > 0.001;

   stays = sum(stay1)+sum(stay2)+sum(stay3);
end
ii_1; ii_2; ii_3;
%    disp('Check to see if stay and stay_ are equivalent.  Should be!')

figure_(42); plot([1:length(ssa)], [Ba_1; Ba_2; Ba_3],'o'); title('Ba variants'); legend('Ba_1','Ba_2','Ba_3')
figure_(43); plot([1:length(ssa)], [Z1; Z2; Z3],'o'); title('SSA variants'); legend('Ext*SSA','Bs','Ba./COA')

return