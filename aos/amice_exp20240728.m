function amice_exp20240728
% "A" line has all 3 PSAP plus CLAP92
% "B" line has TAP12, CLAP10, and both MA
% "C" line has AE33 (2LPM), TAP13, and CLAP10 or CLAP92
% "D" line has AE33 (4LPM)



ae33 = pack_ae33; % 2 LPM, looks like "C"?
clap10 = amice_xap_auto;

% Line "A"
PSAP77 = amice_pxap_auto;
PSAP110 = amice_pxap_auto;
PSAP123 = amice_pxap_auto;
clap92 = amice_xap_auto;


%Line "B"
tap12 = amice_xap_auto;

ma492 = amice_ma_auto;
ma494 = amice_ma_auto;

end