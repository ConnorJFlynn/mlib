% New idea:
% For arbitrary number of instruments (starting with 1) compose Langley leg
% Compute "Refined" (Rayleigh-corrected) Langley for each wavelength.  
% These yield initial AOD_bar as slope of Langley line and Io.
% Compute refined tau_bar langley: assess stats, bias, RMS etc
% Compute refined tau(t) Langley using aod from Io.  Compare Io and stats
% 
% This did NOT work. Acceptable looking Langleys are just too common and
% yield initial AOD that is too far off to be corrected by aod-fit
% Instead must rely on initial or historical calibrations
% Next idea will be to use best aod_fit of a collection of calibrated
% values and compute tau_langleys for each source, then recompute AODs.
% Compare to originals, and compute a new best-fit to also compare.
% What does this mean in terms of actual Matlab functions?
% I think it means to run afit_lang_tau_series on as many sources as possible
% Try as written wi/o SASHe initially. 

these_aods = this_day & (serial2Hh(ttau.time_LST)>(noon+.5)) & ttau.nm==340;
these_340.time = ttau.time(these_aods);
these_340.airmass = ttau.airmass(these_aods);
these_340.aod = ttau.aod(these_aods);
these_340.I = exp(-these_340.airmass.*these_340.aod);
these_340.P = polyfit(these_340.airmass, log(these_340.I),1);
these_340.tau_bar = -these_340.P(1); these_340.Io_bar = exp(these_340.P(2));
these_340.tau_I = -log(these_340.I./these_340.Io_bar)./these_340.airmass;
these_340.I_bar = exp(-these_340.airmass.*these_340.tau_I);
figure; plot(these_340.airmass.*these_340.tau_I, these_340.I, 'o',these_340.airmass.*these_340.tau_I, these_340.I_bar,'x'); logy;
title('340 nm')

these_aods = this_day & (serial2Hh(ttau.time_LST)>(noon+.5)) & ttau.nm==380;
these_380.time = ttau.time(these_aods);
these_380.airmass = ttau.airmass(these_aods);
these_380.aod = ttau.aod(these_aods);
these_380.I = exp(-these_380.airmass.*these_380.aod);
these_380.P = polyfit(these_380.airmass, log(these_380.I),1);
these_380.tau_bar = -these_380.P(1); these_380.Io_bar = exp(these_380.P(2));
these_380.tau_I = -log(these_380.I./these_380.Io_bar)./these_380.airmass;
these_380.I_bar = exp(-these_380.airmass.*these_380.tau_I);
figure; plot(these_380.airmass.*these_380.tau_I, these_380.I, 'o',these_380.airmass.*these_380.tau_I, these_380.I_bar,'x'); logy;
title('380 nm');

these_aods = this_day & (serial2Hh(ttau.time_LST)>(noon+.5)) & ttau.nm==440;
these_440.time = ttau.time(these_aods);
these_440.airmass = ttau.airmass(these_aods);
these_440.aod = ttau.aod(these_aods);
these_440.I = exp(-these_440.airmass.*these_440.aod);
these_440.P = polyfit(these_440.airmass, log(these_440.I),1);
these_440.tau_bar = -these_440.P(1); these_440.Io_bar = exp(these_440.P(2));
these_440.tau_I = -log(these_440.I./these_440.Io_bar)./these_440.airmass;
these_440.I_bar = exp(-these_440.airmass.*these_440.tau_I);
figure; plot(these_440.airmass.*these_440.tau_I, these_440.I, 'o',these_440.airmass.*these_440.tau_I, these_440.I_bar,'x'); logy;
title('440 nm');

