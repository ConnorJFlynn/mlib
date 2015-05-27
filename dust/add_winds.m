function aos = add_winds(aos);
% This adds N and S wind components derived from wind_spd and wind_dir;
aos.wind_N = NaN(size(aos.wind_spd));
aos.wind_E = aos.wind_N;
NaNs = isNaN(aos.wind_spd)|isNaN(aos.wind_dir);
aos.wind_N(~NaNs) = aos.wind_spd(~NaNs) .* cos(aos.wind_dir(~NaNs)*pi/180);
aos.wind_E(~NaNs) = aos.wind_spd(~NaNs) .* sin(aos.wind_dir(~NaNs)*pi/180);

