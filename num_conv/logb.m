function blog = logb(X,B);
% blog = logb(X,B)
% Computes log of an arbitrary base
if ~exist('B','var')
    B = 10;
end
blog = log(X)/log(B);