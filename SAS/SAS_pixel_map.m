function SAS_pixel_map

Ze1_vis = rd_SAS_raw(getfullname('D:\TASZERS\Ze1\Ze1_avalight\SASZe_cals_vis_1s.*.csv','Ze1_vis','Select Ze1 vis files'));
Ze1_nir = rd_SAS_raw(getfullname('D:\TASZERS\Ze1\Ze1_avalight\SASZe_cals_nir_1s.*.csv','Ze1_nir','Select Ze1 nir files'));

%%
nm_in = [312.57	400	
313.154	320	
313.184	320	
334.15	41	
365.01	800	
365.48	200	
366.33	150	
404.66	767	
407.78	61.4	
433.922	7.5	
434.751	15	
435.834	1569.7	
491.607	7	
546.075	2258.4	
576.96	297.9	
579.07	300.6	
623.440 0.1	
667.82	0.4	
671.704	0.1	
675.35	0.1	
687.13	0.07	
690.75	3	
696.54	45	
706.72	8.7	
714.7	1.2	
727.29	6	
738.4	7.2	
750.39	21	
751.47	9	
763.51	23	
772.4	15	
794.82	6.5	
800.616	5	
801.479	4.0	
810.37	7.0	
811.53	14.0	
826.45	11	
840.82	4.6	
842.45	8	
852.14	3.7	
866.79	0.5	
912.3	11.6	
922.45	2.3	
935.422 0.2	
965.778	3.8	
978.4503 0.3	
1013.98	5	];
% Below this lines are from Hg h5 line file
nm_in = [nm_in; 1128.74 1; 1320.99 1; 1357.02 1; 1367.35 1; 1395.06 1; 1529.58 1];

%%
 sig_A = Ze1_vis.sig;
msig_A = nanmean(sig_A);
 sig_B = Ze1_nir.sig;
msig_B = nanmean(sig_B);
figure; plot(Ze1_vis.wl, msig_A,'-',Ze1_nir.wl, msig_B,'-'); logy;
try 
   close(99)
catch
end
[nm_new, pix_B, dels_B, P3_B, S3_B, Mu_B, nm_out_B] = fit_wl2(Ze1_nir.wl, msig_B, nm_in, 1);
SAS_HgAr.new_wl_B = nm_new;
SAS_HgAr.P3_B = P3_B
SAS_HgAr.Mu_B = Mu_B;

% figure; subplot(2,1,1);plot(SAS_HgAr.new_wl_B,msig_B, '-');
% nm_out_B = nm_out_B(:,1);ys = ylim'; ys(1) = 1e-6.*ys(2);
% line([nm_out_B,nm_out_B]',(ys*ones(size([nm_out_B']))),'color','green')
% subplot(2,1,2); plot(Ze1_nir.wl, SAS_HgAr.new_wl_B - Ze1_nir.wl, 'o'); 
% xlabel('nm [SAS nir]');
% legend('fit - SAS WL')
[nm_new, pix_A, dels_A, P3_A, S3_A, Mu_A, nm_out_A] = fit_wl2(Ze1_vis.wl, msig_A, nm_in, 1);
SAS_HgAr.new_wl_A = nm_new;
SAS_HgAr.P3_A = P3_A
SAS_HgAr.Mu_A = Mu_A;
save([Ze1_vis.pname{:}, 'SASZe1_new_wls'],'-struct','SAS_HgAr');
% Plot the locations of the reference lines overlain on the spectra remapped against
% the polyfit
% figure; plot(polyval(P3,[1:length(twst.wl_A)],S3,Mu),msig_A, '-');
% nm_out = nm_out(:,1);ys = ylim'; ys(1) = 1e-6.*ys(2);
% line([nm_out,nm_out]',(ys*ones(size([nm_out']))),'color','green')
% [pix, nms, P3,S3,Mu,nm_out] = fit_wl(polyval(P3,[1:length(twst.wl_A)],S3,Mu), msig_A,nm_in,3);

%%


end
%%