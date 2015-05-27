function [vert, ol] = ol_vert_mpl004_20030131(range);
%function [mpl.vert, mpl.ol_vert] = ol_vert_mpl004_20030131(range);
% The idea is to first calculate a smooth representation of the vertical profile 
% with the tablecurve function and then extrapolate the near field overlap correction.
%
% /*--------------------------------------------------------------*
%    TableCurve Function: E:\\ARM\\devices\\mpl\\sites\\sgp\\20030130\\tablecurve_out\\vert_ol_sgp20030130_eqn6308.c Mar 5, 2003 12:44:46 PM 
%    blue sky with initial olcorr from horiz applied 
%    X= range 
%    Y= dtc_ol_cpus 
%    Eqn# 6308  y=a+blnx+c(lnx)^2+d(lnx)^3+e(lnx)^4+f(lnx)^5+g(lnx)^6+h(lnx)^7+i(lnx)^8+j(lnx)^9+k(lnx)^(10) 
%    r2=0.9988187078558301 
%    r2adj=0.9987716273718234 
%    StdErr=0.01205100207055913 
%    Fstat=23421.19884920515 
%    a= 1.852535325261636 
%    b= 0.1962013922282891 
%    c= -0.5541109534460651 
%    d= -0.2169845238635372 
%    e= 0.1867106958667576 
%    f= 0.07386104251371497 
%    g= -0.03115450501742975 
%    h= -0.01444010443064582 
%    i= 0.001143422096047887 
%    j= 0.001115268338658495 
%    k= 0.0001223815519315258 
%  *--------------------------------------------------------------*/
% {
%   double y;
%   x=log(x);
%   y=1.852535325261636+x*(0.1962013922282891+
%     x*(-0.5541109534460651+x*(-0.2169845238635372+
%     x*(0.1867106958667576+x*(0.07386104251371497+
%     x*(-0.03115450501742975+x*(-0.01444010443064582+
%     x*(0.001143422096047887+x*(0.001115268338658495+
%     x*0.0001223815519315258)))))))));

x_sub = range(find((range>0)&(range<=10)));
x = log(x_sub);
y = 1.852535325261636 + x .* (0.1962013922282891 + x .* (-0.5541109534460651 + x .* (-0.2169845238635372 + x .* (0.1867106958667576 + x .* (0.07386104251371497 + x .* (-0.03115450501742975 + x .* (-0.01444010443064582 + x .* (0.001143422096047887 + x .* (0.001115268338658495 + x .* 0.0001223815519315258)))))))));
logy = log(y);
x_gt_5 = find(x_sub>5);
[P] = POLYFIT(x_sub(x_gt_5),logy(x_gt_5),1);
y_line = POLYVAL(P,x_sub);
y_line = exp(y_line);
vert = y_line;
ol_vert = y_line./y;

min_ol_range = min(x_sub);
max_ol_range = max(x_sub);
sub_range = find((range>min_ol_range)&(range<max_ol_range));
new_ol = interp1( x_sub, ol_vert,range(sub_range));
ol = ones(size(range));
ol(sub_range) = new_ol;
