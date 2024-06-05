function [tws, twst] = cat_twst_mat(mats)
if ~isavar('mats')
   mats = getfullname_('*.mat');
end
twst = load(mats{1});
wl_ = interp1(twst.wl_A,[1:length(twst.wl_A)],[415,440,500,615,673,870],'nearest')';
wl_415_ = twst.wl_A>412 & twst.wl_A<418;
clear tws tws_ twst_
tws.time = twst.time; 
tws.zrad = twst.zenrad_A(wl_,:);
tws.zrad_415avg = mean(twst.zenrad_A(wl_415_,:));

for m = 2:length(mats)
   twst_ = load(mats{m});
   tws_.time = twst_.time;
   tws_.zrad = twst_.zenrad_A(wl_,:);
   tws_.zrad_415avg = mean(twst_.zenrad_A(wl_415_,:));
   [tws.time, ij] = unique([tws.time, tws_.time]);
   tmp = [tws.zrad,tws_.zrad]; tws.zrad = tmp(:,ij);
   tmp = [tws.zrad_415avg,tws_.zrad_415avg]; tws.zrad_415avg = tmp(ij);
   tmp = [twst.time, twst_.time]; twst.time = tmp(ij);
   tmp = [twst.zenrad_A, twst_.zenrad_A]; twst.zenrad_A = tmp(:,ij);
   tmp = [twst.zenrad_B, twst_.zenrad_B]; twst.zenrad_B = tmp(:,ij);
   tmp = [twst.raw_A, twst_.raw_A]; twst.raw_A = tmp(:,ij);
   tmp = [twst.raw_B, twst_.raw_B]; twst.raw_B = tmp(:,ij);
end

% save('D:\AGU_prep\tws_wls.mat','-struct','tws')

return