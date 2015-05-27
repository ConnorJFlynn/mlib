function [coordX_idx,coordY_idx,projType,mdist2point,xRes,yRes] = ...
    findIndexes(LatLon, filename, proj)
% --Summary: This function finds X-Y indexes of given LatLon coordinates in
% certain HDF-EOS files.
%
% --Objective: Before using Matlab's hdfread function in Direct Index mode,
% it is necessary to know the indexes of those elements (or pixels) of the
% HDF file that data for them must be read. If the geographic coordinates
% of those pixels are known, this function can find the corresponding
% direct indexes of them in the HDF file. The type HDF files supported by
% this function can be one of the HDF-EOS datasets that are described in
% this code.
%
% --Function Description:
% This function takes Latitude-Longitude pairs with name of an HDF-EOS file
% and finds the X-Y indexes of each LatLon pair in the HDF file. The
% function will work with HDF files which have:
% 1. Sinusoidal Projection (e.g., MODIS LST Level 3 product);
% 2. Global Cylindrical Equal-Area Projection or Cylindrical Equal-Area 
% Scalable Earth Grid (EASE)
% Important: LatLon pairs must be given in a matrix where first
% column contains Latitude and the SECOND COLUMN LONGITUDE, while the
% function will write X as first and Y as the second output. One or more
% pairs of LatLon coordinates can be given, where each line will contain
% coordinates of one point. The first two output variables will contain 
% the X and Y indexes with the same order as LatLon inputs. The function 
% is tested with the MODIS LST Level 3 (MOD11A1) and MODIS BRDF/Albedo
% (MCD43B3) products for proj=1 (Sinusoidal), and AMSR-E Soil Moisture
% (AMSR_E_L3_DailyLand_V07) product for proj=2 (EASE grid). 
%
% --Note: Matlab (as well as ENVI/IDL) assign given coordinates to the
% UpperLeft corner of each pixel, if the given LatLon coordinates are
% correct at the center of the pixel covering the area of interest, they
% will still be matched with the UL corner metric coordinates of data (in
% Sinusoidal and EASE Grid). Therefore, this function adds half the pixel
% size of any dataset (as specified by filename) to the existing metric
% coordinates of that dataset before matching with the LatLon point. This
% is achieved by xStartLooking=ULx+xRes/2; and yStartLooking=ULy+yRes/2;
% lines of code (see function code below). Therefore, care should be given
% when choosing the input LatLon coordinates so that they are as close as
% possible to the center of target pixel. To achieve this, mdist2point
% output parameter can be experimented to make it minimum. Effectively it
% should be close to 0, but a value of half-the-pixel-size of the dataset
% is acceptable.If the given LatLon coordinates are recorded by, e.g., GPS
% and are meant to be definite, they should still be adjusted to the center
% of pixel in teh dataset, or a pixel that best represents that LatLon
% point in the image/dataset. Otherwise, the code will provide the indexes
% of a pixel that is mathematically nearest to the LatLon point measured 
% from the center of the pixel to the given LatLon coordinates. In any
% case, mdist2point should be less than half-the-pixel-size.
%
% --Input variables:
%   LatLon: matrix with two columns: Latitudes and Longitudes 
%   filename: HDF file name (including filepath if file is not in current 
%   directory) 
%   proj: Projection type of the HDF file (currently only 1 for Sinusoidal 
%   or 2 for EASE-Grid)
%
% --Output variables: 
%   coordX_idx: x indexes of given LatLon coordinates in the given HDF file 
%   coordY_idx: y indexes of given LatLon coordinates in the given HDF file 
%    (if 0 is returned by coordX_idx or coordY_idx means the LatLon pair   
%   could not be found in the given image/HDF file). 
%   projType: (string) full name of the given projection type
%   mdist2point: minimum distance to each point in meters that the function
%   could work out (should not be bigger than xRes or yRes). 
%   xRes: resolution of the image along x or longitudes
%   yRes: resolution of the image along y or latitudes (will be negative->
%   this is now changed to positive in updated version, latitudes origin
%   is changed to 0, and LR corner has the maximum latitude. Both latitudes
%   and longitudes will be positive for any coordinates).
% 
% --Example:
% LatLon=[-43.5,172.5; -43.9,172.75] %some New Zealand cities (Chch,
% %Ashburton)
% %download the following file and put it in the current directory:
% %ftp://e4ftl01.cr.usgs.gov/MODIS_Dailies_E/MOLA/MYD11A1.005/2012.05.07/
% %    MYD11A1.A2012128.h30v13.005.2012129204401.hdf 
% filename='./MYD11A1.A2012128.h30v13.005.2012129204401.hdf';
% proj=1; 
% [coordX_idx,coordY_idx,projType,mdist2point,xRes,yRes] = ...
%    findIndexes(LatLon,filename, proj)
% The returned X and Y are indexes of the LST pixels covering 1km^2 in the 
% above cities.
%
% First Version: Feb 19 2012 (V01)
% Added functionailty: Apr 25 2012 (V02)
% Updated: Jun 15 2012
% Email: sohrabinia.m@gmail.com
%__________________________________________________________________________
%--------------------------------------------------------------------------
%% Theory:
% see: http://geospatialmethods.org/documents/ppgc/ppgc.html (Map Proj
% theory) and http://www.progonos.com/furuti/MapProj/Dither/CartHow/HowER_W12/howER_W12.html#DeductionEquirectangular
%<<< Sinusoidal projection: convert from Lat-Lon to Sinusoidal >>>>>>>>>>>>
% http://mathworld.wolfram.com/SinusoidalProjection.html 
% x=(lambda-lambda0)*cos(phi) 
% y=phi
% Latitude phi (\phi) and Longitude lambda (\lambda)
%..........................................................................
%<<< Global Cylindrical Equal-Area Scalable Earth Grid (EASE-Grid) >>>>>>>>
% http://nsidc.org/data/ease/ease_grid.html (EASE description).
% x = x0 + R/xRes * lambda * cos(30) 
% y = y0 - R/yRes * sin(phi) / cos(30)
% http://nsidc.org/data/docs/daac/ae_land3_l3_soil_moisture.gd.html (data
% description).
% http://nsidc.org/data/docs/daac/ae_land3_l3_soil_moisture/geolocate.html
% (ENVI method to work out AMSRE SM dataset projection).
% http://nsidc.org/data/docs/daac/ae_land3_l3_soil_moisture.gd.html (AMSRE
% SM dataset summary).
%--------------------------------------------------------------------------


