%Compute basic stats on a curve fit
function stats = fit_stat(x,y,P,S,mu)
% Returns a number of statistics from the supplied N-order polynomial
% stats = fit_stat(x,y,P,S,mu);
%
% txt = {['N = ', num2str(stats.N)],...
%     ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
%     ['slope = ',sprintf('%1.3g',P(1))], ...
%     ['Y\_int = ', sprintf('%0.02g',P(2))],...
%     ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
%     ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
% gt = gtext(txt);
%
if ~isavar('mu')
y_hat = polyval(P,x);
else
   y_hat = polyval(P, x, S, mu);
end
r = y-y_hat;
stats.N = length(x);
stats.df = S.df;
stats.x_bar = mean(x);
stats.y_bar = mean(y);
stats.bias = stats.x_bar - stats.y_bar;
stats.normr = S.normr;
% stats.r_bar = mean(r);
stats.r_abs = mean(abs(r));
stats.SSE = sum((y-y_hat).^2);
stats.SSR = sum((y_hat-stats.y_bar).^2);
stats.SST = stats.SSR + stats.SSE;
stats.R_sqrd = stats.SSR./stats.SST;
stats.adj_R_sqrd = 1 - ((stats.SSE./stats.SST)*(length(x)-1)/S.df);
stats.RMSE = sqrt(stats.SSE/S.df);



% SSE = stats.SSE;
% dfe = stats.df;
% Rinv = 1/S.R;;
% 
% if dfe<=0
%    error('curvefit:confint:needMoreObservations',...
%      'Cannot compute confidence intervals if #observations<=#coefficients.');
% end
% 
% % X=Q*R, so X'*X = R'*Q'*Q*R = R'*R.
% % The inverse is Rinv*Rinv' and the diagonals of that can be
% % computed using the sum expression on the following line.
% v = sum(Rinv.^2,2) * (SSE / dfe);
% b = cat(1,fun.coeffValues{:})';
% alpha = (1-level)/2;
% t = -cftinv(alpha,dfe);
% db = NaN*zeros(1,length(activebounds));
% db(~activebounds) = t * sqrt(v');
% ci = [b-db; b+db];