these_aods = this_day & (serial2Hh(ttau.time_LST)>(noon+.5)) & ttau.nm==500;
these_500.time = ttau.time(these_aods);
these_500.airmass = ttau.airmass(these_aods);
these_500.aod = ttau.aod(these_aods);
these_500.I = exp(-these_500.airmass.*these_500.aod);
these_500.P = polyfit(these_500.airmass, log(these_500.I),1);
these_500.tau_bar = -these_500.P(1); these_500.Io_bar = exp(these_500.P(2));
these_500.tau_I = -log(these_500.I./these_500.Io_bar)./these_500.airmass;
these_500.I_bar = exp(-these_500.airmass.*these_500.tau_I);
figure; plot(these_500.airmass.*these_500.tau_I, these_500.I, 'o',these_500.airmass.*these_500.tau_I, these_500.I_bar,'x'); logy;
title('500 nm');

these_aods = this_day & (serial2Hh(ttau.time_LST)>(noon+.5)) & ttau.nm==675;
these_675.time = ttau.time(these_aods);
these_675.airmass = ttau.airmass(these_aods);
these_675.aod = ttau.aod(these_aods);
these_675.I = exp(-these_340.airmass.*these_675.aod);
these_675.P = polyfit(these_675.airmass, log(these_675.I),1);
these_675.tau_bar = -these_675.P(1); these_675.Io_bar = exp(these_675.P(2));
these_675.tau_I = -log(these_675.I./these_675.Io_bar)./these_675.airmass;
these_675.I_bar = exp(-these_675.airmass.*these_675.tau_I);
figure; plot(these_675.airmass.*these_675.tau_I, these_675.I, 'o',these_675.airmass.*these_675.tau_I, these_675.I_bar,'x'); logy;
title('675 nm');

these_aods = this_day & (serial2Hh(ttau.time_LST)>(noon+.5)) & ttau.nm==870;
these_870.time = ttau.time(these_aods);
these_870.airmass = ttau.airmass(these_aods);
these_870.aod = ttau.aod(these_aods);
these_870.I = exp(-these_340.airmass.*these_870.aod);
these_870.P = polyfit(these_870.airmass, log(these_870.I),1);
these_870.tau_bar = -these_870.P(1); these_870.Io_bar = exp(these_870.P(2));
these_870.tau_I = -log(these_870.I./these_870.Io_bar)./these_870.airmass;
these_870.I_bar = exp(-these_870.airmass.*these_870.tau_I);
figure; plot(these_870.airmass.*these_870.tau_I, these_870.I, 'o',these_870.airmass.*these_870.tau_I, these_870.I_bar,'x'); logy;
title('870 nm');

figure; plot(these_870.airmass.*these_870.tau_I, these_870.I./these_870.I_bar,'x'); logy;
title('870 nm  I/I_bar');

these_aods = this_day & (serial2Hh(ttau.time_LST)>(noon+.5)) & ttau.nm==1020;
these_1020.time = ttau.time(these_aods);
these_1020.airmass = ttau.airmass(these_aods);
these_1020.aod = ttau.aod(these_aods);
these_1020.I = exp(-these_340.airmass.*these_1020.aod);
these_1020.P = polyfit(these_1020.airmass, log(these_1020.I),1);
these_1020.tau_bar = -these_1020.P(1); these_1020.Io_bar = exp(these_1020.P(2));
these_1020.tau_I = -log(these_1020.I./these_1020.Io_bar)./these_1020.airmass;
these_1020.I_bar = exp(-these_1020.airmass.*these_1020.tau_I);
figure; plot(these_1020.airmass.*these_1020.tau_I, these_1020.I, 'o',these_1020.airmass.*these_1020.tau_I, these_1020.I_bar,'x'); logy;
title('1020 nm');

