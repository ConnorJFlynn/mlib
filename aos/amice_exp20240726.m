function amice_exp20240726
% "A" line has all 3 PSAP plus CLAP92
% "B" line has TAP12, CLAP10, and both MA
% "C" line has AE33 (2LPM), TAP13, and CLAP10 or CLAP92
% "D" line has AE33 (4LPM)



ae33 = pack_ae33; % 2 LPM, looks like "C"?

menu('Zoom in to desired region and hit OK when done','OK');
xl = xlim; xl_ = ae33.time>xl(1)&ae33.time<xl(2);

   Bap = Bap_ss(ae33.time, ae33.Flow1.*(1-ae33.zeta_leak)./1000, ae33.Tr1(:,3), 1, ae33.spot_area);
   time = ae33.time(xl_); 
   Bap = Bap(xl_); 
   bad = isnan(Bap); Bap(bad) = interp1(time(~bad), Bap(~bad),time(bad),'linear'); 
   bad = isnan(Bap); Bap(bad) = interp1(time(~bad), Bap(~bad),time(bad),'nearest','extrap'); 
   v.time = time; 
   v.Bap = Bap;
   DATA.freq= v.Bap; DATA.rate = 1;
   v.retval = allan(DATA, 'AE33');

clap10 = amice_xap_auto;

menu('Zoom in to desired region and hit OK when done','OK');
xl = xlim; xl_ = clap10.time>xl(1)&clap10.time<xl(2);

   Bap = Bap_ss(clap10.time, clap10.flow_LPM, clap10.Tr(:,2), 1);
   time = clap10.time(xl_); 
   Bap = Bap(xl_); 
   bad = isnan(Bap); Bap(bad) = interp1(time(~bad), Bap(~bad),time(bad),'linear'); 
   bad = isnan(Bap); Bap(bad) = interp1(time(~bad), Bap(~bad),time(bad),'nearest','extrap'); 
   v.time = time; 
   v.Bap = Bap;
   DATA.freq= v.Bap; DATA.rate = 1;
   v.retval = allan(DATA, 'CLAP10');

   clap92 = amice_xap_auto;
   xl = xlim; xl_ = clap92.time>xl(1)&clap92.time<xl(2);

   Bap = Bap_ss(clap92.time, clap92.flow_LPM, clap92.Tr(:,2), 1);
   time = clap92.time(xl_); 
   Bap = Bap(xl_); 
   bad = isnan(Bap); Bap(bad) = interp1(time(~bad), Bap(~bad),time(bad),'linear'); 
   bad = isnan(Bap); Bap(bad) = interp1(time(~bad), Bap(~bad),time(bad),'nearest','extrap'); 
   v.time = time; 
   v.Bap = Bap;
   DATA.freq= v.Bap; DATA.rate = 1;
   v.retval = allan(DATA, 'CLAP92');


% Line "A"
PSAP77 = amice_pxap_auto;
PSAP110 = amice_pxap_auto;
PSAP123 = amice_pxap_auto;



%Line "B"
tap12 = amice_xap_auto;

ma492 = amice_ma_auto;
ma494 = amice_ma_auto;

end