function [out_file] = cat_trt(out_file,filename);
% concatenates Avantes spectrometer files with identical collection
% parameters.
in_file = read_avantes_trt(filename,true);
if in_file.tint==out_file.tint && in_file.Nsamples==out_file.Nsamples && ...
      in_file.AdjacentPixels==out_file.AdjacentPixels && in_file.dark==out_file.dark && ...
      strcmp(in_file.Spec_desc,out_file.Spec_desc)&&(in_file.nm(1)==out_file.nm(1))&& ...
      (length(in_file.nm)==length(out_file.nm))
%    disp(['Concatenating files']);
   out_file.Sample = [out_file.Sample;in_file.Sample];
%    out_file.mean_samp = mean(out_file.Sample,2);
%    out_file.std_samp = std(out_file.Sample,0,2);
   out_file.title = in_file.title;
   out_file.fname = in_file.fname;
   out_file.header = in_file.header;
   out_file.header_rows = in_file.header_rows;
else

%    out_file
   out_file.mean_samp = mean(out_file.Sample,1);
   out_file.std_samp = std(out_file.Sample,0,1);
      disp(['Saving ',out_file.fname{1}])
   save([out_file.pname, out_file.fname{1},'.mat'],'out_file');
%    figure(5); 
%    ax(1) = subplot(2,1,1);plot(out_file.nm, out_file.Sample,'-',out_file.nm, out_file.mean_samp,'k-');
%    title({['Spectrometer:',out_file.Spec_desc{1}],['File:',out_file.fname{1}]},'interp','none');
%    ax(2) = subplot(2,1,2); plot(out_file.nm, 100.*out_file.std_samp./out_file.mean_samp,'r-'); 
%    linkaxes(ax,'x')
%    xlabel('pixel nm');
%    legend('percent deviation from mean');
%    saveas(gcf,[out_file.pname, out_file.fname{1},'.png']);
   
   out_file = in_file;
end

% check static fields
% accumulate spectra, mean and stddev
