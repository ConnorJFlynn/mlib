function aip_1h = make_subs(aip_1h);

% Carry out substitutions in the monthly gridded file.

%Recovery of 1 um data from doy 81 to 124
% Look at comparison of 10 um and 1 um data from data with doy<81. 
% Try different magnitude cuts as well.
%%

% pre_sub = (serial2doy(aip_1h.time)>55)&(serial2doy(aip_1h.time)<81);
pre_sub = (serial2doy(aip_1h.time)>68)&(serial2doy(aip_1h.time)<81);
sub = (serial2doy(aip_1h.time)>81)&(serial2doy(aip_1h.time)<125);
% % For Bsp_B
% NaNs = isNaN(aip_1h.Bsp_B_Dry_10um)|isNaN(aip_1h.Bsp_B_Dry_1um)|(aip_1h.Bsp_B_Dry_10um<200);
% [P,S,Mu] = polyfit(aip_1h.Bsp_B_Dry_10um(pre_sub&~NaNs),aip_1h.Bsp_B_Dry_1um(pre_sub&~NaNs),1);
% aip_1h.Bsp_B_Dry_1um(sub) = polyval(P,aip_1h.Bsp_B_Dry_10um(sub),[],Mu);
% For Bsp_G
NaNs = isNaN(aip_1h.Bsp_G_Dry_10um)|isNaN(aip_1h.Bsp_G_Dry_1um)|(aip_1h.Bsp_G_Dry_10um<200);
[P,S,Mu] = polyfit(aip_1h.Bsp_G_Dry_10um(pre_sub&~NaNs),aip_1h.Bsp_G_Dry_1um(pre_sub&~NaNs),1);
aip_1h.Bsp_G_Dry_1um(sub) = polyval(P,aip_1h.Bsp_G_Dry_10um(sub),[],Mu);


figure; scatter(aip_1h.Bsp_G_Dry_10um(pre_sub&~NaNs),aip_1h.Bsp_G_Dry_1um(pre_sub&~NaNs),24,serial2doy(aip_1h.time(pre_sub&~NaNs)),'filled');colorbar

figure; plot(aip_1h.Bsp_G_Dry_10um(pre_sub&~NaNs),aip_1h.Bsp_G_Dry_1um(pre_sub&~NaNs),'b.',...
  aip_1h.Bsp_G_Dry_10um(pre_sub&~NaNs), polyval(P,aip_1h.Bsp_G_Dry_10um(pre_sub&~NaNs),[],Mu),'r-' );
xlabel('Total scattering coefficient, green, 10 um cut-off (1/Mm)');
ylabel('Total scattering coefficient, green, 1 um cut-off (1/Mm)');
title('Correlation in total scattering coef in weeks prior to impactor problem');

% % For Bsp_R
% NaNs = isNaN(aip_1h.Bsp_R_Dry_10um)|isNaN(aip_1h.Bsp_R_Dry_1um)|(aip_1h.Bsp_R_Dry_10um<200);
% [P,S,Mu] = polyfit(aip_1h.Bsp_R_Dry_10um(pre_sub&~NaNs),aip_1h.Bsp_R_Dry_1um(pre_sub&~NaNs),1);
% aip_1h.Bsp_R_Dry_1um(sub) = polyval(P,aip_1h.Bsp_R_Dry_10um(sub),[],Mu);
% %%

% Recovery of Bsp data from vis
%Generate surrogate of Bsp from vis10.
% AOS back up 224, ITF south on 302. Use this interval to fit Bsp and vis
% for the period from 125-223
Bsp_G_10um_vis = NaN(size(aip_1h.time));
sub = (serial2doy(aip_1h.time)>125)& (serial2doy(aip_1h.time)<224);
post_sub = (serial2doy(aip_1h.time)>224)& (serial2doy(aip_1h.time)<302); %End of wet season
post_sub = ((serial2doy(aip_1h.time)>92)&(serial2doy(aip_1h.time)<125)); %End of dry season
NaNs_1h = isNaN(aip_1h.pwd_avg_vis_10_min)|(aip_1h.pwd_avg_vis_10_min<=3000)|(aip_1h.pwd_avg_vis_10_min>=19000)|...
   isNaN(aip_1h.Bsp_G_Dry_10um)|(aip_1h.Bsp_G_Dry_10um<100);
%%
[P_1h,S_1h,MU_1h] = polyfit(1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub),aip_1h.Bsp_G_Dry_10um(~NaNs_1h&post_sub),1);

Bsp_G_10um_vis(sub|post_sub) = polyval(P_1h, 1000./aip_1h.pwd_avg_vis_10_min(sub|post_sub), [],MU_1h);

