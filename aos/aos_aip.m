function aos = aos_aip(aos);
aip.time = aos.time;
aip.LambdaB = 450;
aip.LambdaG = 550;
aip.LambdaR = 700;
aip.PSAP_B = 467;
aip.PSAP_G = 530;
aip.PSAP_R = 660;

aos.vars.Ang_Bs_B_G_10um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Bs_B_G_10um.atts.long_name.data = 'Angstrom exponent from blue and green scatttering';
aos.vars.Ang_Bs_B_G_10um.atts.units.data = 'unitless';
aos.vars.Ang_Bs_B_R_10um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Bs_B_R_10um.atts.long_name.data = 'Angstrom exponent from blue and red scatttering';
aos.vars.Ang_Bs_B_R_10um.atts.units.data = 'unitless';
aos.vars.Ang_Bs_G_R_10um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Bs_G_R_10um.atts.long_name.data = 'Angstrom exponent from green and red scatttering';
aos.vars.Ang_Bs_G_R_10um.atts.units.data = 'unitless';

aos.vars.Ang_Ba_B_G_10um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Ba_B_G_10um.atts.long_name.data = 'Angstrom exponent from blue and green absorption';
aos.vars.Ang_Ba_B_G_10um.atts.units.data = 'unitless';
aos.vars.Ang_Ba_B_R_10um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Ba_B_R_10um.atts.long_name.data = 'Angstrom exponent from blue and red absorption';
aos.vars.Ang_Ba_B_R_10um.atts.units.data = 'unitless';
aos.vars.Ang_Ba_G_R_10um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Ba_G_R_10um.atts.long_name.data = 'Angstrom exponent from green and red absorption';
aos.vars.Ang_Ba_G_R_10um.atts.units.data = 'unitless';

aos.vars.Ang_Bs_B_G_1um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Bs_B_G_1um.atts.long_name.data = 'Angstrom exponent from blue and green scatttering';
aos.vars.Ang_Bs_B_G_1um.atts.units.data = 'unitless';
aos.vars.Ang_Bs_B_R_1um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Bs_B_R_1um.atts.long_name.data = 'Angstrom exponent from blue and red scatttering';
aos.vars.Ang_Bs_B_R_1um.atts.units.data = 'unitless';
aos.vars.Ang_Bs_G_R_1um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Bs_G_R_1um.atts.long_name.data = 'Angstrom exponent from green and red scatttering';
aos.vars.Ang_Bs_G_R_1um.atts.units.data = 'unitless';

aos.vars.Ang_Ba_B_G_1um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Ba_B_G_1um.atts.long_name.data = 'Angstrom exponent from blue and green absorption';
aos.vars.Ang_Ba_B_G_1um.atts.units.data = 'unitless';
aos.vars.Ang_Ba_B_R_1um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Ba_B_R_1um.atts.long_name.data = 'Angstrom exponent from blue and red absorption';
aos.vars.Ang_Ba_B_R_1um.atts.units.data = 'unitless';
aos.vars.Ang_Ba_G_R_1um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.Ang_Ba_G_R_1um.atts.long_name.data = 'Angstrom exponent from green and red absorption';
aos.vars.Ang_Ba_G_R_1um.atts.units.data = 'unitless';


aos.vars.Ang_Bs_B_G_10um.data = angst(aos.vars.Bs_B_Dry_10um_Neph3W_1.data,aos.vars.Bs_G_Dry_10um_Neph3W_1.data,aip.LambdaB,aip.LambdaG);
aos.vars.Ang_Bs_B_R_10um.data = angst(aos.vars.Bs_B_Dry_10um_Neph3W_1.data,aos.vars.Bs_R_Dry_10um_Neph3W_1.data,aip.LambdaB,aip.LambdaR);
aos.vars.Ang_Bs_G_R_10um.data = angst(aos.vars.Bs_G_Dry_10um_Neph3W_1.data,aos.vars.Bs_R_Dry_10um_Neph3W_1.data,aip.LambdaG,aip.LambdaR);
aos.vars.Ang_Ba_B_G_10um.data = angst(aos.vars.Ba_B_Dry_10um_PSAP3W_1.data,aos.vars.Ba_G_Dry_10um_PSAP3W_1.data,aip.PSAP_B,aip.PSAP_G); 
aos.vars.Ang_Ba_B_R_10um.data = angst(aos.vars.Ba_B_Dry_10um_PSAP3W_1.data,aos.vars.Ba_R_Dry_10um_PSAP3W_1.data,aip.PSAP_B,aip.PSAP_R);
aos.vars.Ang_Ba_G_R_10um.data = angst(aos.vars.Ba_G_Dry_10um_PSAP3W_1.data,aos.vars.Ba_R_Dry_10um_PSAP3W_1.data,aip.PSAP_G,aip.PSAP_R);

