%%
%This was just scraps in progress.  Must be fairly old since I'm still
%using "spas" instead of sunae.
a0 = ancload('C:\datastream\sgp\sgpmfrsrC1\cdf\sgpmfrsrC1.a0.20051108.000000.cdf');
b1 = ancload('C:\datastream\sgp\sgpmfrsrC1\cdf\sgpmfrsrC1.b1.20051108.000000.cdf');
[spas.zen_angle, spas.az_angle, spas.r_au, spas.hour_angle, spas.inc_angle, spas.sunrise, spas.suntransit, spas.sunset] = spa(a0.vars.lat.data, a0.vars.lon.data, a0.vars.alt.data, a0.time);
%%
th_415.raw= a0.vars.hemisp_narrowband_filter1.data;
dif_415.raw = a0.vars.diffuse_hemisp_narrowband_filter1.data;
dh_415.raw = a0.vars.direct_normal_narrowband_filter1.data;
ltz = find((th_415.raw<=0)|(dif_415.raw<=0));
th_415.raw(ltz) = NaN;
dif_415.raw(ltz) = NaN;
dh_415.raw(ltz) = NaN;

CA_415 = -0.28152 * 0.7989 * 0.9636; 
CB_415 =  0.00361; 
CC_415 = -3988.0 * 2; 

th_415.corth = (th_415.raw - CB_415*CC_415)/(CA_415*CC_415);
dif_415.cordif = (dif_415.raw - CB_415*CC_415)/(CA_415*CC_415); 
dh_415.dh = dh_415.raw / (CA_415*CC_415);
%duplicating initial erroneous correction
%dh_415.dh = (dh_415.raw - CB_415*CC_415)/(CA_415*CC_415);

dif_415.b1 = b1.vars.diffuse_hemisp_narrowband_filter1.data;
dh_415.b1 = b1.vars.direct_normal_narrowband_filter1.data;
b1.cos_sza = b1.vars.cosine_solar_zenith_angle.data;
b1.ltz = find(dif_415.b1<=0);
dif_415.b1(b1.ltz) = NaN;
dh_415.b1(b1.ltz) = NaN;
% figure; plot(serial2Hh(a0.time),[dif_415.cordif;dif_415.b1])
% figure; plot(serial2Hh(a0.time),[dif_415.cordif-dif_415.b1], '.')
% title('compare diffuse corrections')
% figure; plot(serial2Hh(b1.time), b1.cos_sza, '.',serial2Hh(a0.time), cos(pi*spas.zen_angle/180),'o')
% figure; plot(serial2Hh(b1.time), b1.cos_sza - cos(pi*spas.zen_angle/180),'o')
%figure; plot(serial2Hh(b1.time), b1.cos_sza./cos(pi*spas.zen_angle/180),'o')

