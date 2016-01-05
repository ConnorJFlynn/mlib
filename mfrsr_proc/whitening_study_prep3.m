function blah 
% Open a Long_Barnard clearsky file
% clear sky path: D:\case_studies\clong\clr_sky\from_JCB_with_formatting_errors
clrsky_fname = getfullname('D:\case_studies\clong\clr_sky\from_JCB_with_formatting_errors\clrsky_jcb.*.mat','clrsky','Select clrsky_cleaned');
if exist(clrsky_fname, 'file')
 clearsky =  load(clrsky_fname);
end
if isfield(clearsky,'clearsky')
   clearsky = clearsky.clearsky;
end
yyyy = datestr(clearsky.time(1),'yyyy');
C1 = anc_bundle_files(getfullname(['D:\case_studies\clong\mfrsrC1_catdir\sgpmfrsrC1.b1.',yyyy,'*.mat'],'mfrsrC1','Select C1 MFR file'));
% C1_fname = getfullname(['D:\case_studies\clong\mfrsrC1_catdir\sgpmfrsrC1.b1.',yyyy,'*.mat'],'mfrsrC1','Select C1 MFR file');
% if exist(C1_fname,'file')
%    C1_aod = load(C1_fname);
% end

E13 = anc_bundle_files(getfullname(['D:\case_studies\clong\mfrsrE13_catdir\sgpmfrsrE13.b1.',yyyy,'*.mat'],'mfrsrE13','Select E13 MFR file'));
% E13_fname = getfullname(['D:\case_studies\clong\mfrsrE13_catdir\sgpmfrsrE13.b1.',yyyy,'*.mat'],'mfrsrE13','Select E13 MFR file');
% if exist(E13_fname,'file')
%    E13_aod = load(E13_fname);
% end

[binc, cinb] = nearest(clearsky.time, C1.time);
[bine, einb] = nearest(clearsky.time, E13.time);

C1 = anc_sift(C1, cinb);
E13 = anc_sift(E13, einb);

[cine, einc] = nearest(C1.time, E13.time);
C1 = anc_sift(C1, cine);
E13 = anc_sift(E13, einc);

% Probably need to add a screen for missings, etc. 
C1.vdata.dir_hor_415 = C1.vdata.direct_normal_narrowband_filter1 .* C1.vdata.cosine_solar_zenith_angle;
C1.vdata.tot_415 = C1.vdata.dir_hor_415 + C1.vdata.diffuse_hemisp_narrowband_filter1;
C1.vdata.ratio_415 = C1.vdata.diffuse_hemisp_narrowband_filter1./C1.vdata.tot_415;
C1.vdata.dir_hor_870 = C1.vdata.direct_normal_narrowband_filter5 .* C1.vdata.cosine_solar_zenith_angle;
C1.vdata.tot_870 = C1.vdata.dir_hor_870 + C1.vdata.diffuse_hemisp_narrowband_filter5;
C1.vdata.ratio_870 = C1.vdata.diffuse_hemisp_narrowband_filter5./C1.vdata.tot_870;

E13.vdata.dir_hor_415 = E13.vdata.direct_normal_narrowband_filter1 .* E13.vdata.cosine_solar_zenith_angle;
E13.vdata.tot_415 = E13.vdata.dir_hor_415 + E13.vdata.diffuse_hemisp_narrowband_filter1;
E13.vdata.ratio_415 = E13.vdata.diffuse_hemisp_narrowband_filter1./E13.vdata.tot_415;
E13.vdata.dir_hor_870 = E13.vdata.direct_normal_narrowband_filter5 .* E13.vdata.cosine_solar_zenith_angle;
E13.vdata.tot_870 = E13.vdata.dir_hor_870 + E13.vdata.diffuse_hemisp_narrowband_filter5;
E13.vdata.ratio_870 = E13.vdata.diffuse_hemisp_narrowband_filter5./E13.vdata.tot_870;


% (1) CosZ – as a check, I compare mine with yours (they are a little different, so I went to the NOAA Solar Calculator and computed CosZ and found that mine agreed extremely well with NOAA)
% (2) Total415
% (3) Diffuse415
% (4) Ratio  Diffuse415/Total415
% (5) AOT415
% (6) Total870
% (7) Diffuse870
% (8) Ratio Diffuse870/Total870
% (9) AOT870

