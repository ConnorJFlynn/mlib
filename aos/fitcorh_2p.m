   function [a,b, rsqr,dryRH] = fitcorh_2p(RH,YY);
   % [a,b,dryRH] = fitcorh_2p(RH,YY);
   % Returns a, b for frh = a.*((1-rh).^(-b));
   % also return effective dry RH such that frh(dry_RH) = 1
   % This function takes the log of frh = a.*((1-rh).^(-b)) to yield a
   % 1st order equation in (1-rh) which is solved by polyfit with direct
   % analogs to the 2p fit equation
   %          XX = 1-aip.vars.RH_NephVol_Wet.data(aip_times)./100;
   %          YY = aip.vars.(rat).data(aip_times);
   XX = 1-RH/100; % convert RH to coRH
   logXX = log(XX); logYY = log(YY);
   logPP = polyfit(logXX,logYY,1);
   a = exp(logPP(2));
   b = -logPP(1);
   % frh = a.*((1-rh).^(-b));
   % frh = 1 = a.*((1-dryRH).^(-b));
   dryRH = (1-((1./a).^(-1./b)))*100;
   rsqr = R_squared(YY,fitrh_2p(RH,a,b));
         
   return