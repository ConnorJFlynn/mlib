function MHz = dtc_sgp_(MHz,in_time);
% MHz = dtc_sgp(MHz,in_time);
% 
dtc.time(1) = [inf];
dtc.dtc{1} = @prescale_generic_dtc;

nxt = length(dtc.time)+1;
dtc.time(nxt) = [datenum('19960501','yyyymmdd')];
dtc.dtc{nxt} = @dtc_sgp_19960501
% deadtime_correction_mpl002_a

nxt = length(dtc.time)+1;
dtc.time(nxt) = [datenum('19970414','yyyymmdd')];
dtc.dtc{nxt} = @dtc_sgp_19970414
% deadtime_correction_mpl004

nxt = length(dtc.time)+1;
dtc.time(nxt) = [datenum('19971006','yyyymmdd')];
dtc.dtc{nxt} = @dtc_sgp_19971006
%deadtime_correction_mpl002_b

nxt = length(dtc.time)+1;
dtc.time(nxt) = datenum('19980812','yyyymmdd');
dtc.dtc{nxt} = @dtc_sgp_19980812; % Need to check these units
% deadtime_correction_mpl054_a
% actually same detector as mpl1002_b above

nxt = length(dtc.time)+1;
dtc.time(nxt) = datenum('19981111','yyyymmdd');
dtc.dtc{nxt} = @dtc_sgp_19981111; % Need to check these units
% deadtime_correction_mpl054_b

nxt = length(dtc.time)+1;
dtc.time(nxt) = datenum('20000303','yyyymmdd');
dtc.dtc{nxt} = @dtc_sgp_20000303; % Need to check these units
% deadtime_correction_mpl054_c

nxt = length(dtc.time)+1;
dtc.time(nxt) = datenum('20000502','yyyymmdd');
dtc.dtc{nxt} = @dtc_sgp_20000502; % Need to check these units
% deadtime_correction_mpl054_d

nxt = length(dtc.time)+1;
dtc.time(nxt) = datenum('20020515','yyyymmdd');
dtc.dtc{nxt} = @dtc_sgp_20020515; % Need to check these units
% deadtime_correction_mpl054_g

nxt = length(dtc.time)+1;
dtc.time(nxt) = [datenum('20030115','yyyymmdd')];
dtc.dtc{nxt} = @dtc_sgp_20030115; % Need to check these units
% deadtime_correction_mpl052_h

nxt = length(dtc.time)+1;
dtc.time(nxt) = [datenum('20040515','yyyymmdd')];
dtc.dtc{nxt} = @deadtime_correction_apd8126; % Need to check these units
%deadtime_correction_apd8126


% Add starting times and detector dtc functions if available...

if ~exist('in_time','var')||isempty(in_time)
   first = 1;
else
   first = find(in_time>dtc.time,1);
end
first = max([1,first]);
MHz = dtc.dtc{first}(MHz);

return

function dtc = dtc_sgp_19960501(D);
% deadtime_correction_mpl002_a(float *bscat, int nbins, char *comment)

dtcf = ones(size(D));
r =  (D<=0);
d = D(r);
dtcf(r) = 1;
d = D(~r);
dtcf(r) = 1.002+ (8.588e-2).* d + (-1.752e-2).* d.^2 + ...
   (4.021e-3).* d.^3 + (-3.361e-4).* d.^4 + (1.162e-5).* d.^5;
dtcf(dtcf<=0) = 1;
dtc = dtcf .* D;

return

function dtc = dtc_sgp_19970414(D);
% deadtime_correction_mpl004
dtcf = ones(size(D));
r =  (D< 1.1);
d = D(r);
dtcf(r) =  1.002+ (9.815e-2).* d + (-1.499e-1).*d.^2 + (1.036e-1).*d.^3;
r = ((1.1 <= D) & (D < 17.1));
dtcf(r) =  1.002+ (6.684e-2)  .* d + (-1.297e-2) .*d.^2 + ...
   (3.843e-3) .*d.^3 + (-3.618e-4) .*d.^4 + (1.271e-5)  .*d.^5;
