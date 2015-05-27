function sashe = proc_sashe_hisun(sashe)
% sasze = proc_sasze_hisun(sasze)
% 1.  Move Inner Band to Low Bound:  
% 2.  Acquire Dark low limit:  Dark Counts at the lower band limit
% 3.  Acquire A:  Take one second of data at the low limit
% 4.  Move to Low Scatter:  
% 5.  Acquire B:  
% 6.  Scan B to C:  Scan the band from the negative scatter angle to the positive scatter angle
% 7.  Acquire C:  
% 8.  Move to 0:  
% 9.  Acquire D (0):  
% 10.  Move to High Limit:  
% 11.  Acquire Dark High Limit:  
% 12.  Acquire E:  
% 13.  Move to Scatter High:  
% 14.  Acquire C:  
% 15.  Scan C to B:  
% 16.  Acquire B:  
% 17.  Move to Vertical (0):  
% 18.  Acquire vertical:  
% 19.  Move to Low Bound:  
%
% Subtract darks, tags 2 & 11
% th = tags 3 & 12
% bk = tag 9 & 18 = diff - band
% side B: 5,16
% side C: 7,14
% subtract bk from mean of sides to get direct_raw
% subtract direct_uncorr from th to get diffuse_raw
% apply cosine correction to direct_raw to get direct_corr
% apply cosine correcton to diffuse_raw to get diffuse_corr
% Add direct_corr to diffuse_corr to get th_corr
% normalize by integration time
% Divide direct_corr by diffuse_corr to get dir/dif
% divide by responsivity
%%
he_vis = rd_raw_SAS(getfullname_('*SASHe_HiSun_vis*.csv','sashe_hisun'));
he_nir = rd_raw_SAS(getfullname_('*SASHe_HiSun_nir*.csv','sashe_hisun'));
% vis_ms =
% rd_raw_SAS(getfullname_('SASHe_HiSun_vis_ms*.csv','sashe_hisun'));

%%
vis_nm = he_vis.lambda>340 & he_vis.lambda<1020;
nir_nm = he_nir.lambda>920 & he_nir.lambda<1700;
vis_dark = mean(he_vis.spec(he_vis.Shutter_open_TF==0,:));
nir_dark = mean(he_nir.spec(he_nir.Shutter_open_TF==0,:));

