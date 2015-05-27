function y = meannonan(x,dim)
%MEAN   Average or mean value.
%   For vectors, MEAN(X) is the mean value of the elements in X. For
%   matrices, MEAN(X) is a row vector containing the mean value of
%   each column.  For N-D arrays, MEAN(X) is the mean value of the
%   elements along the first non-singleton dimension of X.
%
%   MEAN(X,DIM) takes the mean along the dimension DIM of X.
%
%   Example: If X = [1 2 3; 3 3 6; 4 6 8; 4 7 7];
%
%   then mean(X,1) is [3.0000 4.5000 6.0000] and
%   mean(X,2) is [2.0000 4.0000 6.0000 6.0000].'
%
%   Class support for input X:
%      float: double, single
%
%   See also MEDIAN, STD, MIN, MAX, VAR, COV, MODE.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2013/12/11 04:28:15 $

if nargin==1,
    % Determine which dimension SUM will use
    dim = find(size(x)~=1, 1 );
    if isempty(dim),
        dim = 1;
    end
    N = isNaN(x);
    NaNs = sum(isNaN(x));
    x(N) = 0;
    y = sum(x)./(size(x,dim)-NaNs);
else
    N = isNaN(x);
    NaNs = sum(isNaN(x),dim);
    x(N) = 0;
    y = sum(x,dim)./(size(x,dim)-NaNs);
end
