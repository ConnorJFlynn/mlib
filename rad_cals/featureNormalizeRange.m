function [X_norm, mu, range] = featureNormalizeRange(X)
%FEATURENORMALIZE Normalizes the features in X 
%   FEATURENORMALIZERange(X) returns a normalized version of X where
%   the mean value of each feature is 0 (mean subtracted) and there is a
%   division by the values range
%   is 1. This is often a good preprocessing step to do when
%   working with learning algorithms.

mu = nanmean(X);
nanfilt = isNaN(X);
range = max(X(nanfilt==0)) - min(X(nanfilt==0));

X_norm = (X - mu)/range;

% ============================================================

end
