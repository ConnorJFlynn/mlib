function [Y] = smooth_(X, N)
% [Y] = smooth_(X, N);
% CJF: renamed to smooth_ to avoid conflict with built-in
% Function to return 'N' point smoothing on each column of 'X'.
% Note: In order to preserve statistics (mean, sum, etc) of
%	vector, N is rounded to an odd integer if required.
% By Chuck Antill

% --- Test parameters ---
if nargin < 2,
	error( [mfilename ': Function requires two parameters'] );
end

% --- Adjust X if required ---
[r, c] = size( X );
if r == 1,			% X is row vector, make column
	X = X';
	[r, c] = size( X );
end

% --- Round N to odd if required and test ---
N = round( N );

if floor(N/2) == N/2,		% N even
	N = N + 1;
	disp( [mfilename ': N adjusted to odd'] );
end

if ( length(N) ~= 1 ) | ( N < 1 ) | ( N > r ),
	error( [mfilename ': N must be integer >= 1 and <= size(X)'] );
end

% --- Convolute each column with N ones and divide by N ---
K = (N - 1) / 2;				% # elements to append to ends
Y = [];
for I = 1:c,
	X1 = [ X((K:-1:1),I); X(:,I); X((r:-1:r-K+1),I) ];
	Y1 = conv(X1, ones(N,1)) / N;		% M+N-1 + N-1
	Y = [ Y Y1(N:N+r-1) ];
end