r = D >= 17.1;
dtcf(r) = -2.268e+2 + (4.731e+1) .* d  + (-3.254)   .* d.^2 + (7.488e-2) .* d.^3;
dtcf(dtcf<=0) = 1;
dtc = dtcf .* D;
return 

function dtc = dtc_sgp_19971006(D)
%deadtime_correction_mpl002_b(D);
% /****************************************************************************
%  * This function calculates the deadtime correction for the MPL002 instrument
%  * which was at the SGP CART CF site from 10/7/1997 - current.  Correction provided
%  * by Dennis Hlavka, NASA/GSFC.
%  *              Detector #2361
dtcf = ones(size(D));
r = D<1.1;
d = D(r);
dtcf(r) = 1.002 + (9.815e-2) .*d -1.499e-1 .* d.^2  + (1.036e-1).* d.^3;
r =((1.1 <= d) && (d < 17.1)); 
d = D(r);
dtcf(r) =  1.002 + (6.684e-2).* d + (-1.297e-2) .* d.^2 + (3.843e-3).* d.^3 + (-3.618e-4).* d.^4 + (1.271e-5) .* d.^5;
r =(d >= 17.1); 
d = D(r);
dtcf(r) = -2.268e+2 + (4.731e+1) .*d + (-3.254)   .* d.^2+ (7.488e-2) .* d.^3;
dtcf(dtcf<=0) = 1;
dtc = dtcf .* D;
return

function dtc = dtc_sgp_19980812(D);
% deadtime_correction_mpl054_a
% apparently same detector (and thus same correction) as MPL002_b
dtcf = ones(size(D));
r = D<1.1;
d = D(r);
dtcf(r) = 1.002 + (9.815e-2) .*d -1.499e-1 .* d.^2  + (1.036e-1).* d.^3;
r =((1.1 <= d) && (d < 17.1)); 
d = D(r);
dtcf(r) =  1.002 + (6.684e-2).* d + (-1.297e-2) .* d.^2 + (3.843e-3).* d.^3 + (-3.618e-4).* d.^4 + (1.271e-5) .* d.^5;
r =(d >= 17.1); 
d = D(r);
dtcf(r) = -2.268e+2 + (4.731e+1) .*d + (-3.254)   .* d.^2+ (7.488e-2) .* d.^3;
dtcf(dtcf<=0) = 1;
dtc = dtcf .* D;
return 



function dtc = dtc_sgp_19981111(D);
% deadtime_correction_mpl054_b
dtcf = ones(size(D));
r = D<16.753;
d = D(r);
dtcf(r) =  9.916e-1 + ((1.085e-1)  .* d + (-1.751e-2) .* d.^2 + (1.300e-3)  .* d.^3;

r = ((16.753 <= D) && (D < 19.1486));
d = D(r);
dtcf(r) =   -2.00885e+3+ (3.466e+2)  .* d + (-1.995e+1) .* d.^2 + (3.840e-1)  .* d.^3;
r = (D>=19.1486);
d = D(r);
dtcf(r) =   3.443e+3 + (-1.816e+2) .* d + (-9.243e+0)   .* d.^2 + (4.889e-1) .* d.^3;
dtcf(dtcf<=0) = 1;
dtc = dtcf .* D;
return 

function dtc = dtc_sgp_20000303(D);
% deadtime_correction_mpl054_c
dtcf = ones(size(D));
r = D<15.674788;
d = D(r);
dtcf(r) =  9.885e-1 + ((9.324e-2)  .* d + (-9.877e-3) .* d.^2 + (1.032e-3)  .* d.^3;

r = ((15.674788 <= D) && (D < 18.704317));
d = D(r);
dtcf(r) =   -6.320e+2 + ((1.2063e+2))  .* d + (-7.663e+0) .* d.^2 + (1.631e-1)  .* d.^3;
r = (D>=18.704317);
d = D(r);
dtcf(r) =   -4.982e+1 + (-7.740e-1) .* d + (5.827e-2)   .* d.^2 + (8.367e-3) .* d.^3;
dtcf(dtcf<=0) = 1;
dtc = dtcf .* D;
return 


function dtc = dtc_sgp_20000502(D);

dtcf = ones(size(D));
r =  (D<12.0453);
d = D(r);
dtcf(r) = 9.800e-1 + (8.848e-2).* d+ (-9.578e-3).* d.^2 + (1.400e-3).* d.^3;
r = (D>=12.0453 & D<16.2379);
d = D(r);
dtcf(r) = -7.284e+2 + (1.65453e+2) .* d + (-1.249e+1).*d.^2 + (3.151e-1).*d.^3;
r = (D>=16.2379);
d = D(r);
dtcf(r) = 9.826e+3 +(-6.10027e+2) .* d + (-3.686e+1).*d.^2 + (2.292) .* d.^3;
dtcf(dtcf<=0) = 1;
dtc = dtcf .* D;
return


function dtc = dtc_sgp_20020515(D);
% deadtime_correction_mpl054_g
dtcf = ones(size(D));
r = D<10.2437;
d = D(r);
dtcf(r) =  9.833e-1 + ((1.179e-1)  .* d + (-1.365e-2) .* d.^2 + (2.740e-3)  .* d.^3;

r = ((10.2437 <= D) && (D < 11.7491));
d = D(r);
dtcf(r) =   -6.649e+2 + ((1.881e+2))  .* d + (-1.774e+1) .* d.^2 + (5.613e-1)  .* d.^3;
r = (D>=11.7491);
d = D(r);
dtcf(r) =   (-7.608e+3) + (1.93223e+3) .* d + (-1.638e+2)   .* d.^2 + (4.639) .* d.^3;
dtcf(dtcf<=0) = 1;
dtc = dtcf .* D;;
return 


function dtc_cts = dtc_sgp_20030115(raw_cts);
%deadtime_correction_mpl052_h
% This function uses a tablecurve output fit for the deadtime correction of APD6850.
%    Deadtime Correction APD6850 sgp20030130 
%    X= Detected log(cpus) 
%    Y= Actual log(cpus) 
%    Eqn# 7903  y=(a+cx+ex^2)/(1+bx+dx^2) [NL] 
%    r2=0.9999859311811476 
%    r2adj=0.9999815346752562 
%    StdErr=0.0162074304364773 
%    Fstat=302082.2324953516 
%    a= 0.05360696430030077 
%    b= -0.3443590921004309 
%    c= 1.039719372269183 
%    d= 0.000130254480891871 
%    e= -0.3435271210950493 
%  *--------------------------------------------------------------*/

