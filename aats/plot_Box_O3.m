load d:\beat\data\diverse\060797.txt -ascii
UT=X060797(:,1);
O3=X060797(:,2:6);
clear X060797

plot(UT,O3)
legend('set 0','set 1','set 2','set 3','set 4')
set(gca,'FontSize',14)
grid on
xlabel('UT');
ylabel('Ozone [DU]')
