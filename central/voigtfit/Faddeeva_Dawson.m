% Usage: d = Faddeeva_Dawson(z [, relerr])
% 
% Compute Dawson(z) = sqrt(pi)/2 * exp(-z^2) * erfi(z), the 
% Dawson integral (Dawson function), essentially a scaled imaginary
% error function, for an array or matrix of complex values z.
% 
% relerr, if supplied, indicates a desired relative error tolerance in
% w; the default is 0, indicating that machine precision is requested (and
% a relative error < 1e-13 is usually achieved).  Specifying a larger
% relerr may improve performance for some z (at the expense of accuracy).
% 
% S. G. Johnson, http://ab-initio.mit.edu/Faddeeva
