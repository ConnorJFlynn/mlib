CART = read_cimel_aod;
cart = read_cimel_aod;

%%
[anet.time, ind] = sort([cart.time; CART.time]);
fields = fieldnames(cart);
for f = 1:10
   anet.(fields{f}) = cart.(fields{f});
end
for f = 11:length(fields)
   tmp = [cart.(fields{f}); CART.(fields{f})];
   anet.(fields{f}) = tmp(ind);
end
%%
[aero, eps, aero_eps, mad, abs_dev] = aod_screen(anet.time, anet.AOT_500,0, 1,150, 2, 3e-4,100);
anet_screened = sift_anet(anet, aero);
anet_davg = month_avg(anet_screened,[1 1 1 0 0 0]);
anet_mavg = month_avg(anet_screened,[1 1 0 0 0 0]);
%%
anet_season = season_avg(anet_mavg);
%%
figure; this = plot(anet_davg.time, anet_davg.AOT_500,'b.',...
   anet_mavg.time, anet_mavg.AOT_500,'ro',...
anet_season.time, anet_season.AOT_500,'go'); datetick('keeplimits');
set(this(2),'marker','o','markerfa','r','markersize',5)
set(this(3),'marker','o', 'markerfa','k','markersize',10)
legend('daily','monthly','seasonal')
title({['Aeronet AOD 500 nm, version 2'],...
   ['Retained ',num2str(sum(aero)),' of ',num2str(length(aero)),' values after screening.']})
xlabel('year')
ylabel('AOD 500 nm')


%%
% Now to output Chuck's ascii files:

%%
header_str = ' year, month, AOD_500 ';


V = datevec(anet_season.time);
% txt_out needs to be composed of data oriented as column vectors.
txt_out = [V(:,1), V(:,2),anet_season.AOT_500'];




out_dir = 'C:\case_studies\Aeronet\decade\';
fname = 'anet_seasons.txt';
foutname = [[out_dir fname]];
fid = fopen(foutname,'w+');
fprintf(fid,'%s \n',header_str );

format_str = ['%d,  %d,   %2.5f  \n']; % 5

fprintf(fid,format_str,txt_out');
fclose(fid);
