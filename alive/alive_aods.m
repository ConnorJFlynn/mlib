
mfrC1 = ancload;
mfrE13 = ancload;
mfrC1.aero = aod_screen(mfrC1.time, mfrC1.vars.aerosol_optical_depth_filter2.data);
tau = mfrC1.vars.total_optical_depth_filter2.data .* mfrC1.vars.airmass.data;
mfrC1_filtered = ancsift(mfrC1, mfrC1.dims.time, (mfrC1.aero&tau<5));


tau = mfrE13.vars.total_optical_depth_filter2.data .* mfrE13.vars.airmass.data;
mfrE13.aero = aod_screen(mfrE13.time, mfrE13.vars.aerosol_optical_depth_filter2.data);
mfrE13_filtered = ancsift(mfrE13, mfrE13.dims.time, (mfrE13.aero&tau<5));
%%

[mfrC1_filtered.nearE13, mfrE13_filtered.nearC1] = nearest(mfrC1_filtered.time, mfrE13_filtered.time);
%%
% C1_alive = ancsift(mfrC1_filtered, mfrC1_filtered.dims.time, (mfrC1_filtered.time>datenum('2005-09-1','yyyy-mm-dd'))&(mfrC1_filtered.time>datenum('2005-09-30','yyyy-mm-dd')));
% E13_alive = ancsift(mfrE13_filtered, mfrE13_filtered.dims.time, (mfrE13_filtered.time>datenum('2005-09-1','yyyy-mm-dd'))&(mfrE13_filtered.time>datenum('2005-09-30','yyyy-mm-dd')));
%%
bias = mean(mfrE13_filtered.vars.aerosol_optical_depth_filter1.data(mfrE13_filtered.nearC1)-mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearE13));
[P,S] = polyfit(mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter1.data(mfrE13_filtered.nearC1),1);
stats = fit_stat(mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter1.data(mfrE13_filtered.nearC1),P,S);

figure; plot(mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter1.data(mfrE13_filtered.nearC1), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearE13))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearE13))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('MFRSR C1 AOD');
ylabel('MFRSR E13 AOD');
title(['AOD at 415 nm, MFRSR C1 vs MFRSR E13']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)

%%
bias = mean(mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearC1)-mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearE13));
[P,S] = polyfit(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearC1),1);
stats = fit_stat(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearC1),P,S);

figure; plot(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearC1), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearE13))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearE13))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('MFRSR C1 AOD');
ylabel('MFRSR E13 AOD');
title(['AOD at 500 nm, MFRSR C1 vs MFRSR E13']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)

%%
bias = mean(mfrE13_filtered.vars.aerosol_optical_depth_filter3.data(mfrE13_filtered.nearC1)-mfrC1_filtered.vars.aerosol_optical_depth_filter3.data(mfrC1_filtered.nearE13));
[P,S] = polyfit(mfrC1_filtered.vars.aerosol_optical_depth_filter3.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter3.data(mfrE13_filtered.nearC1),1);
stats = fit_stat(mfrC1_filtered.vars.aerosol_optical_depth_filter3.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter3.data(mfrE13_filtered.nearC1),P,S);

figure; plot(mfrC1_filtered.vars.aerosol_optical_depth_filter3.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter3.data(mfrE13_filtered.nearC1), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter3.data(mfrC1_filtered.nearE13))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter3.data(mfrC1_filtered.nearE13))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('MFRSR C1 AOD');
ylabel('MFRSR E13 AOD');
title(['AOD at 615 nm, MFRSR C1 vs MFRSR E13']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)

%%

bias = mean(mfrE13_filtered.vars.aerosol_optical_depth_filter4.data(mfrE13_filtered.nearC1)-mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearE13));
[P,S] = polyfit(mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter4.data(mfrE13_filtered.nearC1),1);
stats = fit_stat(mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter4.data(mfrE13_filtered.nearC1),P,S);

