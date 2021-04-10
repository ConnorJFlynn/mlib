function plot_anet_aip(anetaip)
if ~isavar('anetaip')
    anetaip = parse_anet_aip_output;
end
[~, fname, ~] = fileparts(anetaip.output_fname);
fstem = anetaip.fstem; 
fstem = strrep(fstem, '_VIS', ''); anetaip.fstem = fstem;
paths = set_starpaths; imgdir = paths.starimg; pptdir = paths.starppt;
if ~isadir([imgdir, fstem]);
   mkdir(imgdir, fstem);
end
skyimgdir = [imgdir, fstem, filesep];
pptname = [pptdir, fstem, '.ppt'];
created_str = ['.created', datestr(now, '_yyyymmdd_HHMMSS.')];
pptname = ppt_add_title(pptname, [fstem, ': ', created_str]);

% h1 = figure('units','inches','position',[.1 4.2 4 3],'paperposition',[.1 .1 6.5 5]); 
%    h1 = figure('units','inches','position',[.1 4.2 4 3],'paperposition',[.1 .1 10 7]);     
% subplot(2,2,1)
% semilogy(anetaip.PF_angle(:,1),anetaip.PF_total(:,1),'-.r*');
% hold on
% semilogy(anetaip.PF_angle(:,1),anetaip.PF_fine(:,1),'--go');
% hold on
% semilogy(anetaip.PF_angle(:,1),anetaip.PF_coarse(:,1),':bs');
% hold on
% 
% h = legend('total','fine','coarse');
% set(h,'FontSize', 10);
% 
% % text(140,180,'4STAR output: Phase function',...
% %                            'fontname','arial','fontsize',16,'color','k');
% 
% text(1.5,0.11,sprintf('Wavelength: %1.3f um',anetaip.Wavelength(1)),...
%                            'fontname','arial','fontsize',10,'color','k');
% xx_here=get(gca,'xlim');
% yy_here=get(gca,'ylim');
% xlabel('Angle','FontSize', 10);
% ylabel('Phase function','FontSize', 10);
% set(gca,'xlim',[1 180],'FontSize', 10)
% set(gca,'ylim',[0.0 100],'FontSize', 10)
% grid on
% 
% subplot(2,2,2)
% semilogy(anetaip.PF_angle(:,2),anetaip.PF_total(:,2),'-.r*');
% hold on
% semilogy(anetaip.PF_angle(:,2),anetaip.PF_fine(:,2),'--go');
% hold on
% semilogy(anetaip.PF_angle(:,2),anetaip.PF_coarse(:,2),':bs');
% hold on
% 
% h = legend('total','fine','coarse');
% set(h,'FontSize', 10)
% 
% text(1.5,0.14,sprintf('Wavelength: %1.3f um',anetaip.Wavelength(2)),...
%                            'fontname','arial','fontsize',10,'color','k');
% xx_here=get(gca,'xlim');
% yy_here=get(gca,'ylim');
% xlabel('Angle','FontSize', 10);
% ylabel('Phase function','FontSize', 10);
% set(gca,'xlim',[1 180],'FontSize', 10)
% set(gca,'ylim',[0.0 100],'FontSize', 10)
% grid on
% 
% subplot(2,2,3)
% semilogy(anetaip.PF_angle(:,3),anetaip.PF_total(:,3),'-.r*');
% hold on
% semilogy(anetaip.PF_angle(:,3),anetaip.PF_fine(:,3),'--go');
% hold on
% semilogy(anetaip.PF_angle(:,3),anetaip.PF_coarse(:,3),':bs');
% hold on
% 
% h = legend('total','fine','coarse');
% set(h,'FontSize', 10)
% 
% text(1.5,0.15,sprintf('Wavelength: %1.3f um',anetaip.Wavelength(3)),...
%                            'fontname','arial','fontsize',10,'color','k');
% xx_here=get(gca,'xlim');
% yy_here=get(gca,'ylim');
% xlabel('Angle','FontSize', 10);
% ylabel('Phase function','FontSize', 10);
% set(gca,'xlim',[1 180],'FontSize', 10)
% set(gca,'ylim',[0.0 100],'FontSize', 10)
% grid on
% 
% subplot(2,2,4)
% semilogy(anetaip.PF_angle(:,4),anetaip.PF_total(:,4),'-.r*');
% hold on
% semilogy(anetaip.PF_angle(:,4),anetaip.PF_fine(:,4),'--go');
% hold on
% semilogy(anetaip.PF_angle(:,4),anetaip.PF_coarse(:,4),':bs');
% hold on
% 
% h = legend('total','fine','coarse');
% set(h,'FontSize', 10)
% 
% text(1.5,0.16,sprintf('Wavelength: %1.3f um',anetaip.Wavelength(4)),...
%                            'fontname','arial','fontsize',10,'color','k');
% xx_here=get(gca,'xlim');
% yy_here=get(gca,'ylim');
% xlabel('Angle','FontSize', 10);
% ylabel('Phase function','FontSize', 10);
% set(gca,'xlim',[1 180],'FontSize', 10)
% set(gca,'ylim',[0.0 100],'FontSize', 10)
% grid on
% 
% saveas(gcf, [pname, fname,'.phase_function.png'], 'png');
% saveas(gcf, [pname, fname,'.phase_function.fig'], 'fig');

