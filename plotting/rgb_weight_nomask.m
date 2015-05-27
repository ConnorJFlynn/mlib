function [rgb, color_sqr] = rgb_weight_nomask(x,y,z,w,cmap,clim_ax1,clim_ax2,min_v);
% [rgb, color_sqr] = rgb_weight_nomask(x,y,z,w,cmap,clim_z,clim_w,min_cvw);

if ~exist('min_v','var')
% min_v = min(1,max(0,min_v));
min_v = 0;
end
fin_z = isfinite(z);
fin_w = isfinite(w);
clen  = length(cmap);
if ~exist('clim_ax1','var')
   fins = z(fin_z);
   clim_ax1 = [min(fins(:)), max(fins(:))];
end
if ~exist('clim_ax2','var')
   fins = w(fin_w);
   clim_ax2 = [min(fins(:)), max(fins(:))];
end

%%
% disp('Getting speckle from somewhere...')
% I think this has been fixed by the max/min statements below
z = (z -clim_ax1(1))./abs(clim_ax1(2)-clim_ax1(1));
% z is now scaled from 0 to 1 over clim_ax
z = (z * (clen-1))+1;
% z is now scaled from 1 to clen 
z = max(1,min(clen,z));
% z = min(clen,max(1,z));
% handle out-of-bound colors by pinning to top and bottom
% not sure what happens to non-finites yet.

%and the same for w, except we might want to leave it from 0to1
w = (w -clim_ax2(1))./abs(clim_ax2(2)-clim_ax2(1));
w = max(0,min(1,w));
% w = min(1,max(w,0));

%%
rgb = ind2rgb(z, cmap);
hsv = rgb2hsv(rgb); 
% hsv(~fin1,3) = NaN;
% hsv(~fin2,3) = NaN;
%%
val = (min_v + (1-min_v)*(w));
%set non-finites to NaNs or zero;

val(~fin_z) = NaN;
val(~fin_w) = NaN;

hsv(:,:,3) = val;

rgb = hsv2rgb(hsv);
cmap_len = max(size(cmap));

%rgb_weight(x,y,z,w,cmap,clim_ax1,clim_ax2,min_v,mask);
% [rgb] = rgb_weight(x,y,z2,z1,cmap,cv_dpr,cv_bs,0.15,mask(r.lte_15,:));
if nargout==2
cb_1 = linspace(clim_ax1(1), clim_ax1(2),length(cmap));
cb_2 = linspace(clim_ax2(1),clim_ax2(2),length(cmap))';
zz1 = ones(size(cb_2))*cb_1;
zz2 = cb_2*ones(size(cb_1));
color_sqr = rgb_weight(cb_1,cb_2,zz1',zz2',cmap,clim_ax1,clim_ax2,min_v);
end
% color_sqr = zeros([cmap_len, cmap_len]);
%%
% figure; image(rgb);
% fig = figure; 
% figure(12);
% image(x,y,rgb); 
% colormap(cmap);
% colorbar;
% axis('xy'); 





%