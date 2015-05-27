function ava_dark_test1
% Examination of dark count dependence with integration time for one
% Avantes CCD.
%%
pname = 'C:\case_studies\ARRA\SAS\data_tests\dark_characterization\CCD_0911134U1\TRT\';
infiles = dir([pname, '*.trt']);
ava = read_avantes_trt([pname,infiles(1).name],true);
for ii = 2:length(infiles)
   disp([infiles(ii).name, ': ',num2str(ii), ' of ',num2str(length(infiles))]);
   ava = cat_trt(ava,[pname, infiles(ii).name]);
end

%    ava
   ava.mean_samp = mean(ava.Sample,1);
   ava.std_samp = std(ava.Sample,0,1);
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
   