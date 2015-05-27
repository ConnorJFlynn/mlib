clear all
close all
%----------read CALIPSO data--------
filename='D:\zq_baeri\CALIPSO_data\2006-08-12-L1\CAL_LID_L1-Prov-V1-10.2006-08-12T12-40-03ZD.hdf';

%-------list products which will be used -------
data=['Profile_Time                            ';
    'Profile_UTC_Time                        ';
    'Total_Attenuated_Backscatter_532        ';
    'Perpendicular_Attenuated_Backscatter_532';
    'Attenuated_Backscatter_1064             ';
    'Spacecraft_Altitude                     ';
    'Longitude                               ';
    'Latitude                                ';];
list=cellstr(data);

% Open the input file.
sd_id = hdfsd( 'start', filename, 'read' );
for i = 1:length(list)
    item_name = list{i};
    %- Get index for this variable
    index = hdfsd('nametoindex', sd_id, item_name);
    %- Select the variable and read the data
    var_id = hdfsd('select',sd_id, index);
    [name,rank,dimsizes,data_type,nattrs,status(1)] = hdfsd('getinfo',var_id );
    [item_val,status(2)] = hdfsd('readdata',var_id,zeros(1,rank),[],dimsizes);
    % Now add that parameter data set as a field to the buffer structure.
    eval(['buffer.' item_name ' = item_val;']);
end
status(3) = hdfsd('endaccess',var_id);
hdfsd('end',sd_id);
%status = hdfgd('close', sd_id);
%----end reading data-----------

lat = buffer.Latitude;
lon = buffer.Longitude;
z=buffer.Total_Attenuated_Backscatter_532;
clear buffer

% retrieve the lidar data altitude array
metadata = hdfread(filename, '/metadata', 'Fields','Lidar_Data_Altitudes', 'FirstRecord', 1 ,'NumRecords', 1);
altitude = metadata{1};

clear metadata


%------- get the selected region
latN=0;
latS=-18;
lonW=4;
lonE=16;

h1 = figure('units','inches','position',[.1 .2 4 3],'paperposition',[.1 .1 8 5]);
r1=find(z==-9999);
z(r1)=NaN;
r=find(lat>=latS & lat<=latN);
lat1 = lat(r);
z1 = z(:,r);
clear lat z
%contourf(lat1,altitude,z1,[0.0001 0.1]);
imagesc(lat1,altitude,z1,[0.0001 0.1]);
axis('xy');
%caxis([0.0001 0.1]) ;
hold on
%----
cmap = [  0    0.1647    0.6667
    0    0.4980    1.0000
    0    0.6667    1.0000
    0    0.8314    1.0000
    0    1.0000    1.0000
    0    1.0000    0.8314
    0    1.0000    0.6667
    0    0.4980    0.4980
    0    0.6667    0.3333
    1.0000    1.0000         0
    1.0000    0.8314         0
    1.0000    0.6667         0
    1.0000    0.4980         0
    1.0000    0.3333         0
    1.0000         0         0
    1.0000    0.1647    0.3333
    1.0000    0.3333    0.4980
    1.0000    0.4980    0.6667
    0.2745    0.2745    0.2745
    0.3922    0.3922    0.3922
    0.5098    0.5098    0.5098
    0.6078    0.6078    0.6078
    0.7059    0.7059    0.7059
    0.7843    0.7843    0.7843
    0.8824    0.8824    0.8824
    0.9216    0.9216    0.9216
    0.9412    0.9412    0.9412
    0.9490    0.9490    0.9490
    0.9608    0.9608    0.9608
    0.9765    0.9765    0.9765
    0.9922    0.9922    0.9922
    1.0000    1.0000    1.0000];
%cmap = [jet(20); gray(15)];
colormap(cmap);
colorbar;
caxis([0.0001 0.1]);
%colormap('jet');
%colorbar;
titlestr = 'CALIPSO Total Attenuated Backscatter 532';
title(titlestr,'FontSize',14);
xx_here=get(gca,'xlim');
xlabel('Latitude','FontSize', 8);
ylabel('Altitude','FontSize', 8);
%set(gca,'ylim',[0.0 2],'FontSize',8);
set(gca,'ylim',[-2 30],'FontSize',8);
set(gca,'xlim',[-18 0]);
grid on
box on
image1 = strcat('d:\zq_baeri\CALIPSO_plots\calipso_tab532.ps');
print(h1,'-dpsc2',image1);



