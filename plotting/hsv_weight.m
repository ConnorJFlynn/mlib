function [fig, ax] = hsv_weight(x,y,cmap,ax1,ax2);
% Cool!  Okay, now change it so accepts an axis and
% weighting function as inputs.  For starters, we'll make sure that the
% size of the weighting function matches the size of cdata, but later we
% might create a weighting function of the appropriate size so long as one
% or the other of cdata dims is matched. 
%Returns handle to figure and axis of new plot?s
clim_ax1 = get(ax1,'clim');
cdata_ax1 = get(get(ax1,'children'),'cdata');
cdata_ax1_ = min(clim_ax1(2), max(clim_ax1(1),cdata_ax1));
clim_ax2 = get(ax2,'clim');
cdata_ax2 = get(get(ax2,'children'),'cdata');
cdata_ax2_ = min(clim_ax2(2), max(clim_ax2(1),cdata_ax2));

%%
fin1 = isfinite(cdata_ax1_);
fin2 = isfinite(cdata_ax2_);
%%
min1 = min(min(cdata_ax1_(fin1)));
min2 = min(min(cdata_ax2_(fin2)));
max1 = max(max(cdata_ax1_(fin1)));
max2 = max(max(cdata_ax2_(fin2)));

cdata_ax1_ = (cdata_ax1_ - min1)./abs(max1-min1);
cdata_ax2_ = (cdata_ax2_ - min2)./abs(max2-min2);
%%
rgb = ind2rgb(size(cmap,1)*cdata_ax1_, cmap);
hsv = rgb2hsv(rgb); 
%%

hsv(:,:,3) = (.25 + 0.75*(cdata_ax2_.^2));

rgb_ = hsv2rgb(hsv);

%%
% figure; image(rgb);
% fig = figure; 
figure(12);
image(x,y,rgb_); 
fig = gcf;
axis('xy'); 
ax = gca; 




%