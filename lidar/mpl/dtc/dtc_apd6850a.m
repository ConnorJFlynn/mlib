function [dtc_cts] = dtc_apd6850a(raw_cts);
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

% if any(raw_cts<=0)
%     disp('Some raw counts less than zero?!');
%     break;
%  else 
%     zero_cts = find(raw_cts==0);
%     nonzero_cts = find(raw_cts>0);
%     min_cts = min(raw_cts(nonzero_cts));
%     raw_cts(zero_cts) = (1e-4)*min_cts;
% end;

x = log(raw_cts);
y = (a + x.* (c + e .* x) )./(1+x.*(b+d.*x));
dtc_cts = exp(y);
