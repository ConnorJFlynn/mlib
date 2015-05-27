function aos = aos_aip_(aos);
aos.LambdaB = 450;
aos.LambdaG = 550;
aos.LambdaR = 700;
aos.PSAP_B = 467;
aos.PSAP_G = 530;
aos.PSAP_R = 660;

aos.CN_frac = aos.CN_amb ./ aos.CN_contr ;
NaNs = ~isfinite(aos.CN_frac)|(aos.CN_frac<=0)|(aos.CN_frac>=3);
aos.CN_amb(NaNs) = NaN;
aos.CN_contr(NaNs) = NaN;
aos.CN_frac(NaNs) = NaN;

aos.Ang_Bs_B_G_10um = aos.Bsp_B_Dry_10um;
aos.Ang_Bs_B_R_10um = aos.Bsp_B_Dry_10um;
aos.Ang_Bs_G_R_10um = aos.Bsp_B_Dry_10um;

aos.Ang_Ba_B_G_10um = aos.Bsp_B_Dry_10um;
aos.Ang_Ba_B_R_10um = aos.Bsp_B_Dry_10um;
aos.Ang_Ba_G_R_10um = aos.Bsp_B_Dry_10um;

aos.Ang_Bs_B_G_1um = aos.Bsp_B_Dry_10um;
aos.Ang_Bs_B_R_1um = aos.Bsp_B_Dry_10um;
aos.Ang_Bs_G_R_1um = aos.Bsp_B_Dry_10um;

aos.Ang_Ba_B_G_1um = aos.Bsp_B_Dry_10um;
aos.Ang_Ba_B_R_1um = aos.Bsp_B_Dry_10um;
aos.Ang_Ba_G_R_1um = aos.Bsp_B_Dry_10um;

aos.Ang_Bs_B_G_10um = angst(aos.Bsp_B_Dry_10um,aos.Bsp_G_Dry_10um,aos.LambdaB,aos.LambdaG);
aos.Ang_Bs_B_R_10um = angst(aos.Bsp_B_Dry_10um,aos.Bsp_R_Dry_10um,aos.LambdaB,aos.LambdaR);
aos.Ang_Bs_G_R_10um = angst(aos.Bsp_G_Dry_10um,aos.Bsp_R_Dry_10um,aos.LambdaG,aos.LambdaR);
aos.Ang_Ba_B_G_10um = angst(aos.Bap_B_3W_10um,aos.Bap_G_3W_10um,aos.PSAP_B,aos.PSAP_G); 
aos.Ang_Ba_B_R_10um = angst(aos.Bap_B_3W_10um,aos.Bap_R_3W_10um,aos.PSAP_B,aos.PSAP_R);
aos.Ang_Ba_G_R_10um = angst(aos.Bap_G_3W_10um,aos.Bap_R_3W_10um,aos.PSAP_G,aos.PSAP_R);

aos.Ang_Bs_B_G_1um = angst(aos.Bsp_B_Dry_1um,aos.Bsp_G_Dry_1um,aos.LambdaB,aos.LambdaG);
aos.Ang_Bs_B_R_1um = angst(aos.Bsp_B_Dry_1um,aos.Bsp_R_Dry_1um,aos.LambdaB,aos.LambdaR);
aos.Ang_Bs_G_R_1um = angst(aos.Bsp_G_Dry_1um,aos.Bsp_R_Dry_1um,aos.LambdaG,aos.LambdaR);
aos.Ang_Ba_B_G_1um = angst(aos.Bap_B_3W_1um,aos.Bap_G_3W_1um,aos.PSAP_B,aos.PSAP_G); 
aos.Ang_Ba_B_R_1um = angst(aos.Bap_B_3W_1um,aos.Bap_R_3W_1um,aos.PSAP_B,aos.PSAP_R);
aos.Ang_Ba_G_R_1um = angst(aos.Bap_G_3W_1um,aos.Bap_R_3W_1um,aos.PSAP_G,aos.PSAP_R);

aos.subfrac_Bs_B = aos.Bsp_B_Dry_10um;
aos.subfrac_Bs_G = aos.Bsp_B_Dry_10um;
aos.subfrac_Bs_R = aos.Bsp_B_Dry_10um;

aos.subfrac_Ba_B = aos.Bsp_B_Dry_10um;
aos.subfrac_Ba_G = aos.Bsp_B_Dry_10um;
aos.subfrac_Ba_R = aos.Bsp_B_Dry_10um;

