%% ice fog images Apr 9-10 ISDAC

clear
close('all')
pname = ['C:\case_studies\ISDAC\icefog\'];
% mpl = loadinto([pname, 'isdac_mplpol_3flynn.20080409_00UT.mat']);
% tmp = loadinto([pname, 'isdac_mplpol_3flynn.20080409_12UT.mat']);
mpl = loadinto([pname, 'isdac_mplpol_3flynn.20080410_00UT.mat']);
tmp = loadinto([pname, 'isdac_mplpol_3flynn.20080410_12UT.mat']);
mpl = catpol(mpl,tmp);
%%
cmap = colormap;
x = serial2Hh(mpl.time);
y = mpl.range(mpl.range <= 2);
%%
std_attn_prof = mpl.std_attn_prof(mpl.range <= 2);
%%
z1 = real(log10(mpl.ldr(mpl.range <= 2,:)));
z2 = real(log10(mpl.attn_bscat(mpl.range <= 2,:)./(std_attn_prof*ones([1,length(mpl.time)]))));
mask = ones(size(mpl.cop(mpl.range <= 2,:)));
%%
ldr_snr = 1.5;
      ldr_error_limit = .25;
ldr_error = abs(mpl.ldr(mpl.range <= 2,:))./mpl.ldr_snr(mpl.range <= 2,:);
mask(mpl.ldr_snr(mpl.range <= 2,:)<ldr_snr | ldr_error>ldr_error_limit) = NaN;
%%
[rgb,color_sqr] = rgb_weight(x,y,z1,z2,cmap,[-3,0],[2,5],0.3,mask);
%%
% figure;
set(gcf,'position', [-1366         607        1305         381]);
plots_ppt
ax2(2) = subplot('position',[0.6864    0.15    0.2500    0.76]);
ax2(2) = subplot('position',[0.8423    0.1500    0.0796    0.7600]);
ax2(1) = subplot('position',[0.0800    0.1500    0.560    0.7600]);
ax2(1) = subplot('position',[0.0743    0.1500    0.7106    0.7600]);

imagegap(x,y,rgb);
%%
ylabel('range (km)');
set(ax2(1),'TickDir','out');
xlab = xlabel('time (UTC)');


titlestr = ['Composite lidar image: ldr for color, bscat. ratio for brightness'];
% titlestr = ['Composite image: log10 of backscatter ratio (brightness), log10 of linear depolarization ratio (color) '];
title(ax2(1),titlestr, 'interpreter','none');
%%
plots_ppt
axes(ax2(2))
imagegap([2,5],[-3,0],color_sqr);
%%
title('colormap','fontsize',14)
xlabel('log_1_0(atten bscat ratio)','fontsize',12)
ylabel('log_1_0(ldr)','fontsize',12)
set(gca,'YAxisLoc','right')
set(ax2(2),'TickDir','out');
set(gca,'fontname','Tahoma','fontweight','bold','fontsize',16)
%%

% vc = ancload([pname, 'nsavceil25kC1.b1.20080409.000012.cdf']);
vc = ancload([pname, 'nsavceil25kC1.b1.20080410.000010.cdf']);


%
%%

pos = zeros(size(vc.vars.backscatter.data));
pos(vc.vars.backscatter.data<=0) = NaN;
figure; 

imagesc(serial2Hh(vc.time), vc.vars.range.data./1000, pos+real(log10(vc.vars.backscatter.data))); 
axis('xy');caxis([-.5,4]);cb = colorbar;
% xlabel('time [UTC hours]');
ylabel('range (km AGL)');
title(['Vaisala ceilometer backscatter']);
xx(1) = gca;
ylim([0,1.5]);

xlabel('time [UTC hours]');
set(gcf,'position', [-1366         607        1305         381]);
set(xx(1),'position',[0.0756    0.1417    0.7219    0.7638]);
set(cb,'location','manual');
set(cb,'position',[0.8398    0.1430    0.0705    0.7664]);
set(get(cb,'title'),'string','colormap','fontsize',14)
set(get(cb,'ylabel'),'string','log_1_0(bscat)','fontsize',14)
%%

%
% mmcr =
% ancload([pname,'nsammcrmode1bl200712011clothC1.c1.20080409.000032.cdf' ]);
mmcr = ancload([pname,'nsammcrmode1bl200712011clothC1.c1.20080410.000551.cdf' ]);
pos_z = mmcr.vars.Heights.data>0;
good =(mmcr.vars.qc_ReflectivityClutterFlag.data==1) & (mmcr.vars.qc_RadarArtifacts.data==1);

figure; 

imagesc(serial2Hh(mmcr.time), mmcr.vars.Heights.data(pos_z)./1000, (1./good(pos_z,:)).*mmcr.vars.Reflectivity.data(pos_z,:));
ylabel('range (km AGL)');
title(['Millimeter Cloud Radar reflectivity for ',datestr(mmcr.time(1),'yyyy-mm-dd')]);
axis('xy');cb2=colorbar; 

xlabel('time [UTC hours]');
xx(2) = gca;
set(gcf,'position', [-1366         607        1305         381]);
set(xx(2),'position',[0.0756    0.1417    0.7219    0.7638]);
set(cb2,'location','manual');
set(cb2,'position',[0.8398    0.1430    0.0705    0.7664]);
% set(get(cb2,'title'),'string','dBZ')
set(get(cb2,'title'),'string','colormap','fontsize',14)
set(get(cb2,'ylabel'),'string','dBZ','fontsize',14)
% 
%  linkaxes(xx,'xy');

linkaxes([ax2(1),xx],'xy');
 ylim([0,1.5]);
