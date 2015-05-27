function cos_corr = cos_correction(angle_corrs, az, zen);
%cos_corr = cos_correction(angle_corrs, az, zen, lat)
%channel ch contains time, th, dif, dh, zen_angle, az_angle, and lat
%angle_corrs contains bench angle with SN and WE corrections (flipped
%if in southern hemisphere) and broken into cardinal directions
% N,S,E,W
% Modified from 20060319 version by breaking cos corr into cardinal
% directions and also accounting for reversal with lat<0
% Not sure if the total horizontal is proper.  Might need to
% reconstruct it as th = dif + cos_sza * cordn.
% I'll wait till I have the diffuse cosine corrections to do this...

% 
% 
% %Breaking SN and WE into 4 ordinate directions vs elevation angle.
% N.angle = [0:90];
% N.corr = angle_corrs.SN(181:-1:91);
% S.angle = [0:90];
% S.corr = angle_corrs.SN(1:91);
% W.angle = [0:90];
% W.corr = angle_corrs.WE(1:91);
% E.angle = [0:90];
% E.corr = angle_corrs.WE(181:-1:91);

N_cor = interp1(angle_corrs.zenith_angle, angle_corrs.N, 90-zen);
E_cor = interp1(angle_corrs.zenith_angle, angle_corrs.E, 90-zen);
S_cor = interp1(angle_corrs.zenith_angle, angle_corrs.S, 90-zen);
W_cor = interp1(angle_corrs.zenith_angle, angle_corrs.W, 90-zen);

%  disp('NE quadrant');
Q1 = find(az>=0 & az<90);
if length(Q1>0)
   phi = az(Q1);
   cor_WE(Q1) = (phi/90)./E_cor(Q1);
   cor_SN(Q1) = ((90-phi)/90)./N_cor(Q1);
end

Q2 = find(az>=90 & az<180);
if length(Q2>0)
   phi = 180-az(Q2);
   cor_WE(Q2) = (phi/90)./E_cor(Q2);
   cor_SN(Q2) = ((90-phi)/90)./S_cor(Q2);
end

Q3 = find(az>=180 & az<270);
if length(Q3>0)
   phi = az(Q3)-180;
   cor_WE(Q3) = (phi/90)./W_cor(Q3);
   cor_SN(Q3) = ((90-phi)/90)./S_cor(Q3);
end

Q4 = find(az>=270 & az<360);
if length(Q4>0)
   phi = 360 - az(Q4);
   cor_WE(Q4) = (phi/90)./W_cor(Q4);
   cor_SN(Q4) = ((90-phi)/90)./N_cor(Q4);
end

cos_corr = (cor_WE + cor_SN);

