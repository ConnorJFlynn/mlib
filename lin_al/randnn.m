function R = randn(A);
%n = box_muller(A);
% returns a matrix of size A with normally distributed random numbers 
% having a mean of zero and a standard of deviation of one.
x1 = rand(size(A));
x2 = rand(size(A));
y1 = sqrt(-2.*log(x1)).*cos( 2 .* pi .* x2 );
y2 = sqrt(-2.*log(x1)).*sin( 2 .* pi .* x2 );
R = y1 + y2;