function  [comp, colr_sqr, lims] = comp_image(x,y,z, op, lims, auto)
% [comp, colr_sqr,lims] = comp_image(x,y,z, op, lims, auto)
% Generates an image with a composite colormap.
% x, y, z,op required.
% struct "lims" and logical "auto"
% x,y for x and y axes.
% Color assigned by "z", opacity by "op"
% lims.cv_z lims.cv_o are min/max limits applied to the z and op fields
% lims.alpha_pow is exponent applied to alpha vector with [0:1] range
%   power < 1 brightens.  power > 1 dims.
% Returns structs of handles for fig, img, and ax for composite and colr_sqr
% and struct with limits
% Optional boolean "mask" allows selective masking
% Need to make this robust for inputs.
% Optionally save op to img UserData to permit re-scaling of opacity from
% the original data without re-imaging. But would require another function
% mimicing the scaling of op_ below to do so.  Might be useful in addition
% to the dimming and brightening of alpha in the commented statements below
% Also need to develop the 2D colorsquare

% imagegap maps z onto a uniform grid in the x-dimension
if ~isavar('auto') || isempty(auto) || ~auto
   auto = true;
end

figure_;
[colr.fig, colr.img, colr.axs] = imagegap(x,y,z);
title('color')
if ~isavar('lims')||~isfield(lims,'cv_z')
   cv_z = caxis;
else
   cv_z = lims.cv_z;
end
caxis(cv_z); colorbar;
if auto
   OK = menu({'Reposition image to occupy upper left-hand';...
      'quarter of the screen. Then click "Done".'},'Done')
end
colr.pos = get(colr.fig,'position');
figure_;
[opac.fig, opac.img, opac.axs] = imagegap(x,y,op); op = opac.img.CData;
title('opacity')
if ~isavar('lims')||~isfield(lims,'cv_o')
   cv_o = [min(min(op)),max(max(op))];
else
   cv_o = lims.cv_o;
end
caxis(cv_o);colorbar;
opac.pos = colr.pos; opac.pos(2) = opac.pos(2) -1.3*opac.pos(4);
set(opac.fig,'position',opac.pos);

% Mask out values that are below cv limits, as well as NaNs or non-numbers
% for either z or op

figure_;
[fig, img, axs] = imagegap(x,y,z); title('composite'); z = img.CData;
comp.fig = fig; comp.img = img; comp.axs = axs;
caxis(cv_z);
comp.pos = colr.pos;
comp.pos(1) = comp.pos(1) +1.05.*comp.pos(3);
% comp.pos(2) = comp.pos(2) - 0.5.*comp.pos(4);
set(comp.fig,'position',comp.pos);
set(comp.axs, 'position',get(colr.axs,'position'));
linkaxes([colr.axs, opac.axs, comp.axs], 'xy');

if ~isavar('lims')||~isfield(lims,'xl')
   lims.xl = xlim; 
end
if ~isavar('lims')||~isfield(lims,'yl')
   lims.yl = ylim;
end
xlim(lims.xl); ylim(lims.yl);

mask = op<cv_o(1) | isNaN(z) | isNaN(op) | ~isnumeric(z) | ~isnumeric(op);
%trim to bounds of z1 caxis limits
op_ = max(cv_o(1),min(cv_o(2),op));
% scale from 0:1
op_ = op_-(min(min(op_))); op_ = op_./(max(max(op_)));
op_(mask) = NaN;
if ~isavar('lims')||~isfield(lims,'alpha_pow')
   alpha_pow = 1;
else
   alpha_pow = lims.alpha_pow;
end
set(comp.img, 'alphadata',op_); set(comp.axs,'color','k');
done = false;
while auto && ~done
   choice = menu({'Zoom into images as desired.';'Select buttons below to adjust:'}, 'Color max','Color min','Opacity max','Opacity min','Brighter','Dimmer','Done');
   if choice==1
      tmp = sscanf(input(sprintf('Enter UPPER limit of color bar <%g>: ',cv_z(2)),'s'),'%f');
      if ~isempty(tmp) cv_z(2) = tmp; end      
   elseif choice==2
      tmp = sscanf(input(sprintf('Enter LOWER limit of color bar <%g>: ',cv_z(1)),'s'),'%f');
      if ~isempty(tmp) cv_z(1) = tmp; end
   elseif choice==3
      tmp = sscanf(input(sprintf('Enter UPPER limit of Opacity color bar <%g>: ',cv_o(2)),'s'),'%f');
      if ~isempty(tmp) cv_o(2) = tmp; end
   elseif choice==4
      tmp =  sscanf(input(sprintf('Enter LOWER limit of Opacity color bar <%g>: ',cv_o(1)),'s'),'%f');
      if ~isempty(tmp) cv_o(1) = tmp; end
   elseif choice == 5
      alpha_pow = alpha_pow ./1.25;
   elseif choice == 6
      alpha_pow = alpha_pow.*1.25;
   else
      done = true;
   end
   
   caxis(colr.axs,cv_z); caxis(comp.axs,cv_z); caxis(opac.axs,cv_o);
   
   op_ = max(cv_o(1),min(cv_o(2),op));
   op_ = op_-(min(min(op_))); op_ = op_./(max(max(op_)));
   op_(mask) = NaN;   
   op_= op_ .^ (alpha_pow);
   set(comp.img, 'alphadata',op_);
end
lims.cv_z = cv_z; lims.cv_o = cv_o; lims.alpha_pow = alpha_pow;
lims.xl = xlim; lims.yl = ylim;

col_square = [1:length(colormap)]';
col_square = repmat(col_square,[1,length(colormap)]);
op_square = linspace(0,1,length(colormap)); % To be used for colorsquare
op_square_ = op_square .^(alpha_pow);
op_square = repmat(op_square,[length(colormap),1]);

fig_sqr = figure_; img_sqr = imagesc(cv_o,cv_z,col_square);
axs_sqr = gca; axis('xy');axis('square');
sqr_pos = get(opac.fig,'position'); 
sqr_pos(1) = comp.pos(1)+0.2 .* comp.pos(3); sqr_pos(3) = comp.pos(3)./2;
set(fig_sqr,'position',sqr_pos);
title('color square'); 
xlabel('Opacity_(_A_l_p_h_a_)','interp','tex'); 
set(gca,'color','k','YAxisLocation','right');
ylabel('Color_(_Z_)','interp','tex');
set(img_sqr,'alphadata',op_square); 

rpos = get(gca,'position');rpos(1) = rpos(1)-.05; rpos(2) = rpos(2)+.025; set(gca,'position',rpos);

colr_sqr.fig = fig_sqr; colr_sqr.img = img_sqr; colr_sqr.axs = axs_sqr;

% figure_(13); subplot(1,2,1); subplot(1,2,2);

return


