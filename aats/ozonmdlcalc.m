%ozonmdlcalc.m
clear
close all

colmnozdobson_in=290;

avogad = 6.022045e23;	%molecules/mole
alosmt = 2.68675e19;		%molecules/cm**3
molecwtoz = 47.998;		%g/mole
ozonecrssect605 = 5.073e-21;	%cm2/molecule

s=load('ozonemdl76.dat');
zkmozone = s(:,1);
ozonekgm3 = s(:,2);

ozonenocm3 = ozonekgm3*avogad*1e3*1e-6/molecwtoz;
ozoneperkm605 = 1e5*ozonenocm3*ozonecrssect605;
figure(1)
plot(ozoneperkm605,zkmozone)
axis([0 .003 0 40]);

colmnozone_percm2 = 1e5*trapz(zkmozone,ozonenocm3);
colmnozdobson = 1000*colmnozone_percm2/alosmt;

zkm_flip = flipud(zkmozone);
colmnozcumdobson=-cumtrapz(zkm_flip,flipud(ozoneperkm605));
figure(3)
y12=[12 12];
xodlim=[0 .05];
plot(colmnozcumdobson,zkm_flip,'b')
hold on
plot(colmnozcumdobson*colmnozdobson_in/colmnozdobson,zkm_flip,'r')
set(gca,'FontSize',14)
hh=legend(sprintf('%3.0f DU',colmnozdobson),sprintf('%3.0f DU',colmnozdobson_in))
set(hh,'FontSize',12)
plot(xodlim,y12,'k--')
xlabel('Ozone Optical Depth at 605nm','FontSize',14)
ylabel('Altitude (km)','FontSize',14)
axis([xodlim 0 50])
grid on
title('1976 U.S. Standard Atm Ozone Model','FontSize',12)

figure(2)
ozonenocm3_flip = flipud(ozonenocm3);
colmnozone_percm2_flip = -1e5*cumtrapz(zkm_flip,ozonenocm3_flip);
semilogx(colmnozone_percm2_flip,zkm_flip)

tauozone=flipud(colmnozone_percm2_flip);
%fid=fopen('c:\johnmatlab\UAairmass\ozonetau76.txt','w');
fid=1;
for i=1:length(zkmozone),
 fprintf(fid,'%6.2f %12.3e\n',zkmozone(i),tauozone(i));
end
%fclose(fid);

cumO3_atmcm=flipud((colmnozcumdobson*colmnozdobson_in/colmnozdobson)/(ozonecrssect605*alosmt));
frac_cumO3=cumO3_atmcm./cumO3_atmcm(1);
fid=1;
for i=1:10, %length(zkmozone),
 fprintf(fid,'%6.2f %12.4f %12.4f\n',zkmozone(i),cumO3_atmcm(i),frac_cumO3(i));
end

zkmspline=[0:0.1:14];
pp = spline(zkmozone(1:8),frac_cumO3(1:8));
value_spline = ppval(pp,zkmspline);
[p,s] = polyfit(zkmozone(1:8),frac_cumO3(1:8),5);
value_poly = polyval(p,zkmspline);
figure(4)
plot(frac_cumO3(1:8),zkmozone(1:8),'bo-')
hold on
plot(value_spline,zkmspline,'r.-')
plot(value_poly,zkmspline,'g.-')
axis([0.84 1 0 14])
set(gca,'FontSize',14)
xlabel('Fraction of cumulative columnar ozone','FontSize',14)
ylabel('Altitude (km)','FontSize',14)
grid on

fprintf('%14.5e %14.5e %14.5e %14.5e %14.5e %14.5e\n',p)

pcalc=0;
for k=1:6,
    pcalc=pcalc+p(k)*12^(6-k);
end
pcalc