these_aods = this_day & (serial2Hh(ttau.time_LST)>(noon+.5)) & ttau.nm==1640;
these_1640.time = ttau.time(these_aods);
these_1640.airmass = ttau.airmass(these_aods);
these_1640.aod = ttau.aod(these_aods);
these_1640.I = exp(-these_340.airmass.*these_1640.aod);
these_1640.P = polyfit(these_1640.airmass, log(these_1640.I),1);
these_1640.tau_bar = -these_1640.P(1); these_1640.Io_bar = exp(these_1640.P(2));
these_1640.tau_I = -log(these_1640.I./these_1640.Io_bar)./these_1640.airmass;
these_1640.I_bar = exp(-these_1640.airmass.*these_1640.tau_I);
figure; plot(these_1640.airmass.*these_1640.tau_I, these_1640.I, 'o',these_1640.airmass.*these_1640.tau_I, these_1640.I_bar,'x'); logy;
title('1640 nm');

figure_(77); plot(these_340.time, these_340.aod, 'o',these_380.time, these_380.aod, 'o',...
     these_440.time, these_440.aod, 'o',these_500.time, these_500.aod, 'o',...
     these_675.time, these_675.aod, 'x',these_870.time, these_870.aod, 'x',...
     these_1020.time, these_1020.aod, 'x',these_1640.time, these_1640.aod, 'x');
legend('340','380','440','500','675','870','1020','1640')
P1 = polyfit(these_340.airmass, -these_340.airmass.*these_340.aod,1); 
P2 = polyfit(these_380.airmass, -these_380.airmass.*these_380.aod,1);
P3 = polyfit(these_440.airmass, -these_440.airmass.*these_440.aod,1);
P4 = polyfit(these_500.airmass, -these_340.airmass.*these_500.aod,1);
P5 = polyfit(these_675.airmass, -these_340.airmass.*these_675.aod,1);
P6 = polyfit(these_870.airmass, -these_340.airmass.*these_870.aod,1);
P7 = polyfit(these_1020.airmass, -these_340.airmass.*these_1020.aod,1);
P8 = polyfit(these_1640.airmass, -these_340.airmass.*these_1640.aod,1);

 figure_(78); 
 plot(these_340.airmass, exp(-these_340.airmass.*these_340.aod),'o',[0,7], exp(polyval(P1,[0,7])),'--',...
     these_380.airmass, exp(-these_340.airmass.*these_380.aod), 'o',[0,7], exp(polyval(P2,[0,7])),'--',...
     these_440.airmass, exp(-these_340.airmass.*these_440.aod), 'o',[0,7], exp(polyval(P3,[0,7])),'--',...
     these_500.airmass, exp(-these_340.airmass.*these_500.aod), 'o',[0,7], exp(polyval(P4,[0,7])),'--',...
     these_675.airmass, exp(-these_340.airmass.*these_675.aod), 'x',[0,7], exp(polyval(P5,[0,7])),'--',...
     these_870.airmass, exp(-these_340.airmass.*these_870.aod), 'x',[0,7], exp(polyval(P6,[0,7])),'--',...
     these_1020.airmass, exp(-these_340.airmass.*these_1020.aod), 'x',[0,7], exp(polyval(P7,[0,7])),'--',...
     these_1640.airmass, exp(-these_340.airmass.*these_1640.aod), 'x',[0,7], exp(polyval(P8,[0,7])),'--');
legend('340','380','440','500','640','870','1020','1640');logy
 
 figure_(79); 
 plot(-these_340.airmass.*P1(1), exp(-these_340.airmass.*these_340.aod),'o',-P1(1).*[0,7], exp(polyval(P1,[0,7])),'--',...
     -these_380.airmass.*P2(1), exp(-these_340.airmass.*these_380.aod), 'o',-P2(1).*[0,7], exp(polyval(P2,[0,7])),'--',...
     -these_440.airmass.*P3(1), exp(-these_340.airmass.*these_440.aod), 'o',-P3(1).*[0,7], exp(polyval(P3,[0,7])),'--',...
     -these_500.airmass.*P4(1), exp(-these_340.airmass.*these_500.aod), 'o',-P4(1).*[0,7], exp(polyval(P4,[0,7])),'--',...
     -these_675.airmass.*P5(1), exp(-these_340.airmass.*these_675.aod), 'x',-P5(1).*[0,7], exp(polyval(P5,[0,7])),'--',...
     -these_870.airmass.*P6(1), exp(-these_340.airmass.*these_870.aod), 'x',-P6(1).*[0,7], exp(polyval(P6,[0,7])),'--',...
     -these_1020.airmass.*P7(1), exp(-these_340.airmass.*these_1020.aod), 'x',-P7(1).*[0,7], exp(polyval(P7,[0,7])),'--',...
     -these_1640.airmass.*P8(1), exp(-these_340.airmass.*these_1640.aod), 'x',-P8(1).*[0,7], exp(polyval(P8,[0,7])),'--');
