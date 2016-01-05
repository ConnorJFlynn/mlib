function blah
% Checking MAO BNL mentor-edited PSAP data against our gridded product
% bnl_infile = getfullname('F:\AOS\mao\maoaospsap3wS1.01\*.tsv','psap02');
% % grab the date out of the filename to use for selecting other data
% % Because the filename pattern changes over the duration, I flip the
% % filename left-to-right and pick off the date near the end using strtok
% % since this appears robust.
% [~,fname, ext] = fileparts(bnl_infile);
% emanf = fliplr(fname); [~,emanf] = strtok(emanf,'.');[~,emanf] = strtok(emanf,'.');
% [etad,emanf] = strtok(emanf,'.'); d_str = fliplr(etad);
% ym = d_str(1:6);
% ym = datestr(bnl_01.time(1),'yyyymm');


% load NOAA edited 01 files
n_files = getfullname(['*psap3wM1.00.*.edit.asc'],'NOAA_edited_psap','Select an NOAA edited PSAP file.');
for nn = 1:length(n_files)
   noaa = rd_noaa_psap_edited(n_files{nn});
   if ~exist('noaa_01','var')
      noaa_01 = noaa;
   else
      noaa_01 = cat_timeseries(noaa, noaa_01);
   end
end
ym = datestr(noaa_01.time(1),'yyyymm');
% load ARM M1 files
M1_1m = anc_bundle_files(getfullname(['maoaospsap3w1mM1.b1.',ym,'*.nc'],'psap1mM1','Select psapM1 1m gridded files.'));
M1_Ba_B_qa = anc_qc_impacts(M1_1m.vdata.qc_Ba_B_Weiss, M1_1m.vatts.qc_Ba_B_Weiss);
M1_good = anc_sift(M1_1m, M1_Ba_B_qa<2);
M1_good_1um = anc_sift(M1_good,M1_good.vdata.impactor_state==1);
M1_good_10um = anc_sift(M1_good,M1_good.vdata.impactor_state==10);

M1_neph = anc_bundle_files(getfullname(['maoaosnephdry1mM1.b1.',ym,'*.nc'],'neph1mM1','Select nephM1 1m gridded files.'));
M1_neph_qa = anc_qc_impacts(M1_neph.vdata.qc_Bs_B_Dry_Neph3W, M1_neph.vatts.qc_Bs_B_Dry_Neph3W);
M1_good_neph = anc_sift(M1_neph, M1_neph_qa==0);

neph_B = interp1(M1_good_neph.time, M1_good_neph.vdata.Bs_B_Dry_Neph3W_raw,M1_good.time,'nearest');
neph_G = interp1(M1_good_neph.time, M1_good_neph.vdata.Bs_G_Dry_Neph3W_raw,M1_good.time,'nearest');
neph_R = interp1(M1_good_neph.time, M1_good_neph.vdata.Bs_R_Dry_Neph3W_raw,M1_good.time,'nearest');
Bs_ang_GR = ang_exp(neph_R, neph_G,sscanf(M1_neph.vatts.Bs_R_Dry_Neph3W.measured_wavelength,'%f'),sscanf(M1_neph.vatts.Bs_G_Dry_Neph3W.measured_wavelength,'%f'));

Bs_ang = ang_exp( neph_G,neph_B,sscanf(M1_neph.vatts.Bs_G_Dry_Neph3W.measured_wavelength,'%f'),sscanf(M1_neph.vatts.Bs_B_Dry_Neph3W.measured_wavelength,'%f'));
near_neph = ang_coef(neph_B, Bs_ang, sscanf(M1_neph.vatts.Bs_B_Dry_Neph3W.measured_wavelength,'%f'),sscanf(M1_1m.vatts.Ba_B_Weiss.measured_wavelength,'%f'));



K1 = 0.02; K2 = 1.22;
K1 = 0.02.*ones(size(near_neph))
K1(M1_good.vdata.impactor_state==10 & Bs_ang_GR<=0.2) = 0.00668;
K1(M1_good.vdata.impactor_state==10 & Bs_ang_GR>=0.2) = 0.0334.*Bs_ang_GR(M1_good.vdata.impactor_state==10 & Bs_ang_GR>=0.2);
K1(M1_good.vdata.impactor_state==10 & Bs_ang_GR>0.6) = 0.02;

scat_sub = (K1./K2).*near_neph;
% Angstrom exponent dependent k1 from NOAA for 10 micron particles only
% K1 = 0.02 ; AngGR > 0.6
% K1 = 0.0334*AngGR ; 0.2<AngGR<0.6
% K1= 0.00668; AngGR < 0.2

% Need to really look at this to see if we can get a better match to NOAA
figure; plot(M1_good.time, M1_good.vdata.Ba_B_Weiss - scat_sub,'rx', ....
   noaa_01.time +0.5./(24.*60), noaa_01.Ba_B,'b+');
legend('Bond99','NOAA')
title(['M1 PSAP for ',datestr(M1_good.time(1),'yyyy-mm-dd'), ' thru ',datestr(M1_good.time(end),'yyyy-mm-dd')]);
dynamicDateTicks

% [dinn,nind] = nearest(M1_1m.time, noaa_01.time +0.5./(24.*60));
% figure; plot(M1_1m.time(dinn), ...
%    M1_1m.vdata.Ba_B_Weiss(dinn) - (K1./K2).*near_neph(dinn),'rx', noaa_01.time(nind) +0.5./(24.*60), noaa_01.Ba_B(nind),'b+');
% legend('Bond99','NOAA')
% title(['Nearest M1 PSAP for ',datestr(M1_1m.time(1),'yyyy-mm-dd'), ' thru ',datestr(M1_1m.time(end),'yyyy-mm-dd')]);
% dynamicDateTicks




return