% M is a scale factor indicating how stringently to screen outliers.
% Lower values of M screen out more points.
M = [4];
% M = [2:.1:6];


for m = 1:length(M);
done = false;
good1 = C1.vdata.direct_diffuse_ratio_filter1>0 & ...
   C1.vdata.direct_diffuse_ratio_filter1 < 100 & ...
   E13.vdata.direct_diffuse_ratio_filter1>0 & ...
   E13.vdata.direct_diffuse_ratio_filter1 < 100; % C1 vs E13

good1(good1) = (log10(C1.vdata.direct_diffuse_ratio_filter1(good1)./E13.vdata.direct_diffuse_ratio_filter1(good1))>-1)&...
   (log10(C1.vdata.direct_diffuse_ratio_filter1(good1)./E13.vdata.direct_diffuse_ratio_filter1(good1))<1);

good5 = C1.vdata.direct_diffuse_ratio_filter5>0 & ...
   C1.vdata.direct_diffuse_ratio_filter5 < 100 & ...
   E13.vdata.direct_diffuse_ratio_filter5>0 & ...
   E13.vdata.direct_diffuse_ratio_filter5 < 100; % C1 vs E13

good5(good5) = (log10(C1.vdata.direct_diffuse_ratio_filter5(good5)./E13.vdata.direct_diffuse_ratio_filter5(good5))>-1)&...
   (log10(C1.vdata.direct_diffuse_ratio_filter5(good5)./E13.vdata.direct_diffuse_ratio_filter5(good5))<1);

% check C1 to E13 direct/diffuse
% check C1 to E13 diffuse/total
% check C1orE13 to BB diffuse/total

good1 = rpoly_mad(C1.vdata.direct_diffuse_ratio_filter1,E13.vdata.direct_diffuse_ratio_filter1,1,M(m),good1);
good5 = rpoly_mad(C1.vdata.direct_diffuse_ratio_filter5,E13.vdata.direct_diffuse_ratio_filter5,1,M(m),good5);


figure; 
plot(C1.vdata.direct_diffuse_ratio_filter1,E13.vdata.direct_diffuse_ratio_filter1,'r.',...
   C1.vdata.direct_diffuse_ratio_filter1(good5&good1),E13.vdata.direct_diffuse_ratio_filter1(good5&good1), 'k.');
title(['C1 to E13 filter 1 by both for ',datestr(C1.time(1),'yyyy')])

figure; 
plot(C1.vdata.direct_diffuse_ratio_filter5,E13.vdata.direct_diffuse_ratio_filter5,'r.',...
   C1.vdata.direct_diffuse_ratio_filter5(good1&good5),E13.vdata.direct_diffuse_ratio_filter5(good1&good5), 'k.');
title(['C1 to E13 filter 5 by both for ',datestr(C1.time(1),'yyyy')])


[m5,b5,r,sm,sb]=lsqbisec(C1.vdata.direct_diffuse_ratio_filter5(good1&good5),E13.vdata.direct_diffuse_ratio_filter5(good1&good5));

[m1,b1,r2,sm2,sb2]=lsqbisec(E13.vdata.direct_diffuse_ratio_filter1(good1&good5),C1.vdata.direct_diffuse_ratio_filter1(good1&good5));

good = good1&good5;
ngood = sum(good);
NG(m)= ngood;

end

% Had some unexplained results where using Jim's screened data still left
% some 
% figure; plot(M,NG./max(NG),'.k-');xlabel('MAD factor'); ylabel('N good')
good = good1&good5;
[P,S] = polyfit(C1.vdata.direct_diffuse_ratio_filter1(good), E13.vdata.direct_diffuse_ratio_filter1(good),1);

figure; plot(C1.vdata.direct_diffuse_ratio_filter1, E13.vdata.direct_diffuse_ratio_filter1, 'r.',...
   C1.vdata.direct_diffuse_ratio_filter1(good), E13.vdata.direct_diffuse_ratio_filter1(good), 'k.',...
   [0,5], polyval(P,[0,5]),'g-'); 
