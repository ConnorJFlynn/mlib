function g = g_v_usf(usf);
% usf = usf_v_bsf(bsf);
% g parameterized in upscatter fraction
g = 1.011 - 1.036.*usf -2.005 .* usf.^2; 