% h2 = figure('units','inches','position',[.1 4.2 4 3],'paperposition',[.1 .1 8 5]); 
% h2 = figure('units','inches','position',[ 0.1 0.5 7 5],'paperposition',[.1 .1 10 7]); 
h2 = figure_(4001);
ax = subplot(2,2,1);
% Labels = {'Wavelength','Real','Imaginary'};
%Range = [0.4,1.1; 1.55,1.65 ; 0.029,0.032];
Range = [min(anetaip.Wavelength) max(anetaip.Wavelength)]; 
%Range = [0.42,1.022];
% Legends = {'Imaginary','Real'};
%%
[hAxes,H1,H2] = plotyy(ax,anetaip.Wavelength,anetaip.refractive_index_imaginary_r,...
   anetaip.Wavelength,anetaip.refractive_index_real_r,@plot,@plot); 
set(hAxes(1),'ytickmode','auto');
set(hAxes(1),'xtickmode','auto');
set(hAxes(2),'ytickmode','auto');
% linkaxes(hAxes,'x');
% tl = title(hAxes(1),'Refractive index');
% title(hAxes(2),' ');

xlabel('Wavelength','FontSize', 10);
ylabel('imag','FontSize', 10);

set(hAxes(1),'xlim',Range,'FontSize', 10);
set(hAxes(2),'xlim',Range,'FontSize', 10);
% set(hAxes(1),'XTick',anetaip.Wavelength);
% set(hAxes(2),'XTick',anetaip.Wavelength);
yl1 = get(hAxes(1),'ylabel');
yl2 = get(hAxes(2),'ylabel');
set(yl1,'string','imag','fontsize',10);
set(yl2,'string','real','fontsize',10,'rotation',270);
set(hAxes(1),'Position', [.1 .5858 .3347 .3392]);
%%
grid(hAxes(1), 'on')
grid(hAxes(2),'off');
%  set(hAxes,'XTick',anetaip.Wavelength)
xlim(hAxes(1),[0.8.*min(anetaip.Wavelength),1.1.*max(anetaip.Wavelength)]);
xlim(hAxes(2),[0.8.*min(anetaip.Wavelength),1.1.*max(anetaip.Wavelength)]);
%
% [hAxes,hLine] = layerplot2(anetaip.Wavelength, anetaip.refractive_index_real_r, anetaip.Wavelength, ...
%     anetaip.refractive_index_imaginary_r, Labels,Range, Legends);
% hold on
% title('Refractive index')
% 
% grid on

hAxes(3) = subplot(2,2,2); % Angstrom and AAE
hold off;
P_AE = polyfit(log(anetaip.Wavelength), log(anetaip.aod),2);
P_AAE = polyfit(log(anetaip.Wavelength), log(anetaip.aaod),2);
anetaip.P_AE = P_AE;  
anetaip.P_AAE = P_AAE;
anetaip.AE_fit = -polyval(polyder(P_AE,1),log(anetaip.Wavelength));
anetaip.AAE_fit = -polyval(polyder(P_AAE,1),log(anetaip.Wavelength));

plot(anetaip.Wavelength, anetaip.AE_fit,'o-',...
  anetaip.Wavelength, anetaip.AAE_fit,'x-' )
