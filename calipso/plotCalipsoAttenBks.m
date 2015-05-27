function [output] = plotCalipsoAttenBks(hdfFilename,start_index,len,bSaveFigs);
% Inputs: hdf file name, start index, number of profiles (multiple of 15).
% This is a script to plot the mean value of attenuated backscatter, and the mean
% attenuated scattering ratios.
%



fig_num = 300;


% Set the start and edges array
start = [start_index 0];
edges = [len 583];

disp('Loading data from file');
%alt = load_altitudes();
foo = hdfread(hdfFilename, '/metadata', 'Fields', 'Lidar_Data_Altitudes', 'FirstRecord',1 ,'NumRecords',1);
alt = foo{1}; clear foo;

parameter  = 'Attenuated_Backscatter_1064';
[info betaP_1064]=readHDF(hdfFilename,parameter,start,edges);
betaP_1064 = betaP_1064';

parameter  = 'Total_Attenuated_Backscatter_532';
[info betaP_532]=readHDF(hdfFilename,parameter,start,edges);
betaP_532 = betaP_532';

parameter  = 'Perpendicular_Attenuated_Backscatter_532';
[info betaPP_532]=readHDF(hdfFilename,parameter,start,edges);
betaPP_532 = betaPP_532';

edges = [len 33];
met_alt = load_metAltitudes();

parameter  = 'Temperature';
[info Temperature]=readHDF(hdfFilename,parameter,start,edges);
Temperature = Temperature';
avgTemperature = avg_lidar_data(Temperature,len);

parameter  = 'Pressure';
[info Pressure]=readHDF(hdfFilename,parameter,start,edges);
Pressure = Pressure';
avgPressure = avg_lidar_data(Pressure,len);

parameter  = 'Molecular_Number_Density';
[info molNumDens]=readHDF(hdfFilename,parameter,start,edges);

parameter  = 'Ozone_Number_Density';
[info O3NumDens]=readHDF(hdfFilename,parameter,start,edges);

[betaM05 betaM10] = convertMolDens2BetaM(molNumDens,O3NumDens);

edges = [len 1];

parameter  = 'Latitude';
[info Lat]=readHDF(hdfFilename,parameter,start,edges);

parameter  = 'Longitude';
[info Lon]=readHDF(hdfFilename,parameter,start,edges);

% Process the filename to be used in the titles
str_len = length(hdfFilename);
t_str = hdfFilename(str_len-30+1:str_len);

% Get the text to append to the filenames
out_file_text = hdfFilename(str_len - 13 -4:str_len - 4);

% Deside if we should save the figures to a file
bSave = 0;
if nargin > 3,
    if strcmp(bSaveFigs,'true'),
	bSave = 1;
    end
end

figure(332)
clf
subplot(1,2,1)
plot(avgPressure,met_alt,avgPressure,met_alt,'o');
xlabel('Pressure');
ylabel('Altitude');
subplot(1,2,2)
plot(avgTemperature,met_alt,avgTemperature,met_alt,'o');
xlabel('Temperature');
axis([-80 30 -0.5 25])

% Plot an image
figure(333)
clf
[pos] = get(gcf,'Position');
set(gcf,'Position',[pos(1) pos(2) 700 500]);
set(gcf,'PaperPositionMode','auto')
[avg_data] = avg_lidar_data(betaP_532,15);
[avg_beta_perp] = avg_lidar_data(betaPP_532,15);
ncol = size(avg_data,2);
depol = zeros(583,ncol);
for i=1:ncol,
    tmp = avg_data(:,i)-avg_beta_perp(:,i);
    depol(:,i) = avg_beta_perp(:,i)./tmp;
end
[foo] = avg_lidar_data(betaP_532,5);
make_lidar_image(foo,333,'withColorbar');
%make_lidar_image(avg_data,333,'withColorbar');
title(sprintf('Total attenuated backscatter - %s [%d %d]',t_str,start_index,len));

if length(Lat) > 15,
    figure(233)
    foo_avg = zeros(size(avg_data));
    for i=1:size(foo_avg,2),
        foo_avg(:,i) = smooth(avg_data(:,i),3);
    end
    surf(Lat(7:15:length(Lat)),alt(100:583),real(log10(foo_avg(100:583,:))));view(2);shading flat
    caxis([-4 -1])
    xlabel('Latitude');ylabel('Altitude (km)')
    title(sprintf('%s [%d %d]',t_str,start_index,len))
end

figure(334)
clf
    for i=1:size(depol,2),
        foo_avg(:,i) = smooth(depol(:,i),3);
    end
imagesc(foo_avg)
caxis([-0.01 0.6])
colorbar
title(sprintf('Depolariztion ratio - %s [%d %d]',t_str,start_index,len));