figure; lines = semilogy(he_vis.lambda(vis_nm), he_vis.spec(he_vis.Shutter_open_TF==1,vis_nm)-...
   ones(size(he_vis.time(he_vis.Shutter_open_TF==1)))*mean(he_vis.spec(he_vis.Shutter_open_TF==0,vis_nm)), '-',...
he_nir.lambda(nir_nm), he_nir.spec(he_nir.Shutter_open_TF==1,nir_nm)-ones(size(he_nir.time(he_nir.Shutter_open_TF==1)))*mean(he_nir.spec(he_nir.Shutter_open_TF==0,nir_nm)), '-'   );
lines = recolor(lines, [he_vis.Tag(he_vis.Shutter_open_TF==1);he_nir.Tag(he_nir.Shutter_open_TF==1)]');
colorbar
%%
he_vis.TH_low = he_vis.spec(he_vis.Tag==5,:);
he_vis.SB_A1 = he_vis.spec(he_vis.Tag==7,:);
he_vis.bk_1 = he_vis.spec(he_vis.Tag==9,:);
he_vis.SB_B1 = he_vis.spec(he_vis.Tag==11,:);
he_vis.dirn_raw1 = (he_vis.SB_A1+he_vis.SB_B1)./2 - he_vis.bk_1;
he_vis.diff_raw1 = he_vis.TH_low - he_vis.dirn_raw1 -ones([size(he_vis.TH_low,1),1])*vis_dark;

he_vis.TH_hi = he_vis.spec(he_vis.Tag==16,:);
he_vis.SB_A2 = he_vis.spec(he_vis.Tag==18,:);
he_vis.bk_2 = he_vis.spec(he_vis.Tag==20,:);
he_vis.SB_B2 = he_vis.spec(he_vis.Tag==22,:);
he_vis.dirn_raw2 = (he_vis.SB_A2+he_vis.SB_B2)./2 - he_vis.bk_2;
he_vis.diff_raw2 = he_vis.TH_hi - he_vis.dirn_raw2 -ones([size(he_vis.TH_low,1),1])*vis_dark;

he_nir.TH_low = he_nir.spec(he_nir.Tag==5,:);
he_nir.SB_A1 = he_nir.spec(he_nir.Tag==7,:);
he_nir.bk_1 = he_nir.spec(he_nir.Tag==9,:);
he_nir.SB_B1 = he_nir.spec(he_nir.Tag==11,:);
he_nir.dirn_raw1 = (he_nir.SB_A1+he_nir.SB_B1)./2 - he_nir.bk_1;
he_nir.diff_raw1 = he_nir.TH_low - he_nir.dirn_raw1 -ones([size(he_nir.TH_low,1),1])*nir_dark;

he_nir.TH_hi = he_nir.spec(he_nir.Tag==16,:);
he_nir.SB_A2 = he_nir.spec(he_nir.Tag==18,:);
he_nir.bk_2 = he_nir.spec(he_nir.Tag==20,:);
he_nir.SB_B2 = he_nir.spec(he_nir.Tag==22,:);
he_nir.dirn_raw2 = (he_nir.SB_A2+he_nir.SB_B2)./2 - he_nir.bk_2;
he_nir.diff_raw2 = he_nir.TH_hi - he_nir.dirn_raw2 -ones([size(he_nir.TH_low,1),1])*nir_dark;

figure; 
s(1) = subplot(3,2,1); plot(he_vis.lambda, [mean(he_vis.TH_hi);mean(he_vis.TH_low)],'-'); legend('hi','low'); 
title('Total Hemispheric')
s(2) = subplot(3,2,2); plot(he_vis.lambda, [mean(he_vis.SB_A2);mean(he_vis.SB_B2);mean(he_vis.SB_A1);mean(he_vis.SB_B1)],'-'); 
legend('A2','B2','A1','B1');title('side bands')
s(3) = subplot(3,2,3); plot(he_vis.lambda, [mean(he_vis.bk_1);mean(he_vis.bk_2);vis_dark],'-'); legend('bk_1','bk_2','dark');
title('blocked');
s(4) = subplot(3,2,4); plot(he_vis.lambda, [mean(he_vis.dirn_raw1);mean(he_vis.dirn_raw2)],'-'); legend('dirh_1','dirh_2');
title('dirh')
s(5) = subplot(3,2,5); plot(he_vis.lambda, [mean(he_vis.diff_raw1);mean(he_vis.diff_raw2)],'-'); legend('diff_1','diff_2');
title('diff');
s(6) = subplot(3,2,6); plot(he_vis.lambda, [mean(he_vis.dirn_raw1)./mean(he_vis.diff_raw1);mean(he_vis.dirn_raw2)./mean(he_vis.diff_raw2)],'-'); legend('dir2dif_1','dir2dif_2');
title('dirh / diff');
linkaxes(s,'x');

figure; 
ss(1) = subplot(3,2,1); plot(he_nir.lambda, [mean(he_nir.TH_hi);mean(he_nir.TH_low)],'-'); legend('hi','low'); 
title('Total Hemispheric')
ss(2) = subplot(3,2,2); plot(he_nir.lambda, [mean(he_nir.SB_A2);mean(he_nir.SB_B2);mean(he_nir.SB_A1);mean(he_nir.SB_B1)],'-'); 
legend('A2','B2','A1','B1');title('side bands')
ss(3) = subplot(3,2,3); plot(he_nir.lambda, [mean(he_nir.bk_1);mean(he_nir.bk_2);nir_dark],'-'); legend('bk_1','bk_2','dark');
title('blocked');
ss(4) = subplot(3,2,4); plot(he_nir.lambda, [mean(he_nir.dirn_raw1);mean(he_nir.dirn_raw2)],'-'); legend('dirh_1','dirh_2');
title('dirh')
ss(5) = subplot(3,2,5); plot(he_nir.lambda, [mean(he_nir.diff_raw1);mean(he_nir.diff_raw2)],'-'); legend('diff_1','diff_2');
title('diff');
ss(6) = subplot(3,2,6); plot(he_nir.lambda, [mean(he_nir.dirn_raw1)./mean(he_nir.diff_raw1);mean(he_nir.dirn_raw2)./mean(he_nir.diff_raw2)],'-'); legend('dir2dif_1','dir2dif_2');
title('dirh / diff');
linkaxes(ss,'x');


 figure; plot(he_vis.lambda(vis_nm), [mean(he_vis.dirn_raw1(:,vis_nm))./mean(he_vis.diff_raw1(:,vis_nm))],'-',...
    he_nir.lambda(nir_nm),[mean(he_nir.dirn_raw1(:,nir_nm))./mean(he_nir.diff_raw1(:,nir_nm))],'-' );legend('CCD dir/dif', 'InGaAs dir/dif')
xlabel('wavelength [nm]')
ylabel('direct_to_diffuse ratio')
title('SGP SAS-He direct and diffuse components, no cosine correction');


%%
plots_default;
 figure; plot([he_vis.lambda(vis_nm),he_nir.lambda(nir_nm)], ...
    [he_vis.dirn_raw1(:,vis_nm),he_nir.dirn_raw1(:,nir_nm);he_vis.dirn_raw2(:,vis_nm),he_nir.dirn_raw2(:,nir_nm)],'-',...
    [he_vis.lambda(vis_nm),he_nir.lambda(nir_nm)], ...
    [he_vis.diff_raw1(:,vis_nm),he_nir.diff_raw1(:,nir_nm);he_vis.diff_raw2(:,vis_nm),he_nir.diff_raw2(:,nir_nm)],'-');
 legend('dirn raw', 'dif raw')
xlabel('wavelength [nm]')
ylabel('cts')
title('SGP SAS-He direct and diffuse components, no cosine correction');
%%
