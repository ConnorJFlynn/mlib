function spec = SASHE_reconnect_at_collimator(indir)
% This is a sequence of groups of spectra with embedded darks.
% Shows negligible difference in deviation within groups and bridging
% groups with disconnected between.  Excellent news.
if ~exist('indir','var')
   indir = getdir;
end
%%
discs = dir([indir,'*connect.']);
%%
spec.con(1).vis = SAS_read_ava(getfullname([indir,discs(1).name,filesep,'*.csv']));
[~,tmp] = strtok(spec.con(1).vis.fname,'_');
tmp = tmp{:};
vis_sn = strtok(tmp(2:end),'.');
spec.con(1).nir = SAS_read_ava(getfullname([indir,discs(1).name,filesep,'*.csv']));
[~,tmp] = strtok(spec.con(1).nir.fname,'_');
tmp = tmp{:};
nir_sn = strtok(tmp(2:end),'.');
spec.trh(1).trh = SAS_read_trh(getfullname([indir,discs(1).name,filesep,'*T_RH.csv']));
%%  
for d = length(discs):-1:2
   vis_file = dir([indir,discs(d).name,filesep,'*',vis_sn,'.csv']);
   spec.con(d).vis = SAS_read_ava([indir,discs(d).name,filesep,vis_file(1).name]);
%    spec.con(d).vis
   nir_file = dir([indir,discs(d).name,filesep,'*',nir_sn,'.csv']);
   spec.con(d).nir = SAS_read_ava([indir,discs(d).name,filesep,nir_file(1).name]);
   trh_file = dir([indir,discs(d).name,filesep,'*T_RH.csv']);
   spec.con(d).trh = SAS_read_trh([indir,discs(d).name,filesep,trh_file(1).name]);
end  
for d = 2:length(discs)
stds.vis_within(d-1,:) = std(spec.con(d).vis.spec(spec.con(d).vis.Shuttered_0==1,:));
stds.mean_vis(d-1,:) = mean(spec.con(d).vis.spec(spec.con(d).vis.Shuttered_0==1,:))-...
   mean(spec.con(d).vis.spec(spec.con(d).vis.Shuttered_0==0,:));
vis_bridge = [spec.con(d-1).vis.spec(spec.con(d-1).vis.Shuttered_0==1,:);spec.con(d).vis.spec(spec.con(d).vis.Shuttered_0==1,:)];
stds.vis_bridge(d-1,:) = std(vis_bridge);
stds.nir_within(d-1,:) = std(spec.con(d).nir.spec(spec.con(d).nir.Shuttered_0==1,:));
stds.mean_nir(d-1,:) = mean(spec.con(d).nir.spec(spec.con(d).nir.Shuttered_0==1,:))- ...
   mean(spec.con(d).nir.spec(spec.con(d).nir.Shuttered_0==0,:));
nir_bridge = [spec.con(d-1).nir.spec(spec.con(d-1).nir.Shuttered_0==1,:);spec.con(d).nir.spec(spec.con(d).nir.Shuttered_0==1,:)];
stds.nir_bridge(d-1,:) = std(nir_bridge);

end
%%
[~,vis_pix] = max(stds.mean_vis(1,:));
[~,nir_pix] = max(stds.mean_nir(1,:));
 %%
 figure; plot(spec.con(d).vis.nm, (spec.con(d).vis.spec(spec.con(d).vis.Shuttered_0==1,:)),'b-',...
    spec.con(d).nir.nm, (spec.con(d).nir.spec(spec.con(d).nir.Shuttered_0==1,:)), 'r-')
 %%
 figure; 
 plot([1:length(discs)-1],stds.vis_within(:,vis_pix)./stds.mean_vis(:,vis_pix), 'bo',...
    [1:length(discs)-1],stds.vis_bridge(:,vis_pix)./stds.mean_vis(:,vis_pix), 'bx',...
    [1:length(discs)-1],stds.nir_within(:,nir_pix)./stds.mean_nir(:,nir_pix), 'ro',...
    [1:length(discs)-1],stds.nir_bridge(:,nir_pix)./stds.mean_nir(:,nir_pix), 'rx');
 legend('vis_within','vis_bridge','nir_within','nir_bridge')
   %%
 linkaxes(ax,'xy');
   
   %%
   %%
return
     