% Compute mean values
mn_betaP_532 = mean(betaP_532(:,:),2);
mn_betaP_1064 = mean(betaP_1064(:,:),2);
mn_betaM05 = mean(betaM05,2);
mn_betaM10 = mean(betaM10,2);

windowSize = 11;
%mn_betaP_1064_filt =filter(ones(1,windowSize)/windowSize,1,mn_betaP_1064); 
mn_betaP_1064_filt =smooth(mn_betaP_1064,windowSize); 
mn_betaP_0532_filt =smooth(mn_betaP_532,windowSize); 

output.mn_betaP_532 = mn_betaP_532;
output.mn_betaP_1064 = mn_betaP_1064;
output.mn_betaP_1064_filt = mn_betaP_1064_filt;
output.mn_betaP_0532_filt = mn_betaP_0532_filt;
output.mn_betaM05 = mn_betaM05;
output.mn_betaM10 = mn_betaM10;
output.alt = alt;
output.aSR_1064 = mn_betaP_1064./mn_betaM10;
output.aSR_0532 = double(mn_betaP_532)./double(mn_betaM05);
output.Latitude = avg_lidar_data(Lat,15);
output.Longitude = avg_lidar_data(Lon,15);

% Let's compute some layer average attenuated scattering ratios
output.mn_1064_30_25 = mean(output.aSR_1064(37:61));
output.mn_0532_34_30 = mean(output.aSR_0532(21:34));

output.mn_1064_15_10 = mean(output.aSR_1064(176:258));
output.mn_0532_15_10 = mean(output.aSR_0532(176:258));

output.mn_1064_10_05 = mean(output.aSR_1064(259:396));
output.mn_0532_10_05 = mean(output.aSR_0532(259:396));

output.std_1064_30_25 = std(output.aSR_1064(37:61));
output.std_0532_34_30 = std(output.aSR_0532(21:34));

output.std_1064_15_10 = std(output.aSR_1064(176:258));
output.std_0532_15_10 = std(output.aSR_0532(176:258));

output.std_1064_10_05 = std(output.aSR_1064(259:396));
output.std_0532_10_05 = std(output.aSR_0532(259:396));

output.stats_text = {sprintf('1064 (30-25) %5.3f +/- %5.3f',output.mn_1064_30_25,output.std_1064_30_25);...
                     sprintf('1064 (15-10) %5.3f +/- %5.3f',output.mn_1064_15_10,output.std_1064_15_10);...
                     sprintf('1064  (10-5) %5.3f +/- %5.3f',output.mn_1064_10_05,output.std_1064_10_05);...
                     sprintf(' 532 (34-30) %5.3f +/- %5.3f',output.mn_0532_34_30,output.std_0532_34_30);...
                     sprintf(' 532 (15-10) %5.3f +/- %5.3f',output.mn_0532_15_10,output.std_0532_15_10);...
                     sprintf(' 532  (10-5) %5.3f +/- %5.3f',output.mn_0532_10_05,output.std_0532_10_05)}
%
% Plot the depolarizatio ratio only if there are enough profiles to average
fig_num = fig_num + 1;
foo = floor(ncol/4);
if foo > 5;
    figure(fig_num)
    clf
    [pos] = get(gcf,'Position');
    set(gcf,'Position',[pos(1) pos(2) 500 800]);
    set(gcf,'PaperPositionMode','auto')

    idx = [foo:foo:3*foo]
    mn_depol=zeros(583,3);
    for i=1:3,
	mn_depol(:,i) = mean(depol(:,idx(i):idx(i)+5),2);
    end
    plot_h = subplot('position',[0.08 0.06 0.25 .9]);
    plot(mn_depol(:,1),alt)
    grid on
    xlabel('Depolarization Ratio 532','FontSize',12);
    ylabel('Altitude','FontSize',12);
    %title(sprintf('%s [%d %d]\nLatitude %3.1f to %3.1f',t_str,start_index,len,Lat(1),Lat(len)),'FontSize',12);
    axis([-0.02 0.6 -0.5 30])  

    plot_h = subplot('position',[0.4 0.06 0.25 .9]);
    plot(mn_depol(:,2),alt)
    set(plot_h,'YTickLabel','');
    grid on
    xlabel('Depolarization Ratio 532','FontSize',12);
    axis([-0.02 0.6 -0.5 30])  

    plot_h = subplot('position',[0.7 0.06 0.25 .9]);
    plot(mn_depol(:,3),alt)
    set(plot_h,'YTickLabel','');
    grid on
    xlabel('Depolarization Ratio 532','FontSize',12);
    axis([-0.02 0.6 -0.5 30])  
    %ylabel('Altitude','FontSize',12);
    %title(sprintf('%s [%d %d]\nLatitude %3.1f to %3.1f',t_str,start_index,len,Lat(1),Lat(len)),'FontSize',12);
    suptitle(sprintf('%s [%d %d]\nLatitude %3.1f to %3.1f',t_str,start_index,len,Lat(1),Lat(len)),12);
