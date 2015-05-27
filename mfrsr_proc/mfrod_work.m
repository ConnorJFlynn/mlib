figure; 
td = [2400:3300];
imagesc(serial2doy0(mfrC1.time(td)), log([415,500,615,673,870]),...
    log([mfrC1.aod_415nm(td);mfrC1.aod_500nm(td);...
    mfrC1.aod_615nm(td);mfrC1.aod_673nm(td);...
    mfrC1.aod_870nm(td)]) ...   ); axis('xy') ...
... 
    -polyval(P,log([415; 500; 615; 673; 870]))...
    *ones(size(mfrC1.aod_415nm(td)))); 
axis('xy');
colorbar;
%%
clear
%%

close('all')
pause(1)
mfrC1_dir = ['C:\case_studies\Alive\data\sgpmfrsrC1\sgpmfrsrC1.b1\mat\'];
[mfrC1_fname, mfrC1_dir] = uigetfile([mfrC1_dir,'*.mat']);
mfrC1 = load([mfrC1_dir, mfrC1_fname]);
mfrC1 = mfrC1.mfr;
file_date_str = datestr(mfrC1.time(1), 'yyyymmdd');
mfrE13_dir = ['C:\case_studies\Alive\data\sgpmfrsrE13\sgpmfrsrE13.b1\mat\'];
mfrE13_list = dir([mfrE13_dir, '*',file_date_str,'*.mat']);
mfrE13 = load([mfrE13_dir, mfrE13_list(1).name]);
mfrE13 = mfrE13.mfr;


% mfrC1.dif2dir = mfrC1.vars.diffuse_hemisp_narrowband_filter2.data ./ mfrC1.vars.direct_normal_narrowband_filter2.data;
% 
% mfrE13.goodairm = find(((1./mfrE13.vars.cosine_solar_zenith_angle.data)<7)&((1./mfrE13.vars.cosine_solar_zenith_angle.data)>.9));
% mfrC1.goodairm = find(((1./mfrC1.vars.cosine_solar_zenith_angle.data)<7)&((1./mfrC1.vars.cosine_solar_zenith_angle.data)>.9));
% [mfrC1.aero, mfrC1.eps] = alex_screen(mfrC1.time(mfrC1.goodairm), mfrC1.tod_500nm(mfrC1.goodairm));
% [mfrE13.aero, mfrE13.eps] = alex_screen(mfrE13.time(mfrE13.goodairm), mfrE13.tod_500nm(mfrE13.goodairm));
% mfrC1.aero = mfrC1.eps<1e-3;
% mfrE13.aero = mfrE13.eps<1e-3;

gC = mfrC1.goodairm(mfrC1.aero);
gE = mfrE13.goodairm(mfrE13.aero);


figure; 
plot(serial2Hh(mfrC1.time(gC)), mfrC1.ang_by_fit(:,gC), 'r-')
hold on
plot(serial2Hh(mfrE13.time(gE)), mfrE13.ang_by_fit(:,gE),'k-');

title(['MFRSR best-fit angstrom exponent between C1 and E13 on ', datestr(mfrC1.time(1),'yyyy/mm/dd')]);
legend('C1', 'E13', 'location', 'northeast');
xlabel('time (hours UTC)');
ylabel('angstrom exponent');
v = axis;
axis([12,24, v(3), v(4)]);
hold off

% %%
figure; 
plot(serial2Hh(mfrC1.time(gC)), mfrC1.aod_by_fit(:,gC), '.')
hold on
plot(serial2Hh(mfrE13.time(gE)), mfrE13.aod_by_fit(:,gE),'k.');

title(['MFRSR cloud-screened AOD comparisons between C1 and E13 on ', datestr(mfrC1.time(1),'yyyy/mm/dd')]);
legend('C1:415nm', 'C1:500nm', 'C1:615nm', 'C1:673nm', 'C1:840nm', 'E13: all', 'location', 'northeast');
xlabel('time (hours UTC)');
ylabel('aerosol optical depth');
v = axis;
axis([12,24, v(3), v(4)]);
hold off
% %%
%%

% if length(find(mfrC1.aero==1)>2)
% plot_ods(serial2Hh(mfrC1.time(gC)), real([mfrC1.aod_415nm(gC); ...
%     mfrC1.aod_500nm(gC);mfrC1.aod_615nm(gC); ...
%     mfrC1.aod_673nm(gC);mfrC1.aod_870nm(gC)]),serial2Hh(mfrE13.time(gE)), real([mfrE13.aod_415nm(gE); ... 
% mfrE13.aod_500nm(gE); mfrE13.aod_615nm(gE); ...
% mfrE13.aod_673nm(gE); mfrE13.aod_870nm(gE)]));
      figure; 
        plot(serial2Hh(mfr.time(g)), [mfr.ang_415by500(g);mfr.ang_415by615(g); ... 
            mfr.ang_415by673(g)],'.', ... 
            serial2Hh(mfr.time(g)), [mfr.ang_500by615(g);mfr.ang_500by673(g)],'+', ... 
            serial2Hh(mfr.time(g)), [mfr.ang_615by673(g)],'x', ...
            serial2Hh(mfr.time(g)), [mfr.ang_by_fit(g)],'k-' );
        %        figure; plot(serial2Hh(mfr.time(good_air(aero))), [mfr.ang_415by500(good_air(aero));mfr.ang_415by615(good_air(aero));mfr.ang_415by673(good_air(aero))],'.', serial2Hh(mfr.time(good_air(aero))), [mfr.ang_500by615(good_air(aero));mfr.ang_500by673(good_air(aero))],'+', serial2Hh(mfr.time(good_air(aero))), [mfr.ang_615by673(good_air(aero))],'x' );

        title(['cloud-screened angstrom exponents: ', datestr(floor(mfr.time(1)))]);
        legend('415nm vs 500nm','415nm vs 615nm', '415nm vs 673nm','500nm vs 615nm', '500nm vs 673nm', '615nm vs 673nm');
        xlabel('time (HH UTC)');
        ylabel ('angstrom exponent');
        %    v = axis;
        axis([12,24, 1,3]);
        %     pause
        plot_label = '.ang_screened';
    print( gcf, '-dpng', [mfr.paths.pngs, NAME,plot_label, '.png'] );
    saveas(gcf, [mfr.paths.figs,NAME, plot_label, '.fig'], 'fig')
%%

figure; 
subplot(1,2,1);
plot(serial2Hh(mfrC1.time(gC)), [mfrC1.ang_415by500(gC);mfrC1.ang_415by615(gC);mfrC1.ang_415by673(gC)],'.', ...
    serial2Hh(mfrC1.time(gC)), [mfrC1.ang_500by615(gC);mfrC1.ang_500by673(gC)],'+', ...
    serial2Hh(mfrC1.time(gC)), [mfrC1.ang_615by673(gC)],'x' );
title(['MFRSR C1 ']);
legend('415nm vs 500nm','415nm vs 615nm', '415nm vs 673nm','500nm vs 615nm', '500nm vs 673nm', '615nm vs 673nm');
xlabel('time (HH UTC)');
ylabel ('angstrom exponent');
axis([12,24, 1,3]);

subplot(1,2,2);
plot(serial2Hh(mfrE13.time(gE)), [mfrE13.ang_415by500(gE);mfrE13.ang_415by615(gE);mfrE13.ang_415by673(gE)],'.', ...
    serial2Hh(mfrE13.time(gE)), [mfrE13.ang_500by615(gE);mfrE13.ang_500by673(gE)],'+', ...
    serial2Hh(mfrE13.time(gE)), [mfrE13.ang_615by673(gE)],'x' );
title('MFRSR E13');

xlabel([ datestr(floor(mfrE13.time(1)))]);
ylabel ('angstrom exponent');
axis([12,24, 1,3]);

figure; 
subplot(1,2,1);
plot(serial2Hh(mfrC1.time(gC)), [mfrC1.ang_415by500(gC);mfrC1.ang_415by615(gC);mfrC1.ang_415by673(gC);mfrC1.ang_415by870(gC)],'.', ...
    serial2Hh(mfrC1.time(gC)), [mfrC1.ang_500by615(gC);mfrC1.ang_500by673(gC);mfrC1.ang_500by870(gC)],'+', ...
    serial2Hh(mfrC1.time(gC)), [mfrC1.ang_615by673(gC);mfrC1.ang_615by870(gC)],'x',...
    serial2Hh(mfrC1.time(gC)), [mfrC1.ang_673by870(gC)],'o');
title(['MFRSR C1 ']);
legend('415nm vs 500nm','415nm vs 615nm', '415nm vs 673nm','415nm vs 870nm','500nm vs 615nm', '500nm vs 673nm', '500nm vs 870nm','615nm vs 673nm','615nm vs 870nm','673nm vs 870nm');
xlabel('time (HH UTC)');
ylabel ('angstrom exponent');
axis([12,24, 1,3]);

subplot(1,2,2);
plot(serial2Hh(mfrE13.time(gC)), [mfrE13.ang_415by500(gC);mfrE13.ang_415by615(gC);mfrE13.ang_415by673(gC);mfrE13.ang_415by870(gC)],'.', ...
    serial2Hh(mfrE13.time(gC)), [mfrE13.ang_500by615(gC);mfrE13.ang_500by673(gC);mfrE13.ang_500by870(gC)],'+', ...
    serial2Hh(mfrE13.time(gC)), [mfrE13.ang_615by673(gC);mfrE13.ang_615by870(gC)],'x',...
    serial2Hh(mfrE13.time(gC)), [mfrE13.ang_673by870(gC)],'o');
title('MFRSR E13');

xlabel([ datestr(floor(mfrE13.time(1)))]);
ylabel ('angstrom exponent');
axis([12,24, 1,3]);

%%
