function [xi, yi] = world2ind(x,y,hdf_in);
% returns grid indices corresponding to a set of world coordinates in the
% provided hdf file % x is for Lon, y is for Lat
if ~exist('hdf_in','var')||~exist(hdf_in,'file')
    hdf_in = getfullname('*.hdf','hdf4','Select a MODIS hdf4 file.');
end
info = hdfinfo(hdf_in);
parse_me = info.Attributes(2).Value; % this should be the content of the "StructMetadata.0" attribute
fstr = ['XDim='];
ii = strfind(parse_me,fstr);
xdim = sscanf(parse_me(ii+length(fstr):end),'%d');
fstr = ['YDim='];
ii = strfind(parse_me,fstr);
ydim = sscanf(parse_me(ii+length(fstr):end),'%d');
fstr = ['UpperLeftPointMtrs=('];
ii = strfind(parse_me,fstr);
UL = sscanf(parse_me(ii+length(fstr):end),'%f,%f');
fstr = ['LowerRightMtrs=('];
ii = strfind(parse_me,fstr);
LR = sscanf(parse_me(ii+length(fstr):end),'%f,%f');
fstr = ['ProjParams=('];
ii = strfind(parse_me,fstr);
R = sscanf(parse_me(ii+length(fstr):end),'%f'); %     R = 6371007.18100; %Earth's radius in meters
LL = [UL(1),LR(2)];
UR = [LR(1), UL(2)];
tile_width = 2*pi*R ./ 36;
tile_height = tile_width;
cells = xdim; %number of pixels in the MODIS tile image
pixel_size = tile_width ./ cells;
% This longitude part here doesn't work because we don't have a rectangular
% array.  In KORUS, the UL is actually to the right of the LR corner.
% So what to do?  In fact, while the y divisions are uniform segments in
% Lat and straight, the x contours are sinusoidals.  This might mean that
% "samples" are also sinusoids

xi = floor(interp1([LL(1),UR(1)],[1,xdim],x,'linear')-1); % longitude
yi = floor(interp1([UR(2),LL(2)],[1,ydim],y,'linear')-1); % latitude

% 
% x_steps = pixel_size*[0:xdim-1];
% xi = interp1([LL(1)+pixel_size],[x_steps+1],x,'nearest');
% pixel_size = tile_height ./ ydim;
% y_steps = pixel_size*[0:ydim-1];
% yi = interp1([LL(2)+pixel_size],[y_steps+1],y,'nearest');
% 
% yi = interp1([LL(2),UR(2)],[1,ydim],y,'nearest');
% horiz_tile_no = (LL(1) +pi*R)./tile_width;
% vert_tile_no = (17-(LL(2) + pi*R./2)./tile_height);


%     x_coor_lower_left = -pi*R + horizontal_tile_no * tile_width;
%   y_coor_lower_left = -pi*R/2 + (17 - vertical_tile_no) * tile_height;
%   
%   
%   horizontal_tile_no = 9; % SEAC4RS airport
%   vertical_tile_no = 6; % SEAC4RS airport


return