end
if bSave,
    fname = sprintf('ClrAirAttenBks_%s_%05d_%05d.png',out_file_text,start_index,len);
%    print('-dpng',fname);
end

% Plot the attenuated backscatter values
fig_num = fig_num + 1;
figure(fig_num)
clf
[pos] = get(gcf,'Position');
set(gcf,'Position',[pos(1) pos(2) 500 800]);
set(gcf,'PaperPositionMode','auto')

plot_h = subplot('position',[0.08 0.06 0.4 .9]);
semilogx(mn_betaP_532,alt,mn_betaM05,alt)
grid on
xlabel('Total Attenuated Backscatter 532','FontSize',12);
ylabel('Altitude','FontSize',12);
%title(sprintf('%s [%d %d]\nLatitude %3.1f to %3.1f',t_str,start_index,len,Lat(1),Lat(len)),'FontSize',12);
axis([4e-6 0.2 -0.5 40])  

plot_h = subplot('position',[0.5 0.06 0.4 .9]);
semilogx(mn_betaP_1064,alt,mn_betaM10,alt)
set(plot_h,'YTickLabel','');
grid on
xlabel('Total Attenuated Backscatter 1064','FontSize',12);
axis([1e-6 0.2 -0.5 40])  
%ylabel('Altitude','FontSize',12);
%title(sprintf('%s [%d %d]\nLatitude %3.1f to %3.1f',t_str,start_index,len,Lat(1),Lat(len)),'FontSize',12);
suptitle(sprintf('%s [%d %d]\nLatitude %3.1f to %3.1f',t_str,start_index,len,Lat(1),Lat(len)),12);
if bSave,
    fname = sprintf('ClrAirAttenBks_%s_%05d_%05d.png',out_file_text,start_index,len);
%    print('-dpng',fname);
end

fig_num = fig_num +1;
figure(fig_num)
clf
[pos] = get(gcf,'Position');
set(gcf,'Position',[pos(1) pos(2) 500 800]);
set(gcf,'PaperPositionMode','auto')

plot_h = subplot('position',[0.08 0.06 0.4 .9]);
plot(mn_betaP_532./mn_betaM05,alt,'--')
hold on
h = plot(mn_betaP_0532_filt./mn_betaM05,alt,'LineWidth',2.0);
set(h,'Color',[0 0.5 0]);
axis([0.8 1.2 -0.5 40])
grid on
xlabel('Attenuated Scattering Ratio 532','FontSize',12);
ylabel('Altitude','FontSize',12);
%title(sprintf('%s [%d %d]\nLatitude %3.1f to %3.1f',t_str,start_index,len,Lat(1),Lat(len)),'FontSize',12);

% SUBPLOT('position',[left bottom width height])
plot_h = subplot('position',[0.5 0.06 0.4 .9]);
h1 = plot(mn_betaP_1064./mn_betaM10,alt,'--');
hold on
h2 = plot(mn_betaP_1064_filt./mn_betaM10,alt,'LineWidth',2.0);
set(h2,'Color','r')
set(plot_h,'YTickLabel','');
axis([-1 3 -0.5 40])
grid on
output.th= text(-0.95,35.0,output.stats_text);
set(output.th,'FontSize',12,'FontName','Courier');
xlabel('Attenuated Scattering Ratio 1064','FontSize',12);
%ylabel('Altitude','FontSize',12);
%title(sprintf('%s [%d %d]\nLatitude %3.1f to %3.1f',t_str,start_index,len,Lat(1),Lat(len)),'FontSize',12);
suptitle(sprintf('%s [%d %d]\nLatitude %3.1f to %3.1f',t_str,start_index,len,Lat(1),Lat(len)),12);

if bSave,
    fname = sprintf('ClrSR%s_%05d_%05d.png',out_file_text,start_index,len)
    print('-dpng',fname);
end

fig_num = fig_num +1;
figure(fig_num)
clf
[pos] = get(gcf,'Position');
set(gcf,'Position',[pos(1) pos(2) 500 800]);
set(gcf,'PaperPositionMode','auto')

%plot_h = subplot('position',[0.08 0.06 0.4 .9]);
plot(mn_betaP_532./mn_betaM05,alt,'--')
hold on
h = plot(mn_betaP_0532_filt./mn_betaM05,alt,'LineWidth',2.0);
set(h,'Color',[0 0.5 0]);
axis([-1 20 -0.5 15])
grid on
xlabel('Attenuated Scattering Ratio 532','FontSize',12);
ylabel('Altitude','FontSize',12);
title(sprintf('%s [%d %d]\nLatitude %3.1f to %3.1f',t_str,start_index,len,Lat(1),Lat(len)),'FontSize',12);
