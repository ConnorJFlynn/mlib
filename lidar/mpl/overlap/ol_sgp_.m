function ol_out = ol_sgp_(range,in_time);
% ol_out = ol_sgp_(range,in_time);
% The ol functions return ol_out of length(range)


nxt = 1;
ol.time(nxt) = [datenum('19960501','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_19960501;
% overlap_correction_mpl002_a

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('19970311','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_19970311;
% overlap_correction_mpl004

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('19971006','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_19971006;
%  overlap_correction_mpl002_b

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('19980812','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_19980812;
% overlap_correction_mpl054_a

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('19990122','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_19990122;
% overlap_correction_mpl054_b

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('19990507','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_19990507;
% overlap_correction_mpl054_c

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('19990715','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_19990715;
% overlap_correction_mpl054_d

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('20000303','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_20000303;
% overlap_correction_mpl054_e

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('20000502','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_20000502;
%overlap_correction_mpl054_f;

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('20020515','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_20020515;
%overlap_correction_mpl054_g;

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('20030115','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_20030115;
%overlap_correction_mpl054_h;

nxt = length(ol.time)+1;
ol.time(nxt) = [datenum('20040515','yyyymmdd')];
ol.ol_corr{nxt} = @olcorr_sgp_20040515;
% &overlap_correction_apd8126

nxt = length(ol.time)+1;
ol.time(nxt) = [inf];
ol.ol_corr{nxt} = @ol_unity;

if ~exist('in_time','var')||isempty(in_time)
   first = 1;
else
   first = find(in_time<ol.time,1);
end
first = first -1;
first = max([1,first]);
ol_out = ol.ol_corr{first}(range);

return

function ol_corr = ol_unity(range);
ol_corr = ones(size(range));
return

function corr = olcorr_sgp_19960501(range)
% overlap_correction_mpl002_a

stopr = 6.870;
rone =  0.580;
corr = ones(size(range));
r = range(range<stopr);
corr(range<stopr) = (1.063e-2) + (2.837e-1).*r ;
r = range(range<rone);
corr(range<rone) = (-8.463e-2) + (4.930e-1).*r + (-8.119e-2).*r.^2 + (4.739e-3).*r.^3;
corr = 1./corr;


function corr = olcorr_sgp_19970311(range)
% overlap_correction_mpl004
stopr = 8.200;
rone = 0;
corr = ones(size(range));
r = range(range<stopr);
corr(range<stopr) = (-8.0e-2) + (4.77e-1).*r + (-8.05e-2).*r.^2 + (4.67e-3).*r.^3;

corr(range<rone) = 1;
corr = 1./corr;


function corr = olcorr_sgp_19971006(range)
%overlap_correction_mpl002_b(range);
stopr = 4.850;
rone = 1.200;
corr = ones(size(range));
r = range(range<rone);
corr(range<rone) = (-5.292e-2) + (3.283e-1).*r + (1.233e-1).*r.^2;
r = range(range<stopr);
corr(range<stopr) = (-3.622e-1) + (1.012e+0).*r + (-2.547e-1).*r.^2 + (2.137e-2).*r.^3;
corr = 1./corr;
return


function corr = olcorr_sgp_19980812(range);
% overlap_correction_mpl054_a
corr = ones(size(range));
stopr = 5;
rone = 1.769;
r = range(range<rone);
corr(range<rone) = (4.086e-3) + (3.350e-1).*r + (1.566e-1).*r.^2 + (-7.127e-2).*r.^3;
r = range(range<stopr);
corr(range<stopr) = (-5.464e-2) + (6.519e-1).*r + (-1.498e-1).*r.^2 + (1.234e-2).*r.^3;
corr = 1./corr;

return


function corr = olcorr_sgp_19990122(range);
% ol.ol_corr{nxt} = @olcorr_sgp_19990122;
% overlap_correction_mpl054_b
corr = ones(size(range));
% range, correction
lookup = [0.000, 0.000;
   0.067, 0.001;
   0.157, 0.009;
   0.279, 0.029;
   0.597, 0.127;
   0.982, 0.323;
   1.274, 0.523;
   1.593, 0.686;
   1.596, 0.710;
   1.686, 0.730;
   1.776, 0.749;
   1.866, 0.767;
   1.956, 0.783;
   2.046, 0.799;
   2.136, 0.814;
   2.226, 0.828;
   2.316, 0.841;
   2.406, 0.854;
   2.496, 0.865;
   2.586, 0.876;
   2.676, 0.886;
   2.766, 0.896;
   2.856, 0.904;
   2.946, 0.913;
   3.036, 0.920;
   3.126, 0.927;
   3.215, 0.933;
   3.305, 0.939;
   3.395, 0.945;
   3.485, 0.950;
   3.575, 0.954;
   3.665, 0.959;
   3.755, 0.963;
   3.845, 0.966;
   3.935, 0.970;
   4.025, 0.973;
   4.115, 0.976;
   4.205, 0.978;
   4.295, 0.981;
   4.385, 0.983;
   4.475, 0.986;
   4.565, 0.988;
   4.655, 0.991;
   4.744, 0.993;
   4.834, 0.995;
   4.924, 0.998];

r = range>0 & range<5;
corr(r) = interp1(lookup(:,1), lookup(:,2), range(r), 'linear');

corr = 1./corr;
return


function corr = olcorr_sgp_19990507(range);
% corr = olcorr_sgp_19990507;
% overlap_correction_mpl054_c
% Use prior overlap
corr = olcorr_sgp_19990122(range);

return;


function corr = olcorr_sgp_19990715(range);
% corr = olcorr_sgp_19990715(range);
% overlap_correction_mpl054_d
corr = ones(size(range));
stopr = 5.1;
rone = 1.546;
%       if(r < rone)
%       corr = (-2.462e-2) + (2.434e-1)*r + (4.282e-1)*r*r + (-1.848e-1)*r*r*r;
%     else
%       corr = (1.473e-1) + (4.974e-1)*r + (-1.026e-1)*r*r + (7.447e-3)*r*r*r;
r = range(range<rone);
corr(range<rone) = (-2.462e-2) + (2.434e-1).*r + (4.282e-1).*r.^2 + (-1.848e-1).*r.^3;
r = range(range<stopr);
corr(range<stopr) = (1.473e-1) + (4.974e-1).*r + (-1.026e-1).*r.^2 + (7.447e-3).*r.^3;

corr = 1./corr;

return;

function corr = olcorr_sgp_20000303(range);
overlap_correction_mpl054_e
corr = ones(size(range));
stopr = 5.680;
rone = 2.00;
r = range(range<=rone);
corr(range<rone) = (-5.308e-2) + (3.622e-1).*r + (1.787e-1).*r.^2 + (-7.726e-2).*r.^3;
r = range(range<stopr);
corr (range<=stopr)= (1.341e-1) + (4.851e-1).*r + (-9.540e-2).*r.^2 + (6.486e-3).*r.^3;

corr = 1./corr;
return

function corr = olcorr_sgp_20000502(range);
%overlap_correction_mpl054_f;
stopr = 5.68;
rone = 1.65;
corr = ones(size(range));
r = range(range<stopr);
corr(range<stopr) = (-5.802e-2) + (4.773e-1).*r + (-7.562e-2).*r.^2 + (4.295e-3).*r.^3;
r = range(range<rone);
corr(range<rone) = (-2.215e-2) + (2.053e-1).*r + (2.765e-1).*r.^2 + (-1.189e-1).*r.^3;
corr = 1./corr;
return

function corr = olcorr_sgp_20020515(range);
%overlap_correction_mpl054_g;
corr = ones(size(range));
stopr = 6.20;
rone = 0.950;
r = range(range<=rone);
corr(range<rone) = (-2.988e-2) + (1.644e-1).*r + (2.668e-1).*r.^2 + (-1.590e-1).*r.^3;
r = range(range<stopr);
corr (range<=stopr)=(-3.583e-2) + (3.044e-1).*r + (-2.849e-2).*r.^2 + (1.018e-3).*r.^3;
return

function corr = olcorr_sgp_20030115(range);
%overlap_correction_mpl054_h;
corr = ones(size(range));
lookup = [0.007495; -28926.806641; 0.044969; 1449.280151; 0.074948; 353.848053; 0.104927; 169.747009; 0.134907; 102.538010;
   0.164886; 69.641571; 0.194865; 50.688248; 0.224844; 38.594200; 0.254824; 30.336697; 0.284803; 24.428778;
   0.314782; 20.056839; 0.344761; 16.737936; 0.374741; 14.166979; 0.404720; 12.141880; 0.434699; 10.523797;
   0.464678; 9.214622; 0.494658; 8.143435; 0.524637; 7.258036; 0.554616; 6.519377; 0.584595; 5.897865;
   0.614575; 5.370789; 0.644554; 4.920536; 0.674533; 4.533304; 0.704512; 4.198176; 0.734492; 3.906446;
   0.764471; 3.651113; 0.794450; 3.426500; 0.824429; 3.227976; 0.854409; 3.051737; 0.884388; 2.894634;
   0.914367; 2.754048; 0.944346; 2.627788; 0.974325; 2.514009; 1.004305; 2.411152; 1.034284; 2.317890;
   1.064263; 2.233091; 1.094242; 2.155783; 1.124222; 2.085130; 1.154201; 2.020407; 1.184180; 1.960987;
   1.214159; 1.906320; 1.244139; 1.855927; 1.274118; 1.809389; 1.304097; 1.766333; 1.334076; 1.726434;
   1.364056; 1.689400; 1.394035; 1.654976; 1.424014; 1.622930; 1.453993; 1.593058; 1.483973; 1.565176;
   1.513952; 1.539120; 1.543931; 1.514741; 1.573910; 1.491906; 1.603890; 1.470493; 1.633869; 1.450392;
   1.663848; 1.431506; 1.693827; 1.413742; 1.723807; 1.397019; 1.753786; 1.381262; 1.783765; 1.366401;
   1.813744; 1.352374; 1.843724; 1.339123; 1.873703; 1.326595; 1.903682; 1.314741; 1.933661; 1.303516;
   1.963641; 1.292879; 1.993620; 1.282791; 2.023599; 1.273217; 2.053578; 1.264124; 2.083558; 1.255481;
   2.113537; 1.247260; 2.143516; 1.239435; 2.173495; 1.231981; 2.203475; 1.224876; 2.233454; 1.218098;
   2.263433; 1.211627; 2.293412; 1.205445; 2.323391; 1.199535; 2.353371; 1.193879; 2.383350; 1.188464;
   2.413329; 1.183275; 2.443309; 1.178299; 2.473288; 1.173523; 2.503267; 1.168935; 2.533246; 1.164524;
   2.563226; 1.160281; 2.593205; 1.156195; 2.623184; 1.152258; 2.653163; 1.148460; 2.683142; 1.144794;
   2.713122; 1.141251; 2.743101; 1.137826; 2.773080; 1.134511; 2.803060; 1.131299; 2.833039; 1.128186;
   2.863018; 1.125164; 2.892997; 1.122230; 2.922976; 1.119377; 2.952956; 1.116602; 2.982935; 1.113899;
   3.012914; 1.111266; 3.042893; 1.108697; 3.072873; 1.106189; 3.102852; 1.103739; 3.132831; 1.101342;
   3.162810; 1.098998; 3.192790; 1.096701; 3.222769; 1.094450; 3.252748; 1.092243; 3.282727; 1.090076;
   3.312707; 1.087947; 3.342686; 1.085855; 3.372665; 1.083797; 3.402644; 1.081772; 3.432624; 1.079778;
   3.462603; 1.077812; 3.492582; 1.075875; 3.522561; 1.073964; 3.552541; 1.072077; 3.582520; 1.070215;
   3.612499; 1.068374; 3.642478; 1.066556; 3.672458; 1.064758; 3.702437; 1.062980; 3.732416; 1.061221;
   3.762395; 1.059479; 3.792375; 1.057755; 3.822354; 1.056048; 3.852333; 1.054357; 3.882312; 1.052681;
   3.912292; 1.051020; 3.942271; 1.049374; 3.972250; 1.047743; 4.002229; 1.046125; 4.032208; 1.044520;
   4.062188; 1.042929; 4.092167; 1.041351; 4.122146; 1.039786; 4.152125; 1.038233; 4.182105; 1.036692;
   4.212084; 1.035164; 4.242064; 1.033648; 4.272042; 1.032144; 4.302022; 1.030652; 4.332001; 1.029172;
   4.361980; 1.027704; 4.391960; 1.026248; 4.421939; 1.024804; 4.451918; 1.023371; 4.481897; 1.021951;
   4.511877; 1.020543; 4.541856; 1.019146; 4.571835; 1.017762; 4.601814; 1.016390; 4.631793; 1.015031;
   4.661773; 1.013684; 4.691752; 1.012349; 4.721731; 1.011027; 4.751710; 1.009718; 4.781690; 1.008422;
   4.811669; 1.007138; 4.841648; 1.005868; 4.871627; 1.004611; 4.901607; 1.003367; 4.931586; 1.002136;
   4.961565; 1.000920; 4.991544; 0.999717 ];
tmps = ones([ 2, length(lookup)./2]);
tmps(:) = lookup;
corr(range>0 & range < 5) = interp1(tmps(1,:), tmps(2,:), range(range>0 & range<5),'linear');

return

function corr = olcorr_sgp_20040515(x);
% &overlap_correction_apd8126

y = (1.0+x.*(-55.94930544107336+x.*(1859.427089946109+ ...
   x.*(-13029.31733017854+x.*(19818.07089737063+ ...
   x.*100663.0452403135)))))./ ...
   (1983.692570195181+x.*(-5873.985744477678+...
   x.*(-81601.33188136169+x.*(479773.0339543475+ ...
   x.*(8411.543573508520+x.*100969.7357781541)))));

corr =  1./y;
corr(corr<=0) = 1;
return



