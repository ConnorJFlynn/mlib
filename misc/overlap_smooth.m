function [X_out, Y_out] = overlap_smooth(X1, Y1, X2, Y2,type);
% olap = overlap_smooth(X1, Y1, X2, Y2,type);
% When provide with two vectors or matrices Y1 and Y2 having overlapping X
% domains, compute a final Y where the overlapping regions have been
% combined and weighted according to the supplied  type. 
% Type maybe be <linear> or sinusoidal based on cos^2 + sin^2 = 1;
% X1 and X2 should be monotonic.  

% Interesting. This didn't behave the way I expected for higher powers.  
% Need to re-think this to maintain a 50/50 weight at the midpoint.
% I think I need to rescale after applying the power, but only rescale to
% the midpoint to get from 1:0.5, and then flip it for the second half, 
% and take W2 as 1-W1.


if ~isavar('type'); type = 'linear'; end

X_out = union(X1, X2);
[XX, i1, i2] = intersect(X1,X2);
[~, X1_i] = setdiff(X1,XX); [~,X2_i] = setdiff(X2,XX); 
% Devise X1-weights. Should start at unity and end with zero.
% To ensure that all overlapping elements receive some weight, we define
% or vector of weights to extend one index beyond the intersection
ind_1 = max([1,i1(1)-1]); ind_end = min([length(X2),i2(end)+1]);

XX = [X1(ind_1); XX; X2(ind_end)];
W2 = XX-min(XX); W2= W2./max(W2); 
XX(1) = []; XX(end) = [];
W2(1) = []; W2(end)=[];
if ~strcmp(type,'linear')   
  D2 = (pi./2) .* W2;
  W2 = sin(D2).^2; 
end
W1 = 1-W2;
% figure; plot(XX, W1, 'o-',XX, W2,'-x')

Y_out = zeros([length(X_out),size(Y1,2)]);
Y_out(X1_i,:) = Y1(X1_i,:); 
Y_out(length(X1_i)+[1:length(XX)],:) = Y1(i1).*W1 + Y2(i2).*W2; 
Y_out((length(X1_i)+length(XX))+[1:length(X2_i)],:) = Y2(X2_i,:);

% figure; plot(X1, Y1, 'o',X2, Y2, 'o',X_out, Y_out,'*')

return