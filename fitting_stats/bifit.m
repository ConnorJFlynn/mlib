function [P_bar, stats] = bifit(X,Y)

[P,S] = polyfit(X,Y,1);
[P_] = polyfit(Y,X,1);
P_bar = (P + 1./P_)./2;
P_bar(2) = (P(2) - P_(2)./P_(1))./2;
stats = fit_stat(X,Y,P_bar,S);

end

