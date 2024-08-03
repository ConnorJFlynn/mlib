function blah
% Checking MAO BNL mentor-edited PSAP data against our gridded product
bnl_infile = getfullname('F:\AOS\mao\maoaospsap3wS1.01\*.tsv','psap02');
% grab the date out of the filename to use for selecting other data
% Because the filename pattern changes over the duration, I flip the
% filename left-to-right and pick off the date near the end using strtok
% since this appears robust.
[~,fname, ext] = fileparts(bnl_infile);
emanf = fliplr(fname); [~,emanf] = strtok(emanf,'.');[~,emanf] = strtok(emanf,'.');
[etad,emanf] = strtok(emanf,'.'); d_str = fliplr(etad);
ym = d_str(1:6);
% ym = datestr(bnl_01.time(1),'yyyymm');


% load NOAA edited 01 files
% n_files = getfullname(['*psap3wM1.00.',ym,'*.edit.asc'],'NOAA_edited_psap','Select an NOAA edited PSAP file.');
% for nn = 1:length(n_files)
%    noaa = rd_noaa_psap_edited(n_files{nn});
%    if ~exist('noaa_01','var')
%       noaa_01 = noaa;
%    else
%       noaa_01 = cat_timeseries(noaa, noaa_01);
%    end
% end
% 
% % load ARM M1 files
% M1_1m = anc_bundle_files(getfullname(['maoaospsap3w1mM1.b1.',ym,'*.nc'],'psap1mM1','Select psapM1 1m gridded files.'));
% M1_Ba_B_qa = anc_qc_impacts(M1_1m.vdata.qc_Ba_B_Weiss, M1_1m.vatts.qc_Ba_B_Weiss);
% M1_good = anc_sift(M1_1m, M1_Ba_B_qa==0);
% M1_good_1um = anc_sift(M1_good,M1_good.vdata.impactor_state==1);
% M1_good_10um = anc_sift(M1_good,M1_good.vdata.impactor_state==10);

% % load ARM S1 files
S1_1s = anc_bundle_files(getfullname(['maoaospsap3w1sS1.b1.',ym,'*.nc'],'psap1s','Select psap 1s gridded files'));
S1_Ba_B_qa = anc_qc_impacts(S1_1s.vdata.qc_Ba_B_Weiss, S1_1s.vatts.qc_Ba_B_Weiss);
S1_good = anc_sift(S1_1s, S1_Ba_B_qa==0);
S1_good_1um = anc_sift(S1_good,S1_good.vdata.impactor_state==1);
S1_good_10um = anc_sift(S1_good,S1_good.vdata.impactor_state==10);
S1_sus = anc_sift(S1_1s, S1_Ba_B_qa==1);
S1_sus_1um = anc_sift(S1_sus,S1_sus.vdata.impactor_state==1);
S1_sus_10um = anc_sift(S1_sus,S1_sus.vdata.impactor_state==10);


% load ARM S1 files
% S1_1m = anc_bundle_files(getfullname(['maoaospsap3w1mS1.b1.',ym,'*.nc'],'psap1mS1','Select psap 1m gridded files'));
% S1_Ba_B_qa = anc_qc_impacts(S1_1m.vdata.qc_Ba_B_Weiss, S1_1m.vatts.qc_Ba_B_Weiss);
% S1_good = anc_sift(S1_1m, S1_Ba_B_qa==0);
% S1_good_1um = anc_sift(S1_good,S1_good.vdata.impactor_state==1);
% S1_good_10um = anc_sift(S1_good,S1_good.vdata.impactor_state==10);

% Now, finally, load the 1-month BNL 01 edited file.
% I read this last just because it is large and I didn't want to sit around
% waiting for it every time as I worked on the rest of the code above.
[~,bin,ex] = fileparts(bnl_infile);
disp(['Now reading ',bin,ex])
bnl_01 = rd_bnl_tsv3(bnl_infile, '%s %f %f %f %f %f %f %f ');

figure; plot(bnl_01.time-1./(24.*60), bnl_01.BlueAbs./1.031, 'k+', S1_1s.time, S1_1s.vdata.Ba_B_Weiss,'.');

S1_b1 = anc_bundle_files;
figure; plot(bnl_01.time, bnl_01.BlueAbs,'-g.', S1_1s.time, S1_1s.vdata.Ba_B_Weiss,'r.'); dynamicDateTicks;

figure; plot(bnl_01.time, bnl_01.BlueTransmittance,'-g.', S1_1s.time, ...
   S1_1s.vdata.transmittance_blue,'-r.', ...
   S1_b1.time, S1_b1.vdata.transmittance_blue, 'ko'); dynamicDateTicks;;
