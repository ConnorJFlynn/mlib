function Boptics=BH_Mie_SizeDist(wvl,Dp,dNdlogDp,dlogDp,RIreal,RIimag)

global GSA_Qext; global GSA_Qabs; global GSA_Qsca; 
% Calculate the integrated extinction, scattering and absorption (in 1/Mm)
% for a given size distribution with specified complex refractive index
% Results are stored in the 3-element array "Boptics"
% Boptics[0] = extinction; [1] = absorption; [2] = scattering
% wvl // wavelength in nm
% Dp // diameter in nm
% dNdlogDp // concentration in p/cc
% variable RIreal // real RI
% variable RIimag // imaginary RI
% variable npnts = numpnts(Dp)
% variable i;
% Written by Fan Mei, PNNL
% Modified by Connor Flynn, OU, 2022-08-01
%   Modified to establish agreement with SizeDist_Optics. 
%   Call Mie.m instead of mie.m in order to use same calcs from C. Mätzler  
%   Checked against https://omlc.org/calc/mie_calc.html
%   Fixed factor of pi/2 error.  
%   Applied units conversion to get 1/Mm.  
%   Flipped order of for-loops for speed.
npnts=length(Dp);
% variable/G Bext, Babs, Bsca
% note Boptics "Bext, Babs, Bsca in 1/Mm"
 for i=npnts:-1:1 %Flipped order of loop for speed
%     BH_Mie_FM(wvl,Dp(i)/2,RIreal,RIimag,0);
%     ExtXS_byDiam(i) = GSA_Qext;
%     AbsXS_byDiam(i) = GSA_Qabs;
%     ScaXS_byDiam(i) = GSA_Qsca;
    result(i,:)=Mie(complex(RIreal,RIimag),1.*Dp(i)/wvl);    %C. Mätzler code;
%   Checked against https://omlc.org/calc/mie_calc.html
%     ExtXS_byDiam(i) = result(i,4);                          % These can all be assigned later out of the loop
%     AbsXS_byDiam(i) = result(i,6);
%     ScaXS_byDiam(i) = result(i,5);
%     BScaXS_byDiam(i) = result(i,7);
 end
 bad = dNdlogDp<0; dNdlogDp(bad)=0; bad = isnan(result); result(bad) =0;
 if size(result,2) == size(Dp,1)
     result = result';
 end
 Mie_tots = result' * (pi./4 .* Dp.^2 .* dNdlogDp .* dlogDp); % With line 38 this is faster than nanmean (below)
 Mie_tots = Mie_tots * 1.e-6;                                 % nm2/cm3 * 1.e-6 = Mm-1 
 Bext= Mie_tots(1);
 Babs = Mie_tots(3);
 Bsca = Mie_tots(2);


Boptics = [Bext, Babs, Bsca];
end