function [out_file] = cat_spec_type(out_file,in_file);
if exist('in_file','var')
   if ~isstruct(in_file) && exist(in_file,'file')
     in_file = read_avantes_trt(in_file);
   end
else 
   in_file = read_avantes_trt(in_file);
end

% in_file = read_avantes_trt(filename);
if strcmp(in_file.Spec_desc,out_file.Spec_desc)&&(in_file.nm(1)==out_file.nm(1))&& ...
      (length(in_file.nm)==length(out_file.nm))
   disp(['Concatenating ',char(in_file.fname)]);
   out_file.Sample = [out_file.Sample;in_file.Sample];
   out_file.tint = [out_file.tint;in_file.tint];
   out_file.Nsamples = [out_file.Nsamples;in_file.Nsamples];
   out_file.AdjacentPixels = [out_file.AdjacentPixels;in_file.AdjacentPixels];   
   out_file.dark = [out_file.dark;in_file.dark];
   out_file.timestamp = [out_file.timestamp;in_file.timestamp];
%    out_file.mean_samp = mean(out_file.Sample,1);
%    out_file.std_samp = std(out_file.Sample,0,1);
   out_file.title = in_file.title;
   out_file.fname = in_file.fname;
   out_file.header = in_file.header;
   out_file.header_rows = in_file.header_rows;
else
   disp(['Skipping ',char(in_file.fname)])

end
% check static fields
% accumulate spectra, mean and stddev
