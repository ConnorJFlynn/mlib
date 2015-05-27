%%
bin_sizes = [   1     0.090     0.100     0.095 
  2     0.100     0.110     0.105 
  3     0.110     0.120     0.115 
  4     0.120     0.130     0.125 
  5     0.130     0.140     0.135 
  6     0.140     0.150     0.145 
  7     0.150     0.160     0.155 
  8     0.160     0.170     0.165 
  9     0.170     0.180     0.175 
 10     0.180     0.200     0.190 
 11     0.200     0.220     0.210 
 12     0.220     0.240     0.230 
 13     0.240     0.260     0.250 
 14     0.260     0.280     0.270 
 15     0.280     0.300     0.290 
 16     0.300     0.400     0.350 
 17     0.400     0.500     0.450 
 18     0.500     0.600     0.550 
 19     0.600     0.800     0.700 
 20     0.800     1.000     0.900 
 21     1.000     1.200     1.100 
 22     1.200     1.400     1.300 
 23     1.400     1.600     1.500 
 24     1.600     1.800     1.700 
 25     1.800     2.000     1.900 
 26     2.000     2.200     2.100 
 27     2.200     2.400     2.300 
 28     2.400     2.600     2.500 
 29     2.600     2.800     2.700 
 30     2.800     3.000     2.900 
 ];
%%


figure; 
ax(1) = subplot(2,1,1);
plot([2:30], [mean(sea_080804a.tag_500.bins(2:30,ainb([end/4]:[3*end/4])),2), mean(sea_080804a.tag_700.bins(2:30,bina([end/4]:[3*end/4])),2)],'.-')
ln = line([5,5],ylim); set(ln,'color','r','linestyle','--');
ln = line([15,15],ylim); set(ln,'color','r','linestyle','--');
ylabel('mean counts'); xlabel('raw bin position');
legend('unit B, nose (tag 500)', 'unit A, cabin (tag 700)');
title(['size distribution for flight 080804a'])
ax(2) = subplot(2,1,2);
plot(bin_sizes(2:30,4), [mean(sea_080804a.tag_500.bins(2:30,ainb([end/4]:[3*end/4])),2), mean(sea_080804a.tag_700.bins(2:30,bina([end/4]:[3*end/4])),2)],'.-')
ylabel('mean counts'); xlabel('diameter (um)')
ln = line([0.135,0.135],ylim); set(ln,'color','r','linestyle','--');
ln = line([0.290,0.290],ylim); set(ln,'color','r','linestyle','--');

%%

figure; 
ax(1) = subplot(2,1,1);
plot([2:30], [mean(sea_080805a.tag_500.bins(2:30,AinB([end/4]:[3*end/4])),2), mean(sea_080805a.tag_700.bins(2:30,BinA([end/4]:[3*end/4])),2)],'.-')
ln = line([5,5],ylim); set(ln,'color','r','linestyle','--');
ln = line([15,15],ylim); set(ln,'color','r','linestyle','--');
ylabel('mean counts'); xlabel('raw bin position');
legend('unit A, nose (tag 500)', 'unit B, cabin (tag 700)')
title(['size distribution for flight 080805a'])
ax(2) = subplot(2,1,2);
plot(bin_sizes(2:30,4), [mean(sea_080805a.tag_500.bins(2:30,AinB([end/4]:[3*end/4])),2), mean(sea_080805a.tag_700.bins(2:30,BinA([end/4]:[3*end/4])),2)],'.-')
ylabel('mean counts'); xlabel('diameter (um)')
ln = line([0.135,0.135],ylim); set(ln,'color','r','linestyle','--');
ln = line([0.290,0.290],ylim); set(ln,'color','r','linestyle','--');
%%
sea_080806a = parse_tag(sea_080806a, 700);
%%
sea_080806a = parse_tag(sea_080806a, 500);
%%

