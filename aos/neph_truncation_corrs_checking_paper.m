% Compare truncation corrections for Neph RGB, 1&10um, dry/wet

% compute angstrom exp with positive convention: small particles > 0

% These values are from Anderson & Ogren, Table 4b
%%
ang = [0:.1:3];
Bs_B_Dry_1um_Neph3W_1  = (1.165 - (0.046 * ang));
Bs_G_Dry_1um_Neph3W_1    = (1.152 - (0.044 * ang));
Bs_R_Dry_1um_Neph3W_1    = (1.12 - (0.035 * ang));
Bs_B_Dry_10um_Neph3W_1 = (1.365 - (0.156 * ang));
Bs_G_Dry_10um_Neph3W_1    =(1.337 - (0.138 * ang));
Bs_R_Dry_10um_Neph3W_1    = (1.297 - (0.113 * ang));
figure; 
sb(1) = subplot(3,1,1); 
plot(aGBlrh, [Bs_R_Dry_1um_Neph3W_1], '.r-',aGBlrh, [Bs_R_Dry_10um_Neph3W_1],'or-');
legend('1 um','10 um');
title('Red channel');
sb(2) = subplot(3,1,2);
plot(aGBlrh, [Bs_G_Dry_1um_Neph3W_1], '.g-',aGBlrh, [Bs_G_Dry_10um_Neph3W_1],'og-');
legend('1 um','10 um');
title('Green channel');
sb(3) = subplot(3,1,3);
plot(aGBlrh, [Bs_B_Dry_1um_Neph3W_1], '.b-',aGBlrh, [Bs_B_Dry_10um_Neph3W_1],'ob-');
legend('1 um','10 um');
title('Blue channel');
linkaxes(sb,'x')

%%


% For 1 um dry
if good angstrom:
    Bs_B_Dry_1um_Neph3W_1    = Bs_B_Dry_1um_Neph3W_1 * (1.165 - (0.046 * aGBlrh));
    Bs_G_Dry_1um_Neph3W_1    = Bs_G_Dry_1um_Neph3W_1 * (1.152 - (0.044 * aRBlrh));    
    Bs_R_Dry_1um_Neph3W_1    = Bs_R_Dry_1um_Neph3W_1 * (1.12 - (0.035 * aRGlrh));
else
    Bs_B_Dry_1um_Neph3W_1    = Bs_B_Dry_1um_Neph3W_1 * 1.094;
    Bs_G_Dry_1um_Neph3W_1    = Bs_G_Dry_1um_Neph3W_1 * 1.073;
    Bs_R_Dry_1um_Neph3W_1    = Bs_R_Dry_1um_Neph3W_1 * 1.049;
end
    
Bbs_B_Dry_1um_Neph3W_1    = Bbs_B_Dry_1um_Neph3W_1 * 0.951;
Bbs_G_Dry_1um_Neph3W_1    = Bbs_G_Dry_1um_Neph3W_1 * 0.947;
Bbs_R_Dry_1um_Neph3W_1    = Bbs_R_Dry_1um_Neph3W_1 * 0.952;

% for 10 um dry
if good angstrom:
    Bs_B_Dry_10um_Neph3W_1    = Bs_B_Dry_10um_Neph3W_1 * (1.365 - (0.156 * aGBlrh));
    Bs_G_Dry_10um_Neph3W_1    = Bs_G_Dry_10um_Neph3W_1 * (1.337 - (0.138 * aRBlrh));
    Bs_R_Dry_10um_Neph3W_1    = Bs_R_Dry_10um_Neph3W_1 * (1.297 - (0.113 * aRGlrh));
else
    Bs_B_Dry_10um_Neph3W_1    = Bs_B_Dry_10um_Neph3W_1 * 1.29; 
    Bs_G_Dry_10um_Neph3W_1    = Bs_G_Dry_10um_Neph3W_1 * 1.29; 
    Bs_R_Dry_10um_Neph3W_1    = Bs_R_Dry_10um_Neph3W_1 * 1.26; 
end
Bbs_B_Dry_10um_Neph3W_1       = Bbs_B_Dry_10um_Neph3W_1 * 0.981;
Bbs_G_Dry_10um_Neph3W_1       = Bbs_G_Dry_10um_Neph3W_1 * 0.982;
Bbs_R_Dry_10um_Neph3W_1       = Bbs_R_Dry_10um_Neph3W_1 * 0.985;