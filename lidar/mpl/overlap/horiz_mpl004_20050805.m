function [horiz] = horiz_mpl004_20050805(range, max_range);
%[horiz] = horiz_mpl004_20050805(range, max_range);
% The idea is to first calculate a smooth representation of the horizontal profile 
% with the tablecurve function and then extrapolate the near field overlap correction.
%    Eqn# 7907  y=(a+cx+ex^2+gx^3+ix^4)/(1+bx+dx^2+fx^3+hx^4) [NL] 
%    r2=0.9994460732393154 
%    r2adj=0.999433884141892 
%    StdErr=0.007907657676829737 
%    Fstat=92470.00666696023 
%    a= -0.02152061604520753 
%    b= -1.163753334714509 
%    c= 0.3063326975984949 
%    d= 1.717229483808821 
%    e= -0.4778895466285451 
%    f= 0.04302275769880436 
%    g= 0.8349495812460923 
%    h= 0.06950407211945611 
%    i= -0.02523459573847393 
% 
if nargin <2
    max_range = 10;
end
horiz = zeros(size(range));
pos = find((range>0)&(range<=max_range));
x = range(pos);

   a= -0.02152061604520753 ;
   b= -1.163753334714509 ;
   c= 0.3063326975984949 ;
   d= 1.717229483808821 ;
   e= -0.4778895466285451; 
   f= 0.04302275769880436 ;
   g= 0.8349495812460923 ;
   h= 0.06950407211945611 ;
   ii= -0.02523459573847393 ;

   y=(a + c .* x + e .* x.^2 + g .* x.^3 + ii .* x.^4)./(1 + b .* x + d .* x.^2 + f .* x.^3 + h .* x.^4);
horiz(pos) = y;

% %   double y;
% x = range(find((range>0)&(range<=10)));
% y=(-0.0005738034472976443 + x .* (0.007005564531251132 + x .* (2.134004950149387 + x .* (-0.1822621762913997 + x .* (0.005023033572522107 + x .* -4.396914529169331E-05 ))))) ./ (1.0 + x .* (0.7131394513626649 + x .* (0.7495040098543020 + x .* (0.1471724600727918 + x .* (0.01032885140690796 + x .* 0.0002799087302739472)))));
% 
% logy = log(y);
% x_gt_5 = find(x>5);
% [P] = polyfit(x(x_gt_5),logy(x_gt_5),1);
% y_line = polyval(P,x);
% y_line = exp(y_line);
% horiz = y_line;
% ol_horiz = y_line./y;
% 
% min_ol_range = min(x);
% max_ol_range = max(x);
% sub_range = find((range>min_ol_range)&(range<max_ol_range));
% new_ol = interp1( x, ol_horiz,range(sub_range));
% ol = ones(size(range));
% ol(sub_range) = new_ol;
% %
