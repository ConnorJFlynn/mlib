function [dtc_cts, status] = dtc_apd6851a(raw_cts);
% This function uses a tablecurve output fit for the deadtime correction of APD6851.
% It requires counts per microsecond and outputs corrected cts/us.
% /*--------------------------------------------------------------*/
% double eqn7904(double x)
% /*--------------------------------------------------------------*
%    TableCurve Function: .\CDE14.tmp Mar 16, 2004 10:39:21 AM 
%    APD-6851-FC in MPL-PS NSA 20031111 
%    X= ln(Detected_cpus) 
%    Y= ln(Real_cpus) 
%    Eqn# 7904  y=(a+cx+ex^2)/(1+bx+dx^2+fx^3) [NL] 
%    r2=0.9999887646130569 
%    r2adj=0.9999839494472242 
%    StdErr=0.008414455961500094 
%    Fstat=267010.5007545766 
%    a= 0.02300185641971347 
%    b= -0.3760112491643825 
%    c= 1.050386710451692 
%    d= 0.004038376442503992 
%    e= -0.3625570586137006 
%    f= 0.00128412385484703 
%  *--------------------------------------------------------------*/
% 
%   double y;
%   y=(0.02300185641971347+x*(1.050386710451692+
%     x*-0.3625570586137006))/
%     (1.0+x*(-0.3760112491643825+x*(0.004038376442503992+
%     x*0.001284123854847030)));
%   return(y);

   a= 0.02300185641971347 ;
   b= -0.3760112491643825; 
   c= 1.050386710451692 ;
   d= 0.004038376442503992 ;
   e= -0.3625570586137006 ;
   f= 0.00128412385484703 ;

pos_definite = find(raw_cts>0);
min_pos_cts = min(raw_cts(pos_definite));
zerocts = find(raw_cts==0);
raw_cts(zerocts) = 1e-4* min_pos_cts;

% if any(raw_cts<=0)
%     disp('Some raw counts less than zero?!');
%     break;
%  else 
%     zero_cts = find(raw_cts==0);
%     nonzero_cts = find(raw_cts>0);
%     min_cts = min(raw_cts(nonzero_cts));
%     raw_cts(zero_cts) = (1e-4)*min_cts;
% end;
dtc_cts = raw_cts;
x=ones(size(raw_cts));
y = zeros(size(raw_cts));
pos = find(raw_cts>0);

x(pos) = log(raw_cts(pos));
y(pos)=(a + c .* x(pos) + e .* x(pos) .^ 2)./(1+b.*x(pos)+d.*x(pos).^2+f.*x(pos).^3);
%y = (a + x.* (c + e .* x) )./(1+x.*(b+d.*x));
status = 1;

dtc_cts(pos) = exp(y(pos));
if ~isreal(dtc_cts)
   status = -1;
   dtc_cts = real(dtc_cts);
end;
if any(~isfinite(dtc_cts))
   not_inf = find(~isinf(dtc_cts));
   pos_inf = find(dtc_cts==Inf);
   neg_inf = find(dtc_cts==-inf);
   dtc_cts(pos_inf) = max(dtc_cts(not_inf));
   dtc_cts(neg_inf) = min(dtc_cts(not_inf));
end
too_big = find(dtc_cts>100);
reasonable_max = max(dtc_cts(find(dtc_cts<=100)));
dtc_cts(too_big) = reasonable_max;

return