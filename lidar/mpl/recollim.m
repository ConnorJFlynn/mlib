function mpl = recollim(mpl);
if nargin==0
   mpl = read_mpl;
end
mpl = apply_dtc_to_mpl(mpl, 'dtc_apd10101');
mpl = apply_ap_to_mpl(mpl, ap_mpl102_20050911(mpl.range));
disp(['Select a sonde file...']);
[mpl.sonde.atten_prof, mpl.sonde.tau, altitude, temperature, pressure] = get_sonde_ray_atten(mpl.range);
acid = figure; imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_20), mpl.prof(mpl.r.lte_20,:)); 
axis('xy'); axis([axis, 0, 5, 0, 5]); colormap('jet');  zoom
title(['Zoom into the desired time period for Rayleigh comparison.  Hit any key when finished...']);
xlabel('Time (Hh)');
ylabel('range (km)');

pause
v = axis;
clean_mpl = find((serial2Hh(mpl.time)>=v(1))&(serial2Hh(mpl.time)<=v(2)));
[pileA, pileB] = trimsift_nolog(mpl.range, mpl.prof(:,clean_mpl));
%[pileA, pileB] = sift_nolog(mpl.range, mpl.prof(:,clean_mpl));


clean_mpl = clean_mpl(pileA);

%Do averages...
[avg] = mpl_timeavg3(mpl,60,clean_mpl);
% Averaged: time, prof, rawcts,hk.bg, hk.detectorTemp, hk.energyMonitor;


figure; semilogy(mpl.range(mpl.r.lte_20),avg.prof(mpl.r.lte_20,avg.clean==1), '.');  
v = axis; zoom
ylabel('range (km)');
xlabel('normalized attenuated backscatter');
title(['Select an aerosol-free region for calibration.  Hit enter when done.']);
disp(['Select an aerosol-free region for calibration.  Hit enter when done.']);
pause;

zoom off;
cal_v = axis;
axis(v);
title([sprintf('Using selected region from %2.1f - %2.1f for calibration.', cal_v(3),cal_v(4))]);
mpl.r.cal = find((mpl.range>=cal_v(1))&(mpl.range<=cal_v(2)));
mpl.r.lte_cal = find((mpl.range>.1)&(mpl.range<mpl.range(max(mpl.r.cal))));
mpl.cal.atten_ray = mean(mpl.sonde.atten_prof(mpl.r.cal));
mpl.cal.mean_prof = mean(mpl.prof(mpl.r.cal,:));
mpl.cal.lowess_mean_prof(clean_mpl) = lowess(serial2doy0(mpl.time(clean_mpl))-floor(serial2doy0(mpl.time((clean_mpl(1))))), mpl.cal.mean_prof(clean_mpl), .02)';
%mpl.cal.C(non_missing) = mpl.cal.lowess_mean_prof(non_missing) ./ (mpl.cal.atten_ray .* exp(-2*mpl.mfr.aod_523(non_missing))); 

mpl.cal.invC = mean(avg.prof(mpl.r.cal,:)) / mean(mpl.sonde.atten_prof(mpl.r.cal));
mpl.cal.invC = 1./mpl.cal.invC;
for t = (find(avg.clean==1))
  avg.prof(:,t) = avg.prof(:,t) * mpl.cal.invC(t);
end;
mpl.avg = avg;
semilogy(mpl.range(mpl.r.lte_20),mpl.avg.prof(mpl.r.lte_20,mpl.avg.clean==1), '.',  mpl.range(mpl.r.lte_20),mpl.sonde.atten_prof(mpl.r.lte_20),'r');  
zoom
ylabel('range (km)');
xlabel('normalized attenuated backscatter');
title([sprintf('Using selected region from %2.1f - %2.1f for calibration.', cal_v(1),cal_v(2))]);



%%
mpl.prof = (mpl.rawcts - (ones(size(mpl.range))*mpl.hk.bg)).*((mpl.range.^2)*ones(size(mpl.time)));
mpl.statics.overlap.applied = 'no';
K = 1.1;
mpl = apply_ol_to_mpl(mpl,ol_horiz_mpl4b_102_20050911(mpl.range).^K);

%%
mpl_acid_test(mpl);    