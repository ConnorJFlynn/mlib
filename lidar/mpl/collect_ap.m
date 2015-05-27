%%
% get all MPL afterpulse periods...

mpl_dir = 'C:\case_studies\mplnor\twpC3\';
files = dir([mpl_dir,'*.cdf']);
clear all_ap
figure(1)
for f = 1:length(files)
   mpl = ancload([mpl_dir, files(f).name]);
   ap_time = auto_ap(mpl);
   mpl_ap = ancsift(mpl,mpl.dims.time, ap_time);
   if ~exist('all_ap','var')
      all_ap = mpl_ap;
   else
      all_ap = anccat(all_ap,mpl_ap);
   end
end
mean_ap = mean(all_ap.vars.detector_counts.data,2);
figure; imagesc([1:length(all_ap.time)], all_ap.vars.range.data, real(log10(all_ap.vars.detector_counts.data))); 
colorbar; axis('xy')
figure; imagesc([1:length(all_ap.time)], all_ap.vars.range.data, ((all_ap.vars.detector_counts.data./(mean_ap*ones([1,length(all_ap.time)]))))); 
colorbar; axis('xy')

figure; semilogy(all_ap.vars.range.data, mean(all_ap.vars.detector_counts.data,2), 'r.')
ap_out = double([all_ap.vars.range.data, mean(all_ap.vars.detector_counts.data,2)]);
[fname, pname] = putfile('*.dat','mpl_ap');
save('ap_out',[pname,fname],'-ascii')
%%