[ainz, zina] = nearest(sea_080806a.tag_500.time,sea_080806a.tag_700.time) ;
%%
figure; 
ax(1) = subplot(2,1,1);
errorbar([2:30], [mean(sea_080806a.tag_500.bins(2:30,ainz([end/4]:[3*end/4])),2)],std(sea_080806a.tag_500.bins(2:30,ainz([end/4]:[3*end/4])),2), 'b.-');
hold('on')
errorbar([2:30], [mean(sea_080806a.tag_700.bins(2:30,zina([end/4]:[3*end/4])),2)],std(sea_080806a.tag_700.bins(2:30,zina([end/4]:[3*end/4])),2), 'g.-');
yl = ylim; yl(1) = max(yl(1),1e-4);
ln = line([5,5],yl); set(ln,'color','r','linestyle','--');
ln = line([15,15],yl); set(ln,'color','r','linestyle','--');
ylabel('mean counts'); xlabel('raw bin position');
legend('unit A, nose (tag 500)', 'unit B, cabin (tag 700)')
title(['size distribution for flight 080806a'])
ax(2) = subplot(2,1,2);
% plot(bin_sizes(2:30,4), [mean(sea_080806a.tag_500.bins(2:30,ainz([end/4]:[3*end/4])),2), mean(sea_080806a.tag_700.bins(2:30,zina([end/4]:[3*end/4])),2)],'.-')
errorbar(bin_sizes(2:30,4), [mean(sea_080806a.tag_500.bins(2:30,ainz([end/4]:[3*end/4])),2)],std(sea_080806a.tag_500.bins(2:30,ainz([end/4]:[3*end/4]))'), 'b.-');
hold('on')
errorbar(bin_sizes(2:30,4), [mean(sea_080806a.tag_700.bins(2:30,zina([end/4]:[3*end/4])),2)],std(sea_080806a.tag_700.bins(2:30,zina([end/4]:[3*end/4]))'), 'g.-');
yl = ylim; yl(1) = max(yl(1),1e-4);

%%
figure
rat = sea_080806a.tag_500.bins(:,ainz)./sea_080806a.tag_700.bins(:,zina);
bad_rat = ~isfinite(rat);
rat(bad_rat) = 0;
[row,col] = size(rat);
end_col = floor(col/4);
mean_rat = mean(rat(2:30,[end_col:3*end_col]),2);
std_rat = std(rat(2:30,[end_col:3*end_col])')';
errorbar(bin_sizes(2:30,4), mean_rat,std_rat, 'r.-');
%%
figure; 

plot([2:30], sum(sea_080806a.tag_500.bins(2:30,ainz([end/4]:[3*end/4]))')', 'b.-', ...
   [2:30], sum(sea_080806a.tag_700.bins(2:30,zina([end/4]:[3*end/4]))')', 'g.-');
yl = ylim; yl(1) = max(yl(1),1e-4);
logy
ln = line([5,5],yl); set(ln,'color','r','linestyle','--');
ln = line([15,15],yl); set(ln,'color','r','linestyle','--');
xlabel('raw bin position');
ylabel('mean counts','interp','none');
legend('unit A, nose (tag 500)', 'unit B, cabin (tag 700)')
title(['size distribution for flight 080806a'])

figure
% plot(bin_sizes(2:30,4), [mean(sea_080806a.tag_500.bins(2:30,ainz([end/4]:[3*end/4])),2), mean(sea_080806a.tag_700.bins(2:30,zina([end/4]:[3*end/4])),2)],'.-')
plot(bin_sizes(2:30,4), sum(sea_080806a.tag_500.bins(2:30,ainz([end/4]:[3*end/4])),2), 'b.-', ...
  bin_sizes(2:30,4), sum(sea_080806a.tag_700.bins(2:30,zina([end/4]:[3*end/4])),2), 'g.-' );
yl = ylim; yl(1) = max(yl(1),1e-4);
logy
xlabel('diameter (um)');
ylabel('mean counts','interp','none'); 
ln = line([0.135,0.135],yl); set(ln,'color','r','linestyle','--');
ln = line([0.290,0.290],yl); set(ln,'color','r','linestyle','--');
legend('unit A, nose (tag 500)', 'unit B, cabin (tag 700)')
title(['size distribution for flight 080806a'])




