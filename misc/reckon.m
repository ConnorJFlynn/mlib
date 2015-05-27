function [latout,lonout] = reckon(varargin)
%RECKON  Point at specified azimuth, range on sphere or ellipsoid
%
%   [LATOUT, LONOUT] = RECKON(LAT, LON, ARCLEN, AZ), for scalar inputs,
%   calculates a position (LATOUT, LONOUT) at a given range, ARCLEN, and
%   azimuth, AZ, along a great circle arc from a starting point defined by
%   LAT and LON.  LAT and LON are in degrees.  ARCLEN must be expressed as
%   degrees of arc on a sphere, and equals the length of a great circle arc
%   connecting the point (LAT, LON) to the point (LATOUT, LONOUT).  AZ,
%   also in degrees, is measured clockwise from north.  RECKON calculates
%   multiple positions when given four arrays of matching size. When given
%   a combination of scalar and array inputs, the scalar inputs are
%   automatically expanded to match the size of the arrays.
%
%   [LATOUT, LONOUT] = RECKON(LAT, LON, ARCLEN, AZ, UNITS), where UNITS is
%   either 'degrees' or 'radians', specifies the units of the inputs and
%   outputs, including ARCLEN.  The default value is 'degrees'.
%
%   [LATOUT, LONOUT] = RECKON(LAT, LON, ARCLEN, AZ, ELLIPSOID) calculates
%   positions along a geodesic arc on an ellipsoid, as specified by the
%   input ELLIPSOID.  ELLIPSOID is a reference ellipsoid (oblate spheroid)
%   object, a reference sphere object, or a vector of the form
%   [semimajor_axis, eccentricity].  The range, ARCLEN, must be expressed
%   in units of length that match the units of the semimajor axis of the
%   ellipsoid.
%
%   [LATOUT, LONOUT] = RECKON(LAT, LON, ARCLEN, AZ, ELLIPSOID, UNITS)
%   calculates positions on the specified ellipsoid with LAT, LON, AZ,
%   LATOUT, and LONOUT in the specified angle units. 
%
%   [LATOUT,LONOUT] = RECKON(TRACK,...) calculates positions on great
%   circles (or geodesics) if TRACK is 'gc' and along rhumb lines if TRACK
%   is 'rh'. The default value is 'gc'.
%
%   See also AZIMUTH, DISTANCE.

% Copyright 1996-2011 The MathWorks, Inc.
% $Revision: 1.13.4.12 $  $Date: 2011/12/11 07:43:15 $

narginchk(4,7)
[useGeodesic,lat,lon,rng,az,ellipsoid,units,insize] = parseInputs(varargin{:});
if useGeodesic
    if ellipsoid(2) ~= 0
        [newlat,newlon] = geodesicfwd(lat,lon,az,rng,ellipsoid);
    else
        [newlat,newlon] = greatcirclefwd(lat,lon,az,rng,ellipsoid(1));
    end
else
    if ellipsoid(2) ~= 0
        [newlat,newlon] = rhumblinefwd(lat,lon,az,rng,ellipsoid);
    else
        [newlat,newlon] = rhumblinefwd(lat,lon,az,rng,ellipsoid(1));
    end
end

newlon = npi2pi(newlon,'radians');
[newlat, newlon] = fromRadians(units, newlat, newlon);
newlat = reshape(newlat, insize);
newlon = reshape(newlon, insize);

%  Set the output arguments
if nargout <= 1
    % Undocumented command-line output for single points.
    latout = [newlat newlon];
elseif nargout == 2
    latout = newlat;
    lonout = newlon;
end

%--------------------------------------------------------------------------

function [useGeodesic,lat,lon,rng,az,ellipsoid,units,insize] ...
                                              = parseInputs(varargin)

% Handle optional first input argument
if (nargin >= 1) && ischar(varargin{1})
    trackstr = validatestring(varargin{1}, {'gc','rh'}, 1);
    varargin(1) = [];
    useGeodesic = strcmp(trackstr,'gc');
else
    useGeodesic = true;
end

% Assign the fixed arguments.
lat = varargin{1};
lon = varargin{2};
rng = varargin{3};
az  = varargin{4};
                         
% Parse the optional arguments: ELLIPSOID and UNITS.
ellipsoid = [];
units     = 'degrees';

n = numel(varargin);
if (n == 5)
    if ischar(varargin{5})
        units = checkangleunits(varargin{5});
    else
        ellipsoid = checkellipsoid(varargin{5}, 'RECKON', 'ELLIPSOID');
    end
end

if (n == 6)
	ellipsoid = checkellipsoid(varargin{5}, 'RECKON', 'ELLIPSOID');
    units     = checkangleunits(varargin{6});
end

% If ELLIPSOID was omitted, use a unit sphere.
if isempty(ellipsoid)
    ellipsoid = [1 0];
    % Make sure RNG is a distance on the unit sphere.
    rng = toRadians(units,rng);
end

% Check for matching lat-lon-az-rng sizes and expand scalar inputs if
% necessary.
[lat, lon, az, rng, insize] = expandScalarInputs(lat, lon, az, rng);
if isempty(insize)
    error(['map:' mfilename ':inconsistentLatLonAzRngSizes'], ...
        'Lat, long, azimuth and range inputs must have same dimension')
end

% Make sure angles are in radians and convert the input
% arrays to column vectors.
[lat, lon, az] = toRadians(units, lat(:), lon(:), az(:));
rng = rng(:);