aos.vars.Ang_Bs_B_G_1um.data = angst(aos.vars.Bs_B_Dry_1um_Neph3W_1.data,aos.vars.Bs_G_Dry_1um_Neph3W_1.data,aip.LambdaB,aip.LambdaG);
aos.vars.Ang_Bs_B_R_1um.data = angst(aos.vars.Bs_B_Dry_1um_Neph3W_1.data,aos.vars.Bs_R_Dry_1um_Neph3W_1.data,aip.LambdaB,aip.LambdaR);
aos.vars.Ang_Bs_G_R_1um.data = angst(aos.vars.Bs_G_Dry_1um_Neph3W_1.data,aos.vars.Bs_R_Dry_1um_Neph3W_1.data,aip.LambdaG,aip.LambdaR);
aos.vars.Ang_Ba_B_G_1um.data = angst(aos.vars.Ba_B_Dry_1um_PSAP3W_1.data,aos.vars.Ba_G_Dry_1um_PSAP3W_1.data,aip.PSAP_B,aip.PSAP_G); 
aos.vars.Ang_Ba_B_R_1um.data = angst(aos.vars.Ba_B_Dry_1um_PSAP3W_1.data,aos.vars.Ba_R_Dry_1um_PSAP3W_1.data,aip.PSAP_B,aip.PSAP_R);
aos.vars.Ang_Ba_G_R_1um.data = angst(aos.vars.Ba_G_Dry_1um_PSAP3W_1.data,aos.vars.Ba_R_Dry_1um_PSAP3W_1.data,aip.PSAP_G,aip.PSAP_R);

aos.vars.subfrac_Bs_B = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.subfrac_Bs_B.atts.long_name.data = 'sub-micron scattering ratio Blue';
aos.vars.subfrac_Bs_B.atts.units.data = 'unitless';
aos.vars.subfrac_Bs_G = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.subfrac_Bs_G.atts.long_name.data = 'sub-micron scattering ratio Green';
aos.vars.subfrac_Bs_G.atts.units.data = 'unitless';
aos.vars.subfrac_Bs_R = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.subfrac_Bs_R.atts.long_name.data = 'sub-micron scattering ratio Red';
aos.vars.subfrac_Bs_R.atts.units.data = 'unitless';

aos.vars.subfrac_Ba_B = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.subfrac_Ba_B.atts.long_name.data = 'sub-micron absorption ratio Blue';
aos.vars.subfrac_Ba_B.atts.units.data = 'unitless';
aos.vars.subfrac_Ba_G = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.subfrac_Ba_G.atts.long_name.data = 'sub-micron absorption ratio Green';
aos.vars.subfrac_Ba_G.atts.units.data = 'unitless';
aos.vars.subfrac_Ba_R = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.subfrac_Ba_R.atts.long_name.data = 'sub-micron absorption ratio Red';
aos.vars.subfrac_Ba_R.atts.units.data = 'unitless';

