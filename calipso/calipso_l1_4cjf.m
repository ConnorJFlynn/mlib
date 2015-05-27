clear all
close all
%----------read CALIPSO data--------
load d:\zq_baeri\CALIPSO_plots\calipso_data.mat
%------- get the selected region
latN=0;
latS=-18;
lonW=4;
lonE=16;

h1 = figure('units','inches','position',[.1 .2 4 3],'paperposition',[.1 .1 8 5]);
%contourf(lat1,altitude,z1,[0.0001 0.1]);

X = 1e-4.*[1:9 10:5:80 100:100:1000];
X = 1e-4.*[2:9 10:5:80 100:100:900]; %Adjusted to match size of cmap
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
zmap = z1;
zmap(z1<X(1)) = 0;
zmap(z1>X(end)) = length(X);
for colr = 1:(length(X)-1)
  bin = (z1>=X(colr))&(z1<X(colr+1));
  zmap(bin)= colr;
end
imagesc(lat1,altitude,zmap);
colormap(cmap);
colorbar;
% caxis([0.0001 0.1]);

axis('xy');
%caxis([0.0001 0.1]) ;
hold on
%----
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



