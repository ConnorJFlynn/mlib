function  make_lidar_image(data,figureNum,withColorbar)
% make_lidar_image
%
% Usage:
%    make_lidar_image(data,figureNum,[withColorbar])
%
% Example: make_lidar_image(beta_P_ll,202,'withColorbar')
%
% Description:
%    Makes an image of the lidar attenuated backscatter.
%
% Inputs: 
%    data         - (MxN)= row X col = alt X prof, matrix of attenueted backscatter values
%    figureNum    - the figure number you would like to plot the image in
%    withColorbar - [optional] use 'withColorbar' to add the color bar
%
% Requirements: lidar_colorbar.m, kathys_lidar_colors.m
%
% Acknowledgements: 
% This is based on Kathy Powells IDL code to accomplish a similar task. The colorbar function is based
% on the colorbarf function written by Blair Greenan.
%                   
% Author: R. Kuehn, 8/11/2006
 
% Get the color info
[rgb colors_532 color_bar color_bar_labels] = kathys_lidar_colors('useGrayScale');
% The following code was inserted here to show how the colors are assigned to each pixel (data elements
% within the attenuated backscatter profiles).

% ist and iend are the selected start and end locations along the orbit track
nAlt = size(data,1);
nProf = size(data,2);


if nargin == 3,
    if strcmp('withColorbar',withColorbar),
	addColorbar = 1;
    end
else
    addColorbar = 0;
end

% For some reason adding the color bar messes up the colormap for the image.
%  I spent a bunch of time trying to figure out why and was unable to determine the exact cause.
% So, when adding a colorbar draw the image as MxNx3
if addColorbar,
    out_img = zeros(nAlt,nProf,3,'uint16');
else
    out = zeros(nAlt,nProf,'uint8');
end

for ic=1:nProf,
  % the_profile_mfs contains the attenuated backscatter values in units of /km/sr.
  % division by 1.0e-4 converts the attenuated backscatter values to an integer value.
  % each integer value is associated to a color within colors_532.
  tmp = floor(data(:,ic) / 1.0e-4);

  % Filter out the negative data
  neg_mask = (data(:,ic) > 1.0e-4);
  tmp = neg_mask .* tmp + (~neg_mask) * 1;
  % Filter out the data that exceeds 0.1
  over_mask = (data(:,ic) < 0.1);
  tmp = over_mask .* tmp + (~over_mask) * 1001;

  % Convert the out value (which is an index) to a color.
  if addColorbar,
      tmp = colors_532(tmp);
      out_img(:,ic,1) = uint16(rgb(tmp,1)/255*65535);
      out_img(:,ic,2) = uint16(rgb(tmp,2)/255*65535);
      out_img(:,ic,3) = uint16(rgb(tmp,3)/255*65535);
  else
      out(:,ic) = colors_532(tmp) - 1; % Required for uint8 image indexing
  end
end

figure(figureNum)
clf
if addColorbar,
    image(out_img)
    lidar_colorbar(rgb,color_bar,color_bar_labels,'vert');
else
    colormap(rgb/255);
    image(out)
end