if nargin < 3
   disp(['Error! three mandatory input arguments are required for this '...
       'function, please see Function Description for more information']); 
   return
end
projType={'Sinusoidal'; 'Global Cylindrical Equal-Area'};

if proj>2
    coordX_idx=0; coordY_idx=0; projType='Wrong projType';
    msgbox(sprintf([' "proj = %d" does not match any acceptable projection '...
        'types, only 1: Sinusoidal, and 2: Cylindrical Equal-Area Scalable '...
        'Earth Grid (EASE) are accepted by this function; '...        
        ' please try again'],proj),...
        'Invalid projection type requested!','Error','modal');
    return     %abort code if mismatch detected
end

% Specify Earth's Equatorial Radius based on the Projection Type:
if proj==1
    R=6371007.181; %Radius of Earth in meters (Sinusoidal)
    %False Easting: 0.0
    %False Northing: 0.0
    %ISin NZone: 86400 (see
    %http://geospatialmethods.org/documents/ppgc/ppgc.html)
elseif proj ==2
    R = 6371228; %m R of Earth (EASE & all spherical projns, no eccent.)
    %All spherical projns, eccentricity should not be specified, and 
    %the default equatorial radius is 6371228 m.
else %more projections to work out:
    R=6378137.0; %R Earth (m), WGS84 ellipsoid (eccentricity: 0.081819190843)
    %All elliptical projtns: eccent. 0.082271673 & R 6378206.4 (defaults).    
end

% Circumference of a circle: %C=pi*d so C=pi*R*2
C=pi*(R*2); %circumference of Earth in Equator (meters)
dist1degree=C/360;%metric distance equivalent to 1 degree in Equator



lambda0=0;
% read HDF EOS file information from the given file:
% http://www.mathworks.com/company/newsletters/digest/nov02/earth_pt3.html
% left-right-top-botton bounds and rows-columns of the HDF file are needed
geoInfo = hdfinfo(filename,'eos');    % HDF file info in EOS mode
xDim=geoInfo.Grid(1).Columns;         % columns of data
yDim=geoInfo.Grid(1).Rows;            % rows of data
ULx0=geoInfo.Grid(1).UpperLeft(1);     % UpperLeft bound X
LRx0=geoInfo.Grid(1).LowerRight(1);    % LowerRight bound X
ULy0=geoInfo.Grid(1).UpperLeft(2);     % UpperLeft bound Y
LRy0=geoInfo.Grid(1).LowerRight(2);    % LowerRight bound Y

% add offset: 
xOffset =0;%offset (false Easting)
yOffset =0;%offset (false Northing)

% reformat UL/LR corners
LRx=abs(LRx0 - ULx0); %let LRx as the largest x in dataset 
LRy=abs(LRy0 - ULy0); %let LRy as the largest y in dataset 
ULx=ULx0 - ULx0;      %turn ULx as origin and let it be 0
ULy=ULy0 - ULy0;      %turn ULy as origin ane let it be 0
%LLy=LRy;              %LLy is the same as LRy (not needed)
%LLx=ULx;              %LLx is the same as ULx (not needed)
%ULx=ULx0;ULy=ULy0;LRx=LRx0;LRy=LRy0; %no change (diagnostic)

% calculate resolution across X and Y:
xRes=(LRx-ULx)/xDim;  %resolution along x (longitude) in meters(positive)
%yRes=(ULy-LLy)/yDim;  %resolution along y (latitude) in meters(negative)
yRes=(LRy-ULy)/yDim;  %resolution along y (latitude) in meters(positive)

% determine where to start searching points x-y; since the coordinates
% start from UL corner of pixel, but we want center of pixel, xRes/2 or
% yRes/2 will be added to the start2look point:
xStartLooking=ULx+xRes/2; %start looking from UL corner 
yStartLooking=ULy+yRes/2; %start looking from UL corner

n=size(LatLon,1);      %number of points to look for
coordX_idx=zeros(n,1); %point's x index in HDF file: initialize to 0
coordY_idx=zeros(n,1); %point's y index in HDF file: initialize to 0
mdist2point=ones(n,1)*(abs(xRes)+abs(yRes))*10;

% start looking for all points based on Lat-Lon coordinates:
for i2=1:n
    phi=LatLon(i2,1);    %latitude coordinate
    lambda=LatLon(i2,2); %longitude coordinate
    
    if proj == 1 % Sinusoidal Projection:
        x=(lambda-lambda0)*cos(phi*pi/180);%lon in Sin proj in local lat
        y=phi;                             %latitude in Sin projection
        x=abs(x)*dist1degree-abs(ULx0); %x in m in Global Sin proj
        y=abs(y)*dist1degree-abs(ULy0); %y in m in Global Sin proj
     %xMax=180*cos(phi*pi/180); %max longitude in Sin proj in local lat    
     %cLocal=C*(xMax*2)/360; %circumference of Earth in local latitude (m)
     %dist1degLocal = cLocal/360;%metric dist = 1 deg in local lat 
    elseif proj ==2 % EASE projection:
        % Formula (http://nsidc.org/data/ease/ease_grid.html):
        % �r = r0 + R/C * lambda * cos(30)
        % �s = s0 - R/C * sin(phi) / cos(30)
        % �h = cos(phi) / cos(30)
        % �k = cos(30) / cos(phi)
        % r Column coordinate
        % s Row coordinate
        % h Particular scale along meridians
        % k Particular scale along parallels
        % lambda Longitude in radians (lambda*pi/180)
        % phi Latitude in radians (phi*pi/180)
        % R Radius of the Earth = 6371.228 km in Equator
        % C Nominal cell size
        % r0 Map origin column
        % s0 Map origin row
        %Note: true latitude (30) must also be converted to radians
        r0=floor(xDim/2);
        s0=floor(yDim/2);
        r_x = r0 + R/xRes * (lambda*pi/180) * cos(30*pi/180); %x coord in EASE proj
        s_y = s0 - R/yRes * sin(phi*pi/180) / cos(30*pi/180); %y coord in EASE proj
        %h=cos(phi*pi/180)/cos(30*pi/180);%scale along meridians(not needed)
        %k=cos(30*pi/180)/cos(phi*pi/180);%scale along parallels(not needed)
        x=r_x*xRes; % x in Metric scale
        y=s_y*yRes; % y in Metric scale       
    end
    
    % Now search for the nearest pixel to the given coordinates:
    xMetric=x+xOffset;   %x coordinate in meters adjusted for add-offset
    yMetric=y+yOffset;   %y coordinate in meters adjusted for add-offset
    distInitial=(abs(xRes)+abs(yRes))*10; %approx initial dist based on grid res
    pixelX=xStartLooking; %initial pixel x to check the distance
    for i=1:xDim
        pixelY=yStartLooking; %initial pixel y to check the distance
        for j=1:yDim
            sq1=(pixelY-yMetric)^2; % lat part of dist func
            sq2=(pixelX-xMetric)^2; % lon part of dist func
            dFound=sqrt(sq1+sq2);   % distance function   
            %dfo(i,j)=dFound; %store distances (diagnostic)
            if dFound<distInitial
                coordX_idx(i2)=i;   % point's x index in HDF file (returned)
                coordY_idx(i2)=j;   % point's y index in HDF file (returned)
                distInitial=dFound; % replace initial dist with found dist
            end
            pixelY=pixelY+yRes;  % move 1 pixel forward along Lat
        end
        pixelX=pixelX+xRes;      % move 1 pixel forward along Lon
    end
    mdist2point(i2)=distInitial; %distance from given point to its closest  
    %pixel (indexes of which are given in coordX_idx & coordY_idx)
end

projType=projType{proj}; %return full name of chosen Projection Type
return 

end %end of function