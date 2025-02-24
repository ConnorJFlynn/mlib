function amice_BD
% Intended to process a data set with "BD" configuration.
% "A" line has all 3 PSAP plus CLAP92
% "B" line has TAP12, CLAP10, and both MA
% "C" line has AE33 (2LPM), TAP13, and CLAP10 or CLAP92
% "D" line has AE33 (4LPM)


%Line "B"

ma492 = amice_ma_auto;
ma494 = amice_ma_auto;
tap12 = amice_xap_auto;
clap10 = amice_xap_auto;

figure; plot(tap12.time, tap12.Bap ,'-'); dynamicDateTicks; sgtitle('TAP12'); 
menu('Zoom in to desired region and hit OK when done','OK');

ae33 = pack_ae33;
% ma492 = amice_ma_auto;
% ma494 = amice_ma_auto;
%these need to be fixed to handle new normalization approach

figure; plot(ae33.time, ae33.Bap1_raw,'-'); dynamicDateTicks; sgtitle('AE33'); 
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


end