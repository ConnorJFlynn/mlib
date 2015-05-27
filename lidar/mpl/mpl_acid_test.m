function [mpl] = mpl_acid_test(mpl);
%[mpl] = mpl_acid_test;
%This function puts mpl data to the acid test of comparison with Rayleigh.
% The user is first prompted to select a time-range of interest. 
% Then, permitted to manually "sift" profiles.
% Next, averages are constructed.
% Then, the calibration region is selected.
% Finally, the profiles are pinned to a sonde-derived Rayleigh profiles.
% And finally, a polynomial fit is constructed over a selected range region
% and far-R correction determined.
if nargin<1
    mpl = mpl_con_nor;
end
%disp(['Select a sonde file...']);
%[fname, pname] = file_path('*.nc;*.cdf','sonde');
%sonde = ancload([pname, fname]);
%[mpl.sonde.atten_prof,mpl.sonde.tau, altitude, temperature, pressure] = sonde_std_atm_ray_atten(sonde, mpl.range);
[mpl.sonde.atten_prof,mpl.sonde.tau] = std_ray_atten( mpl.range);
acid = figure; imagesc(serial2Hh(mpl.time),mpl.range(mpl.r.lte_20), mpl.prof(mpl.r.lte_20,:)); 
axis('xy'); axis([axis, 0, 15, 0, 15]); colormap('jet');  zoom
title(['Zoom into the desired time period for Rayleigh comparison.  Hit any key when finished...']);
xlabel('Time (Hh)');
ylabel('range (km)');

pause
v = axis;
clean_mpl = find((serial2Hh(mpl.time)>=v(1))&(serial2Hh(mpl.time)<=v(2)));
[pileA, pileB] = trimsift_nolog(mpl.range(mpl.r.lte_20), mpl.prof(mpl.r.lte_20,clean_mpl));
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
mpl.cal.lowess_mean_prof(clean_mpl) = lowess(serial2doy(mpl.time(clean_mpl))-floor(serial2doy(mpl.time((clean_mpl(1))))), mpl.cal.mean_prof(clean_mpl), .02)';
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

