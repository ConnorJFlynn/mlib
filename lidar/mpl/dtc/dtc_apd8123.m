function [dtc_cts, status] = dtc_apd8123(raw_cts, method);
%dtc_cts, status] = dtc_apd8123a(raw_cts, method);
% Testing of alternate deadtime correction fit methods

%Method 1: logD vs logR
%Method 2: D vs R
%Method 3: logD vs logCorr
%Method 4: logD vs Corr
%Method 5: D vs Corr

if nargin < 2
   method = 5;
end

dtc_cts = raw_cts;

if method==1   %logD vs logR
   %We'll be taking a log so cull out all non-positive points
   pos = find(raw_cts>0);
   x=raw_cts(pos);
   y = zeros(size(x));
% /*--------------------------------------------------------------*/
% double eqn7903(double x)
% /*--------------------------------------------------------------*
%    TableCurve Function: .\CDEB.tmp May 26, 2004 11:28:32 PM 
%    APD_8123 
%    X= Detected_MHz 
%    Y= Real_MHz 
%    Eqn# 7903  y=(a+cx+ex^2)/(1+bx+dx^2) [NL] 
%    r2=0.9999884898397594 
%    r2adj=0.999984379068245 
%    StdErr=0.004654652178106603 
%    Fstat=325795.3632728828 
    a= 0.03848700269987637 ;
    b= -0.8118388111478394; 
    c= 1.033151671280732 ;
    d= 0.005680770890076584; 
    e= -0.815016437839836 ;
    
   x = log10(x);
   y=(0.03848700269987637 + x .* (1.033151671280732 + x .* -0.8150164378398360)) ./ (1.0 + x .* (-0.8118388111478394 + x .* 0.005680770890076584));
   dtc_cts(pos) = 10.^y;
   status = 1;

elseif method==2  %detected vs real, no logs
% Worst method due to high dynamic range
   
%    /*--------------------------------------------------------------*/
% double eqn1490(double x)
% /*--------------------------------------------------------------*
%    TableCurve Function: .\CDEA.tmp May 26, 2004 11:21:37 PM 
%    APD_8123 
%    X= Detected_kHz 
%    Y= Real_kHz 
%    Eqn# 1490  y^(-1)=a+bx^2+c/x 
%    r2=0.9999260091134359 
%    r2adj=0.9999121358222052 
%    StdErr=196.6853918268562 
%    Fstat=114870.512736779 
%     a= -3.515350224088801E-05 ;
%     b= -1.059855498668179E-13 ;
%     c= 0.9303307081504329 ;
   a= -0.03515350224088782 ;
   b= -0.0001059855498668159 ;
   c= 0.9303307081504256 ;

%We'll be dividing by x, so cull out zeros.
   pos = find(raw_cts>0);
   x=raw_cts(pos);
   y = zeros(size(x));
   y = a + b .* (x.^2) + c ./ x;
   dtc_cts(pos) = 1./y;
   status = 2;
   
elseif method==3 %Log(Detected) vs Log(Corr)
   %We'll be dividing by x, so cull out zeros.
   pos = find(raw_cts>0);
   x=raw_cts(pos);
   y = ones(size(x));
%    /*--------------------------------------------------------------*/
% double eqn7904(double x)
% /*--------------------------------------------------------------*
%    TableCurve Function: .\CDEE.tmp May 26, 2004 11:44:45 PM 
%    APD 8123 
%    X= Detected_kHz 
%    Y= Correction 
%    Eqn# 7904  y=(a+cx+ex^2)/(1+bx+dx^2+fx^3) [NL] 
%    r2=0.9997290240037561 
%    r2adj=0.9996039581593359 
%    StdErr=0.00448642400602272 
%    Fstat=10330.21856552723 
    a= 0.03560144584515973 ;
    b= -1.301800084010641 ;
    c= 0.01904296846043904 ;
    d= 0.8332617747687528 ;
    e= 0.004127034748569138 ;
    f= -0.3499884746260548 ;
    
    x = log10(x);
    y=(a+ c.*x + e.*(x.^2))./(1+ b.*x + d.* x.^2 +f .* x.^3);
    corr = 10.^y;
    x = 10.^x;
    dtc_cts(pos) = x.*corr;
   status = 3;

elseif method==4 %Log(detected) vs Corr
%We'll be dividing by x, so cull out zeros.
   pos = find(raw_cts>0);
   x=raw_cts(pos);
   y = ones(size(x));
%       Eqn# 7101  lny=(a+cx)/(1+bx) 
%    r2=0.9997564068887234 
%    r2adj=0.9997107331803591 
%    StdErr=0.02097562230941414 
%    Fstat=34885.75442064237 
    a= 0.0941668260254369 ;
    b= -0.8013053665867722 ;
    c= 0.0532392360804022 ;
    x = log10(x);
    y=(a+c.*x)./(1+b.*x);
    x = 10.^x;
    good_y = find(y>0);
    corr = exp(y(good_y));
    dtc_cts(pos(good_y)) = x(good_y).*corr;
    status = 4;
 else
    method=5; % detected vs Corr
%    Eqn# 7907  y=(a+cx+ex^2+gx^3+ix^4)/(1+bx+dx^2+fx^3+hx^4) [NL] 
    a= 1.006352250039017 ;
    b= -0.0128939514821556 ;
    c= 0.06645815289057501 ;
    d= -0.04421816308558814 ;
    e= -0.05410066947906034 ;
    f= 0.005260263422705353 ;
    g= 0.004812373021969222 ;
    h= -0.0001693920267362744 ;
    i= -0.0001041224365735016 ;
%    Eqn# 7907  y=(a+cx+ex^2+gx^3+ix^4)/(1+bx+dx^2+fx^3+hx^4) [NL] 
   %We'll be dividing by x, so cull out zeros.
   pos = find(raw_cts>0);
   x=raw_cts(pos);
   y = ones(size(x));
   numer = (a + c .* x + e .* x .^ 2 + g .* x .^ 3 + i .* x .^ 4);
   denom = (1 + b .* x + d .* x .^ 2 + f .* x .^ 3 + h .* x .^ 4); 
   good_y = find(denom~=0);
   corr = numer(good_y)./denom(good_y);
   dtc_cts(pos(good_y)) = x(good_y).*corr;
   status = 5;

end

return
