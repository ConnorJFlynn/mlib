function [horiz, ol] = ol_horiz_mpl004_20030131(range);
%function [mpl.horiz, mpl.ol_horiz] = ol_horiz_mpl004_20030131(range_lte_10);
% The idea is to first calculate a smooth representation of the horizontal profile 
% with the tablecurve function and then extrapolate the near field overlap correction.
%
% /*--------------------------------------------------------------*
%    TableCurve Function: E:\\ARM\\devices\\mpl\\sites\\sgp\\20030131\\tablecurve_out\\ol_sgp20030130_eqn7909.c Mar 5, 2003 2:23:41 AM 
%    e:\\arm\\devices\\mpl\\sites\\sgp\\20030131\\sgpmpl_20030130_ol.dat 
%    X= range 
%    Y= overlap (dtc cpus) 
%    Eqn# 7909  y=(a+cx+ex^2+gx^3+ix^4+kx^5)/(1+bx+dx^2+fx^3+hx^4+jx^5) [NL] 
%    r2=0.994988788479886 
%    r2adj=0.9949610743890257 
%    StdErr=0.02495700321889633 
%    Fstat=39511.95596369363 
%    a= -0.0005738034472976443 
%    b= 0.7131394513626649 
%    c= 0.007005564531251132 
%    d= 0.749504009854302 
%    e= 2.134004950149387 
%    f= 0.1471724600727918 
%    g= -0.1822621762913997 
%    h= 0.01032885140690796 
%    i= 0.005023033572522107 
%    j= 0.0002799087302739472 
%    k= -4.396914529169331E-05 
%  *--------------------------------------------------------------*/
% {
%   double y;
%   y=(-0.0005738034472976443+x*(0.007005564531251132+
%     x*(2.134004950149387+x*(-0.1822621762913997+
%     x*(0.005023033572522107+x*-4.396914529169331E-05)))))/
%     (1.0+x*(0.7131394513626649+x*(0.7495040098543020+
%     x*(0.1471724600727918+x*(0.01032885140690796+
%     x*0.0002799087302739472)))));
%   return(y);
% }
% {
%   double y;
x = range(find((range>0)&(range<=10)));
y=(-0.0005738034472976443 + x .* (0.007005564531251132 + x .* (2.134004950149387 + x .* (-0.1822621762913997 + x .* (0.005023033572522107 + x .* -4.396914529169331E-05 ))))) ./ (1.0 + x .* (0.7131394513626649 + x .* (0.7495040098543020 + x .* (0.1471724600727918 + x .* (0.01032885140690796 + x .* 0.0002799087302739472)))));

logy = log(y);
x_gt_5 = find(x>5);
[P] = polyfit(x(x_gt_5),logy(x_gt_5),1);
y_line = polyval(P,x);
y_line = exp(y_line);
horiz = y_line;
ol_horiz = y_line./y;

min_ol_range = min(x);
max_ol_range = max(x);
sub_range = find((range>min_ol_range)&(range<max_ol_range));
new_ol = interp1( x, ol_horiz,range(sub_range));
ol = ones(size(range));
ol(sub_range) = new_ol;
%
