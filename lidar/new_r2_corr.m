function [r2_corr] = new_r2_corr(range, hinge);
% Usage: [r2_corr] = new_r2_corr(range, hinge);
% This function requires a range profile and a hinge-point.  It returns a range-squared profile 
% normalized at the supplied hinge-point.  For ranges less than or equal to hinge, the correction
% factor is unity.  For ranges greater than hinge, the correction is (range/hinge)^2.

r2_corr = ones(size(range));
corr_range = find(range > hinge);
r2_corr(corr_range) = (range(corr_range)/hinge).^2;
