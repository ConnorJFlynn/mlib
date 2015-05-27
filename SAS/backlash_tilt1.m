clear
backtilt = loadit(['C:\case_studies\ARRA\SAS\data_tests\rotary_stage\Rotary Stage Calibration\backlashTilt_2.txt']);
% backtilt = loadit(['C:\case_studies\ARRA\SAS\data_tests\rotary_stage\Rotary Stage Calibration\backlashTilt2_faster.txt']);
figure; plot([1:length(backtilt.step)], backtilt.X_space_degree, '.', [1:length(backtilt.step)], backtilt.Y_space_degree, '.');
legend('X','Y');



%%
Xflipd = flipud(backtilt.X_space_degree);
Yflipd = flipud(backtilt.Y_space_degree);
sflipd = flipud(backtilt.step);

[xR, lags] = xcorr (backtilt.X_space_degree(1:143), Xflipd(1:143));
[yR, lags] = xcorr (backtilt.Y_space_degree(1:143), Yflipd(1:143));
figure; plot(lags, [xR,yR],'-');
legend('X','Y');
%%
m = menu('zoom in to select a peak to fit over then select OK','OK')
xl = xlim;
xsub = (lags>xl(1)&lags<xl(2));
%%
[Px,Sx] = polyfit(lags(xsub), xR(xsub)',2);
Px_prime = [2.*Px(1), Px(2)];
Px_root = roots(Px_prime);
360.*sflipd(2).*Px_root./(256*200*66)
%%
[Py,Sy] = polyfit(lags(xsub), yR(xsub)',2);
Py_prime = [2.*Py(1), Py(2)];
Py_root = roots(Py_prime);
360.*sflipd(2).*Py_root./(256*200*66)



%%
lash = 0;
stepfwd = backtilt.step(1:143);
Xfwd = backtilt.X_space_degree(1:143);
xstep = backtilt.step(1:143);
Yfwd = backtilt.Y_space_degree(1:143);
Xbck = Xflipd(1:143);
Ybck = Yflipd(1:143);
stepbck = sflipd(1:143);
%%
i = 0;
clear lash_diff
for lash = 0:1:500
i = i+1;
backstep = stepbck + lash;
Xint = interp1(backstep,Xbck,stepfwd,'linear','extrap');
lash_xdiff(:,i) =Xfwd-Xint;
Yint = interp1(backstep,Ybck,stepfwd,'linear','extrap');
lash_ydiff(:,i) =Yfwd-Yint;
end

sum_xdiff = mean(abs(lash_xdiff),1);
sum_ydiff = mean(abs(lash_ydiff),1);
figure; ax(1) = subplot(2,1,1);
plot([0:1:500],sum_xdiff,'-o');
ax(2) = subplot(2,1,2);
plot([0:1:500],sum_ydiff,'-x' );
linkaxes(ax,'x')
xlabel('lash')
ylabel('sum diff')

%
% The minima is between -400 and -375 microsteps, so ~2.65 deg for stepper
% or 0.04 deg for rotary stage.  This will increase over time as the gear
% wears in.  

%%
% 
figure; plot([1:length(backtilt.step)], backtilt.X_space_degree, '.', [1:length(backtilt.step)], backtilt.Y_space_degree, '.');
legend('X','Y')
%%
plots_ppt
figure; ax(1)= subplot(2,1,1); 
plot([1:length(backtilt.step)], backtilt.step,'.-');
title('backlash tilt test #1');
ylabel('steps')
xlabel('record number')

ax(2) = subplot(2,1,2);
plot([1:length(backtilt.step)], backtilt.X_space_degree, '.-', [1:length(backtilt.step)], backtilt.Y_space_degree, '.-');
legend('X','Y');
ylabel('degrees')
xlabel('record number')

linkaxes(ax,'x'); zoom('on')

%%
plots_default
figure; plot(backtilt.step, backtilt.X_space_degree, '.-', backtilt.step, backtilt.Y_space_degree, '.-');
legend('X','Y')