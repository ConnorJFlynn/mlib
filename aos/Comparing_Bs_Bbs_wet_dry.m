nephdry = ancload('*sbs.cdf');
nephwet = ancload('*sbs.cdf');

%%
dry_nomiss = nephdry.vars.Bs_G_Dry_10um_Neph3W_1.data>-9000 & nephdry.vars.Bbs_G_Dry_10um_Neph3W_1.data>-9000;

wet_nomiss = nephwet.vars.Bs_G_Wet_10um_Neph3W_2.data>-9000 & nephwet.vars.Bbs_G_Wet_10um_Neph3W_2.data>-9000;
%%
figure; 
sa(1) = subplot(2,1,1); 
plot(serial2doys(nephdry.time(dry_nomiss)), nephdry.vars.Bs_G_Dry_10um_Neph3W_1.data(dry_nomiss), 'ro',...
    serial2doys(nephdry.time(dry_nomiss)), nephdry.vars.Bbs_G_Dry_10um_Neph3W_1.data(dry_nomiss), 'bo');
legend('dry Bs','dry Bbs');
grid('on'); zoom('on');
sa(2) = subplot(2,1,2); 
plot(serial2doys(nephwet.time(wet_nomiss)), nephwet.vars.Bs_G_Wet_10um_Neph3W_2.data(wet_nomiss), 'ro',...
    serial2doys(nephwet.time(wet_nomiss)), nephwet.vars.Bbs_G_Wet_10um_Neph3W_2.data(wet_nomiss), 'bo');
legend('wet Bs','wet Bbs');
grid('on'); zoom('on');

figure;
sc(1) = subplot(2,1,1); 
plot(serial2doys(nephdry.time(dry_nomiss)), nephdry.vars.Bs_G_Dry_10um_Neph3W_1.data(dry_nomiss)- nephdry.vars.Bbs_G_Dry_10um_Neph3W_1.data(dry_nomiss), 'xk-');
legend('dry Bs - dry Bbs');
grid('on'); zoom('on');
sc(2) = subplot(2,1,2); 
plot(serial2doys(nephwet.time(wet_nomiss)), nephwet.vars.Bs_G_Wet_10um_Neph3W_2.data(wet_nomiss) - ...
 nephwet.vars.Bbs_G_Wet_10um_Neph3W_2.data(wet_nomiss), 'k-o');
legend('wet Bs - wet Bbs');
grid('on'); zoom('on');



[ainb, bina] = nearest(nephdry.time(dry_nomiss), nephwet.time(wet_nomiss));
dry_ii = find(dry_nomiss);
wet_ii = find(wet_nomiss);

figure; 
sb(1) = subplot(2,1,1); 
plot(serial2doys(nephdry.time(dry_ii(ainb))), nephwet.vars.Bs_G_Wet_10um_Neph3W_2.data(wet_ii(bina))-...
    nephdry.vars.Bs_G_Dry_10um_Neph3W_1.data(dry_ii(ainb)), 'o'); legend('Bs wet - dry');
grid('on'); zoom('on');
sb(2) = subplot(2,1,2); 
plot(serial2doys(nephdry.time(dry_ii(ainb))), nephwet.vars.Bbs_G_Wet_10um_Neph3W_2.data(wet_ii(bina))-...
    nephdry.vars.Bbs_G_Dry_10um_Neph3W_1.data(dry_ii(ainb)), 'o'); legend('Bbs wet - dry');
grid('on'); zoom('on');
linkaxes([sa,sb, sc],'x')