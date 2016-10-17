% Compare 4STARS and Prede raw signals

prede.wl(1) = 0;
prede.wl(2) = 395.3;
prede.wl(3) = 504.3;
prede.wl(4) = 682.3;
prede.wl(5) = 875.8 ;
prede.wl(6) = 938;
prede.wl(7) = 1010;
star = load(getfullname('*star.mat','star_mat'));
star.nir_sun.dark = mean(star.nir_sun.raw(star.nir_sun.Str==0,:));
star.nir_sun.rate = star.nir_sun.raw-(ones([length(star.nir_sun.t),1])*star.nir_sun.dark);
star.nir_sun.rate = star.nir_sun.rate./unique(star.nir_sun.Tint);
nir_ii = interp1(star.nir_sun.t, [1:length(star.nir_sun.t)],star.vis_sun.t,'nearest');
day_str = datestr(star.vis_sun.t(1),'yymmdd');
prede = read_prede(getfullname([day_str,'*.SUN'],'prede'));
[vis_nm, nir_nm] = starwavelengths(star.vis_sun.t(1)); 
vis_nm = 1000.*vis_nm; nir_nm = nir_nm.*1000;
vi2 = interp1(vis_nm, [1:length(vis_nm)],prede.wl(2),'nearest')-6;
vi3 = interp1(vis_nm, [1:length(vis_nm)],prede.wl(3),'nearest')+5;
vi4 = interp1(vis_nm, [1:length(vis_nm)],prede.wl(4),'nearest')+9;
vi5 = interp1(vis_nm, [1:length(vis_nm)],prede.wl(5),'nearest')+7;
vi6 = interp1(vis_nm, [1:length(vis_nm)],prede.wl(6),'nearest')-3;
ni7 = interp1(nir_nm, [1:length(nir_nm)],prede.wl(7),'nearest')-6;
airmass = interp1(prede.time, prede.airmass, star.vis_sun.t,'linear');

prede_at_star.filter_3 = interp1(prede.time, prede.filter_3, star.vis_sun.t,'linear');
prede_at_star.filter_2 = interp1(prede.time, prede.filter_2, star.vis_sun.t,'linear');
prede_at_star.filter_4 = interp1(prede.time, prede.filter_4, star.vis_sun.t,'linear');
prede_at_star.filter_5 = interp1(prede.time, prede.filter_5, star.vis_sun.t,'linear');
prede_at_star.filter_6 = interp1(prede.time, prede.filter_6, star.vis_sun.t,'linear');
prede_at_star.filter_7 = interp1(prede.time, prede.filter_7, star.vis_sun.t,'linear');


ff = 2;
figure(ff); 
sb(1) = subplot(3,1,1); 
plot(airmass, star.vis_sun.raw(:,vi2),'x'); logy;
title(sprintf('4STAR over Prede %4.0f nm',vis_nm(vi2)));
legend(sprintf('4STAR %4.0f nm',vis_nm(vi2)))
sb(2) = subplot(3,1,2);
plot(airmass, prede_at_star.filter_2,'o'); logy;
legend(sprintf('Prede %4.0f nm',vis_nm(vi2)))
sb(3) = subplot(3,1,3);
these = plot(airmass, star.vis_sun.raw(:,[vi2:vi2])./(prede_at_star.filter_2*ones([1,1])), '-'); 
% recolor(these,[0:2])
legend('4STAR/Prede');
linkaxes(sb,'x');

ff = 3;
figure(ff); 
sb(1) = subplot(3,1,1); 
plot(airmass, star.vis_sun.raw(:,vi3),'gx'); logy;
title(sprintf('4STAR over Prede %4.0f nm',vis_nm(vi3)));
legend(sprintf('4STAR %4.0f nm',vis_nm(vi3)))
sb(2) = subplot(3,1,2);
plot(airmass, prede_at_star.filter_3,'go'); logy;
legend(sprintf('Prede %4.0f nm',vis_nm(vi3)))
sb(3) = subplot(3,1,3);
these = plot(airmass, mean(star.vis_sun.raw(:,[vi3-1:vi3]),2)./(prede_at_star.filter_3*ones([1,1])), '-'); 
legend('4STAR/Prede');
linkaxes(sb,'x');

