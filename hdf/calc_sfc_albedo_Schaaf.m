function [albedo_sfc] = calc_sfc_albedo_Schaaf(fiso,fvol,fgeo,frac_diffuse,SZAin)
%UNTITLED3 Summary of this function goes here
%   calculates MODIS (Schaaf et al.) black-sky and white-sky albedos using assumed and subsequent surface albedo
%   fiso,fvol,fgeo are single values
%   frac_diffuse is a vector (with length=length(SZAIN))that is a function of SZA (hence, for a specific AOD)
%   SZAin is a vector of SZA

g0bs=[1.0 -0.007574 -1.284909];
g1bs=[0.0 -0.070987 -0.166314];
g2bs=[0.0  0.307588  0.041840];
gws =[1.0  0.189184 -1.377622];

SZAinrad=deg2rad(SZAin);
SZAsq=SZAinrad.*SZAinrad;
SZAcub=SZAinrad.*SZAsq;

for i=1:length(fiso),
    alb_bs=fiso(i)*(g0bs(1) + g1bs(1).*SZAsq + g2bs(1).*SZAcub) + fvol(i)*(g0bs(2) + g1bs(2).*SZAsq + g2bs(2).*SZAcub) + fgeo(i)*(g0bs(3) + g1bs(3).*SZAsq + g2bs(3).*SZAcub);
    alb_ws=fiso(i)*gws(1) + fvol(i)*gws(2) + fgeo(i)*gws(3);
    
    albedo_sfc(i,:) = alb_ws*frac_diffuse + (1-frac_diffuse).*alb_bs;
end
%now for all SZA>=90 set surface albedo=0
albedo_sfc(:,SZAin>=90)=0.;

end

