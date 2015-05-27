function aos = aos_aip_2(aos);
% Recompute aip properties involving Bap (since these were newly filled)
% Check for physical limits and flag impactor times as still bad.
aos.subfrac_Ba_B = submicron(aos.Bap_B_3W_1um,aos.Bap_B_3W_10um);
aos.subfrac_Ba_G = submicron(aos.Bap_G_3W_1um,aos.Bap_G_3W_10um);
aos.subfrac_Ba_R = submicron(aos.Bap_R_3W_1um,aos.Bap_R_3W_10um);

NaNs = (aos.subfrac_Ba_B>1)|(aos.subfrac_Ba_B<=0);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bap_B_3W_1um(NaNs&(aos.impactor_sub>0)) = NaN;
aos.Bap_B_3W_10um(NaNs&(aos.impactor_sup>0)) = NaN;

NaNs = (aos.subfrac_Ba_G>1)|(aos.subfrac_Ba_G<=0);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bap_G_3W_1um(NaNs&(aos.impactor_sub>0)) = NaN;
aos.Bap_G_3W_10um(NaNs&(aos.impactor_sup>0)) = NaN;

NaNs = (aos.subfrac_Ba_R>1)|(aos.subfrac_Ba_R<=0);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bap_R_3W_1um(NaNs&(aos.impactor_sub>0)) = NaN;
aos.Bap_R_3W_10um(NaNs&(aos.impactor_sup>0)) = NaN;

NaNs = (aos.subfrac_Bs_B>1)|(aos.subfrac_Bs_B<=0);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bsp_B_Dry_1um(NaNs&(aos.impactor_sub>0)) = NaN;
aos.Bsp_B_Dry_10um(NaNs&(aos.impactor_sup>0)) = NaN;

NaNs = (aos.subfrac_Bs_G>1)|(aos.subfrac_Bs_G<=0);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bsp_G_Dry_1um(NaNs&(aos.impactor_sub>0)) = NaN;
aos.Bsp_G_Dry_10um(NaNs&(aos.impactor_sup>0)) = NaN;

NaNs = (aos.subfrac_Bs_R>1)|(aos.subfrac_Bs_R<=0);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bsp_R_Dry_1um(NaNs&(aos.impactor_sub>0)) = NaN;
aos.Bsp_R_Dry_10um(NaNs&(aos.impactor_sup>0)) = NaN;


aos.w_B_10um = SSA(aos.Bsp_B_Dry_10um, aos.Bap_B_3W_10um);
aos.w_G_10um = SSA(aos.Bsp_G_Dry_10um, aos.Bap_G_3W_10um);
aos.w_R_10um = SSA(aos.Bsp_R_Dry_10um, aos.Bap_R_3W_10um);

NaNs = (aos.w_B_10um>1)|(aos.w_B_10um<=.3);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bap_B_3W_10um(NaNs&(aos.impactor_sup>0)) = NaN;
aos.Bsp_B_Dry_10um(NaNs&(aos.impactor_sup>0)) = NaN;

NaNs = (aos.w_G_10um>1)|(aos.w_G_10um<=.3);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bap_G_3W_10um(NaNs&(aos.impactor_sup>0)) = NaN;
aos.Bsp_G_Dry_10um(NaNs&(aos.impactor_sup>0)) = NaN;

NaNs = (aos.w_R_10um>1)|(aos.w_R_10um<=.3);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bap_R_3W_10um(NaNs&(aos.impactor_sup>0)) = NaN;
aos.Bsp_R_Dry_10um(NaNs&(aos.impactor_sup>0)) = NaN;

aos.w_B_1um = SSA(aos.Bsp_B_Dry_1um, aos.Bap_B_3W_1um);
aos.w_G_1um = SSA(aos.Bsp_G_Dry_1um, aos.Bap_G_3W_1um);
aos.w_R_1um = SSA(aos.Bsp_R_Dry_1um, aos.Bap_R_3W_1um);

NaNs = (aos.w_B_1um>1)|(aos.w_B_1um<=.3);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bap_B_3W_1um(NaNs&(aos.impactor_sub>0)) = NaN;
aos.Bsp_B_Dry_1um(NaNs&(aos.impactor_sub>0)) = NaN;

NaNs = (aos.w_G_1um>1)|(aos.w_G_1um<=.3);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bap_G_3W_1um(NaNs&(aos.impactor_sub>0)) = NaN;
aos.Bsp_G_Dry_1um(NaNs&(aos.impactor_sub>0)) = NaN;

NaNs = (aos.w_R_1um>1)|(aos.w_R_1um<=.3);
windowSize = 5; NaNs = filter(ones(1,windowSize)/windowSize,1,NaNs)>0;
aos.Bap_R_3W_1um(NaNs&(aos.impactor_sub>0)) = NaN;
aos.Bsp_R_Dry_1um(NaNs&(aos.impactor_sub>0)) = NaN;


