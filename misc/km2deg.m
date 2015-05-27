function deg = km2deg(km,sphere)
%KM2DEG Convert distance from kilometers to degrees
%
%   DEG = KM2DEG(KM) converts distances from kilometers to degrees as
%   measured along a great circle on a sphere with a radius of 6371 km, the
%   mean radius of the Earth.
%
%   DEG = KM2DEG(KM,RADIUS) converts distances from kilometers to degrees
%   as measured along a great circle on a sphere having the specified
%   radius. RADIUS must be in units of kilometers.
%
%   DEG = KM2DEG(KM,SPHERE) converts distances from kilometers to degrees,
%   as measured along a great circle on a sphere approximating an object in
%   the Solar System.  SPHERE may be one of the following strings: 'sun',
%   'moon', 'mercury', 'venus', 'earth', 'mars', 'jupiter', 'saturn',
%   'uranus', 'neptune', or 'pluto', and is case-insensitive.
%
%  See also DEG2KM, KM2RAD, KM2NM, KM2SM.

% Copyright 1996-2009 The MathWorks, Inc.
% $Revision: 1.10.4.4 $  $Date: 2009/03/30 23:38:30 $

if nargin == 1
    rad = km2rad(km);
else
    rad = km2rad(km,sphere);
end

deg = radtodeg(rad);
