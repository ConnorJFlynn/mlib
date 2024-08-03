function blah
% Checking DMF-processed MAO M1 and S1 PSAP data against each other
% bnl_infile = getfullname('F:\AOS\mao\maoaospsap3wS1.01\*.tsv','psap02');
% % grab the date out of the filename to use for selecting other data
% % Because the filename pattern changes over the duration, I flip the
% % filename left-to-right and pick off the date near the end using strtok
% % since this appears robust.
% [~,fname, ext] = fileparts(bnl_infile);
% emanf = fliplr(fname); [~,emanf] = strtok(emanf,'.');[~,emanf] = strtok(emanf,'.');
% [etad,emanf] = strtok(emanf,'.'); d_str = fliplr(etad);
% ym = d_str(1:6);
% % ym = datestr(bnl_01.time(1),'yyyymm');
% 
% 
% % load NOAA edited 01 files
% n_files = getfullname(['*psap3wM1.00.',ym,'*.edit.asc'],'NOAA_edited_psap','Select an NOAA edited PSAP file.');
% for nn = 1:length(n_files)
%    noaa = rd_noaa_psap_edited(n_files{nn});
%    if ~exist('noaa_01','var')
%       noaa_01 = noaa;
%    else
%       noaa_01 = cat_timeseries(noaa, noaa_01);
%    end
% end

% load ARM M1 files
M1_1m = anc_bundle_files(getfullname(['maoaospsap3w1mM1.b1.*.nc'],'psap1mM1','Select psapM1 1m gridded files.'));
M1_Ba_B_qa = anc_qc_impacts(M1_1m.vdata.qc_Ba_B_Weiss, M1_1m.vatts.qc_Ba_B_Weiss);
M1_good = anc_sift(M1_1m, M1_Ba_B_qa==0);
M1_good_1um = anc_sift(M1_good,M1_good.vdata.impactor_state==1);
M1_good_10um = anc_sift(M1_good,M1_good.vdata.impactor_state==10);

ym = datestr(M1_1m.time(1),'yyyymm');

% % load ARM S1 files
% S1_1s = anc_bundle_files(getfullname(['maoaospsap3w1sS1.b1.',ym,'*.nc'],'psap1s','Select psap 1s gridded files'));
% S1_Ba_B_qa = anc_qc_impacts(S1_1s.vdata.qc_Ba_B_Weiss, S1_1s.vatts.qc_Ba_B_Weiss);
% S1_good = anc_sift(S1_1s, S1_Ba_B_qa==0);
% S1_good_1um = anc_sift(S1_good,S1_good.vdata.impactor_state==1);
% S1_good_10um = anc_sift(S1_good,S1_good.vdata.impactor_state==10);

% load ARM S1 files
S1_1m = anc_bundle_files(getfullname(['maoaospsap3w1mS1.b1.',ym,'*.nc'],'psap1mS1','Select psap 1m gridded files'));
S1_Ba_B_qa = anc_qc_impacts(S1_1m.vdata.qc_Ba_B_Weiss, S1_1m.vatts.qc_Ba_B_Weiss);
S1_good = anc_sift(S1_1m, S1_Ba_B_qa==0);
S1_good_1um = anc_sift(S1_good,S1_good.vdata.impactor_state==1);
S1_good_10um = anc_sift(S1_good,S1_good.vdata.impactor_state==10);

% Now, finally, load the 1-month BNL 01 edited file.
% I read this last just because it is large and I didn't want to sit around
% waiting for it every time as I worked on the rest of the code above.
% bnl_01 = rd_bnl_tsv3(bnl_infile, '%s %f %f %f %f %f %f %f ');



figure; plot(S1_good_1um.time, S1_good_1um.vdata.Ba_B_Weiss, '.', ...
   S1_good_10um.time, S1_good_10um.vdata.Ba_B_Weiss, '+'); ax(1) = gca;
legend('1 um','10 um'); dynamicDateTicks;
title(['S1 PSAP for ',datestr(S1_good.time(1),'yyyy-mm-dd'), ' thru ',datestr(S1_good.time(end),'yyyy-mm-dd')]);


figure; plot(M1_good_1um.time, M1_good_1um.vdata.Ba_B_Weiss, '.', ...
   M1_good_10um.time, M1_good_10um.vdata.Ba_B_Weiss, 'x'); ax(2) = gca;
legend('1 um','10 um'); dynamicDateTicks
title(['M1 PSAP for ',datestr(M1_1m.time(1),'yyyy-mm-dd'), ' thru ',datestr(M1_1m.time(end),'yyyy-mm-dd')]);
linkaxes(ax,'xy')

[sinm_10,mins_10] = nearest(S1_good_10um.time, M1_good_10um.time);
[sinm_1,mins_1] = nearest(S1_good_1um.time, M1_good_1um.time);


figure; plot(S1_good_10um.time(sinm_10), S1_good_10um.vdata.Ba_B_Weiss(sinm_10), 'o', ...
   M1_good_10um.time(mins_10), M1_good_10um.vdata.Ba_B_Weiss(mins_10), 'd'); ax(1) = gca;
legend('S1','M1'); dynamicDateTicks;
title(['PSAP for 10um size cut ',datestr(S1_good.time(1),'yyyy-mm-dd'), ' thru ',datestr(S1_good.time(end),'yyyy-mm-dd')]);


figure; plot(S1_good_1um.time(sinm_1), S1_good_1um.vdata.Ba_B_Weiss(sinm_1), '.',...
   M1_good_1um.time(mins_1), M1_good_1um.vdata.Ba_B_Weiss(mins_1), '.'); ax(2) = gca;
legend('S1','M1'); dynamicDateTicks
title(['PSAP for 1 um size cut',datestr(M1_1m.time(1),'yyyy-mm-dd'), ' thru ',datestr(M1_1m.time(end),'yyyy-mm-dd')]);
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