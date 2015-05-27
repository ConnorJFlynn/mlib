function [ol] = ol_horiz_mpl004_20050805(range, max_range);
%[horiz, ol] = ol_horiz_mpl004_20050805(range);
% This is a smoothed/fitted function via table curve of a horizontal
% overlap correction determined directly from unsmoothed data.
%

%    Eqn# 7909  y=(a+cx+ex^2+gx^3+ix^4+kx^5)/(1+bx+dx^2+fx^3+hx^4+jx^5) [NL] 
%    r2=0.9999987810591687 
%    r2adj=0.9999987607126601 
%    StdErr=0.1114861384323544 
%    Fstat=54145302.09779627 
%    a= 1983.692570195181 
%    b= -55.94930544107336 
%    c= -5873.985744477678 
%    d= 1859.427089946109 
%    e= -81601.33188136169 
%    f= -13029.31733017854 
%    g= 479773.0339543475 
%    h= 19818.07089737063 
%    i= 8411.54357350852 
%    j= 100663.0452403135 
%    k= 100969.7357781541 

if nargin<3
    max_range = 10;
end
a= 1983.692570195181 ;
b= -55.94930544107336 ;
c= -5873.985744477678 ;
d= 1859.427089946109 ;
e= -81601.33188136169 ;
f= -13029.31733017854 ;
g= 479773.0339543475 ;
h= 19818.07089737063 ;
ii= 8411.54357350852 ;
jj= 100663.0452403135 ;
k= 100969.7357781541 ;
x = range;


ol = ones(size(range));
pos = find((range>0)&(range<=max_range));
x = range(pos);

y=(a + c .* x + e .* x.^2 + g .* x.^3 + ii .* x.^4 + k .* x.^5) ./(1 + b .* x + d .* x.^2 + f .* x.^3 + h .* x.^4 + jj .* x.^5);
ol(pos) = y;