NaNs = (Bsp_G_10um_vis<111)|(Bsp_G_10um_vis>5000)|isNaN(Bsp_G_10um_vis)|~isfinite(Bsp_G_10um_vis);

Bsp_G_10um_vis(NaNs) = NaN;
aip_1h.Bsp_G_10um_vis = NaN(size(Bsp_G_10um_vis));
aip_1h.Bsp_G_10um_vis(sub)= Bsp_G_10um_vis(sub);
figure; scatter(1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub), aip_1h.Bsp_G_Dry_10um(~NaNs_1h&post_sub), 24,serial2doy(aip_1h.time(~NaNs_1h&post_sub)),'filled'); colorbar
hold('on')
plot(1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub), Bsp_G_10um_vis(~NaNs_1h&post_sub), 'b');
xlabel('1/visibility (1/Mm)');
ylabel('total scattering coef G, 10 um (1/Mm)')

figure; plot(1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub), aip_1h.Bsp_G_Dry_10um(~NaNs_1h&post_sub),'bo',...
   (1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub)), Bsp_G_10um_vis(~NaNs_1h&post_sub), 'r');
xlabel('1/visibility (1/Mm)');
ylabel('total scattering coef G, 10 um (1/Mm)')
title('Correlation between total scattering and visibilty sensor.')

% v = axis;
figure; plot(serial2doy(aip_1h.time(sub|post_sub)),aip_1h.Bsp_G_Dry_10um(sub|post_sub),'g.',...
   serial2doy(aip_1h.time(sub|post_sub)),Bsp_G_10um_vis(sub|post_sub),'k.')


%%
% Recovery of Bsp data from vis for gap in 2nd dry season
%Generate surrogate of Bsp from vis10.
% AOS back up 224, ITF south on 302. Use this interval to fit Bsp and vis
% for the period from 125-223
%%
Bsp_G_10um_vis = NaN(size(aip_1h.time));
sub = ((serial2doy(aip_1h.time)>321)& (serial2doy(aip_1h.time)<333))...
   |((serial2doy(aip_1h.time)>302)& (serial2doy(aip_1h.time)<303));
post_sub = (serial2doy(aip_1h.time)>305)& (serial2doy(aip_1h.time)<320); %End of wet season
NaNs_1h = isNaN(aip_1h.pwd_avg_vis_10_min)|(aip_1h.pwd_avg_vis_10_min<=3000)|(aip_1h.pwd_avg_vis_10_min>=19000)|...
   isNaN(aip_1h.Bsp_G_Dry_10um)|(aip_1h.Bsp_G_Dry_10um<100);
% figure; scatter(1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub), aip_1h.Bsp_G_Dry_10um(~NaNs_1h&post_sub), 24,serial2doy(aip_1h.time(~NaNs_1h&post_sub)),'filled'); colorbar

%%
[P_1h,S_1h,MU_1h] = polyfit(1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub),aip_1h.Bsp_G_Dry_10um(~NaNs_1h&post_sub),1);

Bsp_G_10um_vis(sub|post_sub) = polyval(P_1h, 1000./aip_1h.pwd_avg_vis_10_min(sub|post_sub), [],MU_1h);

NaNs = (Bsp_G_10um_vis<111)|(Bsp_G_10um_vis>5000)|isNaN(Bsp_G_10um_vis)|~isfinite(Bsp_G_10um_vis);

Bsp_G_10um_vis(NaNs) = NaN;
aip_1h.Bsp_G_10um_vis(sub)= Bsp_G_10um_vis(sub);
figure; scatter(1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub), aip_1h.Bsp_G_Dry_10um(~NaNs_1h&post_sub), 24,serial2doy(aip_1h.time(~NaNs_1h&post_sub)),'filled'); colorbar
hold('on')
plot(1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub), Bsp_G_10um_vis(~NaNs_1h&post_sub), 'b');
xlabel('1/visibility (1/Mm)');
ylabel('total scattering coef G, 10 um (1/Mm)')

% figure; plot(1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub), aip_1h.Bsp_G_Dry_10um(~NaNs_1h&post_sub),'bo',...
%    (1000./aip_1h.pwd_avg_vis_10_min(~NaNs_1h&post_sub)), Bsp_G_10um_vis(~NaNs_1h&post_sub), 'r');
% xlabel('1/visibility (1/Mm)');
% ylabel('total scattering coef G, 10 um (1/Mm)')
% title('Correlation between total scattering and visibilty sensor.')

% v = axis;
%%
figure; plot(serial2doy(aip_1h.time(sub|post_sub)),aip_1h.Bsp_G_Dry_10um(sub|post_sub),'g.',...
   serial2doy(aip_1h.time(sub|post_sub)),Bsp_G_10um_vis(sub|post_sub),'k.')
