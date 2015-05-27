function ch = corr_channel(ch, det_corrs, angle_corrs)
%ch = corr_channel(ch, det_corrs, angle_corrs)
%channel ch contains time, th, dif, dh, zen_angle, az_angle, and lat
%det_corrs contains det_sens, offset, gain
%angle_corrs contains bench angle with SN and WE corrections
% Modified from 20060319 version by breaking cos corr into cardinal
% directions and also accounting for reversal with lat<0

det_sens = det_corrs.det_sens;
offset = det_corrs.offset;
gain = det_corrs.gain;

th = ch.th;
dif = ch.dif;
dn = ch.dn;
%Applying the following lines (with det_sens and gain) replicates previous
%mfrsr b1 data level, except for the correction to cordn (no offset
%subtraction to direct beam)
% th = (th - offset*gain)/(det_sens*gain);
% dif = (dif - offset*gain)/(det_sens*gain); 
% cordn = dn / (det_sens*gain);

%Applying the following lines (without det_sens) preserves measured units
%of counts / mV but does properly remove offset from diffuse measurements
th = (th - offset*gain);
dif = (dif - offset*gain); 
cordn = dn ;
%duplicating initial erroneous correction
%cordn = (dh - offset*gain)/(det_sens*gain);

% if ~exist('angle_corrs', 'var')
% angle_corrs.SN = [0.47590 0.58154 0.67423 0.75428 0.81553 0.86882 0.91471 0.95429 0.99014 1.02046 1.04319 1.05591 1.05687 1.04160 1.02785 1.01781 1.00853 1.00116 0.99504 0.99044 0.98655 0.98274 0.97953 0.97682 0.97531 0.97317 0.97162 0.97144 0.96901 0.96898 0.96797 0.96701 0.96693 0.96530 0.96536 0.96603 0.96709 0.96763 0.96865 0.96803 0.96867 0.96945 0.96940 0.97007 0.97049 0.97154 0.97131 0.97226 0.97343 0.97386 0.97452 0.97462 0.97533 0.97717 0.97721 0.97775 0.97883 0.97878 0.97981 0.98156 0.98027 0.98128 0.98122 0.98282 0.98288 0.98276 0.98278 0.98283 0.98312 0.98406 0.98413 0.98399 0.98465 0.98441 0.98494 0.98379 0.98487 0.98525 0.98431 0.98396 0.98407 0.98478 0.98457 0.98423 0.98592 0.98607 0.98904 0.99246 0.99807 1.00000 0.99800 0.99327 0.98943 0.98716 0.98524 0.98557 0.98437 0.98390 0.98412 0.98308 0.98270 0.98240 0.98161 0.98176 0.98193 0.98147 0.97961 0.97946 0.97881 0.97768 0.97809 0.97716 0.97545 0.97472 0.97409 0.97376 0.97211 0.97026 0.97043 0.96814 0.96779 0.96601 0.96547 0.96311 0.96182 0.96077 0.95912 0.95803 0.95672 0.95574 0.95519 0.95353 0.95191 0.94992 0.94927 0.94728 0.94495 0.94311 0.94314 0.94193 0.94066 0.93936 0.93888 0.93697 0.93688 0.93626 0.93438 0.93431 0.93334 0.93360 0.93368 0.93328 0.93372 0.93367 0.93427 0.93463 0.93784 0.94006 0.94252 0.94626 0.95082 0.95522 0.96220 0.96882 0.97896 0.98950 1.00370 1.00434 0.99528 0.97841 0.95959 0.92749 0.88912 0.84767 0.80043 0.74069 0.67330 0.58625 0.49929];
% angle_corrs.WE = [0.46541,0.58025,0.67193,0.74719,0.80818,0.85913,0.90471,0.94293,0.97751, 1.00760,1.03140,1.04322,1.04602,1.03268,1.02037,1.01071,1.00074,0.99436,0.98818,0.98351,0.97978,0.97550,0.97290,0.97064,0.96889,0.96796,0.96588,0.96505,0.96439,0.96411,0.96453,0.96362,0.96353,0.96283,0.96330,0.96404,0.96324,0.96343,0.96424,0.96460,0.96533,0.96645,0.96691,0.96816,0.96947,0.96913,0.96990,0.97044,0.97118,0.97109,0.97187,0.97299,0.97455,0.97359,0.97459,0.97587,0.97666,0.97663,0.97783,0.97767,0.97835,0.97923,0.98030,0.98123,0.98083,0.98160,0.98248,0.98306,0.98294,0.98218,0.98429,0.98413,0.98374,0.98348,0.98365,0.98461,0.98441,0.98445,0.98371,0.98441,0.98457,0.98461,0.98355,0.98500,0.98508,0.98660,0.98891,0.99345,0.99758,1.00000,0.99701,0.99198,0.98819 0.98610,0.98405,0.98343,0.98223,0.98259,0.98148,0.98200,0.98203,0.98082,0.98134 0.98119,0.98054,0.97979,0.97982,0.97933,0.97921,0.97755,0.97758,0.97710,0.97579 0.97556,0.97439,0.97347,0.97053,0.97196,0.97064,0.97065,0.96877,0.96824,0.96677 0.96590,0.96352,0.96238,0.96067,0.96056,0.95917,0.95725,0.95592,0.95545,0.95390 0.95319,0.95316,0.95071,0.94978,0.94863,0.94664,0.94543,0.94443,0.94383,0.94318 0.94225,0.94217,0.94189,0.94135,0.94104,0.94039,0.94059,0.94141,0.94146,0.94225 0.94327,0.94358,0.94494,0.94734,0.94999,0.95318,0.95758,0.96295,0.96806,0.97513 0.98317,0.99448,1.00638,1.02109,1.03359,1.03051,1.01439,0.98571,0.95357,0.91768 0.87498,0.82688,0.77191 0.70266,0.62167,0.55179];
% angle_corrs.zen_angle = [-89:89];
% end
% If lat < 0, flip angle_corrs 
if ch.lat < 0
   angle_corrs.SN = angle_corrs.SN(end:-1:1);
   angle_corrs.WE = angle_corrs.WE(end:-1:1);
