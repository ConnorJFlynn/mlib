function ava_dark_test2_part1
% Examination of dark count dependence with integration time for one
% Avantes CCD.
% Read entire directory of existing trt files and bundles files with
% identical settings.
%%
pname = 'C:\case_studies\ARRA\SAS\data_tests\dark_characterization\CCD_0911134U1_2\trt\';
% pname = 'C:\case_studies\ARRA\SAS\data_tests\dark_characterization\CCD_0911136U1_1\';
% pname = 'C:\case_studies\ARRA\SAS\data_tests\dark_characterization\CCD_0911136U1_2\';
% pname = 'C:\case_studies\ARRA\SAS\data_tests\dark_characterization\CCD_0911136U1_3\';
infiles = dir([pname, '*.trt']);
ava = read_avantes_trt([pname,infiles(1).name],true);
for ii = 2:length(infiles)
   disp([infiles(ii).name, ': ',num2str(ii), ' of ',num2str(length(infiles))]);
   ava = cat_trt_data(ava,[pname, infiles(ii).name]);
end
%    ava
noNaNs = ~any(isnan(ava.Sample));
   ava.mean_samp = mean(ava.Sample(:,noNaNs),2);
  figure; 
  plot(ava.tint, ava.mean_samp, 'o');
  %%
  P = polyfit(ava.tint(25:45), ava.mean_samp(25:45)',1);
  plot(ava.tint, ava.mean_samp, 'o',ava.tint, polyval(P,ava.tint),'r-');
  ff = ava.mean_samp(1:45)./polyval(P,ava.tint(1:45))';
  txt_out = 
  sprintf('%1.1f %2.3e \n',[ava.tint(1:45);ff'])
  %%
      disp(['Saving ',ava.fname{1}])
   save([ava.pname, ava.fname{1},'.mat'],'ava');

%    figure(5); 
%    ax(1) = subplot(2,1,1);plot(ava.nm, ava.Sample,'-',ava.nm, ava.mean_samp,'k-');
%    title({['Spectrometer:',ava.Spec_desc{1}],['File:',ava.fname{1}]},'interp','none');
%    ax(2) = subplot(2,1,2); plot(ava.nm, 100.*ava.std_samp./ava.mean_samp,'r-'); 
%    linkaxes(ax,'x')
%    xlabel('pixel nm');
%    legend('percent deviation from mean');
%    saveas(gcf,[ava.pname, ava.fname{1},'.png']);
   
%%
   