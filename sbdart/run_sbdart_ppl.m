function ppl  = run_sbdart_ppl(qry)
% ppl  = run_sbdart_ppl(qry)
% critical components of qry:
% .wlinf (=0.44)
% w.sup  (=0.44)
% w.inc   (=0.001) 1 nm
% .isalb (=6 vegetation)
% .iaer (5, aerosol model needs aerosol props below)
% .wlbaer = 1xM wavelengths eg [0.44, 0.675, 0.87, 1.02];
% .qbaer = 1xM optical depths eg [0.566709, 0.30555, 0.20587, 0.158665];
% .wbaer = 1xM SSA eg [0.9087, 0.8866, 0.8635, 0.8477];
% .gbaer = 1xM g eg [0.746985, 0.653263, 0.600973, 0.57403];
% .abaer = 1x1 Angstrom Exponent eg, 1.48;
% .SZA=47; 
% .UZEN = zenith angles [0:5:90]; (SZA will be excluded automatically)


%Modify this to accept input and to format the output
%PPL
% from Gouyong
qry = qry_ppl(qry);
% qry.IOUT=21;
ppl = qry_sbdart(qry,figure_(qry.IOUT));
[~, uiz] =  unique(ppl.zen);
ppl.zrad = interp1(ppl.zen(uiz), ppl.rad(uiz), 0,'linear','extrap');


end