a= 0.05360696430030077 ;
b= -0.3443590921004309 ;
c= 1.039719372269183 ;
d= 0.000130254480891871 ;
e= -0.3435271210950493 ;

pos_definite = find(raw_cts>0);
min_pos_cts = min(raw_cts(pos_definite));
zerocts = find(raw_cts==0);
raw_cts(zerocts) = 1e-4* min_pos_cts;

x = log(raw_cts);
y = (a + x.* (c + e .* x) )./(1+x.*(b+d.*x));
dtc_cts = exp(y);

return 

function dtc_cts = dtc_sgp_20040515(raw_cts);
% deadtime_correction_apd8126
% [dtc_cts] = dtc_apd8126(raw_cts);
% This function uses a tablecurve output fit for the deadtime correction of
% APD8126 in the MPL at SGP as of 2004-05-16. 
%    Eqn# 1535  y^(-1)=a+bx^3+c/x 
%    a= -0.05578176389719666 
%    b= -3.81300961983901E-06 
%    c= 1.000972202313869 
% 
% %  *--------------------------------------------------------------*/
% This curve generated from a fit of D(MHz) vs R(MHz) on 2005-09-07
   a= -0.05578176389719666 ;
   b= -3.81300961983901E-06 ;
   c= 1.000972202313869 ;


dtc_cts = zeros(size(raw_cts));
pos = find(raw_cts>0);
y = a + b .* (raw_cts(pos).^3) + c ./ raw_cts(pos);
dtc_cts(pos) = 1./y;
return 

