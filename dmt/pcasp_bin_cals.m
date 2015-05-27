% PCASP bin threshold cals
% Okay, learning quite a bit.
% 
% From a plot of the actual PSL diameters versus their bin locations (as measured), we find a remarkable 
% similarity to the default supplied chan.def file, including the spacing of the points (apparently on
% a log-spaced interval) and the relative allotment of the number of bins per gain region.
% This would seem to provide a near optimal distribution of bins assuming that log-spacing is desired.
% 
% But this configuration, while near-optimal for measurement provides 
% too coarse a spacing for calibrating the lowest gain range.


%The fields below (d, bin_pos) were copied from the pcasp_mie.m file.

%Also, it is clear that we get a near linear response of each gain region
%with respect to the square of the particle diameter, as expected.
% To see this most clearly, one must account for the bin threshold A/D
% shift and then plot the adjusted bin position squared, or subtract the 
% corresponding baseline diameter pertaining to the gain region and the
% plot the square root of this baseline adjusted diameter versus bin
% position. 
d = 1e-3*[102, 114, 125, 152, 199, 220, 240, 269, 350, 450, 596, 799, 1361, 2013]';
% fix cross section units to cm^2
bnl = 1e12*[1.98e-16, 3.71e-16, 6.55e-16, 2.15e-15, 9.94e-15, 1.74e-14, 2.69e-14, 4.6e-14, ...
1.64e-13, 3.26e-13, 5.79e-13, 9.88e-13, 1.93e-12, 2.57e-12]';
bin_pos = [250,  370, 880, 4180, 4550, 4880, 5300, 6080, 8290, 8370, 8470, ...
    8800, 9700, 9875]';


figure; ax(1) = subplot(2,1,1); pl = semilogx(d*1000, bin_pos, 'bo');ylim([0,3*4096]); ylabel('bin position')
set(pl,'markerfacecolor','r');
ax(2) = subplot(2,1,2); pl = semilogx(1000*d, [bin_pos(1); diff(bin_pos)], 'ro');linkaxes(ax,'x'); xlim([100,2000]);ylim('auto');xlabel('diameter (nm)');
set(pl,'markerfacecolor','b');