h = legend('AE fit','AAE fit'); set(h,'location','southeast')
set(h,'FontSize', 10);


%  plot(anetaip.Wavelength,anetaip.tod_meas,'-ko',anetaip.Wavelength,anetaip.tod_fit,'-rx');
%  %
hold on


xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Wavelength','FontSize', 10);
% yl = ylabel('Angstrom Exp','FontSize', 10);yl.Position = [1.15,1.25,1];
% title('Angstrom Exponents')

set(gca,'xlim',[min(anetaip.Wavelength) max(anetaip.Wavelength)],'FontSize', 10);
xlim(gca,[0.8.*min(anetaip.Wavelength),1.1.*max(anetaip.Wavelength)]);
% set(gca,'XTick',[anetaip.Wavelength]);
set(gca,'FontSize', 10);
grid on

hAxes(end+1) = subplot(2,2,3);
hold off;
 plot(anetaip.Wavelength, [anetaip.ssa_fine;anetaip.ssa_coarse;anetaip.ssa_total]','-*',...
    anetaip.Wavelength, anetaip.sfc_alb, 'k-s');
h = legend('fine','coarse','total', 'sfc alb');
set(h,'FontSize', 8, 'location','southwest');
xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');ylim([0,1.05]);
xlabel('Wavelength','FontSize', 10);
ylabel('SSA','FontSize', 10);
% title('Single Scattering Albedo');

% set(gca,'xlim',[0.4 1.1],'FontSize', 10)
xlim(gca,[0.8.*min(anetaip.Wavelength),1.1.*max(anetaip.Wavelength)]);
% set(gca,'xlim',Range,'FontSize', 10);
% set(gca,'XTick',anetaip.Wavelength);
set(gca,'FontSize', 10);
grid on;
hold on;
%% 

hAxes(end+1) = subplot(2,2,4);
hold off;
if ~isempty(anetaip.input.aods)
plot(anetaip.Wavelength, anetaip.input.aods,'-ko');
hold on
end
plot(anetaip.Wavelength, anetaip.aod,'-r');
hold on
plot(anetaip.Wavelength, anetaip.aaod,'-b*');
hold on
if ~isempty(anetaip.input.aods)
   h = legend('AOD meas','AOD fit','AAOD');
else
    h = legend('AOD fit','AAOD');
end

set(h,'FontSize', 10);

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Wavelength','FontSize', 10);
ylabel('AOD and AAOD','FontSize', 10);
% title('Aerosol extinction optical depth');

xlim(gca,[0.8.*min(anetaip.Wavelength),1.1.*max(anetaip.Wavelength)]);
% set(gca,'xlim',Range,'FontSize', 10);
% set(gca,'XTick',anetaip.Wavelength);
set(gca,'ylim',[-0.02 0.6],'FontSize', 10);
grid on
%% 

% Add skytag, houtput (measurement altitude), H,W (assumed height and width
% of aerosol layers), NLYRS, hlyr, rad transfer boundaries
%
[inp_pname,skytag,ext] = fileparts(anetaip.input_fname); 
%tmpA = textscan(skytag,'%s','delimiter','.'); tmpA = tmpA{:};
%skytag = char(tmpA(2));
[inp_pname,skyscan,x] = fileparts(anetaip.input_fname);
houtput = anetaip.input.houtput; H = anetaip.input.H; W = anetaip.input.W; 
NLYRS = anetaip.input.NLYRS; hlyr = anetaip.input.hlyr;
big_title_str = skyscan;
%%
p=mtit(big_title_str,'fontsize',8,'interp','none');
param_str = ['Parameters: ',sprintf('Scaling[%1.2g], ',...
   anetaip.input.rad_scale),sprintf('houtput[%1.2g], ',houtput),...
   sprintf('H[%1.3g,%1.3g], ',H),sprintf('W[,%1.3g,%1.3g], ',W), ...
    sprintf('NLYRS[%d], hlyr[%1.3g,%1.3g]',NLYRS, hlyr)];
bot_ax = axes('position', [0,0,1,.01]);
bot_tl = title(bot_ax,param_str);
set(bot_tl, 'fontsize',7,'units','normalized', 'interp','none')
set(bot_tl, 'position',[0.5,0,0], 'verticalAlignment','bottom', 'horizontalAlignment', 'center')

