function prof_prime = slant_attenprof(height, a, b, range, cza)
% prof_prime = slant_attenprof(height, a, b, range, cza)
% returns the attenuated backscatter profile for a given range profile 
% when profided with vertical profiles of height, ext, bscat, and cosine
% zenith angle between height and range

if ~exist('height','var')
   ST = dbstack;
   disp(['The function "',ST.name, '" requires height as input.']);
   return
end
if ~exist('a','var')
   ST = dbstack;
   disp(['The function "',ST.name, '" requires an extinction profile as input.']);
   return
end
if ~exist('b','var')
   ST = dbstack;
   disp(['The function "',ST.name, '" requires a backscatter profile as input.']);
   return
end
if ~exist('range','var')
   range = height;
end
if ~exist('cza','var')
   cza = 1;
end


a = interp1(height, a, cza .* range,'linear');
b = interp1(height, b, cza .* range,'linear');

tau = cumtrapz(range, a); 
prof_prime = b .* exp(-2*tau);