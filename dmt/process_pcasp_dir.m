in_dir = getdir;
%%
spp = dir([in_dir, '*nm_*.txt']);
%%

for d = 1:length(spp)
   disp(spp(d).name)
   d = rd_pcasp_dat([in_dir,filesep,spp(d).name]);
   output_SPP_table(d);
   d = plot_pcasp(d);
end
%%
   