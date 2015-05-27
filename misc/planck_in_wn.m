function y=planck_in_wn(nu,T)
% nu has to be in inverse cm, T in Kelvin
% y has units of [mw/(m^2.sr.cm^-1)]
c1 = 1.1910427e-5; % [mw/(m^2.sr.cm^-4)]
c2 = 1.4387752; %[K.cm]
% c1 = 1.191044 x 10-5 (mW/m2/ster/cm-4)
% c1 = 2hc2 = 1.191044 x 10-8 W/(m2*ster*cm-4)
%%
% h = 6.6262e-34;% J-s N-m-s  = kg m^2 
% cc = 2.99793e10;% m/s
% kb = 1.38062e-23; %J/degK = N-m/degK = kg m^2
% k1 = 2*h*(cc.^2)*1e7; % = J-s m^2/s^2 = W s^2 m^2/s^2 = W m^2 = W
% k2 = h*cc/kb; % units m degK
%%

y = c1.*(nu.^3)./(exp(c2.*nu./T)-1);

%copied verbatim from 
% http://www.star.nesdis.noaa.gov/smcd/spb/calibration/planck.html
% changyong.cao@noaa.gov
% Agrees with Tim Schmit, NOAA, Paul Menzel UW SSEC

return