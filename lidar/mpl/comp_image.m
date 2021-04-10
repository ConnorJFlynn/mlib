function  [comp] = comp_image(x,y,zz, op, cv_z, cv_a, masked);
% Generates an image with a composite colormap. Color assigned by "zz",
% opacity by "op" with limits in "cv".  
% Optional "masked" composed of ones and NaNs allows selective masking
% min_v1, min_v2 not used yet. 
% Need to make this robust for inputs. 
% Optionally save op to img UserData to permit re-scaling of opacity from
% the original data without re-imaging. But would require another function
% mimicing the scaling of op_ below to do so.  Might be useful in addition
% to the dimming and brightening of alpha in the commented statements below
% Also need to develop the 2D colorsquare


fig_comp = figure_(double(gcf)+1); 
ax2(1) = subplot(1,2,1);
ax2(2) = subplot(1,2,2); 
col_sqr = (ones([length(colormap),1])*linspace(cv_z(1), cv_z(2), length(colormap)))'; 
alpha_sqr =(ones([length(colormap),1])*linspace(0, 1, length(colormap)));
img = imagesc(cv_a, cv_z,col_sqr); caxis(cv_z); grid('off')
axis(ax2(2),'square','xy');
axes(ax2(1)); 
set(ax2(2),'YAxisLocation','right');
s1_pos = get(ax2(1), 'position'); 
s2_pos = get(ax2(2),'position');
s1_pos_ = s1_pos; s2_pos_ = s2_pos; 
s2_pos_(1) = s2_pos_(1) + s2_pos(3)./2; s2_pos_(3) = s2_pos(3)./2 ;
set(ax2(2),'position',s2_pos_); 
 xt = xlabel(ax2(2),'Log_1_0(bscat)');set(xt,'interp','Tex') ;
 yt = ylabel(ax2(2),'Log_1_0(ldr)'); set(yt, 'interp','Tex');
%  tl = title('color square')

set(img,'alphadata',alpha_sqr);set(ax2(2),'color','k')

dx = (s2_pos(1) - s1_pos(1)-s1_pos(3));
s1_pos_(3) = s2_pos_(1) - dx -.05;
s1_pos_(1) = s1_pos(1).*(.75); s1_pos_(2) = s1_pos(2)+.05;s1_pos_(4) = s1_pos(4)-.05;
set(ax2(1), 'position',s1_pos_);
axes(ax2(1));

[img, x_grid]= imagegap(x,y,zz);
%trim to bounds of z1 caxis limits
op_ = max(cv_a(1),min(cv_a(2),op));
% scale from 0:1
op_ = op_-(min(min(op_))); op_ = op_./(max(max(op_)));
op_ = (op_.*masked); op_ = fill_img(op_, x, x_grid);
set(img, 'alphadata',op_); set(ax2(1),'color','k');

 xlabel('time [UTC]'); ylabel('range [km]');
 caxis(cv_z);
  tx = text(.5, .5, ['Composite of backscatter & dpr']); 
 set(tx,'color','w')
set(tx,'units','normalized');set(tx,'position',[.02,.95,0])


% dims: set(img99, 'alphadata',get(img99, 'alphadata').^(1.33));
% brightens: set(img99, 'alphadata',get(img99, 'alphadata').^(.75));
comp.fig = gcf; 
comp.img = img;
comp.axs = ax2;
return


