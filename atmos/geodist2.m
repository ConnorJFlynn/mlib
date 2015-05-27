function dist = geodist(lat1,lon1,lat2, lon2);
% dist = geodist(lat1,lon1,lat2, lon2);
% Returns distance in meters between any two geographic lat/lon pairs (in radians).
% Have to require that either all of these have the same dims, or one pair
% is a constant.
% drawn directly from © 2002-2006 Chris Veness
% http://www.movable-type.co.uk/scripts/LatLongVincenty.html

% WGS-84  a = 6 378 137 m (±2 m) b = 6 356 752.3142 m  	
% f = 1 / 298.257223563
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
a = 6378137; % meters,  semi-major axis
b = 6356752.3142; % meters, minor axis
f = (a-b)./a; % flattening
L = lon2 - lon1;
U1 = atan((1-f) .* tan(lat1));
U2 = atan((1-f) .* tan(lat2));
sinU1 = sin(U1);
cosU1 = cos(U1);
sinU2 = sin(U2);
cosU2 = cos(U2);
lambda = L;
lambdaP = 2*pi;
iterlimit = 20;
while (abs(lambda-(lambdaP))>1e-12)&(iterlimit>0)
    iterlimit = iterlimit - 1;
    sinLambda = sin(lambda);
    cosLambda = cos(lambda);
    sinSigma = sqrt((cosU2.*sinLambda).^2 + (cosU1.*sinU2-sinU1.*cosU2.*cosLambda).^2);
    if sinSigma ==0
        dist = 0;
        return
    end
    cosSigma = sinU1.*sinU2 + cosU1.*cosU2.*cosLambda;
    %!! I hope this is what it is supposed to do
    sigma = atan(sinSigma./cosSigma);
    sinAlpha = cosU1 .* cosU2 .* sinLambda ./ sinSigma;
    cosSqAlpha = 1 - sinAlpha.^2;
    cos2SigmaM = cosSigma - 2.*sinU1.*sinU2./cosSqAlpha;
    if (isNaN(cos2SigmaM)) 
        cos2SigmaM = 0;  
        % equatorial line: cosSqAlpha=0 (§6)
    end
    C = f/16.*cosSqAlpha.*(4+f*(4-3*cosSqAlpha));
    lambdaP = lambda;
    lambda = L + (1-C) .* f .* sinAlpha .* ...
        (sigma + C.*sinSigma.*(cos2SigmaM+C.*cosSigma.*(-1+2*cos2SigmaM.*cos2SigmaM)));
end
if iterlimit==0
    dist = NaN;
    % Failure to converge
    return
end
uSq = cosSqAlpha .* (a.^2 - b.^2) ./ (b.^2);
A = 1 + uSq./16384.*(4096+uSq.*(-768+uSq.*(320-175.*uSq)));
B = uSq./1024 .* (256+uSq.*(-128+uSq.*(74-47.*uSq)));
deltaSigma = B.*sinSigma ... 
    .* (cos2SigmaM+B./4.*(cosSigma.*(-1+2.*cos2SigmaM.*cos2SigmaM) ...
    - B./6.*cos2SigmaM.*(-3+4*sinSigma.*sinSigma).*(-3+4*cos2SigmaM.*cos2SigmaM)));
dist = b.*A.*(sigma-deltaSigma);
return    
  