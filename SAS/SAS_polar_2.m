function ava = SAS_polar_2(ins)
% This script to assess the degree of sensitivity to polarized light as a
% function of angle of the rotating polarizer
close('all');
ins = SAS_read_ava
pre_stem = 'PolScan_';
sum_darks = sum(ins.spec(ins.Shuttered_0==0,:),2);
sum_darks = sum_darks./mean(sum_darks);
avg_darks = mean(ins.spec(ins.Shuttered_0==0,:),1);
dark_factor = interp1(find(ins.Shuttered_0==0),sum_darks,[1:length(ins.time)],'linear','extrap')';

light = ins.spec - dark_factor*avg_darks;
avg_light = mean(light(ins.Shuttered_0==1,:));
max_light = max(light(ins.Shuttered_0==1,:));
sat = max_light>=.99*max(max_light);
lights = (light(ins.Shuttered_0==1,:)) ./ (ones([sum(ins.Shuttered_0==1),1])*avg_light);
angle_NaN = ins.Angle;
angle_NaN(angle_NaN==0) = NaN;
% lights =(ins.spec(ins.Shuttered_0==1,:)-ones([sum(ins.Shuttered_0==1),1])*dark);


%%
figure;
 plot([1:length(ins.Angle)],ins.Angle, '-o');
 xlabel('[1:length(ins.Angle)]')
 ylabel('angle [deg]')

 %%
 figure; 


