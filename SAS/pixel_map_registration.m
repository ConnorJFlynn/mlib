% wavelength pixel map registration
% number 7
cmos_1000 = read_avantes_trt(getfullname_('*.trt'));
% number 6?
cmos_1000_dark = read_avantes_trt(getfullname_('*.trt'));
%
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
%%
[pix, nms, P3,S3] = fit_wl(cmos_1000.nm, cmos_1000.Sample-cmos_1000_dark.Sample,nm_in,3);
%%
[P4,S4] = fit_wl(cmos_1000.nm, cmos_1000.Sample-cmos_1000_dark.Sample,nm_in,4);

%%
figure; plot(cmos_1000.nm, polyval(P3,cmos_1000.nm,S3)- polyval(P4,cmos_1000.nm,S4), '-b')
%%
[P5,S5] = fit_wl(cmos_1000.nm, cmos_1000.Sample-cmos_1000_dark.Sample,nm_in,5);
%%