function [sumdiff]=fit3(x)

% fit3 water vapor transmittance parameterization: tw=c*exp(-a(swp)^b)
%      fit3 is called by lblrtm_coeff(3)
%
%
% Thomas Ingold, IAP, 12/1999



eval(['load ',tempdir,filesep,'data.mat'])
tw_mean=x(1).*exp(-x(2).*(swp).^x(3));
sumdiff=sum((tw_mean-tw).^2);
