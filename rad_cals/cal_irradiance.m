
function star = cal_irradiance(star)
% star = cal_irradiance(star)
% 2DU: repeat comparisons with AATS
   star.rad(:,star.suns) = star.rad(:,star.suns)./(ones(size(star.Lambda))*star.raw.Integration(star.suns));
return
