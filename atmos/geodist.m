function dist = geodist(lat1,lon1,lat2, lon2);
% dist = geodist(lat1,lon1,lat2, lon2);
% Returns distance in meters between any two geographic lat/lon pairs.
% Have to require that either all of these have the same dims, or one pair
% is a constant.
% 
% Based merely on a scattering angle computation and then multiplication of
% the scattering angle by the solar radius.

% WGS-84  a = 6 378 137 m (±2 m) b = 6 356 752.3142 m  	
if (max(size(lat1))~=max(size(lon1)))||(max(size(lat2))~=max(size(lon2)))
    disp('Pairs of lat and lon must match dimensions')
    return
end
if ((max(size(lat1))>1)&&(max(size(lat2))==1))
    lat2 = lat2*ones(size(lat1));
    lon2 = lon2*ones(size(lon1));
elseif ((max(size(lat1))==1)&&(max(size(lat2))>1))
    lat1 = lat1*ones(size(lat2));
    lon1 = lon1*ones(size(lon2));
end    
if max(abs([lat1, lon1, lat2, lon2]))>(pi)
    %Then these are probably in degrees so convert to radians
    lat1 = lat1 *pi/180;
    lon1 = lon1 *pi/180;
    lat2 = lat2 *pi/180;
    lon2 = lon2 *pi/180;
end
% SA = scat_ang_rads(sza,saz,za,az);
SA = zeros(size(lat1));
SA(:) = scat_ang_rads(lat1(:),lon1(:),lat2(:),lon2(:));
a = 6378137; % meters,  semi-major axis
b = 6356752.3142; % meters, minor axis
r = (a+b)./2;
dist = r.*SA;
return    
  