aos.vars.subfrac_Bs_B.data = submicron(aos.vars.Bs_B_Dry_1um_Neph3W_1.data,aos.vars.Bs_B_Dry_10um_Neph3W_1.data);
aos.vars.subfrac_Bs_G.data = submicron(aos.vars.Bs_G_Dry_1um_Neph3W_1.data,aos.vars.Bs_G_Dry_10um_Neph3W_1.data);
aos.vars.subfrac_Bs_R.data = submicron(aos.vars.Bs_R_Dry_1um_Neph3W_1.data,aos.vars.Bs_R_Dry_10um_Neph3W_1.data);
aos.vars.subfrac_Ba_B.data = submicron(aos.vars.Ba_B_Dry_1um_PSAP3W_1.data,aos.vars.Ba_B_Dry_10um_PSAP3W_1.data);
aos.vars.subfrac_Ba_G.data = submicron(aos.vars.Ba_G_Dry_1um_PSAP3W_1.data,aos.vars.Ba_G_Dry_10um_PSAP3W_1.data);
aos.vars.subfrac_Ba_R.data = submicron(aos.vars.Ba_R_Dry_1um_PSAP3W_1.data,aos.vars.Ba_R_Dry_10um_PSAP3W_1.data);

aos.vars.w_R_10um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.w_R_10um.atts.long_name.data = 'single scattering albedo Red 10 um';
aos.vars.w_R_10um.atts.units.data = 'unitless';
aos.vars.w_G_10um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.w_G_10um.atts.long_name.data = 'single scattering albedo Green 10 um';
aos.vars.w_G_10um.atts.units.data = 'unitless';
aos.vars.w_B_10um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.w_B_10um.atts.long_name.data = 'single scattering albedo Blue 10 um';
aos.vars.w_B_10um.atts.units.data = 'unitless';

aos.vars.w_R_1um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.w_R_1um.atts.long_name.data = 'single scattering albedo Red 1 um';
aos.vars.w_R_1um.atts.units.data = 'unitless';
aos.vars.w_G_1um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.w_G_1um.atts.long_name.data = 'single scattering albedo Green 1 um';
aos.vars.w_G_1um.atts.units.data = 'unitless';
aos.vars.w_B_1um = aos.vars.Bs_B_Dry_10um_Neph3W_1;
aos.vars.w_B_1um.atts.long_name.data = 'single scattering albedo Blue 1 um';
aos.vars.w_B_1um.atts.units.data = 'unitless';

aos.vars.w_B_10um.data = SSA(aos.vars.Bs_B_Dry_10um_Neph3W_1.data, aos.vars.Ba_B_Dry_10um_PSAP3W_1.data);
aos.vars.w_G_10um.data = SSA(aos.vars.Bs_G_Dry_10um_Neph3W_1.data, aos.vars.Ba_G_Dry_10um_PSAP3W_1.data);
aos.vars.w_R_10um.data = SSA(aos.vars.Bs_R_Dry_10um_Neph3W_1.data, aos.vars.Ba_R_Dry_10um_PSAP3W_1.data);
aos.vars.w_B_1um.data = SSA(aos.vars.Bs_B_Dry_1um_Neph3W_1.data, aos.vars.Ba_B_Dry_1um_PSAP3W_1.data);
aos.vars.w_G_1um.data = SSA(aos.vars.Bs_G_Dry_1um_Neph3W_1.data, aos.vars.Ba_G_Dry_1um_PSAP3W_1.data);
aos.vars.w_R_1um.data = SSA(aos.vars.Bs_R_Dry_1um_Neph3W_1.data, aos.vars.Ba_R_Dry_1um_PSAP3W_1.data);

% aip.Ang_Bs_G_R_10um 
% aip.Ang_Bbs_B_G_10um 
% aip.Ang_Bbs_B_R_10um 
% aip.Ang_Bbs_G_R_10um 
% 
% aip.Ang_Bs_B_G_1um 
% aip.Ang_Bs_B_R_1um 
% aip.Ang_Bs_G_R_1um 
% aip.Ang_Bbs_B_G_1um 
% aip.Ang_Bbs_B_R_1um 
% aip.Ang_Bbs_G_R_1um 

% aip.Ang_Ba_G_R_10um 
% aip.Ang_Ba_B_G_1um 
% aip.Ang_Ba_B_R_1um 
% aip.Ang_Ba_G_R_1um 


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

function bsf = bfrac(Bbs,Bs);
bsf = NaN(size(Bs));
NaNs = ~isfinite(Bbs)|~isfinite(Bs)|(Bbs<0)|(Bs<=0);
bsf(~NaNs) = Bbs(~NaNs)./Bs(~NaNs);

