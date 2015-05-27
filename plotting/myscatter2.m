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

diffs    = zeros(1, 17);
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
mycolor   = [1, 30,30, 140,140,140,140,140,140,140,140,140,140,140,140, 200,200];
% 
% 
%        for n=1:17
%            diffs(n) = alltime(n) - lab(n);
%        end
       diffs = (alltime - lab);
       figure;
       plots_ppt;
    
%  1= nimM1,   
%  2= nsaC1,   3=nsaC2
%  4= sgpC1,   5=sgpE1,   6=sgpE3,   7=sgpE4,   8=sgpE7,   9=sgpE9, 10=sgpE11,
% 11= sgpE12, 12=sgpE13, 13=sgpE16, 14=sgpE24, 15=sgpE27
% 16= twpC1,  17=twpC3
       points = (1:17);
       hold all;
       subplot(2,1,1); 
       plot(points(1:1), alltime(1:1), 'mo',points(2:3), alltime(2:3), 'bo', ...
              points(4:15), alltime(4:15), 'go',points(16:17), alltime(16:17),'ro');
%        legend('NIM', 'NSA', 'SGP', 'TWP')
       xlim([0,18]);
       ylim([-7.5,7.5]);
       ylabel('offset')
%        ylim([-10,10])
       set(gca,'ygrid', 'On');
       set(gca, 'XTick', [])
       title('Offset Corrections for 500 nm filter at ARM Sites')
       text(1,alltime(1)+1.5,'M1','fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','magenta');
       text(2,alltime(2)+1.5,'C1','fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','blue');
       text(3,alltime(3)+1.5,'C2','fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','blue');
       text(4,alltime(4)+1.5,'C1', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(5,alltime(5)+1.5,'E1', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(6,alltime(6)+1.5,'E3', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
%        text(7,alltime(7)+1.5,'E4', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(8,alltime(8)+1.5,'E7', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(9,alltime(9)+1.5,'E9', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(10,alltime(10)+1.5,'E11', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(11,alltime(11)+1.5,'E12', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(12,alltime(12)+1.5,'E13', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(13,alltime(13)+1.5,'E16', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(14,alltime(14)+1.5,'E24', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(15,alltime(15)+1.5,'E27', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(16,alltime(16)+1.5,'C1', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','red');
       text(17,alltime(17)+1.5,'C3', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','red');

%        text(1,alltime(1)+1.5,'M1','fontweight','bold','horizontalalignment','center','color','magenta');
%        text(2,alltime(2)+1.5,'C1','fontweight','bold','horizontalalignment','center','color','blue');
%        text(3,alltime(3)+1.5,'C2','fontweight','bold','horizontalalignment','center','color','blue');
%        text(4,alltime(4)+1.5,'C1', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(5,alltime(5)+1.5,'E1', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(6,alltime(6)+1.5,'E3', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(7,alltime(7)+1.5,'E4', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(8,alltime(8)+1.5,'E7', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(9,alltime(9)+1.5,'E9', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(10,alltime(10)+1.5,'E11', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(11,alltime(11)+1.5,'E12', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(12,alltime(12)+1.5,'E13', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(13,alltime(13)+1.5,'E16', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(14,alltime(14)+1.5,'E24', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(15,alltime(15)+1.5,'E27', 'fontweight','bold','horizontalalignment','center','color','green');
%        text(16,alltime(16)+1.5,'C1', 'fontweight','bold','horizontalalignment','center','color','red');
%        text(17,alltime(17)+1.5,'C3', 'fontweight','bold','horizontalalignment','center','color','red');

       subplot(2,1,2); 
       ylabel('expected')
       plot(points(1:1), diffs(1:1), 'mo',points(2:3), diffs(2:3), 'bo', ...
              points(4:15), diffs(4:15), 'go',points(16:17), diffs(16:17),'ro');
       leg = legend('NIM', 'NSA', 'SGP', 'TWP', 'Location',[.25,.5,.6,.05],...
           'Orientation','Horizontal');
       xlim([0,18]);
       ylim([-8,8]);
ylabel('Actual - Expected')
       set(gca,'ygrid', 'On');
       set(gca, 'XTick', [])
       text(1,diffs(1)+1.5,'M1','fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','magenta');
       text(2,diffs(2)+1.5,'C1','fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','blue');
       text(3,diffs(3)+1.5,'C2','fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','blue');
       text(4,diffs(4)+1.5,'C1', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(5,diffs(5)+1.5,'E1', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(6,diffs(6)+1.5,'E3', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(7,diffs(7)+1.5,'E4', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(8,diffs(8)+1.5,'E7', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(9,diffs(9)+1.5,'E9', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(10,diffs(10)+1.5,'E11', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(11,diffs(11)+1.5,'E12', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(12,diffs(12)+1.5,'E13', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(13,diffs(13)+1.5,'E16', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(14,diffs(14)+1.5,'E24', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(15,diffs(15)+1.5,'E27', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','green');
       text(16,diffs(16)+1.5,'C1', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','red');
       text(17,diffs(17)+1.5,'C3', 'fontweight','bold','horizontalalignment','center','verticalalignment','middle','color','red');

%       set(gad,'Grid', 'On', 'Grid','On');       
       
%       scatter([1:17], diff, 100, mycolor,'filled')
       
%       xlim([-12,5]);
%       ylim([-12,5]);
       
%       ylabel('Lamp-Measured Offset, Counts, Filter 2');

%       hold all;
%       x = [-12,5];
%       y = [-12,5];
%       plot(x,y,'LineWidth', 2);
       hold all;



     

       
       