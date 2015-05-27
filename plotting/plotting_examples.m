% Single X-Y plot using stars to mark the data points:
plot(serial2Hh(nc.time), nc.vars.tdry.data,'*');
title('dry bulb temp')
xlabel('time (UTC hours)')
ylabel('degrees C')

% Single X-Y plot using a circle to mark the data points connected by a dashed line:
plot(serial2Hh(nc.time), nc.vars.tdry.data,':o');

% Single X-Y plot with more than 1 data quantity of the same length
plot(serial2Hh(nc.time), [nc.vars.tdry.data ; nc.vars.twet.data],':o');

% Single X-Y plot with more than 1 data quantity of differing lengths 
% displayes as red "x" and green "o"
plot(serial2Hh(nc1.time), nc1.vars.tdry.data,'rx',serial2Hh(nc2.time), nc2.vars.tdry.data],'go');
title('dry bulb temps')
xlabel('time (UTC hours)')
ylabel('degrees C');
legend('data #1','data #2')


% Two-pane plot...
subplot(2,1,1);
plot(serial2doy(nc1.time), nc1.vars.tdry.data,'rx');
title('title #1')
subplot(2,1,2);
plot(serial2doy(nc2.time), nc2.vars.tdry.data],'go');
title('title #2')

% Easy color intensity plot... This works if there are no missings and the
% vertical grid is uniform
imagesc(serial2doy(vc.time), vc.vars.range.data, vc.vars.backscatter.data); 
axis('xy'); %required to put origin at lower left corner (x,y) notation
            %rather than upper left as with matrix (i,j) notation
caxis([0,1]); % selects lower and upper limits of the color scale
colorbar % adds a colorbar to the RHS of the plot

% If there are gaps, use imagegap instead.  To do: make imagegap smart
% enough to default to imagesc if no gaps exist.

% If the vertical grid is irregular use a trick like this to make a new
% data object with a regular grid.  Then use imagesc or imagegap as before:
spacing = min(diff(altitude));
new_alt = [min(altitude):spacing:max(altitude)]';
new_z = interp1(altitude,z1,new_alt,'linear');
imagesc(time, new_alt, new_z); 
axis('xy'); % and so on...


