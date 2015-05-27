function plot_anet_aip(anetaip);

if ~exist('anetaip','var');
    anetaip = rd_anet_aip_output;
end
[pname, fname, ext] = fileparts(anetaip.fname);
% h1 = figure('units','inches','position',[.1 4.2 4 3],'paperposition',[.1 .1 6.5 5]); 
   h1 = figure('units','inches','position',[.1 4.2 4 3],'paperposition',[.1 .1 10 7]);     
subplot(2,2,1)
semilogy(anetaip.angle(:,1),anetaip.total(:,1),'-.r*');
hold on
semilogy(anetaip.angle(:,1),anetaip.fine(:,1),'--go');
hold on
semilogy(anetaip.angle(:,1),anetaip.coarse(:,1),':bs');
hold on

h = legend('total','fine','coarse');
set(h,'FontSize', 10)

% text(140,180,'4STAR output: Phase function',...
%                            'fontname','arial','fontsize',16,'color','k');

text(1.5,0.11,'Wavelength:0.440',...
                           'fontname','arial','fontsize',10,'color','k');
xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Angle','FontSize', 10);
ylabel('Phase function','FontSize', 10);
set(gca,'xlim',[1 180],'FontSize', 10)
set(gca,'ylim',[0.0 100],'FontSize', 10)
grid on

subplot(2,2,2)
semilogy(anetaip.angle(:,2),anetaip.total(:,2),'-.r*');
hold on
semilogy(anetaip.angle(:,2),anetaip.fine(:,2),'--go');
hold on
semilogy(anetaip.angle(:,2),anetaip.coarse(:,2),':bs');
hold on

h = legend('total','fine','coarse');
set(h,'FontSize', 10)

text(1.5,0.14,'Wavelength: 0.674',...
                           'fontname','arial','fontsize',10,'color','k');
xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Angle','FontSize', 10);
ylabel('Phase function','FontSize', 10);
set(gca,'xlim',[1 180],'FontSize', 10)
set(gca,'ylim',[0.0 100],'FontSize', 10)
grid on

subplot(2,2,3)
semilogy(anetaip.angle(:,3),anetaip.total(:,3),'-.r*');
hold on
semilogy(anetaip.angle(:,3),anetaip.fine(:,3),'--go');
hold on
semilogy(anetaip.angle(:,3),anetaip.coarse(:,3),':bs');
hold on

h = legend('total','fine','coarse');
set(h,'FontSize', 10)

text(1.5,0.15,'Wavelength: 0.871',...
                           'fontname','arial','fontsize',10,'color','k');
xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Angle','FontSize', 10);
ylabel('Phase function','FontSize', 10);
set(gca,'xlim',[1 180],'FontSize', 10)
set(gca,'ylim',[0.0 100],'FontSize', 10)
grid on

subplot(2,2,4)
semilogy(anetaip.angle(:,4),anetaip.total(:,4),'-.r*');
hold on
semilogy(anetaip.angle(:,4),anetaip.fine(:,4),'--go');
hold on
semilogy(anetaip.angle(:,4),anetaip.coarse(:,4),':bs');
hold on

h = legend('total','fine','coarse');
set(h,'FontSize', 10)

text(1.5,0.16,'Wavelength: 1.019',...
                           'fontname','arial','fontsize',10,'color','k');
xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Angle','FontSize', 10);
ylabel('Phase function','FontSize', 10);
set(gca,'xlim',[1 180],'FontSize', 10)
set(gca,'ylim',[0.0 100],'FontSize', 10)
grid on

saveas(gcf, [pname, filesep,fname,'.phase_function.png'], 'png');

% h2 = figure('units','inches','position',[.1 4.2 4 3],'paperposition',[.1 .1 8 5]); 
h2 = figure('units','inches','position',[4.1 4.2 4 3],'paperposition',[.1 .1 10 7]); 
subplot(2,2,1)
 plot(anetaip.Wavelength,anetaip.sky_error,'-r*');
hold on

h = legend('sky error');
set(h,'FontSize', 10)

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Wavelength','FontSize', 10);
ylabel('Sky error(%)','FontSize', 10);
title('Sky error')

set(gca,'xlim',[0.440 1.019],'FontSize', 10)
set(gca,'XTick',[0.440;0.674;0.871;1.019])
set(gca,'ylim',[1.2 1.8],'FontSize', 10)
grid on