end
%Breaking SN and WE into 4 ordinate directions vs elevation angle.
N.angle = [0:90];
N.corr = angle_corrs.SN(181:-1:91);
S.angle = [0:90];
S.corr = angle_corrs.SN(1:91);
W.angle = [0:90];
W.corr = angle_corrs.WE(1:91);
E.angle = [0:90];
E.corr = angle_corrs.WE(181:-1:91);

N_cor = interp1(E.angle, E.corr, ch.zen_angle);
E_cor = interp1(E.angle, E.corr, ch.zen_angle);
S_cor = interp1(S.angle, S.corr, ch.zen_angle);
W_cor = interp1(W.angle, W.corr, ch.zen_angle);

%  disp('NE quadrant');
Q1 = find(ch.az_angle>=0 & ch.az_angle<90);
if length(Q1>0)
   phi = ch.az_angle(Q1);
   cor_WE(Q1) = (phi/90)./W_cor(Q1);
   cor_SN(Q1) = ((90-phi)/90)./N_cor(Q1);
end

Q2 = find(ch.az_angle>=90 & ch.az_angle<180);
if length(Q1>0)
   phi = 180-ch.az_angle(Q2);
   cor_WE(Q2) = (phi/90)./E_cor(Q2);
   cor_SN(Q2) = ((90-phi)/90)./S_cor(Q2);
end

Q3 = find(ch.az_angle>=180 & ch.az_angle<270);
if length(Q3>0)
   phi = ch.az_angle(Q3)-180;
   cor_WE(Q3) = (phi/90)./W_cor(Q3);
   cor_SN(Q3) = ((90-phi)/90)./S_cor(Q3);
end

Q4 = find(ch.az_angle>=270 & ch.az_angle<360);
if length(Q4>0)
   phi = 360 - ch.az_angle(Q4);
   cor_WE(Q4) = (phi/90)./W_cor(Q4);
   cor_SN(Q4) = ((90-phi)/90)./N_cor(Q4);
end

cos_corr = (cor_WE + cor_SN);

cordn = cordn .* cos_corr;

%figure; plot(serial2Hh(a0.time),[dh_415.cordn],'o',serial2Hh(b1.time),dh_415.b1,'.')
% figure; plot(serial2Hh(a0.time),[dh_415.cordn-dh_415.b1], '.')

ch.th = th;
ch.dif = dif;
ch.cordn = cordn;
ch.cos_corr = cos_corr;

function status = sandbox
% All the c-code below is from TU src file cos.c

