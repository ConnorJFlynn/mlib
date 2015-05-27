function trt = ava_cat_trt_dir(indir)
% trt = ava_cat_trt_dir(indir)
if ~exist('indir','var')
   indir = [getdir, filesep]; 
end
% indir = ['C:\case_studies\4STAR\data\2012\2012_05_02_Avantes_Prede\20120502_ava.trt\20120502_ava\'];
files = dir([indir, '*.trt']);
trt = read_avantes_trt([indir,files(1).name],true);
%%
trt = cat_trt_data(trt,read_avantes_trt([indir,files(2).name],true));
%%
for f = 3:length(files)
    trt = cat_trt_data(trt,read_avantes_trt([indir,files(f).name],true));
end
save([indir,char(trt.fname{:}),'.mat'],'trt');
%%
figure; lines = plot(trt.nm, trt.Sample-(ones(size(trt.timestamp'))*min(trt.Sample)), '-'); lines = recolor(lines, trt.timestamp); colorbar
%%

