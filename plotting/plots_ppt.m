%powerpoint_plots
% new 2014b colororder
cc = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; 0.9290  0.6940  0.1250;...
 0.4940  0.1840  0.5560; 0.4660 0.6740 0.1880;0.3010 0.7450 0.9330; ...
 0.6350 0.0780 0.1840];
% old 2014a colororder
cc = [ 0 0  1;  0 0.5 0; 1 0 0; 0 .75 .75; .75 0 .75; .75 .75 0; .25 .25 .25];
set(groot,'DefaultAxesColorOrder', cc);
clear cc
set(groot,'DefaultFigureColorMap',jet);     

set(0,'DefaultAxesFontName','Tahoma');
set(0,'DefaultAxesFontSize',16);
set(0,'DefaultAxesFontWeight','bold');
set(0,'DefaultTextFontName','Tahoma');
set(0,'DefaultTextFontSize',16);
set(0,'DefaultTextFontWeight','bold');
set(0,'DefaultAxesLineWidth',3)
set(0,'DefaultLineLineWidth',3);
set(0,'DefaultLineMarkerSize',10);

% colormap([.20,.20,.20;colormap('jet'); 1,1,1]);
% set(0,'DefaultFigureColormap', colormap)
%set(0,'DefaultLegendLineWidth','factory');