lines = plot(ins.nm, light(ins.Shuttered_0==1,:), '-');
lines = recolor(lines, rem(ins.Angle(ins.Shuttered_0==1,:),180)');

colorbar

ylabel('(DN - darks)')
xlabel('wavelength [nm]')
zoom('on');
R = input('Zoom into desired range.  When done zooming, enter a comment describing the measurement: (no underbars!)','s');
title({['Polarization Sensitivity of SAS-Ze ',ins.sn],R});
img_fname = input('Now enter a descriptor for naming the images: ','s');

xl = xlim;
yl = ylim;
% subnm = ins.nm>=xl(1) & ins.nm<=xl(2);
subnm = any(light(ins.Shuttered_0==1,:)>yl(2),1);
subnm_ii = find(subnm);
subnm(subnm_ii(1):subnm_ii(end)) = true;

%%

% figure; 
% subplot(2,2,1)
imagesc([1:length(ins.Angle(ins.Shuttered_0==1))], ins.nm(~sat&subnm), lights(:,~sat&subnm)'); axis('xy');
imagegap(find(ins.Shuttered_0==1)', ins.nm(~sat&subnm)', lights(:,~sat&subnm)'); axis('xy');

zoom('on');
xlabel('[1:length(ins.Angle(ins.Shuttered_0==1))]');
ylabel('wavelength [nm]');
colorbar
Menu('Zoom into desired x-axis range. Select OK when done.','OK') 
xl = xlim;
% subnm = ins.nm>=xl(1) & ins.nm<=xl(2);
subx = [max([1 ceil(xl(1))]):min([length(ins.Angle),floor(xl(2))])];
suba = false(size(ins.Angle(ins.Shuttered_0==1)));
suba(subx) = true;

%%
% subplot(2,2,2);
% % figure; 
% lines = plot(angle_NaN(ins.Shuttered_0==1), lights(:,~sat&subnm),'-');
% recolor(lines,ins.nm(~sat&subnm));
% xlabel('angle [deg]');
% ylabel('deviation about mean over angle for each pixel')
% % logy
% colorbar
% 
% %%
% 
% % figure; 
% subplot(2,2,3);
% lines3 = plot(ins.nm(~sat&subnm),(lights(:,~sat&subnm)-1),'-');
% recolor(lines3,rem(angle_NaN(ins.Shuttered_0==1)',180));
% colorbar
% mins = min(lights(:,~sat&subnm),[],2);
% maxs = max(lights(:,~sat&subnm),[],2);
% 
% subplot(2,2,4);
% plot(rem(angle_NaN(ins.Shuttered_0==1)',180), maxs-mins, 'o-')

%%
% saveas(gcf,[ins.pname,pre_stem,'SN',ins.sn,'.', 'recolored_vs_nm','.fig']);
% saveas(gcf,[ins.pname,pre_stem,'SN',ins.sn,'.', 'recolored_vs_nm','.png']);
%%
% 
% imagesc(ins.Angle(ins.Shuttered_0==1), ins.nm, real(log10(lights'-1))); axis('xy');
% ylabel('wavelength [nm]');
% xlabel('angle [deg]');
% colorbar; caxis([-6,0]); 
% title({['Polarization Sensitivity of SAS-Ze ',ins.sn],R});
%%
% figure;
imagesc(ins.Angle(ins.Shuttered_0==1), ins.nm(~sat&subnm), 100.*(lights(:,~sat&subnm)'-1)); axis('xy');
imagesc(ins.Angle(suba), ins.nm(~sat&subnm), 100.*(lights(suba,~sat&subnm)'-1)); axis('xy');

ylabel('wavelength [nm]');
xlabel('angle [deg]');
cl = ceil(max(max(100.*(lights(suba,~sat&subnm)'-1))));
colorbar; caxis([-cl,cl]); 
title({['Polarization Sensitivity of SAS-Ze ',ins.sn],R});
%%
angles = unique(ins.Angle(suba));
for a = length(angles):-1:1
   as = ins.Angle(suba)==angles(a);
   if sum(as)==1
      light_a(a,:) = lights(as,:);
   else
      light_a(a,:) = mean(lights(as,:),1);
   end
end
%%

% figure; imagesc(angles, ins.nm(subnm), 100.*(light_a'-1)); axis('xy');
% ylabel('wavelength [nm]');
% xlabel('angle [deg]');
% colorbar; caxis([-cl,cl]); 
% title(['Polarization Sensitivity of SAS-Ze ',ins.sn]);
% zoom('on');

%% a
figure;
subplot(2,2,1)
imagegap(angles', ins.nm(subnm), 100.*(light_a(:,subnm)'-1)); axis('xy');
% cl = 150.*max(abs(mean(light_a(:,subnm)'-1,1)));
% cl = max([cl,2]);
colorbar; 
caxis([-cl,cl]);
ylabel('wavelength [nm]');
xlabel('angle [deg]');
title({['Color is % Sensitivity: ',ins.sn],R});

%%
subplot(2,2,3);
% figure; 
lines = plot(angles, 100.*(light_a(:,~sat&subnm)'-1),'-');
recolor(lines,ins.nm(~sat&subnm));
xlabel('angle [deg]');
ylabel('Sensitivity in %');
title('Color is nm')
% logy
colorbar

%%

% figure; 
subplot(2,2,2);
lines3 = plot(ins.nm(~sat&subnm),100.*(light_a(:,~sat&subnm)-1),'-');
recolor(lines3,rem(angles',180));
xl = xlim;
cb = colorbar('location','North');
xlim(xl);
yl = ylim;
ylim([yl(1),1.5.*yl(2)]);
xlabel('wavelength [nm]');
ylabel('Sensitivity in %')
title('Color is degrees');


mins = min(light_a(:,~sat&subnm),[],2);
maxs = max(light_a(:,~sat&subnm),[],2);
subplot(2,2,4);
plot(rem(angles',180), maxs-mins, '*')
ylabel('(max%-min%) vs angle')
xlabel('angle [deg]');

%% /a

saveas(gcf,[ins.pname,pre_stem,'SN',ins.sn,'.', img_fname,'.fig']);
saveas(gcf,[ins.pname,pre_stem,'SN',ins.sn,'.', img_fname,'.png']);
%%
% figure;  plot([1:length(ins.nm)], avg_light, '-');zoom('on');
% xlabel('index')
% 
% %%
% % vis
% subnm = [ceil(xl(1)):50:floor(xl(2))];  %ccd
% 
% %%
%  lines = plot(ins.Angle(ins.Shuttered_0==1),   lights(:,subnm)-1,'-');
% recolor(lines, ins.nm(subnm))
% cb = colorbar
% 
% xlabel('angle of rotation [deg]')
% ylabel('relative signal')
% set(get(cb,'title'),'string','nm')
% title(['Polarization Sensitivity of SAS-Ze ',ins.sn]);
% %%


% title('Polarization Sensitivity of SAS-Ze InGaAs Spectrometer')
%%
%nir
% plot([1:length(ins.Averages)],ins.Shuttered_0,'-x');
% figure; plot(ins.nm,max_light,'-')
disp('done')
%%
%