subplot(2,2,2)
Labels = {'Wavelength','Real','Imaginary'};
%Range = [0.4,1.1; 1.55,1.65 ; 0.029,0.032];
Range = [0.44,1.019]; 
%Range = [0.42,1.022];
Legends = {'Real','Imaginary'};
[hAxes,hLine] = layerplot2(anetaip.Wavelength, anetaip.refractive_index_real_r, anetaip.Wavelength, ...
    anetaip.refractive_index_imaginary_r, Labels,Range, Legends);
hold on
title('Refractive index')
set(hAxes,'XTick',[0.440;0.674;0.871;1.019])
grid on

subplot(2,2,3)
 plot(anetaip.Wavelength, anetaip.ssa_r,'-r*');
hold on

h = legend('SSA');
set(h,'FontSize', 10)

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Wavelength','FontSize', 10);
ylabel('SSA','FontSize', 10);
title('Single Scattering Albedo')

% set(gca,'xlim',[0.4 1.1],'FontSize', 10)
set(gca,'xlim',[0.440 1.019],'FontSize', 10)
set(gca,'XTick',[0.440;0.674;0.871;1.019])
set(gca,'ylim',[0.7 0.9],'FontSize', 10)
grid on

subplot(2,2,4)
plot(anetaip.Wavelength, anetaip.aod,'-r*');
hold on
plot(anetaip.Wavelength, anetaip.aaod,'-b*');
hold on

h = legend('AOD','AAOD');
set(h,'FontSize', 10)

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Wavelength','FontSize', 10);
ylabel('AOD and AAOD','FontSize', 10);
title('Aerosol extinction optical depth')

set(gca,'xlim',[0.440 1.019],'FontSize', 10)
set(gca,'XTick',[0.440;0.674;0.871;1.019])
set(gca,'ylim',[0 0.2],'FontSize', 10)
grid on

saveas(gcf, [pname, filesep,fname,'.aod_ssa.png'], 'png');


h3 = figure('units','inches','position',[.1 .2 4 3],'paperposition',[.1 .1 10 7]); 
     
subplot(2,2,1)     
loglog(anetaip.radius, anetaip.psd,'-.r*');
hold on

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Radius (um)','FontSize', 10);
ylabel('dV/dlnR','FontSize', 10);
title('Particle size distribution')

set(gca,'xlim',[0 15],'FontSize', 10)
set(gca,'ylim',[0 0.2],'FontSize', 10)
grid on

subplot(2,2,2)     
semilogy(anetaip.angle(:,1), anetaip.total(:,1),'-r*');
hold on
semilogy(anetaip.angle(:,2), anetaip.total(:,2),'-y*');
hold on
semilogy(anetaip.angle(:,3), anetaip.total(:,3),'-b*');
hold on
semilogy(anetaip.angle(:,4), anetaip.total(:,4),'-g*');
hold on

h = legend('total (0.440)','total (0.674)','total (0.871)','total (1.019)');
set(h,'FontSize', 10)

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Angle','FontSize', 10);
ylabel('Total','FontSize', 10);
set(gca,'xlim',[1 180],'FontSize', 10)
set(gca,'ylim',[0.0 100],'FontSize', 10)
title('Phase function: Total');
grid on

subplot(2,2,3)
semilogy(anetaip.sky_radiances_angle(:,1),anetaip.sky_radiances_fit(:,1),'r');
hold on
semilogy(anetaip.sky_radiances_angle(:,1),anetaip.sky_radiances_measured(:,1),'ro');
hold on

semilogy(anetaip.sky_radiances_angle(:,2),anetaip.sky_radiances_fit(:,2),'y');
hold on
semilogy(anetaip.sky_radiances_angle(:,2),anetaip.sky_radiances_measured(:,2),'yo');
hold on

semilogy(anetaip.sky_radiances_angle(:,3),anetaip.sky_radiances_fit(:,3),'b');
hold on
semilogy(anetaip.sky_radiances_angle(:,3),anetaip.sky_radiances_measured(:,3),'bo');
hold on

semilogy(anetaip.sky_radiances_angle(:,4),anetaip.sky_radiances_fit(:,4),'g');
hold on
semilogy(anetaip.sky_radiances_angle(:,4),anetaip.sky_radiances_measured(:,4),'go');
hold on

h = legend('fit (0.440)','measured (0.440)','fit (0.674)','measured (0.674)','fit (0.871)',...
    'measured (0.871)','fit (1.019)','measured (1.019)');
