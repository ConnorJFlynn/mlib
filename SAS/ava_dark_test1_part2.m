function ava_dark_test1_part2
% Examination of dark count dependence with integration time for one
% Avantes CCD.
% Reads mat files created in part 1 to populate a matrix with only the mean
% spectra vs t_int.

%%
pname = 'C:\case_studies\ARRA\SAS\data_tests\dark_characterization\CCD_0911134U1\TRT\';
infiles = dir([pname, '*.mat']);
ava = loadinto([pname, infiles(1).name]);
ava = rmfield(ava,'Sample');
for ii = 2:length(infiles)
   disp([infiles(ii).name, ': ',num2str(ii), ' of ',num2str(length(infiles))]);
tmp = loadinto([pname, infiles(ii).name]);
ava.tint = [ava.tint;tmp.tint];
ava.mean_samp = [ava.mean_samp;tmp.mean_samp];
ava.std_samp = [ava.std_samp;tmp.std_samp];
end
[ava.tint, inds] = sort(ava.tint);
ava.mean_samp = ava.mean_samp(inds,:);
ava.std_samp = ava.std_samp(inds,:);
noNaNs = ~any(isNaN(ava.mean_samp));
ava.mean_mean = mean(ava.mean_samp(:,noNaNs),2);
ava.Pofmean = polyfit(ava.tint, ava.mean_mean,1);
noNaNs_ii = find(noNaNs);
ava.P = NaN([length(ava.nm),2]);
for ii = noNaNs_ii
   ava.P(ii,:) = polyfit(ava.tint, ava.mean_samp(:,ii),1);
end
figure; 
subplot(2,1,1); 
plot(ava.nm, ava.P(:,1),'o');
title({['Mean value: ',num2str(mean(ava.P(noNaNs,1)))], ['Fit to mean:',num2str(ava.Pofmean(1))]});
subplot(2,1,2);
plot(ava.nm, ava.P(:,2),'o')
title({['Mean value: ',num2str(mean(ava.P(noNaNs,2)))], ['Fit to mean:',num2str(ava.Pofmean(2))]});

return


%%