% /*
% ** fixup_tables
% **
% ** The Tables read from the solarinfo files are kinda hard to use;
% ** it would be nice if there were 4 90-point vectors in the 4
% ** azimuthal directions that listed the cosine correction for each
% ** degree from the horizon to the zenith, say. But there aren't.
% ** This function changes the 181-element west-to-east and south-to-
% ** north vectors around so they are a bit easier to work with...
% **
% ** West/                           East/
% ** South Horizon             ZenithNorth Horizon           Zenith
% ** 0000   ....                8888899999                      778
% ** 0123   ....                5678901234                      890
% **
% ** That is, the west/east vector goes from the western horizon to zenith
% ** in 1-degree increments as the west-east index goes from 0 to 89. Then
% ** it goes from the eastern horizon to the zenith as the vector index
% ** ranges from 90 to 179. The same goes for the south-to-north vector.
% ** I.e., this function reverses the order of the last 90 elements of the
% ** we and sn arrays.
% **
% ** But wait, there's more. The tables are created using nomenclature
% ** appropriate for the northern hemisphere. When the site in question
% ** is in the southern hemisphere, then north and south are reversed,
% ** as are east and west. So, reverse the arrays if the site is
% ** south of the equator.
% */
% 
% /* static void fixup_tables(solarinfo *si, double lat) */
% void fixup_tables(solarinfo *si, double lat)
% {
%     int		i, j;
%     void	swap(double *, double *);
% 
%     for (j=0; j<si->num_lambdas; j++)
% 	if (si->lambdas[j].corr_table != NULL)
% 	    for (i=90; i<135; i++) {
% 		swap(si->lambdas[j].corr_table->we + i,
% 		     si->lambdas[j].corr_table->we + 270-i);
% 		swap(si->lambdas[j].corr_table->sn + i,
% 		     si->lambdas[j].corr_table->sn + 270-i);
% 	    }
% 
%     if (lat < 0.0)
% 	for (j=0; j<si->num_lambdas; j++)
% 	    if (si->lambdas[j].corr_table != NULL)
% 		for (i=0; i<90; i++) {
% 		    swap(si->lambdas[j].corr_table->we + i,
% 			 si->lambdas[j].corr_table->we + 90);
% 		    swap(si->lambdas[j].corr_table->sn + i,
% 			 si->lambdas[j].corr_table->sn + 90);
% 		}
% }

% void get_vectors(double az, double el, weight_vector *wt)
% {
%     static double	last_az, last_el;
%     double		tmp;
% 
%     if (last_az == az && last_el == el)
% 	return;
% 
%     last_az = az;
%     last_el = el;
% 
%     wt->awt2 = modf(az/90.0, &tmp);	/* weight of 2nd direction */
%     wt->quad = (int) (tmp + 0.5);	/* quadrant of 1st direction */
%     wt->awt1 = 1.0 - wt->awt2;		/* weight of 1st direction */
% 
%     wt->ewt2 = modf(el, &tmp);		/* weight of next highest degree */
%     wt->el_deg = (int) (tmp + 0.5);	/* this degree */
%     wt->ewt1 = 1.0 - wt->ewt2;		/* weight of this degree */
% }

%     if (el_d > 89.5)
% 	return 1.0;
% 
%     get_vectors(az_d, el_d, &wt);
% 
%     switch (wt.quad) {
%     case 0:
% 	p1 = si->lambdas[channel].corr_table->sn + 90;  /* north */
% 	p2 = si->lambdas[channel].corr_table->we + 90;  /* east */
% 	break;
%     case 1:
% 	p1 = si->lambdas[channel].corr_table->we + 90;  /* east */
% 	p2 = si->lambdas[channel].corr_table->sn;        /* south */
% 	break;
%     case 2:
% 	p1 = si->lambdas[channel].corr_table->sn;        /* south */
% 	p2 = si->lambdas[channel].corr_table->we;        /* west */
% 	break;
%     case 3:
% 	p1 = si->lambdas[channel].corr_table->we;        /* west */
% 	p2 = si->lambdas[channel].corr_table->sn + 90;  /* north */
% 	break;
%     default:
% 	return -1.0;
%     }
% 
%     c1 = p1[wt.el_deg]*wt.ewt1 + p1[wt.el_deg + 1]*wt.ewt2;
%     c2 = p2[wt.el_deg]*wt.ewt1 + p2[wt.el_deg + 1]*wt.ewt2;
%     corr = c1*wt.awt1 + c2*wt.awt2;