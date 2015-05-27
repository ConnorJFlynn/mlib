function H2OVAPPMB = vappres(dewpt)
%  Calculates water vapor vapor pressure using the Van Goff formula
%  found in the Smithsonian Met. Tables (1958).  It makes an adjustment
%  for the density variations caused by moisture variations.  

	A0 = -7.90298;
	A1 = 5.02808;
	A2 = -1.3816d-7;
	A3 = 8.1328d-3;
	A4 = 1013.246;
	TS = 373.16;
	B1 = 11.344;
	B2 = -3.49149;

	if (dewpt < 223.15)
      H2OVAPPMB = 0;
   else     
      EZ=A0*(TS./dewpt-1)+A1*log10(TS./dewpt);
      EZ=EZ+A2*(10.^(B1*(1-dewpt./TS))-1);
      EZ=EZ+A3*(10.^(B2*(TS./dewpt-1))-1);
      H2OVAPPMB = A4*(10.^EZ);
	end
return