set(h,'FontSize', 10)

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Angle','FontSize', 10);
ylabel('Sky radiances','FontSize', 10);
set(gca,'xlim',[1 180],'FontSize', 10)
set(gca,'ylim',[0 1],'FontSize', 10)
title('Sky Radiances')
grid on

saveas(gcf, [pname, filesep,fname,'.radius_psd.png'], 'png');



h4 = figure('units','inches','position',[4.1 .2 4 3],'paperposition',[.1 .1 10 7]); 

subplot(2,2,1)
semilogy(anetaip.angle(:,1),anetaip.total(:,1),'-r.');
hold on
semilogy(anetaip.angle(:,2),anetaip.total(:,2),'-y.');
hold on
semilogy(anetaip.angle(:,3),anetaip.total(:,3),'-b.');
hold on
semilogy(anetaip.angle(:,4),anetaip.total(:,4),'-g.');
hold on

h = legend('total (0.440)','total (0.674)','total (0.871)','total (1.019)');
set(h,'FontSize', 10)

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Angle','FontSize', 10);
ylabel('Total','FontSize', 10);
set(gca,'xlim',[1 180],'FontSize', 10)
set(gca,'ylim',[0.0 100],'FontSize', 10)
title('Phase function: Total');
grid on



subplot(2,2,4)
semilogy(anetaip.sky_radiances_angle(:,1),anetaip.sky_radiances_fit(:,1),'r');
hold on
semilogy(anetaip.sky_radiances_angle(:,1),anetaip.sky_radiances_measured(:,1),'ro');
hold on

semilogy(anetaip.sky_radiances_angle(:,2),anetaip.sky_radiances_fit(:,2),'y');
hold on
semilogy(anetaip.sky_radiances_angle(:,2),anetaip.sky_radiances_measured(:,2),'yo');
hold on

semilogy(anetaip.sky_radiances_angle(:,3),anetaip.sky_radiances_fit(:,3),'b');
hold on
semilogy(anetaip.sky_radiances_angle(:,3),anetaip.sky_radiances_measured(:,3),'bo');
hold on

semilogy(anetaip.sky_radiances_angle(:,4),anetaip.sky_radiances_fit(:,4),'g');
hold on
semilogy(anetaip.sky_radiances_angle(:,4),anetaip.sky_radiances_measured(:,4),'go');
hold on

h = legend('fit (0.440)','measured (0.440)','fit (0.674)','measured (0.674)','fit (0.871)',...
    'measured (0.871)','fit (1.019)','measured (1.019)');
set(h,'FontSize', 10)

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Angle','FontSize', 10);
ylabel('Sky radiances','FontSize', 10);
set(gca,'xlim',[1 180],'FontSize', 10)
set(gca,'ylim',[0 1],'FontSize', 10)
title('Sky Radiances')
grid on


subplot(2,2,2)       
semilogy(anetaip.angle(:,1), anetaip.fine(:,1),'-r.');
hold on
semilogy(anetaip.angle(:,2), anetaip.fine(:,2),'-y.');
hold on
semilogy(anetaip.angle(:,3), anetaip.fine(:,3),'-b.');
hold on
semilogy(anetaip.angle(:,4), anetaip.fine(:,4),'-g.');
hold on

h = legend('fine (0.440)','fine (0.674)','fine (0.871)','fine (1.019)');
set(h,'FontSize', 10)

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Angle','FontSize', 10);
ylabel('Fine','FontSize', 10);
set(gca,'xlim',[1 180],'FontSize', 10)
set(gca,'ylim',[0.0 100],'FontSize', 10)
title('Phase function: Fine');
grid on


subplot(2,2,3)
semilogy(anetaip.angle(:,1),anetaip.coarse(:,1),'-r.');
hold on
semilogy(anetaip.angle(:,2),anetaip.coarse(:,2),'-y.');
hold on
semilogy(anetaip.angle(:,3),anetaip.coarse(:,3),'-b.');
hold on
semilogy(anetaip.angle(:,4),anetaip.coarse(:,4),'-g.');
hold on

h = legend('coarse (0.440)','coarse (0.674)','coarse (0.871)','coarse (1.019)');
set(h,'FontSize', 10)

xx_here=get(gca,'xlim');
yy_here=get(gca,'ylim');
xlabel('Angle','FontSize', 10);
ylabel('Coarse','FontSize', 10);
set(gca,'xlim',[1 180],'FontSize', 10)
set(gca,'ylim',[0.0 100],'FontSize', 10)
title('Phase function: Coarse');
grid on

saveas(gcf, [pname, filesep,fname,'.l4.png'], 'png');


       