set(bot_ax,'visi','off');set(bot_tl,'visi','off');
%%
%	p=mtit('the BIG title',...
%	     'fontsize',14,'color',[1 0 0],...
%	     'xoff',-.1,'yoff',.025);
% % refine title using its handle <p.th>
%	set(p.th,'edgecolor',.5*[1 1 1]);
linkaxes(hAxes,'x');
% aos_ssa
fig_out = [skyimgdir, fname, '_aod_ssa'];
saveas(gcf, [fig_out, '.fig']);
saveas(gcf, [fig_out, '.png']);
ppt_add_slide(pptname, fig_out);

%%
% h3 = figure('units','inches','position',[7    0.5    7    5],'paperposition',[.1 .1 10 7]); 
h3 = figure_(4002);
subplot(2,2,1);     
semilogx(anetaip.radius, anetaip.psd,'-r*');
hold on

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Radius (um)','FontSize', 10);
ylabel('dV/dlnR','FontSize', 10);
% title('Particle size distribution')

set(gca,'xlim',[0 15],'FontSize', 10)
set(gca,'ylim',[0 0.2],'FontSize', 10)
grid on

hAxes3 =  subplot(2,2,4);
ll = semilogx(anetaip.sky_radiances_angle, anetaip.sky_radiances_pct_diff,'o-');
recolor(ll,1000.*anetaip.Wavelength,1000.*[min(anetaip.Wavelength),ceil(max(anetaip.Wavelength))]);
if length(anetaip.Wavelength)<7
for wv = 1:length(anetaip.Wavelength);
    leg_str(wv) = {sprintf('%1.3f um',anetaip.Wavelength(wv))}; 
end
h = legend(leg_str{:});
else
   cb = colorbar('location','east');
   cb_pos = get(cb,'position');cb_pos(1)= .97;
   set(cb, 'Position', cb_pos); 
end
xlabel('scattering angle','fontsize',10); ylabel('(meas - fit)%','fontsize',10)
set(gca,'xlim',[3 180],'FontSize', 10); set(gca,'ylim',[-25,25])
% title('Sky Error (meas - fit) %');

subplot(2,2,3);
hold off;
 plot(anetaip.Wavelength,anetaip.sky_error,'-r*');
hold on; xlim(gca,[0.8.*min(anetaip.Wavelength),1.1.*max(anetaip.Wavelength)]);
% set(gca,'XTick',anetaip.Wavelength);
% for wv = 1:length(anetaip.Wavelength);
%     leg_str(wv) = {sprintf('total %1.3f um',anetaip.Wavelength(wv))}; 
% end
% h = legend(leg_str{:});
% set(h,'FontSize', 10)

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Wavelength','FontSize', 10);
ylabel('(meas - fit)%','FontSize', 10);
% xlim([min(anetaip.Wavelength), max(anetaip.Wavelength)]);
% set(gca,'ylim',[0.0 100],'FontSize', 10)
% title('Sky Error (meas - fit) %');
grid on

hAxes3(end+1) = subplot(2,2,2);
mm = loglog(anetaip.sky_radiances_angle,anetaip.sky_radiances_measured,'o');
recolor(mm,1000.*anetaip.Wavelength,1000.*[min(anetaip.Wavelength),ceil(max(anetaip.Wavelength))]);
hold('on');
ll =loglog(anetaip.sky_radiances_angle, anetaip.sky_radiances_fit, 'k-');
if length(anetaip.Wavelength)<7
for wv = 1:length(anetaip.Wavelength);
    leg_str(wv) = {sprintf('%1.3f um',anetaip.Wavelength(wv))}; 
end
h = legend(leg_str{:});
else
   cb = colorbar('location','east');
   cb_pos = get(cb,'position');cb_pos(1)= .97;
   set(cb, 'Position', cb_pos); 
end
hold off

