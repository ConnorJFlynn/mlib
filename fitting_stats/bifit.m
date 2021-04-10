function [P_bar, stats] = bifit(X,Y)

[P,S] = polyfit(X,Y,1);
[P_] = polyfit(Y,X,1);

ang_1 = atan(P(1)); ang_2 = atan(1./P_(1));
P_bar(1) = tan((ang_1 + ang_2)./2);
% P_bar = (P + 1./P_)./2; % Take mean of angles, not of slopes because
% slope can be infinite
% P_bar(2) = (P(2) - P_(2)./P_(1))./2;
% Don't take mean of intercepts, take intercept using mean slope with mean X and Y
P_bar(2) = mean(Y) - P_bar(1).*mean(X);

P_bar = (P + 1./P_)./2;
P_bar(2) = (P(2) - P_(2)./P_(1))./2;

stats = fit_stat(X,Y,P_bar,S);

end

