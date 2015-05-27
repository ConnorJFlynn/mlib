function new_ol = ol_renorm(old_ol, factor, pin);
% 2004-11-12
% This function reshapes an existing overlap profile.  It keeps the
% end-points of the correction unchanged but flexes the interior points.
% This same technique can be applied to adjusting an afterpulse correction.
% I'm also intending to try another that only pins one end point and allows
% the other to scale.

test_renorm_ol = real(log(old_ol)); 
peak = test_renorm_ol(pin);
test_renorm_ol = test_renorm_ol./peak; 
test_renorm_ol = test_renorm_ol .^ (factor); 
test_renorm_ol = test_renorm_ol .* peak;
test_renorm_ol = real(exp(test_renorm_ol));
% figure; semilogx([old_ol ], mpl.range, 'r.', test_renorm_ol, mpl.range, 'b'); 
% legend(['original', 'modified']); zoom;
% correction = test_renorm_ol ./ old_ol; 
% figure; plot(correction(mpl.r.lte_5), mpl.range(mpl.r.lte_5));
new_ol = test_renorm_ol;