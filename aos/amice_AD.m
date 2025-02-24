function amice_AD
% "A" line has all 3 PSAP plus CLAP92
% "B" line has TAP12, CLAP10, and both MA
% "C" line has AE33 (2LPM), TAP13, and CLAP10 or CLAP92
% "D" line has AE33 (4LPM)

% Line "A"
PSAP77 = amice_pxap_auto;
PSAP110 = amice_pxap_auto;
PSAP123 = amice_pxap_auto;
clap92 = amice_xap_auto;

% Line "D"
%these need to be fixed to handle new normalization approach
ae33 = pack_ae33;

end