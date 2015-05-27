function [out_file] = cat_trt_data(out_file,in_file);
% [out_file] = cat_all_trt(out_file,in_file);
% Concatenate all normal data (not header, serial number, etc.)

if exist('in_file','var')
   if ~isstruct(in_file) && exist(in_file,'file')
     in_file = read_avantes_trt(in_file,true);
   end
else 
   in_file = read_avantes_trt(in_file,true);
end
if ~any(in_file.timestamp == out_file.timestamp)
   disp(['Concatenating ',in_file.fname{1}]);
   out_file.timestamp = [out_file.timestamp,in_file.timestamp];
   n = length(out_file.timestamp);
   out_file.Sample(n,:) = in_file.Sample;
%    out_file.nm(n,:) = in_file.nm;
%    out_file.good(n,:) = in_file.good;
   out_file.tint = [out_file.tint,in_file.tint];
   out_file.Nsamples = [out_file.Nsamples,in_file.Nsamples];
   out_file.AdjacentPixels = [out_file.AdjacentPixels,in_file.AdjacentPixels];
   out_file.dark = [out_file.dark,in_file.dark];
%    out_file.mean_samp = mean(out_file.Sample,2);
%    out_file.std_samp = std(out_file.Sample,0,2);
   out_file.title{n} = in_file.title{1};
%    out_file.fname{n} = in_file.fname{1};
%    out_file.Spec_desc{n} = in_file.Spec_desc{1};
%    out_file.header{n} = in_file.header{1};
%    out_file.header_rows(n) = in_file.header_rows;
else
   disp(['Skipping ',in_file.fname{1}])

end
% check static fields
% accumulate spectra, mean and stddev