legend('340','380','440','500','640','870','1020','1640');logy

 figure_(79); 
 plot(-these_340.airmass.*P1(1), exp(-these_340.airmass.*these_340.aod),'o',-P1(1).*[0,7], exp(polyval(P1,[0,7])),'--',...
     -these_380.airmass.*P2(1), exp(-these_340.airmass.*these_380.aod), 'o',-P2(1).*[0,7], exp(polyval(P2,[0,7])),'--',...
     -these_440.airmass.*P3(1), exp(-these_340.airmass.*these_440.aod), 'o',-P3(1).*[0,7], exp(polyval(P3,[0,7])),'--',...
     -these_500.airmass.*P4(1), exp(-these_340.airmass.*these_500.aod), 'o',-P4(1).*[0,7], exp(polyval(P4,[0,7])),'--',...
     -these_675.airmass.*P5(1), exp(-these_340.airmass.*these_675.aod), 'x',-P5(1).*[0,7], exp(polyval(P5,[0,7])),'--',...
     -these_870.airmass.*P6(1), exp(-these_340.airmass.*these_870.aod), 'x',-P6(1).*[0,7], exp(polyval(P6,[0,7])),'--',...
     -these_1020.airmass.*P7(1), exp(-these_340.airmass.*these_1020.aod), 'x',-P7(1).*[0,7], exp(polyval(P7,[0,7])),'--',...
     -these_1640.airmass.*P8(1), exp(-these_340.airmass.*these_1640.aod), 'x',-P8(1).*[0,7], exp(polyval(P8,[0,7])),'--');
legend('340','380','440','500','640','870','1020','1640');logy
 


 plot(aod_500_raw.airmass, exp(-aod_500_raw.airmass.*aod_500_raw.aod_500),'o',...
   these_440.airmass, exp(-these_440.airmass.*these_440.aod),'x'  ); logy

figure_(24); set(gcf,'visible','on')
xx(1) = subplot(3,1,1);
plot(PM_leg.airmass, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');

P_11 = polyfit(PM_leg.airmass, -PM_leg.airmass.*PM_leg.aod_fit(:,11),1);

hold('on'); plot([0,xl(2)], exp(polyval(P_11,[0,xl(2)])),'r--');


xx(2) = subplot(2,1,2); 
plot(tau_bar.*PM_leg.airmass, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');
plot(PM_leg.airmass.*tau_bar, -PM_leg.airmass.*PM_leg.aod_fit(:,11));
hold('on'); plot([0,xl(2)], exp(polyval(P_11,[0,xl(2)])),'r--');



        xl = xlim; xlim([-0.25, xl(2)])
        title([datestr(mean(PM_leg.time_LST)-6.5./24,'yyyy-mm-dd'), ', PM Leg']);
        ylabel('Tr')
        xx(2) = subplot(2,1,2);
        plot(PM_leg.aod_fit(:,11).*PM_leg.airmass, exp(-PM_leg.airmass.*PM_leg.aod_fit(:,11)),'-o');
        xl = xlim; xlim([0, xl(2)])
        xlabel('airmass*tau');
        ylabel('Tr');
        linkaxes(xx,'y');
        pause(.01)
