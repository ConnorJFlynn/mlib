function ap = ap_twpC2_20090201(range);
% Uses raw data below 0.1 km
% Uses fit above
ap.cop = zeros(size(range));
ap.crs = ap.cop;
low = range<.1;
ap.cop(low) = [    0.0003
    0.0003
   10.0001
   19.9999
   19.6264
   10.3711
   15.5621
    7.0612
    1.3546
    0.0533];
 ap.crs(low) = [    0.0003
    0.0002
   10.0001
   20.0000
   19.3716
   10.4845
   11.3784
    4.9483
    0.7734
    0.0363];
ap.cop(~low) = ap_cop(range(~low));
ap.crs(~low) = ap_crs(range(~low));

return

function y = ap_cop(range);
% % twpC2 crs.ap
% /*--------------------------------------------------------------*/
% double eqn6502(double x)
% /*--------------------------------------------------------------*
%    Eqn# 6502  y=a+b/x+c/x^2+d/x^3+e/x^4 
   a= 0.0002195742341491075 ;
   b= 0.00184531836771916 ;
   c= 0.0003013113774847502; 
   d= -7.026361961890325E-05 ;
   e= 7.01988621321395E-06 ;
   
  x=1.0./range;
  y=a + x .* (b + x .* ( c + x .* ( d + x .* e)));
return

function y = ap_crs(range);
% % twpC2 crs.ap
% /*--------------------------------------------------------------*/
% double eqn6502(double x)
% /*--------------------------------------------------------------*
%    Eqn# 6502  y=a+b/x+c/x^2+d/x^3+e/x^4 
   a= 0.000186738611156334 ;
   b= 0.001319723677358545 ;
   c= 9.627550397758672E-05; 
   d= -3.128445089707764E-05; 
   e= 4.12924583202472E-06 ;
  x=1.0./range;
  y=a + x .* (b + x .* ( c + x .* ( d + x .* e)));
return