legend('bnl','dmf 1s','dmf b1')
title('Blue transmittance');


figure; plot(bnl_01.time, bnl_01.InstrumentFlow,'-g.', ...
   S1_1s.time, S1_1s.vdata.sample_flow_rate,'-r.', ...
   S1_b1.time, S1_b1.vdata.sample_flow_rate,'ko'); dynamicDateTicks;
legend('bnl','dmf 1s','dmf b1')
title('Sample flow rate');

figure; plot(bnl_01.time, bnl_01.BlueAbs,'-g.', S1_1s.time, ...
   S1_1s.vdata.Ba_B_Weiss,'-r.'); dynamicDateTicks;;
legend('bnl','dmf 1s')
title('Blue absorption');




figure; plot(bnl_01.time-1./(24.*60), bnl_01.BlueAbs./1.031, 'k+', ...
   S1_good_1um.time, S1_good_1um.vdata.Ba_B_Weiss, 'b.',...
   S1_good_10um.time, S1_good_10um.vdata.Ba_B_Weiss, 'r.',...
   S1_sus_1um.time, S1_sus_1um.vdata.Ba_B_Weiss, 'c.',...
   S1_sus_10um.time, S1_sus_10um.vdata.Ba_B_Weiss, 'm.'); ax(1) = gca;
legend('BNL','DMF 1um','DMF 10um','DMF 1um suspect','DMF 10 um suspect'); dynamicDateTicks;
title(['S1 PSAP for ',datestr(S1_good.time(1),'yyyy-mm-dd'), ' thru ',datestr(S1_good.time(end),'yyyy-mm-dd')]);

nephdry = anc_bundle_subsample(getfullname('maoneph*.*','nephdry'),10);
good_neph = nephdry.vdata.P_Neph_Dry>900 & nephdry.vdata.P_Neph_Dry<1100;
met = anc_bundle_subsample(getfullname('maomet*.*', 'aosmet'),10);
good_P = met.vdata.P_Ambient>900 & met.vdata.P_Ambient< 1100;
nephdry.vdata.P(good_neph) = interp1(met.time(good_P), met.vdata.P_Ambient(good_P), nephdry.time(good_neph), 'nearest');
figure; plot(nephdry.time(good_neph), nephdry.vdata.P(good_neph) - nephdry.vdata.P_Neph_Dry(good_neph),'o-'); legend('P - Pneph')
dynamicDateTicks



ARM_display;
% 
% figure; plot(S1_good_1um.time, S1_good_1um.vdata.Ba_B_Weiss, '.', ...
%    S1_good_10um.time, S1_good_10um.vdata.Ba_B_Weiss, '+'); ax(1) = gca;
% legend('1 um','10 um'); dynamicDateTicks;
% title(['S1 PSAP for ',datestr(S1_good.time(1),'yyyy-mm-dd'), ' thru ',datestr(S1_good.time(end),'yyyy-mm-dd')]);


figure; plot(M1_good_1um.time, M1_good_1um.vdata.Ba_B_Weiss, '.', ...
   M1_good_10um.time, M1_good_10um.vdata.Ba_B_Weiss, 'x'); ax(2) = gca;
legend('1 um','10 um'); dynamicDateTicks
title(['M1 PSAP for ',datestr(M1_1m.time(1),'yyyy-mm-dd'), ' thru ',datestr(M1_1m.time(end),'yyyy-mm-dd')]);
linkaxes(ax,'xy')

