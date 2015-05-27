%%

t = datenum('2008-06-21','yyyy-mm-dd')+[0:.01:1]+.28;
[zen, az, soldst, ha, dec, el, am] = sunae(36.6070, -97.4880, t);
% t = datenum('2008-03-22','yyyy-mm-dd')+[0:.01:1]-.475;
% [zen, az, soldst, ha, dec, el, am] = sunae(36.6070, -97.4880, t);
% figure; plot(az, el.*(el>0),'.-')
[max_el, el_i] = max(el)

%%

a = 5;
riser = 2;
mast = 28;
b = riser.*ones(size(t));
cut_spot = 0; %(cut at due east)
b = riser.*ones(size(t));
az_SE = (az>=(cut_spot))&(az<=180);
b(az_SE) = b(az_SE)+ mast.*(az(az_SE)-cut_spot)./(180-cut_spot);
az_SW = (az>=180)&(az<=(360-cut_spot));
b(az_SW) = b(az_SW)+ mast.*((360-cut_spot)-az(az_SW))./(180-cut_spot);
arm = b./a;
shade = 180*atan(arm)./pi;
figure; subplot(2,1,1); plot(az,shade,'r-',az, el.*(el>0),'.-');
xlabel('az angle')
ylabel('angle (deg)')
title('Sun shade angle')
legend('shade angle','solar el')
subplot(2,1,2);  plot(az,shade-(el.*(el>0)),'x');
xlabel('az angle')
ylabel('slack angle')


%%