cos_cor.SN_415 = [0.47590 0.58154 0.67423 0.75428 0.81553 0.86882 0.91471 0.95429 0.99014 1.02046 1.04319 1.05591 1.05687 1.04160 1.02785 1.01781 1.00853 1.00116 0.99504 0.99044 0.98655 0.98274 0.97953 0.97682 0.97531 0.97317 0.97162 0.97144 0.96901 0.96898 0.96797 0.96701 0.96693 0.96530 0.96536 0.96603 0.96709 0.96763 0.96865 0.96803 0.96867 0.96945 0.96940 0.97007 0.97049 0.97154 0.97131 0.97226 0.97343 0.97386 0.97452 0.97462 0.97533 0.97717 0.97721 0.97775 0.97883 0.97878 0.97981 0.98156 0.98027 0.98128 0.98122 0.98282 0.98288 0.98276 0.98278 0.98283 0.98312 0.98406 0.98413 0.98399 0.98465 0.98441 0.98494 0.98379 0.98487 0.98525 0.98431 0.98396 0.98407 0.98478 0.98457 0.98423 0.98592 0.98607 0.98904 0.99246 0.99807 1.00000 0.99800 0.99327 0.98943 0.98716 0.98524 0.98557 0.98437 0.98390 0.98412 0.98308 0.98270 0.98240 0.98161 0.98176 0.98193 0.98147 0.97961 0.97946 0.97881 0.97768 0.97809 0.97716 0.97545 0.97472 0.97409 0.97376 0.97211 0.97026 0.97043 0.96814 0.96779 0.96601 0.96547 0.96311 0.96182 0.96077 0.95912 0.95803 0.95672 0.95574 0.95519 0.95353 0.95191 0.94992 0.94927 0.94728 0.94495 0.94311 0.94314 0.94193 0.94066 0.93936 0.93888 0.93697 0.93688 0.93626 0.93438 0.93431 0.93334 0.93360 0.93368 0.93328 0.93372 0.93367 0.93427 0.93463 0.93784 0.94006 0.94252 0.94626 0.95082 0.95522 0.96220 0.96882 0.97896 0.98950 1.00370 1.00434 0.99528 0.97841 0.95959 0.92749 0.88912 0.84767 0.80043 0.74069 0.67330 0.58625 0.49929];
cos_cor.WE_415 = [0.46541,0.58025,0.67193,0.74719,0.80818,0.85913,0.90471,0.94293,0.97751, 1.00760,1.03140,1.04322,1.04602,1.03268,1.02037,1.01071,1.00074,0.99436,0.98818,0.98351,0.97978,0.97550,0.97290,0.97064,0.96889,0.96796,0.96588,0.96505,0.96439,0.96411,0.96453,0.96362,0.96353,0.96283,0.96330,0.96404,0.96324,0.96343,0.96424,0.96460,0.96533,0.96645,0.96691,0.96816,0.96947,0.96913,0.96990,0.97044,0.97118,0.97109,0.97187,0.97299,0.97455,0.97359,0.97459,0.97587,0.97666,0.97663,0.97783,0.97767,0.97835,0.97923,0.98030,0.98123,0.98083,0.98160,0.98248,0.98306,0.98294,0.98218,0.98429,0.98413,0.98374,0.98348,0.98365,0.98461,0.98441,0.98445,0.98371,0.98441,0.98457,0.98461,0.98355,0.98500,0.98508,0.98660,0.98891,0.99345,0.99758,1.00000,0.99701,0.99198,0.98819 0.98610,0.98405,0.98343,0.98223,0.98259,0.98148,0.98200,0.98203,0.98082,0.98134 0.98119,0.98054,0.97979,0.97982,0.97933,0.97921,0.97755,0.97758,0.97710,0.97579 0.97556,0.97439,0.97347,0.97053,0.97196,0.97064,0.97065,0.96877,0.96824,0.96677 0.96590,0.96352,0.96238,0.96067,0.96056,0.95917,0.95725,0.95592,0.95545,0.95390 0.95319,0.95316,0.95071,0.94978,0.94863,0.94664,0.94543,0.94443,0.94383,0.94318 0.94225,0.94217,0.94189,0.94135,0.94104,0.94039,0.94059,0.94141,0.94146,0.94225 0.94327,0.94358,0.94494,0.94734,0.94999,0.95318,0.95758,0.96295,0.96806,0.97513 0.98317,0.99448,1.00638,1.02109,1.03359,1.03051,1.01439,0.98571,0.95357,0.91768 0.87498,0.82688,0.77191 0.70266,0.62167,0.55179];
cos_cor.zen_angle = [-89:89];
%cos_cor.SN_415 = fliplr(cos_cor.SN_415);
%cos_cor.WE_415 = fliplr(cos_cor.WE_415);

neg_el = find(spas.zen_angle>90);
zen_angle = spas.zen_angle;
az_angle = spas.az_angle;
zen_angle(neg_el) = NaN;

zen_angle_WE = zen_angle .* (az_angle<=180) ...
    - zen_angle .* (az_angle>180);
zen_angle_SN = zen_angle .* ((az_angle<=90)|(az_angle>270)) ... 
    - zen_angle .* ((az_angle>90)&(az_angle<=270));

% figure; plot(serial2Hh(a0.time), zen_angle_WE)
% title('zenith angle WE')
% figure; plot(serial2Hh(a0.time), zen_angle_SN)
% title('zenith angle SN')


WE_cor = interp1(cos_cor.zen_angle, cos_cor.WE_415, zen_angle_WE);
SN_cor = interp1(cos_cor.zen_angle, cos_cor.SN_415, zen_angle_SN);

Q1 = find(spas.az_angle>=0 & spas.az_angle<90);
if length(Q1>0)
phi = spas.az_angle(Q1);
cor_WE(Q1) = (phi/90)./WE_cor(Q1);
cor_SN(Q1) = ((90-phi)/90)./SN_cor(Q1);
end

Q2 = find(spas.az_angle>=90 & spas.az_angle<180);
if length(Q1>0)
phi = 180-spas.az_angle(Q2);
cor_WE(Q2) = (phi/90)./WE_cor(Q2);
cor_SN(Q2) = ((90-phi)/90)./SN_cor(Q2);
end

Q3 = find(spas.az_angle>=180 & spas.az_angle<270);
if length(Q3>0)
    phi = spas.az_angle(Q3)-180;
cor_WE(Q3) = (phi/90)./WE_cor(Q3);
cor_SN(Q3) = ((90-phi)/90)./SN_cor(Q3);
end

Q4 = find(spas.az_angle>=270 & spas.az_angle<360);
if length(Q4>0)
    phi = 360 - spas.az_angle(Q4);
cor_WE(Q4) = (phi/90)./WE_cor(Q4);
cor_SN(Q4) = ((90-phi)/90)./SN_cor(Q4);
end

% figure; plot(serial2Hh(a0.time), [cor_WE; cor_SN])
% figure; plot(serial2Hh(a0.time), [cor_WE+ cor_SN])

dh_415.cordh = dh_415.dh .* (cor_WE + cor_SN);

%figure; plot(serial2Hh(a0.time),[dh_415.cordh],'o',serial2Hh(b1.time),dh_415.b1,'.')
figure; plot(serial2Hh(a0.time),[dh_415.cordh-dh_415.b1], '.')
%%
clear
%%