%%
% semilogy(anetaip.sky_radiances_angle(:,2),anetaip.sky_radiances_fit(:,2),'y');
% hold on
% semilogy(anetaip.sky_radiances_angle(:,2),anetaip.sky_radiances_measured(:,2),'yo');
% hold on
% 
% semilogy(anetaip.sky_radiances_angle(:,3),anetaip.sky_radiances_fit(:,3),'b');
% hold on
% semilogy(anetaip.sky_radiances_angle(:,3),anetaip.sky_radiances_measured(:,3),'bo');
% hold on
% 
% semilogy(anetaip.sky_radiances_angle(:,4),anetaip.sky_radiances_fit(:,4),'g');
% hold on
% semilogy(anetaip.sky_radiances_angle(:,4),anetaip.sky_radiances_measured(:,4),'go');
% hold on
% sprintf('fit %1.3f um',anetaip.Wavelength(1))
% h = legend(sprintf('fit %1.3f um',anetaip.Wavelength(1)),sprintf('meas %1.3f um',anetaip.Wavelength(1)),...
% sprintf('fit %1.3f um',anetaip.Wavelength(2)),sprintf('meas %1.3f um',anetaip.Wavelength(2)),...
% sprintf('fit %1.3f um',anetaip.Wavelength(3)),sprintf('meas %1.3f um',anetaip.Wavelength(3)),...
% sprintf('fit %1.3f um',anetaip.Wavelength(4)),sprintf('meas %1.3f um',anetaip.Wavelength(4)));
set(h,'FontSize', 10);

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('scattering angle','FontSize', 10);
ylabel('sky radiances','FontSize', 10);
set(gca,'xlim',[3 180],'FontSize', 10)
set(gca,'ylim',[min(min(anetaip.sky_radiances_fit))./1.2, max(max(anetaip.sky_radiances_fit)).*1.2],'FontSize', 10)
% title('Sky Radiances')
grid on

p=mtit(big_title_str,'fontsize',8,'interp','none');
bot_ax = axes('position', [0,0,1,.01]);
bot_tl = title(bot_ax,param_str);
set(bot_tl, 'fontsize',7,'units','normalized', 'interp','none')
set(bot_tl, 'position',[0.5,0,0], 'verticalAlignment','bottom', 'horizontalAlignment', 'center')
%%
set(bot_ax,'visi','off');set(bot_tl,'visi','off');
linkaxes(hAxes3, 'x');
fig_out = [skyimgdir, fname,'_radius_psd'];
saveas(gcf,[fig_out,'.fig']);
saveas(gcf,[fig_out,'.png']);
ppt_add_slide(pptname, fig_out);

