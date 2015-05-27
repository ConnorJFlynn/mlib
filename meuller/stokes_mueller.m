%This script defines common Stokes vectors and Mueller matrices 
% First the Stokes vectors:
% S = [I,Q,U,V] where 
% I is the total intensity
% Q is power through a LPH - power through LPV
% U is power through LPp45 - power through LPn45
% V is power through CPL - power through CPR

%% From Hovenir and Mishenko:
M_atm = [a 0 0 0 ; 0 b 0 0 ; 0 0 -b 0 ; 0 0 0 a - 2*b]
%when a = b = 1,non-depolarizing
%when a = 1, b = 0 depolarizing

%% From Flynn et al
d = 0;
M_atm = [1 0 0 0 ;0 (1-d) 0 0;0 0 (d-1) 0 ;0 0 0 (2*d -1)];
%%
clear M_atm
for di = 101:-1:1
   d = (di-1)./100;
   M_atm{di} = [1 0 0 0 ;0 (1-d) 0 0;0 0 (d-1) 0 ;0 0 0 (2*d -1)];
end
%%
%when d = 0, non-depolarizing
%when d = 1, depolarizing
% MPLpol operating modes
%half-wave mode.  
% M_LPH * M_QWn45 * M_QWn45 * M_atm * M_QWp45 * M_QWp45 * M_LPV * S_LV
% M_QWn45 * M_QWn45 * M_atm * M_QWp45 * M_QWp45 * M_LPV * S_LV
%%
S_par = M_LPV * M_QWn45 * M_QWn45 * M_atm{1} * M_QWp45 * M_QWp45 * M_LPV * S_LV;
S_perp = M_LPH * M_QWn45 * M_QWn45 * M_atm{end} * M_QWp45 * M_QWp45 * M_LPV * S_LV
%%

%quarter-wave mode:
% M_LPH *  M_QWn45 * M_atm * M_QWp45 * M_LPV * S_LV

S_LH = M_LPV * M_QWn45 * M_atm * M_QWp45 * M_LPV * S_LV
S_RH = M_LPH * M_QWn45 * M_atm * M_QWp45 * M_LPV * S_LV


%M_delta_theta(90,45)*M_delta_theta(90,45)* M_LPH * S_LH


M_LPV * M_delta_theta(90, -45)^2 * M_atm{1} * M_delta_theta(90, 45)^2* S_LH
%%
delta = 90;
theta = 43;
%

% S_par = M_LPV * M_QWn45 * M_QWn45 * M_atm{1} * M_QWp45 * M_QWp45 * M_LPV * S_LV;
% S_perp = M_LPH * M_QWn45 * M_QWn45 * M_atm{end} * M_QWp45 * M_QWp45 * M_LPV * S_LV
disp('half-wave mode'); %detect depol
crs_0= (M_LPV * M_delta_theta(delta, -theta)^2 * M_atm{1} * M_delta_theta(delta, theta)^2* S_LH)'
(M_LPV * M_delta_theta(delta, -theta)^2 * M_atm{31} * M_delta_theta(delta, theta)^2* S_LH)'
(M_LPV * M_delta_theta(delta, -theta)^2 * M_atm{71} * M_delta_theta(delta, theta)^2* S_LH)'
crs_1 = (M_LPV * M_delta_theta(delta, -theta)^2 * M_atm{101} * M_delta_theta(delta, theta)^2* S_LH)'

%
disp('quarter-wave mode'); %detect copol
cop_0=(M_LPV * M_delta_theta(delta, -theta) * M_atm{1} * M_delta_theta(delta, theta)* S_LH)'
(M_LPV * M_delta_theta(delta, -theta) * M_atm{31} * M_delta_theta(delta, theta)* S_LH)'
(M_LPV * M_delta_theta(delta, -theta) * M_atm{71} * M_delta_theta(delta, theta)* S_LH)'
cop_1 = (M_LPV * M_delta_theta(delta, -theta) * M_atm{101} * M_delta_theta(delta, theta)* S_LH)'
ldr_0 = cop_0(1)./(crs_0(1)+cop_0(1));
ldr_1 = cop_1(1)./(crs_1(1)+cop_1(1));

%%

for dd = length(d):-1:1
   tmp = M_LPV * M_delta_theta(delta, -theta)^2 * M_atm{dd} * M_delta_theta(delta, theta)^2* S_LH;
   hwave_true(dd) = tmp(1);
   tmp = M_LPV * M_delta_theta(delta, -theta) * M_atm{dd} * M_delta_theta(delta, theta)* S_LH;
   qwave_true(dd) = tmp(1);
   ldr_true(dd) = hwave_true(dd)./(qwave_true(dd)+hwave_true(dd));
   
end
   

