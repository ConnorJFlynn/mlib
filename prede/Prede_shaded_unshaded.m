prede = read_prede;

figure; plot([1:18 20:25],[prede.filter_1([1:18 20:25]);prede.filter_2([1:18 20:25]);prede.filter_3([1:18 20:25]);prede.filter_4([1:18 20:25]);prede.filter_5([1:18 20:25]);prede.filter_6([1:18 20:25]);prede.filter_7([1:18 20:25])],'-o')
%%
SA_3 = [1:6];
SA_4 = [7:12];
SA_5 = [13:18];
SA_6 = [20:25];
%%
unshaded_3 =  SA_3(2:2:end);
shaded_3 =  SA_3(1:2:end);
for f = 2:7
P = polyfit(prede.time(unshaded_3),prede.(['filter_',num2str(f)])(unshaded_3),1);
prede.(['SA_3_filter',num2str(f),'_unshaded']) = polyval(P,mean(prede.time(SA_3)));
P = polyfit(prede.time(shaded_3),prede.(['filter_',num2str(f)])(shaded_3),1);
prede.(['SA_3_filter',num2str(f),'_shaded']) = polyval(P,mean(prede.time(SA_3)));
end
unshaded_4 =  SA_4(2:2:end);
shaded_4 =  SA_4(1:2:end);
for f = 2:7
P = polyfit(prede.time(unshaded_4),prede.(['filter_',num2str(f)])(unshaded_4),1);
prede.(['SA_4_filter',num2str(f),'_unshaded']) = polyval(P,mean(prede.time(SA_4)));
P = polyfit(prede.time(shaded_4),prede.(['filter_',num2str(f)])(shaded_4),1);
prede.(['SA_4_filter',num2str(f),'_shaded']) = polyval(P,mean(prede.time(SA_4)));
end
unshaded_5 =  SA_5(2:2:end);
shaded_5 =  SA_5(1:2:end);
for f = 2:7
P = polyfit(prede.time(unshaded_5),prede.(['filter_',num2str(f)])(unshaded_5),1);
prede.(['SA_5_filter',num2str(f),'_unshaded']) = polyval(P,mean(prede.time(SA_5)));
P = polyfit(prede.time(shaded_5),prede.(['filter_',num2str(f)])(shaded_5),1);
prede.(['SA_5_filter',num2str(f),'_shaded']) = polyval(P,mean(prede.time(SA_5)));
end
unshaded_6 =  SA_6(2:2:end);
shaded_6 =  SA_6(1:2:end);
for f = 2:7
P = polyfit(prede.time(unshaded_6),prede.(['filter_',num2str(f)])(unshaded_6),1);
prede.(['SA_6_filter',num2str(f),'_unshaded']) = polyval(P,mean(prede.time(SA_6)));
P = polyfit(prede.time(shaded_6),prede.(['filter_',num2str(f)])(shaded_6),1);
prede.(['SA_6_filter',num2str(f),'_shaded']) = polyval(P,mean(prede.time(SA_6)));
end

%%
shaded = [prede.SA_3_filter2_shaded,prede.SA_4_filter2_shaded,prede.SA_5_filter2_shaded,prede.SA_6_filter2_shaded;...
prede.SA_3_filter3_shaded,prede.SA_4_filter3_shaded,prede.SA_5_filter3_shaded,prede.SA_6_filter3_shaded;...
prede.SA_3_filter4_shaded,prede.SA_4_filter4_shaded,prede.SA_5_filter4_shaded,prede.SA_6_filter4_shaded;...
prede.SA_3_filter5_shaded,prede.SA_4_filter5_shaded,prede.SA_5_filter5_shaded,prede.SA_6_filter5_shaded;...
prede.SA_3_filter6_shaded,prede.SA_4_filter6_shaded,prede.SA_5_filter6_shaded,prede.SA_6_filter6_shaded;...
prede.SA_3_filter7_shaded,prede.SA_4_filter7_shaded,prede.SA_5_filter7_shaded,prede.SA_6_filter7_shaded]';

unshaded = [prede.SA_3_filter2_unshaded,prede.SA_4_filter2_unshaded,prede.SA_5_filter2_unshaded,prede.SA_6_filter2_unshaded;...
prede.SA_3_filter3_unshaded,prede.SA_4_filter3_unshaded,prede.SA_5_filter3_unshaded,prede.SA_6_filter3_unshaded;...
prede.SA_3_filter4_unshaded,prede.SA_4_filter4_unshaded,prede.SA_5_filter4_unshaded,prede.SA_6_filter4_unshaded;...
prede.SA_3_filter5_unshaded,prede.SA_4_filter5_unshaded,prede.SA_5_filter5_unshaded,prede.SA_6_filter5_unshaded;...
prede.SA_3_filter6_unshaded,prede.SA_4_filter6_unshaded,prede.SA_5_filter6_unshaded,prede.SA_6_filter6_unshaded;...
prede.SA_3_filter7_unshaded,prede.SA_4_filter7_unshaded,prede.SA_5_filter7_unshaded,prede.SA_6_filter7_unshaded]';

%%
figure; 
s(1) = subplot(2,1,1);
plot([3:6], shaded,'-o',[3:6], unshaded,'-x');
title('Prede shaded/unshaded sky radiance vs SA');
xlabel('Scattering angle (deg)')

s(2) = subplot(2,1,2);
plot([3:6], 100.*(unshaded-shaded)./shaded,'-*');
ylabel('%')
title('100 x (unshaded-shaded)/shaded)');
xlabel('Scattering angle (deg)')
linkaxes(s,'x')