% h4 = figure('units','inches','position',[4.1 .2 4 3],'paperposition',[.1 .1 10 7]); 
% 
% subplot(2,2,1)
% semilogy(anetaip.PF_angle(:,1),anetaip.PF_total(:,1),'-r.');
% hold on
% semilogy(anetaip.PF_angle(:,2),anetaip.PF_total(:,2),'-y.');
% hold on
% semilogy(anetaip.PF_angle(:,3),anetaip.PF_total(:,3),'-b.');
% hold on
% semilogy(anetaip.PF_angle(:,4),anetaip.PF_total(:,4),'-g.');
% hold on
% 
% h = legend(sprintf('total %1.3f um',anetaip.Wavelength(1)),sprintf('total %1.3f um',anetaip.Wavelength(2)),...
% sprintf('total %1.3f um',anetaip.Wavelength(3)),sprintf('total %1.3f um',anetaip.Wavelength(4)));
% 
% set(h,'FontSize', 10);
% 
% xx_here=get(gca,'xlim');
% yy_here=get(gca,'ylim');
% xlabel('Angle','FontSize', 10);
% ylabel('Total','FontSize', 10);
% set(gca,'xlim',[1 180],'FontSize', 10)
% set(gca,'ylim',[0.0 100],'FontSize', 10)
% title('Phase function: Total');
% grid on
% 
% 
% 
% subplot(2,2,4)
% semilogy(anetaip.sky_radiances_angle(:,1),anetaip.sky_radiances_fit(:,1),'r');
% hold on
% semilogy(anetaip.sky_radiances_angle(:,1),anetaip.sky_radiances_measured(:,1),'ro');
% hold on
% 
% semilogy(anetaip.sky_radiances_angle(:,2),anetaip.sky_radiances_fit(:,2),'y');
% ae on
% semilogy(anetaip.sky_radiances_angle(:,2),anetaip.sky_radiances_measured(:,2),'yo');
% hold on
% 
% semilogy(anetaip.sky_radiances_angle(:,3),anetaip.sky_radiances_fit(:,3),'b');
% hold on
% semilogy(anetaip.sky_radiances_angle(:,3),anetaip.sky_radiances_measured(:,3),'bo');
% hold on
% 
% semilogy(anetaip.sky_radiances_angle(:,4),anetaip.sky_radiances_fit(:,4),'g');
% hold on
% semilogy(anetaip.sky_radiances_angle(:,4),anetaip.sky_radiances_measured(:,4),'go');
% hold on
% 
% h = legend(sprintf('fit %1.3f um',anetaip.Wavelength(1)),sprintf('meas %1.3f um',anetaip.Wavelength(1)),...
% sprintf('fit %1.3f um',anetaip.Wavelength(2)),sprintf('meas %1.3f um',anetaip.Wavelength(2)),...
% sprintf('fit %1.3f um',anetaip.Wavelength(3)),sprintf('meas %1.3f um',anetaip.Wavelength(3)),...
% sprintf('fit %1.3f um',anetaip.Wavelength(4)),sprintf('meas %1.3f um',anetaip.Wavelength(4)));
% set(h,'FontSize', 10);
% 
% xx_here=get(gca,'xlim');
% yy_here=get(gca,'ylim');
% xlabel('Angle','FontSize', 10);
% ylabel('Sky radiances','FontSize', 10);
% set(gca,'xlim',[1 180],'FontSize', 10)
% set(gca,'ylim',[0 1],'FontSize', 10)
% title('Sky Radiances')
% grid on
% 
% 
% subplot(2,2,2)       
% semilogy(anetaip.PF_angle(:,1), anetaip.PF_fine(:,1),'-r.');
% hold on
% semilogy(anetaip.PF_angle(:,2), anetaip.PF_fine(:,2),'-y.');
% hold on
% semilogy(anetaip.PF_angle(:,3), anetaip.PF_fine(:,3),'-b.');
% hold on
% semilogy(anetaip.PF_angle(:,4), anetaip.PF_fine(:,4),'-g.');
% hold on
% 
% h = legend(sprintf('fine %1.3f um',anetaip.Wavelength(1)),sprintf('fine %1.3f um',anetaip.Wavelength(2)),...
% sprintf('fine %1.3f um',anetaip.Wavelength(3)),sprintf('fine %1.3f um',anetaip.Wavelength(4)));
% set(h,'FontSize', 10);
% 
% xx_here=get(gca,'xlim');
% yy_here=get(gca,'ylim');
% xlabel('Angle','FontSize', 10);
% ylabel('Fine','FontSize', 10);
% set(gca,'xlim',[1 180],'FontSize', 10)
% set(gca,'ylim',[0.0 100],'FontSize', 10)
% title('Phase function: Fine');
% grid on
% 
% 
% subplot(2,2,3)
% semilogy(anetaip.PF_angle(:,1),anetaip.PF_coarse(:,1),'-r.');
% hold on
% semilogy(anetaip.PF_angle(:,2),anetaip.PF_coarse(:,2),'-y.');
% hold on
% semilogy(anetaip.PF_angle(:,3),anetaip.PF_coarse(:,3),'-b.');
% hold on
% semilogy(anetaip.PF_angle(:,4),anetaip.PF_coarse(:,4),'-g.');
% hold on
% 
% h = legend(sprintf('coarse %1.3f um',anetaip.Wavelength(1)),sprintf('coarse %1.3f um',anetaip.Wavelength(2)),...
% sprintf('coarse %1.3f um',anetaip.Wavelength(3)),sprintf('coarse %1.3f um',anetaip.Wavelength(4)));
% set(h,'FontSize', 10);
% 
% xx_here=get(gca,'xlim');
% yy_here=get(gca,'ylim');
% xlabel('Angle','FontSize', 10);
% ylabel('Coarse','FontSize', 10);
% set(gca,'xlim',[1 180],'FontSize', 10)
% set(gca,'ylim',[0.0 100],'FontSize', 10)
% title('Phase function: Coarse');
% grid on
% 
% saveas(gcf, [pname, filesep,fname,'.l4.png'], 'png');
% saveas(gcf, [pname, filesep,fname,'.l4.fig'], 'fig');

return

