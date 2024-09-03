function amice_AB
% Intended to process a data set with "AB" configuration.
% The A line has all 3 PSAP plus CLAP92
% The B line has TAP12, CLAP10, and both MA
PSAP77 = amice_pxap_auto;
PSAP110 = amice_pxap_auto;
PSAP123 = amice_pxap_auto;
ma492 = amice_ma_auto;
ma494 = amice_ma_auto;
%these need to be fixed to handle new normalization approach
clap92 = amice_xap_auto;
tap12 = amice_xap_auto;


end