aos.subfrac_Ba_B = submicron(aos.Bap_B_3W_1um,aos.Bap_B_3W_10um);
aos.subfrac_Ba_G = submicron(aos.Bap_G_3W_1um,aos.Bap_G_3W_10um);
aos.subfrac_Ba_R = submicron(aos.Bap_R_3W_1um,aos.Bap_R_3W_10um);
aos.subfrac_Bs_B = submicron(aos.Bsp_B_Dry_1um,aos.Bsp_B_Dry_10um);
aos.subfrac_Bs_G = submicron(aos.Bsp_G_Dry_1um,aos.Bsp_G_Dry_10um);
aos.subfrac_Bs_R = submicron(aos.Bsp_R_Dry_1um,aos.Bsp_R_Dry_10um);
aos.w_B_1um = SSA(aos.Bsp_B_Dry_1um, aos.Bap_B_3W_1um);
aos.w_G_1um = SSA(aos.Bsp_G_Dry_1um, aos.Bap_G_3W_1um);
aos.w_R_1um = SSA(aos.Bsp_R_Dry_1um, aos.Bap_R_3W_1um);
aos.w_B_10um = SSA(aos.Bsp_B_Dry_10um, aos.Bap_B_3W_10um);
aos.w_G_10um = SSA(aos.Bsp_G_Dry_10um, aos.Bap_G_3W_10um);
aos.w_R_10um = SSA(aos.Bsp_R_Dry_10um, aos.Bap_R_3W_10um);

aos.Ang_Ba_B_G_1um = angst(aos.Bap_B_3W_1um,aos.Bap_G_3W_1um,aos.PSAP_B,aos.PSAP_G); 
aos.Ang_Ba_B_R_1um = angst(aos.Bap_B_3W_1um,aos.Bap_R_3W_1um,aos.PSAP_B,aos.PSAP_R);
aos.Ang_Ba_G_R_1um = angst(aos.Bap_G_3W_1um,aos.Bap_R_3W_1um,aos.PSAP_G,aos.PSAP_R);

aos.Ang_Ba_B_G_10um = angst(aos.Bap_B_3W_10um,aos.Bap_G_3W_10um,aos.PSAP_B,aos.PSAP_G); 
aos.Ang_Ba_B_R_10um = angst(aos.Bap_B_3W_10um,aos.Bap_R_3W_10um,aos.PSAP_B,aos.PSAP_R);
aos.Ang_Ba_G_R_10um = angst(aos.Bap_G_3W_10um,aos.Bap_R_3W_10um,aos.PSAP_G,aos.PSAP_R);

aos.Ang_Bs_B_G_10um = angst(aos.Bsp_B_Dry_10um,aos.Bsp_G_Dry_10um,aos.LambdaB,aos.LambdaG);
aos.Ang_Bs_B_R_10um = angst(aos.Bsp_B_Dry_10um,aos.Bsp_R_Dry_10um,aos.LambdaB,aos.LambdaR);
aos.Ang_Bs_G_R_10um = angst(aos.Bsp_G_Dry_10um,aos.Bsp_R_Dry_10um,aos.LambdaG,aos.LambdaR);

aos.Ang_Bs_B_G_1um = angst(aos.Bsp_B_Dry_1um,aos.Bsp_G_Dry_1um,aos.LambdaB,aos.LambdaG);
aos.Ang_Bs_B_R_1um = angst(aos.Bsp_B_Dry_1um,aos.Bsp_R_Dry_1um,aos.LambdaB,aos.LambdaR);
aos.Ang_Bs_G_R_1um = angst(aos.Bsp_G_Dry_1um,aos.Bsp_R_Dry_1um,aos.LambdaG,aos.LambdaR);


function ang = angst(A,B,a,b);
ang = NaN(size(A));
NaNs = ~isfinite(A)|~isfinite(B)|(A<0)|(B<=0);
ang(~NaNs) = log(A(~NaNs)./B(~NaNs))./log(b/a);

function frac = submicron(B_1,B_10);
frac = NaN(size(B_1));
NaNs = ~isfinite(B_1)|~isfinite(B_10)|(B_1<0)|(B_10<=0);
frac(~NaNs) = B_1(~NaNs)./B_10(~NaNs);

function w = SSA(Bs, Ba);
w = NaN(size(Bs));
NaNs = ~isfinite(Bs)|~isfinite(Ba)|(Bs<=0)|(Ba<=0);
w(~NaNs) = Bs(~NaNs)./(Bs(~NaNs)+Ba(~NaNs));