aos.subfrac_Bs_B = submicron(aos.Bsp_B_Dry_1um,aos.Bsp_B_Dry_10um);
aos.subfrac_Bs_G = submicron(aos.Bsp_G_Dry_1um,aos.Bsp_G_Dry_10um);
aos.subfrac_Bs_R = submicron(aos.Bsp_R_Dry_1um,aos.Bsp_R_Dry_10um);
aos.subfrac_Ba_B = submicron(aos.Bap_B_3W_1um,aos.Bap_B_3W_10um);
aos.subfrac_Ba_G = submicron(aos.Bap_G_3W_1um,aos.Bap_G_3W_10um);
aos.subfrac_Ba_R = submicron(aos.Bap_R_3W_1um,aos.Bap_R_3W_10um);

aos.w_R_10um = aos.Bsp_B_Dry_10um;
aos.w_G_10um = aos.Bsp_B_Dry_10um;
aos.w_B_10um = aos.Bsp_B_Dry_10um;

aos.w_R_1um = aos.Bsp_B_Dry_10um;
aos.w_G_1um = aos.Bsp_B_Dry_10um;
aos.w_B_1um = aos.Bsp_B_Dry_10um;

aos.w_B_10um = SSA(aos.Bsp_B_Dry_10um, aos.Bap_B_3W_10um);
aos.w_G_10um = SSA(aos.Bsp_G_Dry_10um, aos.Bap_G_3W_10um);
aos.w_R_10um = SSA(aos.Bsp_R_Dry_10um, aos.Bap_R_3W_10um);
aos.w_B_1um = SSA(aos.Bsp_B_Dry_1um, aos.Bap_B_3W_1um);
aos.w_G_1um = SSA(aos.Bsp_G_Dry_1um, aos.Bap_G_3W_1um);
aos.w_R_1um = SSA(aos.Bsp_R_Dry_1um, aos.Bap_R_3W_1um);

aos.bsf_R_10um = aos.Bsp_B_Dry_10um;
aos.bsf_G_10um = aos.Bsp_B_Dry_10um;
aos.bsf_B_10um = aos.Bsp_B_Dry_10um;

aos.bsf_R_1um = aos.Bsp_B_Dry_10um;
aos.bsf_G_1um = aos.Bsp_B_Dry_10um;
aos.bsf_B_1um = aos.Bsp_B_Dry_10um;

aos.bsf_B_10um = bfrac(aos.Bsp_B_Dry_10um, aos.Bbsp_B_Dry_10um);
aos.bsf_G_10um = bfrac(aos.Bsp_G_Dry_10um, aos.Bbsp_G_Dry_10um);
aos.bsf_R_10um = bfrac(aos.Bsp_R_Dry_10um, aos.Bbsp_R_Dry_10um);
aos.bsf_B_1um = bfrac(aos.Bsp_B_Dry_1um, aos.Bbsp_B_Dry_1um);
aos.bsf_G_1um = bfrac(aos.Bsp_G_Dry_1um, aos.Bbsp_G_Dry_1um);
aos.bsf_R_1um = bfrac(aos.Bsp_R_Dry_1um, aos.Bbsp_R_Dry_1um);

aos.g_R_10um = aos.Bsp_B_Dry_10um;
aos.g_G_10um = aos.Bsp_B_Dry_10um;
aos.g_B_10um = aos.Bsp_B_Dry_10um;

aos.g_R_1um = aos.Bsp_B_Dry_10um;
aos.g_G_1um = aos.Bsp_B_Dry_10um;
aos.g_B_1um = aos.Bsp_B_Dry_10um;

aos.g_B_10um = asymp(aos.bsf_B_10um);
aos.g_G_10um = asymp(aos.bsf_G_10um);
aos.g_R_10um = asymp(aos.bsf_R_10um);
aos.g_B_1um = asymp(aos.bsf_B_1um);
aos.g_G_1um = asymp(aos.bsf_G_1um);
aos.g_R_1um = asymp(aos.bsf_R_1um);

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

function bsf = bfrac(Bs,Bbs);
bsf = NaN(size(Bs));
NaNs = ~isfinite(Bbs)|~isfinite(Bs)|(Bbs<0)|(Bs<=0);
bsf(~NaNs) = Bbs(~NaNs)./Bs(~NaNs);

function g = asymp(bsf);
%%g parameterization -7.14*AK2^3 + 7.46 * AK2^2 -3.96*AK2+0.99
g = NaN(size(bsf));
NaNs = ~isfinite(bsf)|(bsf<0)|(bsf>=.79);
g(~NaNs) = 0.99 -3.96*bsf(~NaNs)  + 7.46*bsf(~NaNs).^2 - 7.14*bsf(~NaNs).^3;
NaNs = ~isfinite(g)|(g>1)|(g<-1);
g(NaNs) = NaN;