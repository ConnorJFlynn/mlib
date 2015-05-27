% scatter plot of alltime vs lamp offsets, filter2,
% data from 2006/10/01
%
% subscripts
%
%  1= nimM1,   
%  2= nsaC1,   3=nsaC2
%  4= sgpC1,   5=sgpE1,   6=sgpE3,   7=sgpE4,   8=sgpE7,   9=sgpE9, 10=sgpE11,
% 11= sgpE12, 12=sgpE13, 13=sgpE16, 14=sgpE18, 15=sgpE24, 16=sgpE27
% 17= twpC1,  18=twpC3
%
% all values currently from filter2
%
%%

diff    = zeros(1, 17);
%
alltime = [1.715084, 1.206704,    0.0,    0.0,    -1.106145, -0.2773109, -11.83519, ...
           0.8823529, -5.837534, -3.0084, -1.37535, -2.,     -0.4106145, -2.529412, 0.0, ...
           -3.924581, -2.005587];
lab     = [1.6339,   0.882424, -3.29697, 0.460606, -1.17091, 1.139394, -4.13091, ...
           4.58182, -2.66182,   -1.49091, -0.99394, -0.87273, 0.368485, -0.89697, -0.78788, ...
           -1.84485, -1.09091];
%mycolor   = ['m', 'b', 'b', ...
%            'r', 'r', 'r', 'r', 'r', 'r', 'r', 'r', 'r', 'r', 'r', 'r', ...
%             'g', 'g'];
nim = 1;
nsa = 30;
twp = 200;
sgp = 140;
mycolor   = [nim, nsa, nsa, sgp*ones([1,12]), twp,twp];

%        for n=1:17
%            diff(n) = alltime(n) - lab(n);
%        end
offset_diff = alltime - lab;
       
       figure;
       plots_ppt;
       scatter([1:17],offset_diff,200,mycolor,'filledX');
       colormap('jet');
%        colorbar
       ylabel('lab offsets - night-time')
       
       
       figure;
       scatter(lab, alltime, 200, mycolor, 'filledX');
       colormap('jet');
       xlim([-12,5]);
       ylim([-12,5]);
       
       xlabel('Lamp Offset, Counts, Filter 2');
       ylabel('Measured Offset,Counts, Filter 2');
       hold all;
       x = [-12,5];
       y = [-12,5];
       plot(x,y,'LineWidth', 2);
       
       