function ch = corr_channel_v2(ch, corrs)
% ch = corr_channel(ch, corrs)
% channel ch contains time, th, dif, dh, zen_angle, az_angle, and lat
% corrs contains 
%  .det_corrs with sens, offset, gain
%  .cos_corrs with .bench_angle, .SN{ch}, and .WE{ch} with ch=[1:7]
%   and .zenith_angle, .N{ch}, .E{ch}, S{ch}, and W{ch} with ch=[1:7]
%  .trace with lots of fields
% angle_corrs contains bench angle with SN and WE corrections
%  Modified from 20060319 version by breaking cos corr into cardinal
%  directions and also accounting for reversal with lat<0
%  Not sure if the total horizontal is proper.  Might need to
%  reconstruct it as th = dif + cos_sza * cordn.
%  I'll wait till I have the diffuse cosine corrections to do this...
%  20060424 Modified to split cosine correction into own function to
%  prepare for diffuse correction
%

det_sens = corrs.det_sens;
offset = corrs.offset_cts;
gain = corrs.logger_gain;
ch.th(ch.sundown) = NaN;
ch.dirhor(ch.sundown) = NaN;
th = ch.th;
dirhor = ch.dirhor;

%Applying the following lines (with det_sens and gain) replicates previous
%mfrsr b1 data level, except for the correction to cordn (no offset
%subtraction to direct beam)
% th = (th - offset*gain)/(det_sens*gain);
% dif = (dif - offset*gain)/(det_sens*gain); 
% cordn = dn / (det_sens*gain);

%Applying the following lines (without det_sens) preserves measured units
%of counts / mV but properly removes offset from diffuse measurements
ch.th = (ch.th - offset);
ch.dif = (ch.th - ch.dirhor); 

ch.diffuse_correction = 1./corrs.dif_corr; %because I prefer multiplying corrections
ch.cordif = ch.dif * ch.diffuse_correction;
ch.cos_corr = cos_correction(corrs.cos_corr, ch.az_angle, ch.zen_angle)';
ch.cos_corr(ch.sundown) = NaN;
ch.cordirhor = ch.dirhor .* ch.cos_corr;
ch.corth = ch.cordirhor + ch.cordif;
ch.dif2dirhor = NaN(size(ch.cordif));
pos = ch.cordirhor>0;
ch.dif2dirhor(pos) = ch.cordif(pos)./ch.cordirhor(pos);
ch.cordirnorm = ch.cordirhor ./ cos(ch.zen_angle*pi/180);
ch.cordirnorm(ch.sundown) = NaN;

