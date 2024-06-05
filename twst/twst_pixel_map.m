function twst_pixel_map

% wavelength pixel map registration
if ~isavar('in_file')||isempty(in_file)
   in_file = getfullname('*TWST*.nc','twst_nc4','Select instrument-level TWST pol test file');
end
if isstruct(in_file)&&~empty(in_file)&&isafile(in_file{1})
   in_file = in_file{1};
end

twst = twst4_to_struct(in_file); 


%     line_lib = getfullname('*.h5','spectral_line_library','Select spectra lines library.');
% 
% 
% %%
% h5disp(line_lib,'/','min')
% %%

% Cd = h5read(line_lib,'/Cd');
% [Cd, Cd_] = clean_lines(Cd);

% Ar = h5read(line_lib,'/Ar');
% [Ar, Ar_] = clean_lines(Ar);
% 
% Hg = h5read(line_lib,'/Hg');
% [Hg, Hg_] = clean_lines(Hg);
% % 

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
 sig_A = twst.raw_A - interp1( twst.dark_time,twst.dark_A', twst.time,'linear')';
msig_A = nanmean(sig_A,2);
 sig_B = twst.raw_B - interp1( twst.dark_time,twst.dark_B', twst.time,'linear')';
msig_B = nanmean(sig_B,2);
figure; plot(twst.wl_A, msig_A,'-',twst.wl_B, msig_B,'-'); logy;
% [nm_new, pix,dels,P,S,Mu,nm_out]
[new_wl_B,pix_b, nms_B, P3_B, S3_B, Mu_B, nm_out_B] = fit_wl2(twst.wl_B, msig_B, nm_in, 2);
% new_wl_B = polyval(P3_B, [1:length(twst.wl_B)],[],Mu_B);
TWST_HgAr.new_wl_B = new_wl_B;
TWST_HgAr.P3_B = P3_B;
TWST_HgAr.Mu_B = Mu_B;

[new_wl_A,pix, nms, P3,S3,Mu,nm_out] = fit_wl2(twst.wl_A, msig_A,nm_in,2);
% new_wl_A = polyval(P3, [1:length(twst.wl_A)],[],Mu);
TWST_HgAr.new_wl_A = new_wl_A;
TWST_HgAr.P3_A = P3
TWST_HgAr.Mu_A = Mu;
save([twst.pname, 'TWST11_new_wls'],'-struct','TWST_HgAr');



end
%%