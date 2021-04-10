function ava = SAS_polar_1(ins)
% This script to confirm that source is strongly polarized based on
% extinction of crossed polarizers. 

ins = SAS_read_Albert_csv
pre_stem = 'CrossedPolScan_';
sum_darks = sum(ins.spec(ins.Shuttered_0==0,:),2);
sum_darks = sum_darks./mean(sum_darks);
avg_darks = mean(ins.spec(ins.Shuttered_0==0,:),1);
dark_factor = interp1(find(ins.Shuttered_0==0),sum_darks,[1:length(ins.time)],'linear','extrap')';

light = ins.spec - dark_factor*avg_darks;
avg_light = mean(light(ins.Shuttered_0==1,:));
max_light = max(light(ins.Shuttered_0==1,:));
sat = max_light>=.99*max(max_light);
lights = (light(ins.Shuttered_0==1,:)) ./ (ones([sum(ins.Shuttered_0==1),1])*max_light);
% lights =(ins.spec(ins.Shuttered_0==1,:)-ones([sum(ins.Shuttered_0==1),1])*dark);


%%

figure; 
lines = plot(ins.nm, light(ins.Shuttered_0==1,:), '-');
lines = recolor(lines, rem(ins.Angle(ins.Shuttered_0==1,:)-180,90)');
colorbar

xlabel('nm')
ylabel('DN')
zoom('on');
R = input('Zoom into desired range.  When done zooming, enter a comment describing the measurement: (no underbars!)','s');
title({['Polarization Sensitivity of SAS-Ze ',ins.sn],R});

xl = xlim;
subnm = ins.nm>=xl(1) & ins.nm<=xl(2);

%%



% figure; plot([1:length(ins.Angle)],ins.Angle, '-o')
%%


figure; imagesc([1:length(ins.Angle(ins.Shuttered_0==1))], ins.nm(~sat&subnm), lights(:,~sat&subnm)'); axis('xy');
zoom('on');
%%
figure; lines = plot(ins.Angle(ins.Shuttered_0==1), lights(:,~sat&subnm),'-');
recolor(lines,ins.nm(~sat&subnm));
logy
colorbar
%%

imagegap(ins.Angle(ins.Shuttered_0==1)', ins.nm, real(log10(lights(:,~sat&subnm)'))); axis('xy');
ylabel('wavelength [nm]');
xlabel('angle [deg]');
colorbar; caxis([-6,0]); 
title({['Polarization Sensitivity of SAS-Ze ',ins.sn],R});
%%
angles = unique(ins.Angle(ins.Shuttered_0==1));
for a = length(angles):-1:1
   as = ins.Angle(ins.Shuttered_0==1)==angles(a);
   if sum(as)==1
      light_a(a,:) = lights(as,:);
   else
      light_a(a,:) = mean(lights(as,:),1);
   end
end
%%
figure; imagegap(angles', ins.nm, real(log10(light_a(:,~sat&subnm)'))); axis('xy');
ylabel('wavelength [nm]');
xlabel('angle [deg]');
colorbar; caxis([-4,0]); 
title(['Extinction of crossed polarizers',ins.sn]);
zoom('on');
k = menu('Zoom into desired range.  Select okay when done.','OK');
yl = ylim;
subnm = ins.nm>=yl(1) & ins.nm<=yl(2);

img_fname = input('Now enter a descriptor for naming the images: ','s');
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