function state = atmos_state(P,T,rh);
%Computes the following atmospheric state quantities:
% mixing ratio
% virtual temperature
% potential temperature
% equivalent potential temperature
% hypsometric altitude
% returns structure state with fields:
% .P
% .T
% .rh
% .w mixing ratio in kg/kg
% .mr mixing ratio in g/kg
% .Tv
% .theta (PT)
% .theta_v (virtual PT)
% .theta_e (equ PT)
% .alt

% All of these have come from:
% http://www.theweatherprediction.com/basic/equations/

state.P = P;
if any(T<=0)
    state.T = T+273.15;
else
    state.T = T;
end
state.rh = rh;
state.w = mixing_ratio_sonde(state.T,state.P,state.rh);
state.mr = state.w *1000;
state.Tv = virtual_temp(state.T,state.w);
state.theta = potential_temp(state.T,state.P);
state.theta_v = virtual_pot_temp(state.theta, state.w);
state.theta_e = equiv_potential_temp(state.theta,state.w);
state.alt = hypso(state.P,state.Tv,state.rh);
 
state.Es = ClausiusClapeyron(state.T);
state.Es_W = Wobus(state.T -273.15);
state.p_ice = GoffGratchIce(state.T);
state.p_water = MurphyKoop(state.T);

function w = mixing_ratio_sonde(T,P,rh);
%mixing ratio in kg/kg
Es = ClausiusClapeyron(T); %Saturation vapor pressure at T
ws = vp2mr(P,Es); %Saturation mixing ratio at P (and Es at T)
w = ws .* rh/100;

function Es = ClausiusClapeyron(T_K);
% Es = saturation vapor pressure;
L = 2.453e6; % J/kg Latent heat of vaporization = 
Rv = 461; % J/kg= Gas constant for moist air 
Es = 6.11 * exp((L/Rv)*(1/273 - 1./T_K));

function p_water = MurphyKoop(T_K)
T = T_K;
log_pw = 54.842763 - 6763.22 ./ T - 4.21 * log(T)+ 0.000367*T ...
    + tanh(0.0415*(T - 218.8)).* ...
    (53.878 - 1331.22 ./ T - 9.44523 *log(T) + 0.014025* T);    
p_water = exp(log_pw);
p_water = p_water/100;

function p_ice = GoffGratchIce(T_K);
%Saturation vapor pressure of water over ice
% p_ice in hPa
T = T_K;
log10_pi = -9.09718 * (273.16 ./T - 1) - 3.56654 * log10(273.16./ T) ...
    + 0.876793 *(1 - T / 273.16) + log10(6.1071);
p_ice = 10.^log10_pi;
p_ice(T>273.16) = NaN;


function Es = Wobus(T_C);
T = T_C;
eso = 6.1078;
pol = 0.99999683 + T.*(-0.90826951E-02 + T.*(0.78736169E-04  ...
    + T.*(-0.61117958E-06 +  T.*(0.43884187E-08  ...
    + T.*(-0.29883885E-10 + T.*(0.21874425E-12 ...
    + T.*(-0.17892321E-14 +  T.*(0.11112018E-16 ...
    + T.*(-0.30994571E-19)))))))));
Es = eso./(pol.^8);

function vp = mr2vp(P,w);
%P is pressure in mB
%w is mixing ratio in kg/kg
%mr is mixing ratio in g/kg
% w = mr/1000;
e = (w * P)./(.622 + w);
vp = e;

function w = vp2mr(P,vp);
%P is pressure in mB
%mr is mixing ratio in g/kg
%w is kg/kg
e = vp;
w = (0.622 * e)./(P - e);
% mr = w*1000;

function z_msl = hypso(P,Tv,rh);
Po = 1013.25 ; %mB
Rd= 287;% J K^-1 kg^-1
Tv = (Tv(1)+Tv(end))./2;
%Apparently this is just the mean of the top and bottom Tv
% Not a profile weighted mean.  So we don't need the following code:
% for i = length(Tv):-1:1
%     Tv(i) = mean(Tv(1:i));
% end

z_msl = (Rd/9.81) * (Tv .* log(Po./P)) ;

function Tv = virtual_temp(T,w);
% Tv = T(1 + 0.61w)
% T= temperature in Kelvins
% w= mixing ratio in kg of moisture per kg of dry air
Tv = T.*(1 + 0.61*w);

function theta = potential_temp(T,P);
% PT = T(1000/P)^Rd/cp = T(1000/P)^0.286
% Rd = gas constant for dry air
% Cp = constant pressure process
theta = T.*((1000./P).^0.286);

function theta_v = virtual_pot_temp(theta, w);
theta_v = theta.*(1+0.61*w);

function theta_e = equiv_potential_temp(theta,w);
% Theta-E = T(1000/P)^0.286 + 3w = PT + 3w
% T = Temperature in Kelvins
% P = Pressure in millibars
% w = Mixing ratio in kg/kg
theta_e =  theta + 3*w;
