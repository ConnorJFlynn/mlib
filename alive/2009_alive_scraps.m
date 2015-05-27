
load('C:\matlib\alive_aod.mat')
%%
all_aats = get_aats_aod(mfrC1_filtered);

%%

[mfrC1_filtered.nearAats, all_aats.nearC1] = nearest(mfrC1_filtered.time,all_aats.time);
%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats)-all_aats.col_aod(4,all_aats.nearC1));

[P,S] = polyfit(all_aats.col_aod(4,all_aats.nearC1), mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),1);
stats = fit_stat(all_aats.col_aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),P,S);
figure; plot(all_aats.col_aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('AATS COL AOD 500nm');
ylabel('MFRSR C1 AOD');
title(['AOD at 500 nm, AATS vs MFRSR C1']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',stats.bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.3f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)


stats.x_bar = mean(all_aats.col_aod(4,all_aats.nearC1))


%%

[mfrC1_filtered.nearAats, all_aats.nearC1] = nearest(mfrC1_filtered.time,all_aats.time);
%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats)-all_aats.col_aod(4,all_aats.nearC1));

[P,S] = polyfit(all_aats.col_aod(4,all_aats.nearC1), mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),1);
stats = fit_stat(all_aats.col_aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),P,S);
stats.x_bar = mean(all_aats.col_aod(4,all_aats.nearC1));
figure; plot(all_aats.col_aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('AATS COL AOD 500nm');
ylabel('MFRSR C1 AOD');
title(['AOD at 500 nm, AATS vs MFRSR C1']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['mean(x) = ',sprintf('%1.3f',stats.x_bar)],...    
    ['mean(y) = ',sprintf('%1.3f',stats.y_bar)]};
    % , ['RMSE = ',sprintf('%1.3f',stats.RMSE)]
gt = gtext(txt);
set(gt,'fontsize',14)
%%

[mfrC1_filtered.nearAats, all_aats.nearC1] = nearest(mfrC1_filtered.time,all_aats.time);
%
bias = mean(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats)-all_aats.col_aod(4,all_aats.nearC1));

[P,S] = polyfit(all_aats.col_aod(4,all_aats.nearC1), mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),1);
stats = fit_stat(all_aats.col_aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats),P,S);
stats.x_bar = mean(all_aats.col_aod(4,all_aats.nearC1));
figure; plot(all_aats.col_aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats))]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim(xl);
xlabel('AATS COL AOD 500nm');
ylabel('MFRSR C1 AOD');
title(['AOD at 500 nm, AATS vs MFRSR C1']);
txt = {['N = ', num2str(stats.N)],...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['slope = ',sprintf('%1.3g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.3f',stats.R_sqrd)],...
    ['mean(x) = ',sprintf('%1.3f',stats.x_bar)],...    
    ['mean(y) = ',sprintf('%1.3f',stats.y_bar)]};
    % , ['RMSE = ',sprintf('%1.3f',stats.RMSE)]
gt = gtext(txt);
set(gt,'fontsize',13)
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
    ['mean(x) = ',sprintf('%1.3f',stats.x_bar)],...    
    ['mean(y) = ',sprintf('%1.3f',stats.y_bar)]};
    % , ['RMSE = ',sprintf('%1.3f',stats.RMSE)]
gt = gtext(txt);
set(gt,'fontsize',13)
set(gca,'fontsize',12)
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
    ['mean(x) = ',sprintf('%1.3f',stats.x_bar)],...    
    ['mean(y) = ',sprintf('%1.3f',stats.y_bar)]};
    % , ['RMSE = ',sprintf('%1.3f',stats.RMSE)]
gt = gtext(txt);
set(gt,'fontsize',13)
set(gca,'fontsize',12);
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
    ['mean(x) = ',sprintf('%1.3f',stats.x_bar)],...    
    ['mean(y) = ',sprintf('%1.3f',stats.y_bar)]};
    % , ['RMSE = ',sprintf('%1.3f',stats.RMSE)]
set(gca,'fontsize',12);
gt = gtext(txt);
set(gt,'fontsize',13)
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
gt = gtext(txt);
set(gt,'fontsize',13)
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
gt = gtext(txt);
set(gt,'fontsize',13)
axis([0,.3,0,.3])
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
exit
load('C:\matlib\alive_aod.mat')
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
figure; plot(all_aats.aod(4,all_aats.nearC1),mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats), '.',[[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats))]],polyval(P,[0,max(mfrC1_filtered.vars.aerosol_optical_depth_filter2.data(mfrC1_filtered.nearAats))]),'r');
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
axis([0,.3,0,.3]);
axis([0,.301,0,.301]);
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
exit
