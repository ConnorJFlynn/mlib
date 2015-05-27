function [sumdiff]=fit2(x)

% fit2 water vapor transmittance parameterization: tw=exp(-a(swp)^b)
%      fit2 is called by lblrtm_coeff(2)
%
%
% Thomas Ingold, IAP, 12/1999

eval(['load ',tempdir,filesep,'data.mat'])
tw_mean=exp(-x(1).*(swp).^x(2));
sumdiff=sum((tw_mean-tw).^2);
