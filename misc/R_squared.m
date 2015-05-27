function  rsqr = R_squared(obs,Y);
SS = ((obs-Y).^2);
   SS = sum(SS);
   SStot = sum((Y - mean(Y)).^2);
   rsqr = 1-sum(SS)./SStot;
