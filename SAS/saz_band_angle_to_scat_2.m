% SAS band scattering angle when band axis aligned to solar azimuth
% 
% a is the area of the band centered on angle "a" measured from  vertical.
% b is the band angle of rotation measured again from the vertical
a = [-90:.01:90]*pi./180;
b = [0:2:88].*pi./180;
X = (cos(a')*sin(b));
Y = sin(a')*ones(size(b));
Z = cos(a')*cos(b);
%%
sza = 78.5;
zen = interp1(a,[1:length(a)],sza.*pi./180,'nearest');
%
% these = plot3(X, Y, Z,'-'); recolor(these,b);colorbar
%
dot_sun = [X.*0 + Y.*sin(sza.*pi./180) + Z.*cos(sza.*pi./180)];
scatang = acos(dot_sun);
[mins,ii] = min(scatang);
%%

figure; these = plot(a.*180/pi-15, scatang.*180/pi, '-'); recolor(these,180.*b./pi);colorbar
hold('on');

plot(a(zen).*180./pi-15, scatang(zen,:).*180/pi,'k.',a(ii).*180/pi-15,mins.*180/pi,'ro');
hold('off');
title(sprintf('solar zenith angle = %2.0f degrees',sza))
%%
figure; 
plot(b.*180./pi,scatang(zen,:).*180./pi,'ro',b.*180./pi,(180.*b./pi).* cos(sza.*pi./180),'k.');
xlabel('band angle')
ylabel('scat angle of arc of band at sza')
title(sprintf('This shows that even at SZA=%3.1f we can approximate scat ang as cos(sza)*b',sza))