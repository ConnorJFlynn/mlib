mplpol = rd_Sigma;
polV = mean(mplpol.hk.pol_V1);
cop = (mplpol.hk.pol_V1<polV);
cop_ind = find(cop);
crs_ind = find(~cop);
figure; ax(1) = subplot(2,1,1); imagegap(serial2Hh(mplpol.time(cop)), mplpol.range(mplpol.r.lte_20), real(log10(mplpol.rawcts(mplpol.r.lte_20,cop)))); colorbar;
ax(2) = subplot(2,1,2); imagegap(serial2Hh(mplpol.time(~cop)), mplpol.range(mplpol.r.lte_20), real(log10(mplpol.rawcts(mplpol.r.lte_20,~cop)))); colorbar;
linkaxes(ax,'xy')
%%
xl = xlim; ap1.min_t = xl(1);

xl = xlim; ap1.max_t = xl(2);
%%

ap1.t = (serial2Hh(mplpol.time)>=ap1.min_t)&(serial2Hh(mplpol.time)<=ap1.max_t);
%%
xl = xlim; ap2.min_t = xl(1);
%%
xl = xlim; ap2.max_t = xl(2);
ap2.t = (serial2Hh(mplpol.time)>=ap2.min_t)&(serial2Hh(mplpol.time)<=ap2.max_t);
%%
figure; semilogy(mplpol.range,mean(mplpol.rawcts(:,cop&ap1.t),2), 'r.', mplpol.range,mean(mplpol.rawcts(:,~cop&ap1.t),2), 'b.',mplpol.range,mean(mplpol.rawcts(:,cop&ap2.t),2), 'r', mplpol.range,mean(mplpol.rawcts(:,~cop&ap2.t),2), 'b')
ap.range = mplpol.range;
ap.cop = mean(mplpol.rawcts(:,cop&(ap1.t|ap2.t)),2);
ap.crs = mean(mplpol.rawcts(:,~cop&(ap1.t|ap2.t)),2);
ap.cop_snr = ap.cop ./ sqrt(ap.cop);
ap.crs_snr = ap.crs ./ sqrt(ap.crs);
bin_width = ap.range(4)-ap.range(3);
ap.cop_smooth = (ap.range>0)'.* 10.^gsmooth(ap.range, log10(ap.cop), 0.25*bin_width ./ ap.cop_snr);
ap.cop_smooth = (ap.range>0)'.* gsmooth(ap.range,(ap.cop_smooth'), 0.33*bin_width ./ ap.cop_snr);
figure; semilogy(ap.range,ap.cop, 'r.', ap.range,ap.cop_smooth, 'k')
%%
ap.crs_smooth = (ap.range>0)'.* 10.^gsmooth(ap.range, log10(ap.crs), 0.25*bin_width ./ ap.crs_snr);
ap.crs_smooth = (ap.range>0)'.* gsmooth(ap.range,(ap.crs_smooth'), 0.33*bin_width ./ ap.crs_snr);
figure; semilogy(ap.range,ap.crs, 'b.', ap.range,ap.crs_smooth, 'k');
%%
[p,f,x,v] = fileparts(mplpol.statics.fname);
ap.time = mplpol.time(1);
save([p,filesep,'afterpulse.isdac.',datestr(ap.time,'yyyy-mm-dd_HHMM'),'.dat'],'ap')

%%
%%
figure; semilogy(mplpol.range,mean(mplpol.rawcts(:,cop&ap1.t),2), 'r.', mplpol.range,mean(mplpol.rawcts(:,~cop&ap1.t),2), 'b.')
ap.range = mplpol.range;
ap.cop = mean(mplpol.rawcts(:,cop&(ap1.t)),2);
ap.crs = mean(mplpol.rawcts(:,~cop&(ap1.t)),2);
ap.cop_snr = ap.cop ./ sqrt(ap.cop);
ap.crs_snr = ap.crs ./ sqrt(ap.crs);
bin_width = ap.range(4)-ap.range(3);
ap.cop_smooth = (ap.range>0)'.* 10.^gsmooth(ap.range, log10(ap.cop), 0.25*bin_width ./ ap.cop_snr);
ap.cop_smooth = (ap.range>0)'.* gsmooth(ap.range,(ap.cop_smooth'), 0.33*bin_width ./ ap.cop_snr);
figure; semilogy(ap.range,ap.cop, 'r.', ap.range,ap.cop_smooth, 'k')
%%
ap.crs_smooth = (ap.range>0)'.* 10.^gsmooth(ap.range, log10(ap.crs), 0.25*bin_width ./ ap.crs_snr);
ap.crs_smooth = (ap.range>0)'.* gsmooth(ap.range,(ap.crs_smooth'), 0.33*bin_width ./ ap.crs_snr);
figure; semilogy(ap.range,ap.crs, 'b.', ap.range,ap.crs_smooth, 'k');
%%
[p,f,x,v] = fileparts(mplpol.statics.fname);
ap.time = mplpol.time(1);
%%
save([p,filesep,'afterpulse.isdac.',datestr(ap.time,'yyyy-mm-dd_HHMM'),'.dat'],'ap')

