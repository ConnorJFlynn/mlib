function SASZe_RC_TransTests
% SASZe RC-08 Transmittance tests

 dark_start = SAS_read_Albert_csv;
 dark_end = SAS_read_Albert_csv;

%  figure; plot([1:length(dark_start.time)], dark_start.spec(:,600),'o',length(dark_start.time)+[1:length(dark_end.time)], dark_end.spec(:,600),'o')
 dark = mean([dark_start.spec;dark_end.spec]);
 
 bare_start = SAS_read_Albert_csv;
 bare_end = SAS_read_Albert_csv;
 figure; plot([1:length(bare_start.time)], bare_start.spec(:,floor(length(bare_start.nm)./2)),'o',length(bare_start.time)+[1:length(bare_end.time)], bare_end.spec(:,floor(length(bare_start.nm)./2)),'o')
bare = mean([bare_start.spec; bare_end.spec]) - dark;

 RC08 = SAS_read_Albert_csv;
 
 RC08uv = SAS_read_Albert_csv;
 
rc08 = mean(RC08.spec) - dark; rc08uv = mean(RC08uv.spec)-dark;

figure; plot(bare_start.nm, [bare; rc08; rc08uv], '-'); legend('bare','rc08','rc08uv')

figure; plot(bare_start.nm, [rc08./bare; rc08uv./bare], '-'); legend('rc08','rc08uv')


 ndark_start = SAS_read_Albert_csv;
 ndark_end = SAS_read_Albert_csv;

%  figure; plot([1:length(dark_start.time)], dark_start.spec(:,600),'o',length(dark_start.time)+[1:length(dark_end.time)], dark_end.spec(:,600),'o')
 ndark = mean([ndark_start.spec;ndark_end.spec]);
 
 nbare_start = SAS_read_Albert_csv;
 nbare_end = SAS_read_Albert_csv;
%  figure; plot([1:length(bare_start.time)], bare_start.spec(:,600),'o',length(bare_start.time)+[1:length(bare_end.time)], bare_end.spec(:,600),'o')
nbare = mean([nbare_start.spec; nbare_end.spec]) - ndark;

 nRC08 = SAS_read_Albert_csv;
 
 nRC08uv = SAS_read_Albert_csv;
 
nrc08 = mean(nRC08.spec) - ndark; nrc08uv = mean(nRC08uv.spec)-ndark;

figure; plot(nbare_start.nm, [nbare; nrc08; nrc08uv], '-'); legend('bare','rc08','rc08uv')

figure; plot(nbare_start.nm, [nrc08./nbare; nrc08uv./nbare], '-'); legend('rc08','rc08uv')





 
 
 return