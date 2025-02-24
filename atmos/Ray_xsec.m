function [sigma, beta] = Ray_xsec(nm)
if ~isavar('nm') 
   nm = 370;
end
cm = nm*1e-7;
nu = 1./cm;
nu2 = nu.^2;
%sig_nu = ((24.*pi.^3.*nu.^4)/N.^2).*((n.^2-1)./(n.^2+2)).^2 .* King
N = 2.5469e19;
sig_base = ((24.*pi.^3.*nu.^4)/N.^2);
n_sub1_He = (2283 + 1.8102e13./(1.5342e10 - nu.^2)).*1e-8; 
K_He = 1;
n_sub1_CO2 = 1.1427e11.*(5799.25./(128908.9.^2 -nu2 ) + 120.05./(89223.8.^2-nu2)...
   + 5.3334./(75037.5.^2 -nu2) + 4.3244./(67837.7.^2-nu2) + 1.218145e-5./(2418.136.^2-nu2)).*1e-8; 
K_CO2 = 1.1364+2.53e-11.*nu2;

n_sub1_air_Penndorf = (6432.8 + 2949810./(146-nu2) + 25540./(41 - nu2)).*1e-8;

sigma.He = sig_base .*dis(1+n_sub1_He) .* K_He;
sigma.CO2 = sig_base .*dis(1+n_sub1_CO2) .* K_CO2;

beta.CO2 = 1e8.*sigma.CO2 .*N;
beta.He = 1e8.*sigma.He.*N;

   function en_sub = en_sub1(A,B,C,nu2);
   en_sub = A + Bl/(C-nu2);
   en_sub = en_sub*1e-8;
   end


   function D = dis(n)
      D = ((n.^2-1)./(n.^2+2)).^2;
   end

   function K = King(p)
      K = (6+3.*p)./(6-7.*p);
   end


end