axis('square'); xlim([0,5]); ylim(xlim);
title(['MFRSR C1 vs E13 DDR for ',datestr(C1.time(1),'yyyy')]);
xlabel('C1'); ylabel('E13');

[binc, cinb] = nearest(clearsky.time, C1.time);
figure; plot(clearsky.Ratio415(binc),C1.vdata.ratio_415,  'r.',...
   clearsky.Ratio415(binc),E13.vdata.ratio_415,  'b.',...
   clearsky.Ratio415(binc(good)),E13.vdata.ratio_415(good),  'k.');
legend('Clearsky vs C1','Clearsky vs E13','E13 good');
% good = rpoly_mad(clearsky.Ratio415(binc)',E13.vdata.ratio_415,1,4,good);

% figure; plot(clearsky.Ratio415(binc),C1.vdata.ratio_415,  'r.',...
%    clearsky.Ratio415(binc),E13.vdata.ratio_415,  'b.',...
%    clearsky.Ratio415(binc(good)),E13.vdata.ratio_415(good),  'k.');
% legend('Clearsky vs C1','Clearsky vs E13','E13 good');

% figure; plot(clearsky.Ratio415, clearsky.DifR,'r.',...
%    clearsky.Ratio415(binc(good)), clearsky.DifR(binc(good)),'.')

figure; ax(1) = subplot(2,1,1); plot(C1.time(good), C1.vdata.direct_normal_narrowband_filter1(good), 'b.',...
   E13.time(good), E13.vdata.direct_normal_narrowband_filter1(good),'k.',...
   C1.time(good), C1.vdata.direct_normal_narrowband_filter1(good), 'b.',...
   E13.time(good), E13.vdata.direct_normal_narrowband_filter1(good),'k.',...
      C1.time(~good), C1.vdata.direct_normal_narrowband_filter1(~good),'r.', ...
   E13.time(~good), E13.vdata.direct_normal_narrowband_filter1(~good),'r-'); legend('dirn C1','dirn E13');
title('Filter 1');
ax(2) = subplot(2,1,2); plot(C1.time(good), C1.vdata.diffuse_hemisp_narrowband_filter1(good), 'b.',...
   E13.time(good), E13.vdata.diffuse_hemisp_narrowband_filter1(good),'k.',...
   C1.time(good), C1.vdata.diffuse_hemisp_narrowband_filter1(good), 'b.',...
   E13.time(good), E13.vdata.diffuse_hemisp_narrowband_filter1(good),'k.',...
   C1.time(~good), C1.vdata.diffuse_hemisp_narrowband_filter1(~good),'r.', ...
   E13.time(~good), E13.vdata.diffuse_hemisp_narrowband_filter1(~good),'r-'); legend('dif C1','dif E13');
dynamicDateTicks; zoom('on');

figure; ax(3) = subplot(2,1,1); plot(C1.time(good), C1.vdata.direct_normal_narrowband_filter5(good), 'b.',...
   E13.time(good), E13.vdata.direct_normal_narrowband_filter5(good),'k.',...
   C1.time(good), C1.vdata.direct_normal_narrowband_filter5(good), 'b.',...
   E13.time(good), E13.vdata.direct_normal_narrowband_filter5(good),'k.',...
      C1.time(~good), C1.vdata.direct_normal_narrowband_filter5(~good),'r.', ...
   E13.time(~good), E13.vdata.direct_normal_narrowband_filter5(~good),'r-'); legend('dirn C1','dirn E13');
title('Filter 5');
ax(4) = subplot(2,1,2); plot(C1.time(good), C1.vdata.diffuse_hemisp_narrowband_filter5(good), 'b.',...
   E13.time(good), E13.vdata.diffuse_hemisp_narrowband_filter5(good),'k.',...
   C1.time(good), C1.vdata.diffuse_hemisp_narrowband_filter5(good), 'b.',...
   E13.time(good), E13.vdata.diffuse_hemisp_narrowband_filter5(good),'k.',...
      C1.time(~good), C1.vdata.diffuse_hemisp_narrowband_filter5(~good),'r.', ...
   E13.time(~good), E13.vdata.diffuse_hemisp_narrowband_filter5(~good),'r-'); legend('dif C1','dif E13');
dynamicDateTicks; zoom('on');
linkaxes(ax,'x');

return