figure; plot(mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter4.data(mfrE13_filtered.nearC1), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearE13))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearE13))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('MFRSR C1 AOD');
ylabel('MFRSR E13 AOD');
title(['AOD at 673 nm, MFRSR C1 vs MFRSR E13']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)

%%
bias = mean(mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearC1)-mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearE13));
[P,S] = polyfit(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearC1),1);
stats = fit_stat(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearC1),P,S);

figure; plot(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearE13), mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearC1), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearE13))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearE13))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('MFRSR C1 AOD');
ylabel('MFRSR E13 AOD');
title(['AOD at 870 nm, MFRSR C1 vs MFRSR E13']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)

% %%
% bias = mean(E13_alive.vars.aerosol_optical_depth_filter2.data(test3.nearC1)-C1_alive.vars.aerosol_optical_depth_filter2.data(test3.nearE13));
% [P,S] = polyfit(C1_alive.vars.aerosol_optical_depth_filter2.data(test3.nearE13), E13_alive.vars.aerosol_optical_depth_filter2.data(test3.nearC1),1);
% stats = fit_stat(C1_alive.vars.aerosol_optical_depth_filter2.data(test3.nearE13), E13_alive.vars.aerosol_optical_depth_filter2.data(test3.nearC1),P,S);
% figure; plot(C1_alive.vars.aerosol_optical_depth_filter2.data(test3.nearE13), E13_alive.vars.aerosol_optical_depth_filter2.data(test3.nearC1), '.',[[0,max(C1_alive.vars.aerosol_optical_depth_filter2.data(test3.nearE13))]],polyval(P,[0,max(C1_alive.vars.aerosol_optical_depth_filter2.data(test3.nearE13))]),'r');
% axis('square');
% xl = xlim; line(xl,xl,'color','black','linestyle','- -');
% ylim(xl);
% xlabel('MFRSR C1 AOD');
% ylabel('MFRSR E13 AOD');
% title(['AOD at 500 nm, MFRSR C1 vs MFRSR E13']);
% txt = {['N = ', num2str(stats.N)],...
%     ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
%     ['slope = ',sprintf('%1.3g',P(1))], ...
%     ['Y\_int = ', sprintf('%0.02g',P(2))],...
%     ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
%     ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
% gt = gtext(txt);
% set(gt,'fontsize',14)

%%
cimel = read_cimel_2p1;
%%
[mfrC1_filtered.nearCimel, cimel.nearC1] = nearest(mfrC1_filtered.time, cimel.time');
[mfrE13_filtered.nearCimel, cimel.nearE13] = nearest(mfrE13_filtered.time, cimel.time');
%%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearCimel)-cimel.aod_870(cimel.nearC1)');

[P,S] = polyfit(cimel.aod_500(cimel.nearC1)', mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearCimel),1);
stats = fit_stat(cimel.aod_500(cimel.nearC1)',mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearCimel),P,S);
figure; plot(cimel.aod_500(cimel.nearC1)',mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearCimel), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearCimel))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearCimel))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('Cimel AOD');
ylabel('MFRSR C1 AOD');
title(['AOD at 500 nm, Cimel vs MFRSR C1']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%

bias = mean(mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearCimel)-cimel.aod_500(cimel.nearE13)');
[P,S] = polyfit(cimel.aod_500(cimel.nearE13)', mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearCimel),1);
stats = fit_stat(cimel.aod_500(cimel.nearE13)',mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearCimel),P,S);
figure; plot(cimel.aod_500(cimel.nearE13)',mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearCimel), '.',[[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearCimel))]],polyval(P,[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearCimel))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('Cimel AOD');
ylabel('MFRSR E13 AOD');
title(['AOD at 500 nm, Cimel vs MFRSR E13']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearCimel)-cimel.aod_870(cimel.nearC1)');

[P,S] = polyfit(cimel.aod_870(cimel.nearC1)', mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearCimel),1);
stats = fit_stat(cimel.aod_870(cimel.nearC1)',mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearCimel),P,S);
figure; plot(cimel.aod_870(cimel.nearC1)',mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearCimel), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearCimel))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearCimel))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('Cimel AOD');
ylabel('MFRSR C1 AOD');
title(['AOD at 870 nm, Cimel vs MFRSR C1']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%

bias = mean(mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearCimel)-cimel.aod_870(cimel.nearE13)');
[P,S] = polyfit(cimel.aod_870(cimel.nearE13)', mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearCimel),1);
stats = fit_stat(cimel.aod_870(cimel.nearE13)',mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearCimel),P,S);
figure; plot(cimel.aod_870(cimel.nearE13)',mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearCimel), '.',[[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearCimel))]],polyval(P,[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearCimel))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('Cimel AOD');
ylabel('MFRSR E13 AOD');
title(['AOD at 870 nm, Cimel vs MFRSR E13']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearCimel)-cimel.aod_415(cimel.nearC1)');

[P,S] = polyfit(cimel.aod_415(cimel.nearC1)', mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearCimel),1);
stats = fit_stat(cimel.aod_415(cimel.nearC1)',mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearCimel),P,S);
figure; plot(cimel.aod_415(cimel.nearC1)',mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearCimel), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearCimel))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter1.data(mfrC1_filtered.nearCimel))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('Cimel AOD');
ylabel('MFRSR C1 AOD');
title(['AOD at 415 nm, Cimel vs MFRSR C1']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)

bias = mean(mfrE13_filtered.vars.aerosol_optical_depth_filter1.data(mfrE13_filtered.nearCimel)-cimel.aod_415(cimel.nearE13)');
[P,S] = polyfit(cimel.aod_415(cimel.nearE13)', mfrE13_filtered.vars.aerosol_optical_depth_filter1.data(mfrE13_filtered.nearCimel),1);
stats = fit_stat(cimel.aod_415(cimel.nearE13)',mfrE13_filtered.vars.aerosol_optical_depth_filter1.data(mfrE13_filtered.nearCimel),P,S);
figure; plot(cimel.aod_415(cimel.nearE13)',mfrE13_filtered.vars.aerosol_optical_depth_filter1.data(mfrE13_filtered.nearCimel), '.',[[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter1.data(mfrE13_filtered.nearCimel))]],polyval(P,[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter1.data(mfrE13_filtered.nearCimel))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('Cimel AOD');
ylabel('MFRSR E13 AOD');
title(['AOD at 415 nm, Cimel vs MFRSR E13']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearCimel)-cimel.aod_670(cimel.nearC1)');

[P,S] = polyfit(cimel.aod_670(cimel.nearC1)', mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearCimel),1);
stats = fit_stat(cimel.aod_670(cimel.nearC1)',mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearCimel),P,S);
figure; plot(cimel.aod_670(cimel.nearC1)',mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearCimel), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearCimel))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter4.data(mfrC1_filtered.nearCimel))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('Cimel AOD');
ylabel('MFRSR C1 AOD');
title(['AOD at 670 nm, Cimel vs MFRSR C1']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%

bias = mean(mfrE13_filtered.vars.aerosol_optical_depth_filter4.data(mfrE13_filtered.nearCimel)-cimel.aod_670(cimel.nearE13)');
[P,S] = polyfit(cimel.aod_670(cimel.nearE13)', mfrE13_filtered.vars.aerosol_optical_depth_filter4.data(mfrE13_filtered.nearCimel),1);
stats = fit_stat(cimel.aod_670(cimel.nearE13)',mfrE13_filtered.vars.aerosol_optical_depth_filter4.data(mfrE13_filtered.nearCimel),P,S);
figure; plot(cimel.aod_670(cimel.nearE13)',mfrE13_filtered.vars.aerosol_optical_depth_filter4.data(mfrE13_filtered.nearCimel), '.',[[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter4.data(mfrE13_filtered.nearCimel))]],polyval(P,[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter4.data(mfrE13_filtered.nearCimel))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('Cimel AOD');
ylabel('MFRSR E13 AOD');
title(['AOD at 670 nm, Cimel vs MFRSR E13']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
rss = read_rss_v3;
%%
[rss.nearCimel, cimel.nearRss] = nearest(rss.time', cimel.time');
[rss.nearC1, mfrC1_filtered.nearRss] = nearest(rss.time', mfrC1_filtered.time,5/(24*60*60));
[rss.nearE13, mfrE13_filtered.nearRss] = nearest(rss.time', mfrE13_filtered.time,5/(24*60*60));

%%
bias = mean(rss.aod_870(rss.nearCimel)' -cimel.aod_870(cimel.nearRss)');
[P,S] = polyfit(cimel.aod_870(cimel.nearRss)', rss.aod_870(rss.nearCimel)',1);
stats = fit_stat(cimel.aod_870(cimel.nearRss)',rss.aod_870(rss.nearCimel)',P,S);
figure; plot(cimel.aod_870(cimel.nearRss)',rss.aod_870(rss.nearCimel)', '.',[0,max(rss.aod_870(rss.nearCimel))],polyval(P,[0,max(rss.aod_870(rss.nearCimel))]),'r');
axis('square');

xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('Cimel AOD');
ylabel('RSS AOD');
title(['AOD at 870 nm, Cimel vs RSS']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
bias = mean(rss.aod_500(rss.nearCimel)' -cimel.aod_500(cimel.nearRss)');
[P,S] = polyfit(cimel.aod_500(cimel.nearRss)', rss.aod_500(rss.nearCimel)',1);
stats = fit_stat(cimel.aod_500(cimel.nearRss)',rss.aod_500(rss.nearCimel)',P,S);
figure; plot(cimel.aod_500(cimel.nearRss)',rss.aod_500(rss.nearCimel)', '.',[0,max(rss.aod_500(rss.nearCimel))],polyval(P,[0,max(rss.aod_500(rss.nearCimel))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('Cimel AOD');
ylabel('RSS AOD');
title(['AOD at 500 nm, Cimel vs RSS']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
bias = mean(rss.aod_870(rss.nearC1)' - mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearRss));
[P,S] = polyfit(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearRss), rss.aod_870(rss.nearC1)',1);
stats = fit_stat(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearRss),rss.aod_870(rss.nearC1)',P,S);
figure; plot(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearRss),rss.aod_870(rss.nearC1)', '.',[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearRss))],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearRss))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('MFRSR C1 AOD');
ylabel('RSS AOD');
title(['AOD at 870 nm, MFRSR C1 vs RSS']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
bias = mean(rss.aod_500(rss.nearC1)' - mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearRss));
[P,S] = polyfit(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearRss), rss.aod_500(rss.nearC1)',1);
stats = fit_stat(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearRss),rss.aod_500(rss.nearC1)',P,S);
figure; plot(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearRss),rss.aod_500(rss.nearC1)', '.',[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearRss))],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearRss))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('MFRSR C1 AOD');
ylabel('RSS AOD');
title(['AOD at 500 nm, MFRSR C1 vs RSS']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
bias = mean(rss.aod_870(rss.nearE13)' - mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearRss));
[P,S] = polyfit(mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearRss), rss.aod_870(rss.nearE13)',1);
stats = fit_stat(mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearRss),rss.aod_870(rss.nearE13)',P,S);
figure; plot(mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearRss),rss.aod_870(rss.nearE13)', '.',[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearRss))],polyval(P,[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter5.data(mfrE13_filtered.nearRss))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('MFRSR E13 AOD');
ylabel('RSS AOD');
title(['AOD at 870 nm, MFRSR E13 vs RSS']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
bias = mean(rss.aod_500(rss.nearE13)' - mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearRss));
[P,S] = polyfit(mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearRss), rss.aod_500(rss.nearE13)',1);
stats = fit_stat(mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearRss),rss.aod_500(rss.nearE13)',P,S);
figure; plot(mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearRss),rss.aod_500(rss.nearE13)', '.',[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearRss))],polyval(P,[0,max(mfrE13_filtered.vars.aerosol_optical_depth_filter2.data(mfrE13_filtered.nearRss))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('MFRSR E13 AOD');
ylabel('RSS AOD');
title(['AOD at 500 nm, MFRSR E13 vs RSS']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
%Output text data files of cloud-screened MFRSR C1, E13 files.  
%% 
basename = 'C:\case_studies\Alive\data\flynn-xmfrx-od\';
date_dir = datestr(now,'yyyy_mm_dd');
if ~exist([basename,date_dir],'dir')
    mkdir(basename, date_dir)
end
pname = [basename,date_dir,filesep];
fname = 'sgpmfrsrC1.filtered_aod.alive.txt';

V = datevec(mfrC1_filtered.time);
    yyyy = V(:,1);
    mm = V(:,2);
    dd = V(:,3);
    HH = V(:,4);
    MM = V(:,5);
    SS = V(:,6);
    doy = serial2doy(mfrC1_filtered.time)';
    HHhh = (doy - floor(doy)) *24;

    txt_out = [yyyy, doy, HHhh, mm, dd, HH, MM, SS,...
        mfrC1_filtered.vars.aerosol_optical_depth_filter1.data',...
        mfrC1_filtered.vars.aerosol_optical_depth_filter2.data',...
        mfrC1_filtered.vars.aerosol_optical_depth_filter3.data',...
        mfrC1_filtered.vars.aerosol_optical_depth_filter4.data',...
        mfrC1_filtered.vars.aerosol_optical_depth_filter5.data',...
        mfrC1_filtered.vars.angstrom_exponent.data'];

        fid = fopen([pname, fname],'wt');
        fprintf(fid, '%s \n','yyyy, doy, HHhh, mm, dd, HH, MM, SS, aod_415, aod_500,aod_615,aod_673,aod_870,ang_500_870');
        fprintf(fid,'%d, %3.7f, %3.5f, %d, %d, %d, %d, %.f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f \n',txt_out');
        fclose(fid);
%% 
basename = 'C:\case_studies\Alive\data\flynn-xmfrx-od\';
date_dir = datestr(now,'yyyy_mm_dd');
if ~exist([basename,date_dir],'dir')
    mkdir(basename, date_dir)
end
pname = [basename,date_dir,filesep];
fname = 'sgpmfrsrE13.filtered_aod.alive.txt';

V = datevec(mfrE13_filtered.time);
    yyyy = V(:,1);
    mm = V(:,2);
    dd = V(:,3);
    HH = V(:,4);
    MM = V(:,5);
    SS = V(:,6);
    doy = serial2doy(mfrE13_filtered.time)';
    HHhh = (doy - floor(doy)) *24;

    txt_out = [yyyy, doy, HHhh, mm, dd, HH, MM, SS,...
        mfrE13_filtered.vars.aerosol_optical_depth_filter1.data',...
        mfrE13_filtered.vars.aerosol_optical_depth_filter2.data',...
        mfrE13_filtered.vars.aerosol_optical_depth_filter3.data',...
        mfrE13_filtered.vars.aerosol_optical_depth_filter4.data',...
        mfrE13_filtered.vars.aerosol_optical_depth_filter5.data',...
        mfrE13_filtered.vars.angstrom_exponent.data'];

        fid = fopen([pname, fname],'wt');
        fprintf(fid, '%s \n','yyyy, doy, HHhh, mm, dd, HH, MM, SS, aod_415, aod_500,aod_615,aod_673,aod_870,ang_500_870');
        fprintf(fid,'%d, %3.7f, %3.5f, %d, %d, %d, %d, %.f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f, %3.3f \n',txt_out');
        fclose(fid);
%%
all_aats = get_aats_aod;
%%

[mfrC1_filtered.nearAats, all_aats.nearC1] = nearest(mfrC1_filtered.time,all_aats.time);
%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats)-all_aats.col_aod(4,all_aats.nearC1));

[P,S] = polyfit(all_aats.col_aod(4,all_aats.nearC1), mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),1);
stats = fit_stat(all_aats.col_aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),P,S);
stats.x_bar = mean(all_aats.col_aod(4,all_aats.nearC1));
figure; plot(all_aats.col_aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),...
   '.',[[0,.4]],polyval(P,[0,.4]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('AATS COL AOD 500nm', 'fontsize',12);
ylabel('MFRSR C1 AOD', 'fontsize',12);
title(['AOD at 500 nm, AATS vs MFRSR C1'], 'fontsize',12);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['mean x = ',sprintf('%1.3f',stats.x_bar)],...    
    ['mean y = ',sprintf('%1.3f',stats.y_bar)]};
    % , ['RMSE = ',sprintf('%1.3f',stats.RMSE)]
set(gca,'fontsize',12);
axis([0,.3,0,.3])
gt = gtext(txt);
set(gt,'fontsize',13)

%%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats)-all_aats.aod(4,all_aats.nearC1));

[P,S] = polyfit(all_aats.aod(4,all_aats.nearC1), mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),1);
stats = fit_stat(all_aats.aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),P,S);
figure; 
plot(all_aats.aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats))]),'r');
plot(all_aats.aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats), '.',[[0,.4]],polyval(P,[0,.4]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('AATS AOD 500nm');
ylabel('MFRSR C1 AOD');
title(['AOD at 500 nm, AATS vs MFRSR C1']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
 txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['mean x = ',sprintf('%1.3f',stats.x_bar)],...    
    ['mean y = ',sprintf('%1.3f',stats.y_bar)]};
gt = gtext(txt);
set(gt,'fontsize',14)
axis([0,.301,0,.301]);
%%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats)-all_aats.col_aod(9,all_aats.nearC1));

[P,S] = polyfit(all_aats.col_aod(9,all_aats.nearC1), mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats),1);
stats = fit_stat(all_aats.col_aod(9,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats),P,S);
figure; plot(all_aats.col_aod(9,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('AATS COL AOD 870nm');
ylabel('MFRSR C1 AOD');
title(['AOD at 870 nm, AATS vs MFRSR C1']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats)-all_aats.aod(9,all_aats.nearC1));

[P,S] = polyfit(all_aats.aod(9,all_aats.nearC1), mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats),1);
stats = fit_stat(all_aats.aod(9,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats),P,S);
figure; plot(all_aats.aod(9,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter5.data(mfrC1_filtered.nearAats))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('AATS AOD 870nm');
ylabel('MFRSR C1 AOD');
title(['AOD at 870 nm, AATS vs MFRSR C1']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%
%%
rl_path = 'C:\case_studies\Alive\data\ferrare-carl\Feb2007\';
clear rl
for d = datenum('2005-09-06','yyyy-mm-dd'):datenum('2005-09-29','yyyy-mm-dd')
    datestr(d)
    ext_in = dir([rl_path,'sgp10rlprofext1ferrC1.c1.',datestr(d,'yyyymmdd'),'.*.cdf']);
    rl_ext = ancload_coords([rl_path,ext_in(1).name]);
    be_in =  dir([rl_path,'sgp10rlprofbe1turnC1.c0.',datestr(d,'yyyymmdd'),'.*.cdf']);
    rl_be = ancload_coords([rl_path,be_in(1).name]);
    rl_ext.vars.aod_1.data =  ancgetdata(rl_ext, 'aod_1');
    rl_ext.vars.aod_bscat.data =  ancgetdata(rl_ext, 'aod_bscat');
    rl_ext.vars.aod_married1.data =  ancgetdata(rl_ext, 'aod_married1');
    rl_be.vars.aod.data = ancgetdata(rl_be,'aod');
    if ~exist('rl','var')
        [rl_out, fname,ext] = fileparts(rl_ext.fname);
        rl.fname = fullfile(rl_out,['alive_rl_aod',ext]);
        rl.atts = rl_ext.atts;
        rl.recdim = rl_ext.recdim;
        rl.dims.time = rl_ext.dims.time;
        rl.vars.aod_1 = rl_ext.vars.aod_1;
        rl.vars.aod_bscat = rl_ext.vars.aod_bscat;
        rl.vars.aod_married1 = rl_ext.vars.aod_married1;
        rl.vars.aod_be = rl_be.vars.aod;
        rl.time = rl_ext.time;
    else
        [rl.time,ind] = unique([rl.time,rl_ext.time]);
        rl.recdim.length = length(rl.time);
        rl.dims.time.length = length(rl.time);
        rl.vars.aod_1.data = [rl.vars.aod_1.data rl_ext.vars.aod_1.data];
        rl.vars.aod_1.data =rl.vars.aod_1.data(ind);
        rl.vars.aod_bscat.data = [rl.vars.aod_bscat.data rl_ext.vars.aod_bscat.data];
        rl.vars.aod_bscat.data =rl.vars.aod_bscat.data(ind);
        rl.vars.aod_married1.data = [rl.vars.aod_married1.data rl_ext.vars.aod_married1.data];
        rl.vars.aod_married1.data = rl.vars.aod_married1.data(ind);
        rl.vars.aod_be.data = [rl.vars.aod_be.data rl_be.vars.aod.data];
        rl.vars.aod_be.data = rl.vars.aod_be.data(ind);
    end
end
clear rl_ext rl_be 
%%
good = find((rl.vars.aod_1.data>0)&(rl.vars.aod_bscat.data>0)&(rl.vars.aod_married1.data>0)&(rl.vars.aod_be.data>0));
[rl.nearC1,mfrC1_filtered.nearRl] = nearest(rl.time(good),mfrC1_filtered.time);
figure; 
% subplot(2,1,1); 
% plot(serial2doy(rl.time(good)), ...
%     [rl.vars.aod_bscat.data(good);rl.vars.aod_1.data(good);rl.vars.aod_married1.data(good)],'.',...
%     serial2doy(rl.time(good)), rl.vars.aod_be.data(good),'bo');
% subplot(2,1,2);
plot(serial2doy(rl.time(good(rl.nearC1))), [rl.vars.aod_bscat.data(good(rl.nearC1));...
    rl.vars.aod_1.data(good(rl.nearC1));...
    rl.vars.aod_married1.data(good(rl.nearC1))],'.',...
    serial2doy(rl.time(good(rl.nearC1))), rl.vars.aod_be.data(good(rl.nearC1)),'bo');
legend('aod\_bscat','aod\_1','aod\_married','aod\_be')
%%


%%
    V = datevec(rl.time(good));
    yyyy = V(:,1);
    mm = V(:,2);
    dd = V(:,3);
    HH = V(:,4);
    MM = V(:,5);
    SS = V(:,6);
    doy = serial2doy(rl.time(good))';
    HHhh = (doy - floor(doy)) *24;
%%
    txt_out = [yyyy, doy, HHhh, mm, dd, HH, MM, SS, rl.vars.aod_1.data(good)', rl.vars.aod_bscat.data(good)',rl.vars.aod_bscat.data(good)'- rl.vars.aod_1.data(good)' ]; 
        fid = fopen([rl_path,'../', 'alive_rl_aod_v2.csv'],'wt');
        fprintf(fid, '%s \n','yyyy, doy, HHhh, mm, dd, HH, MM, SS, aod_1, aod_bscat, (aod_bscat-aod_1)');
        fprintf(fid,'%d, %2.10g, %d, %d, %d, %d, %d, %d, %3.6f, %3.6f, %3.6f \n',txt_out');
        fclose(fid);
    close('all');   