done = false;
[sinm_10,mins_10] = nearest(S1_good_10um.time, M1_good_10um.time);
F10 = figure;zoom('on')
V10 = datevec(S1_good_10um.time(sinm_10)); days = V10(:,3)+V10(:,4)./24;
while ~done
   figure(F10); plot(S1_good_10um.vdata.Ba_B_Weiss(sinm_10), M1_good_10um.vdata.Ba_B_Weiss(mins_10),'ko','markersize',8);hold('on');
   scatter(S1_good_10um.vdata.Ba_B_Weiss(sinm_10), M1_good_10um.vdata.Ba_B_Weiss(mins_10),40,days, 'filled');
   legend('Ba_B 10 um');
   xlabel('S1'); ylabel('M1');
   title(datestr(S1_good_10um.time(1),'yyyy-mm-dd'));
   hold('on');zoom('on')
   m_10 = menu('Select "OK" when done zooming','OK');
   v10 = axis;
   figure(F10);
   v10_ = S1_good_10um.vdata.Ba_B_Weiss(sinm_10)>v10(1) & ...
      S1_good_10um.vdata.Ba_B_Weiss(sinm_10)<v10(2) & ...
      M1_good_10um.vdata.Ba_B_Weiss(mins_10)>v10(3) & ...
      M1_good_10um.vdata.Ba_B_Weiss(mins_10)<v10(4) ;
   [P10,S10] = polyfit(S1_good_10um.vdata.Ba_B_Weiss(sinm_10(v10_)), M1_good_10um.vdata.Ba_B_Weiss(mins_10(v10_)),1);
   [P10_,S10_] = polyfit(M1_good_10um.vdata.Ba_B_Weiss(mins_10(v10_)),S1_good_10um.vdata.Ba_B_Weiss(sinm_10(v10_)),1);
   
   P10_bar(1) = (P10(1) + 1./P10_(1))./2;P10_bar(2) = (P10(2) - P10_(2))./2;
   stats10 = fit_stat(S1_good_10um.vdata.Ba_B_Weiss(sinm_10(v10_)), M1_good_10um.vdata.Ba_B_Weiss(mins_10(v10_)),P10_bar,S10);
   txt10 = {['N pts= ', num2str(stats10.N)],...
      ['slope = ',sprintf('%1.3f',P10_bar(1))]};
   
   lims10 = [min(v10),max(v10)];
   plot(lims10, lims10, 'k--',lims10, polyval(P10_bar,lims10),'r-');
   gt10 = gtext(txt10); set(gt10,'backgroundColor','w','color','r');
   
   hold('off')
   if menu('Select DONE when satisfied with the fit','Repeat', 'Done')==2
      done = true;
   end
end


[sinm_1,mins_1] = nearest(S1_good_1um.time, M1_good_1um.time);
V1 = datevec(S1_good_1um.time(sinm_1)); days = V1(:,3)+V1(:,4)./24;
F1 = figure;zoom('on')
done = false;
while ~done
   figure(F1);
%    plot(S1_good_1um.vdata.Ba_B_Weiss(sinm_1), M1_good_1um.vdata.Ba_B_Weiss(mins_1), 'o')
   plot(S1_good_1um.vdata.Ba_B_Weiss(sinm_1), M1_good_1um.vdata.Ba_B_Weiss(mins_1),'ko','markersize',8);hold('on');
   scatter(S1_good_1um.vdata.Ba_B_Weiss(sinm_1), M1_good_1um.vdata.Ba_B_Weiss(mins_1),40,days, 'filled');
   legend('Ba_B 1 um');
   xlabel('S1'); ylabel('M1');
   title(datestr(S1_good_10um.time(1),'yyyy-mm-dd'));
   hold('on');zoom('on');
   m_1 = menu('Select "OK" when done zooming','OK'); 
   v1 = axis;
   figure(F1);
   v1_ = S1_good_1um.vdata.Ba_B_Weiss(sinm_1)>v1(1) & ...
      S1_good_1um.vdata.Ba_B_Weiss(sinm_1)<v1(2) & ...
      M1_good_1um.vdata.Ba_B_Weiss(mins_1)>v1(3) & ...
      M1_good_1um.vdata.Ba_B_Weiss(mins_1)<v1(4) ;
   [P1,S1] = polyfit(S1_good_1um.vdata.Ba_B_Weiss(sinm_1(v1_)), M1_good_1um.vdata.Ba_B_Weiss(mins_1(v1_)),1);
   [P1_,S1_] = polyfit(M1_good_1um.vdata.Ba_B_Weiss(mins_1(v1_)),S1_good_1um.vdata.Ba_B_Weiss(sinm_1(v1_)), 1);
   P1_bar(1) = (P1(1) + 1./P1_(1))./2;P1_bar(2) = (P1(2) - P1_(2))./2;
   stats1 = fit_stat(S1_good_1um.vdata.Ba_B_Weiss(sinm_1(v1_)), M1_good_1um.vdata.Ba_B_Weiss(mins_1(v1_)),P1_bar,S1);
   txt1 = {['N pts= ', num2str(stats1.N)],...
      ['slope = ',sprintf('%1.3f',P1_bar(1))]};
   
   lims1 = [min(v1),max(v1)];
   plot(lims1, lims1, 'k--',lims1, polyval(P1_bar,lims1),'r-');
   gt1 = gtext(txt1); set(gt1,'backgroundColor','w','color','r');
   
   hold('off');
   if menu('Select DONE when satisfied with the fit','Repeat', 'Done')==2
      done = true;
   end
end

return