ff = 4;
figure(ff); 
sb(1) = subplot(3,1,1); 
plot(airmass, star.vis_sun.raw(:,vi4),'cx'); logy;
title(sprintf('4STAR over Prede %4.0f nm',vis_nm(vi4)));
legend(sprintf('4STAR %4.0f nm',vis_nm(vi4)))
sb(2) = subplot(3,1,2);
plot(airmass, prede_at_star.filter_4,'co'); logy;
legend(sprintf('Prede %4.0f nm',vis_nm(vi4)))
sb(3) = subplot(3,1,3);
these =plot(airmass, star.vis_sun.raw(:,vi4:vi4)./(prede_at_star.filter_4*ones([1,1])), 'c-'); 
% recolor(these,[-1:1]); colorbar
legend('4STAR/Prede');
linkaxes(sb,'x');

ff = 5;
figure(ff); 
sb(1) = subplot(3,1,1); 
plot(airmass, star.vis_sun.raw(:,vi5),'kx'); logy;
title(sprintf('4STAR over Prede %4.0f nm',vis_nm(vi5)));
legend(sprintf('4STAR %4.0f nm',vis_nm(vi5)))
sb(2) = subplot(3,1,2);
plot(airmass, prede_at_star.filter_5,'ko'); logy;
legend(sprintf('Prede %4.0f nm',vis_nm(vi5)))
sb(3) = subplot(3,1,3);
these = plot(airmass, mean(star.vis_sun.raw(:,vi5:vi5+1),2)./(prede_at_star.filter_5*ones([1,1])), 'r-'); 
% recolor(these,[5:10]); colorbar
legend('4STAR/Prede');
linkaxes(sb,'x');

ff = 6;
figure(ff); 
sb(1) = subplot(3,1,1); 
plot(airmass, star.vis_sun.raw(:,vi6),'kx'); logy;
title(sprintf('4STAR over Prede %4.0f nm',mean(vis_nm(vi6:vi6+1))));
legend(sprintf('4STAR %4.0f nm',mean(vis_nm(vi6:vi6+1))))
sb(2) = subplot(3,1,2);
plot(airmass, prede_at_star.filter_6,'ko'); logy;
legend(sprintf('Prede %4.0f nm',mean(vis_nm(vi6:vi6+1))))
sb(3) = subplot(3,1,3);
these = plot(airmass, mean(star.vis_sun.raw(:,[vi6:vi6+1]),2)./(prede_at_star.filter_6*ones([1,1])), 'k.'); 
recolor(these,[-4:-1]); colorbar
legend('4STAR/Prede');
linkaxes(sb,'x');

ff = 7;
figure(ff); 
sb(1) = subplot(3,1,1); 
plot(airmass, star.nir_sun.rate(nir_ii,ni7),'kx'); logy;
title(sprintf('4STAR over Prede %4.0f nm',mean(nir_nm(ni7:ni7+1))));
legend(sprintf('4STAR %4.0f nm',mean(nir_nm(ni7:ni7+1))))
sb(2) = subplot(3,1,2);
plot(airmass, prede_at_star.filter_7,'ko'); logy;
legend(sprintf('Prede %4.0f nm',mean(nir_nm(ni7:ni7+1))))
sb(3) = subplot(3,1,3);
these = plot(airmass, mean(star.nir_sun.rate(nir_ii,[ni7:ni7+1]),2)./(prede_at_star.filter_7*ones([1,1])), 'k-'); 
% recolor(these,[-1:+1]); colorbar
legend('4STAR/Prede');
linkaxes(sb,'x');


        infile =files{f};
        [pname, fname] = fileparts(infile);
        prede.LatN = prede.header.lat;% MLO is 19.5365;
        prede.LonE = prede.header.lon; % MLO is -155.5761;
        [prede.zen_sun,prede.azi_sun, prede.soldst, HA_Sun, Decl_Sun, prede.ele_sun, prede.airmass] = ...
            sunae(prede.LatN, prede.LonE, prede.time);

