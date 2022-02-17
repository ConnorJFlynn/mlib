%  Notes...  Three comparison days.  The second two are best due to
%  synchronous filter changes. 

%First load files, then select analysis interval, filter for selection,
%define nan_mask, maybe [ainb, bina] = nearest(psap_aaf, psap_b1

%  Significant questions: going from _raw to _Weiss, how can the agreement
%  change so much while filter is relatively new?  Differences in
%  correction should be small, not factor of 2.

%  Duplicate _WBO correction from filter trans and reproduce Ba_*_WBO from  Ba_raw
%  Isolate just 10 um mode.

% Plot Tr
% Plot Ba_raw Do we need to confirm this too? No. Irrelevant regarding 2nd part
% Plot Ba_WBO
% Plot fr_WBO
clear;

psapi = cat_struct(rd_psapi_gd_cor,cat_struct(rd_psapi_gd_cor, rd_psapi_gd_cor));
[~,IA] = unique(psapi.time); keep = false(size(psapi.time)); keep(IA) = true;
[psapi, psapi_] = cut_struct(psapi, keep);
[psapo] = proc_psapi_gd_cor(psapi);
figure; plot(psapi.time, psapi.Ba_B,'r.'); legend('psapi Ba_F_P'); dynamicDateTicks

psap_b1 = anc_bundle_files(getfullname('sgpaospsap*.nc','sgppsap'));

%zoom into select filter period
NaNs =max([anc_qc_impacts(psap_b1.vdata.qc_Ba_B_Weiss, psap_b1.vatts.qc_Ba_B_Weiss);...
    anc_qc_impacts(psap_b1.vdata.qc_Ba_G_Weiss, psap_b1.vatts.qc_Ba_G_Weiss);...
    anc_qc_impacts(psap_b1.vdata.qc_Ba_R_Weiss, psap_b1.vatts.qc_Ba_R_Weiss)])>1;
NaNs = NaNs | psap_b1.vdata.impactor_state<9 | psap_b1.vdata.Ba_B_Weiss<-9 | psap_b1.vdata.Ba_G_Weiss<-9 | psap_b1.vdata.Ba_R_Weiss<-9;
xnani = find(~NaNs);
xx = zeros(size(NaNs)); xx(NaNs) = NaN;

figure; plot(psap_b1.time, repmat(xx,[3,1])+[psap_b1.vdata.Ba_B_Weiss;psap_b1.vdata.Ba_G_Weiss;psap_b1.vdata.Ba_R_Weiss],'.'); dynamicDateTicks
figure; plot(psap_b1.time(~NaNs), psap_b1.vdata.transmittance_blue(~NaNs),'.'); dynamicDateTicks
hold('on'); plot(psapi.time, [psapi.Tr_B],'k.'); 
figure; plot(psap_b1.time(~NaNs), psap_b1.vdata.Ba_B_Weiss(~NaNs),'.'); dynamicDateTicks
hold('on'); plot(psapi.time, [psapi.Ba_B],'k.'); 


% [ainb, bina] = nearest(psapi.time, psap_b1.time(~NaNs));
[ainb, bina] = nearest(psapo.time, psap_b1.time(~NaNs));
figure; plot(psap_b1.time(xnani(bina)), repmat(xx(xnani(bina)),[3,1])+...
    [psap_b1.vdata.Ba_B_Weiss(xnani(bina));psap_b1.vdata.Ba_G_Weiss(xnani(bina));psap_b1.vdata.Ba_R_Weiss(xnani(bina))],'.'); dynamicDateTicks
hold('on'); plot(psapo.time(ainb), [psapo.Ba_B_sm_WBO(ainb),psapo.Ba_G_sm_WBO(ainb),psapo.Ba_R_sm_WBO(ainb)],'k.'); 

figure; 
ax(1) = subplot(3,1,1);
plot(psap_b1.time, [psap_b1.vdata.transmittance_blue],'b-',psapo.time, psapo.trans_B_sm,'k-');
ax(2) = subplot(3,1,2);
plot(psap_b1.time(xnani(bina)), xx(xnani(bina))+ psap_b1.vdata.Ba_B_raw(xnani(bina)),'.',psapo.time(ainb), [psapo.Ba_B_sm(ainb)],'k.'); 
dynamicDateTicks;    legend('SGP E13 b1','AAF')
ax(3) = subplot(3,1,3);
plot(psap_b1.time(xnani(bina)), xx(xnani(bina))+ psap_b1.vdata.Ba_B_Weiss(xnani(bina)),'.',psapo.time(ainb), [psapo.Ba_B_sm_WBO(ainb)],'k.'); 
dynamicDateTicks;
linkaxes(ax,'x'); ylim(ax(1),[0,1.1]); ylim(ax(2),[0,20]);ylim(ax(3),[0,10]);

 

mn = menu('Zoom to select...', 'ok')
xl = xlim
psap_AAF = cut_struct(psapi,psapi.time>=xl(1)&psapi.time<=xl(2));
psap_b1_ = anc_sift(psap_b1, psap_b1.time>=xl(1)&psap_b1.time<=xl(2));
figure; plot(psap_AAF.time, psap_AAF.mass_flow_mv, '.');
figure; plot(psap_AAF.time, [psap_AAF.Ba_B, psap_AAF.Ba_G, psap_AAF.Ba_R],'-'); dynamicDateTicks; title('ARM AAF PSAP Front-Panel Ba')



figure; plot(psapi_15.time, [psapi_15.Ba_B,psapi_15.Ba_G,psapi_15.Ba_R],'-'); dynamicDateTicks; hold('on')
 plot(psapi_16.time, [psapi_16.Ba_B,psapi_16.Ba_G,psapi_16.Ba_R],'-'); dynamicDateTicks
 
 
 [psapo] = proc_psapi_gd_cor(psapi, spot_area, flow_cal)
 
 
 % Now plot raw bnl
 raw_fnames = getfullname_('*psap3w.*.tsv','bnl_psap');
 psap = read_psap3w_bnl(raw_fnames{1});
 for r = 2:length(raw_fnames);
     psap_ = read_psap3w_bnl(raw_fnames{r});
     psap = cat_struct(psap, psap_);
 end
 
 
 figure; plot(psap_AAF.time, [psap_AAF.Tr_B,psap_AAF.Tr_G,psap_AAF.Tr_R],'-', psap.time, [psap.Tr_blu,psap.Tr_grn,psap.Tr_red],'-.'); 
 dynamicDateTicks; title('ARM SGP PSAP Tr')
 legend('AAF Tr_B','AAF Tr_G','AAF Tr_G','SGP Tr_B','SGP Tr_G','SGP Tr_R')
  figure; plot(psap.time, [psap.Bap_blu,psap.Bap_grn,psap.Bap_red],'-'); dynamicDateTicks; title('ARM SGP PSAP Ba')
 figure; plot(psap.time, [psap.flow_mv],'-'); dynamicDateTicks; title('ARM SGP PSAP Flow'); 
  figure; plot(psap.time, [psap.dil_flow_setpt],'-'); dynamicDateTicks; title('ARM SGP PSAP DilFlow'); 
  
  linkexes