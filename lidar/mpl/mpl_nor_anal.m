function mpl_nor_anal
%MPL NOR Dead time correction analysis.
warning('off','MATLAB:dispatcher:InexactMatch')
pname = 'C:\matlab_sandbox\mlib\lidar\mpl\';
fname = 'all SPCM det deadtime AQR FC AQ_CS_v3.xls';

% [fid,fname,pname]= getfile('*.xls','excel');

% fclose(fid);
%% Read Excel spreadsheet and Plot the values.
a =xlsread([pname fname]);
% plot([a(5:52,1)],[a(5:52,2)],
% [a(5:52,3)],[a(5:52,4)],[a(5:52,5)],[a(5:52,6)], [a(5:52,7)],[a(5:52,8)],[a(5:52,9)],[a(5:52,10)], [a(5:52,11)],[a(5:52,12)],[a(5:52,13)],[a(5:52,14)], [a(5:52,15)],[a(5:52,16)],[a(5:52,17)],[a(5:52,18)], [a(5:52,19)],[a(5:52,20)],[a(5:52,21)],[a(5:52,22)], [a(5:52,23)],[a(5:52,24)],[a(5:52,25)],[a(5:52,26)], [a(5:52,27)],[a(5:52,28)],[a(5:52,29)],[a(5:52,30)], [a(5:52,31)],[a(5:52,32)],[a(5:52,33)],[a(5:52,34)], [a(5:52,35)],[a(5:52,36)],[a(5:52,37)],[a(5:52,38)], [a(5:52,39)],[a(5:52,40)],[a(5:52,41)],[a(5:52,42)], [a(5:52,43)],[a(5:52,44)],[a(5:52,45)],[a(5:52,46)],a(5:52,47), a(5:52,48),a(5:52,49), a(5:52,50),a(5:52,51), a(5:52,52),a(5:52,53), a(5:52,54),a(5:52,55), a(5:52,56),a(5:52,57), a(5:52,58),a(5:52,59), a(5:52,60),a(5:52,61), a(5:52,62),a(5:52,63), a(5:52,64),a(5:52,65), a(5:52,66),a(5:52,67), a(5:52,68),a(5:52,69), a(5:52,70),a(5:52,71), a(5:52,72),a(5:52,73), a(5:52,74),a(5:52,75), a(5:52,76),a(5:52,77), a(5:52,78),a(5:52,79), a(5:52,80),a(5:52,81), a(5:52,82),a(5:52,83), a(5:52,84) ,a(5:52,85), a(5:52,86)); %, a(5:52,87), a(5:52,88),a(5:52,89), a(5:52,90); % a(5:52,47), a(5:52,48)a(5:52,47), a(5:52,48)a(5:52,47), a(5:52,48)a(5:52,47), a(5:52,48)a(5:52,47), a(5:52,48)a(5:52,47), a(5:52,48));
% title('MPLNOR Dead-time Corrections')
% xlabel('D (kHz)')
% ylabel('DT Corr')
%%
% Compile all the values less than 10000 into a single row.
n=1;
for row=1:2:86,
   for col=5:26,
      if (a(col,row)<=10000)
         one_col(n,1)=(a(col,row));
         one_col(n,2)=(a(col,row+1));
         n= n+1;
      end;
   end;
end;
%% sort based on the first row
close all;
sort_col = sortrows(one_col,1);
%Plot the sorted columns
%plot(sort_col(:,1),sort_col(:,2));
%xlabel('D (kHz) Sorted');
%ylabel('DT Corr');
%Find the log10 of the sorted values.
log_R = log10(sort_col(:,1));
%Find the maximum difference between values and multiply by 2.5
min_step = 2.5* max(diff(log_R));
log_R_spaced = [min(log_R):min_step:max(log_R)];
%Now walk through the spaced array and find the mean of the values
%between the ranges for dtc.
for s = (length(log_R_spaced)-1):-1:1
   subR = (log_R>=log_R_spaced(s))&(log_R<=log_R_spaced(s+1));
   mean_logR(s) = (log_R_spaced(s)+log_R_spaced(s+1))/2;
   tmp = mean_logR(s);
   mean_dtc(s) = mean(sort_col(subR,2));
end
 figure(1); plot(log10(sort_col(:,1)), sort_col(:,2),'b.',mean_logR,mean_dtc,'r-o');
 xlabel('Mean D (kHz)');
 ylabel('Mean DT Corr');
 title('Dead time corrections (Vendor) ');
dtc = logR_dtc(mean_logR);
 figure(2); plot(mean_logR,mean_dtc,'b.',mean_logR,dtc,'r.');
 xlabel('Mean D (kHz)');
 ylabel('Mean DT Corr');
 title('Deadtime corrections (Generic)');
fit_dtc = logR_dtc(log10(sort_col(:,1)));
fit_dtc = logR_dtc(log_R);
 figure;
 plot(log10(sort_col(:,1)), sort_col(:,2),'b.',...
    log10(sort_col(:,1)),fit_dtc,'g.');
 xlabel('D (kHz)');
 ylabel('DT Corr');
 title('Deadtime Corrections (Vendor and Generic)');
 
%%
 %Plot Histogram of Vendor specific corrections and Generic corrections.
 x = 1:.5:3;
[n, xout] = hist(sort_col(:,2),x);
n_per = (n(:)/sum(n)) * 100;
figure;
bar(xout, n_per);
title('Vendor Dtc');
ylabel('Percentage');
xlabel('Vendor Dtc');
[n_gen, xout_gen] = hist(fit_dtc,x);
n_per_gen = (n_gen(:)/sum(n_gen)) * 100
figure;
bar(xout_gen, n_per_gen);
title('Generic Dtc');
ylabel('Percentage');
xlabel('Generic Dtc');
mat_dtc = zeros(numel(fit_dtc),2);
mat_dtc = sort_col(:,2);
mat_dtc(:,2) = fit_dtc;
x = 1:.5:3;
[n,xout]= hist(mat_dtc, x);
n_per_1 = n(:,1)/sum(n(:,1)) * 100;
n_per_2 = n(:,2)/sum(n(:,2)) * 100;
n(:,1) = n_per_1;
n(:,2) = n_per_2;

figure;
bar(xout,n);
ylabel('Percentage');
xlabel('Dtc Vendor/Generic');
title('Vendor vs Generic Dtc');

 
%% Now compute some statistics... such as bias (difference), absolute bias,
%% standard deviation of original values within a log_R_spaced steps,
%% standard deviation of bias values
%% and relative deviations (divide by the mean_dtc)

bias = fit_dtc - sort_col(:,2);
abs_bias = abs(bias);
for y = (length(log_R_spaced)-1):-1:1
   arr_spc = (log_R>=log_R_spaced(y))&(log_R<=log_R_spaced(y+1));

   std_dev_dtc(y)= std(sort_col(arr_spc,2));
   mean_bias(y)= mean(bias(arr_spc));
   std_dev_bias(y)= std(bias(arr_spc));
   rel_dev_bias(y)= std_dev_bias(y)/mean_dtc(y);
%    ax(1) = subplot(3,1,1);
%    plot(log10(sort_col(:,1)), sort_col(:,2),'b.', ...
%       log10(sort_col(arr_spc,1)), sort_col(arr_spc,2),'r.', ...
%       log10(sort_col(:,1)), fit_dtc,'k', ...
%       mean_logR(y), mean_dtc(y), 'ko','MarkerFaceColor','k');
%    ylabel('dtc')
%    ax(2) = subplot(3,1,2);
%    plot(log10(sort_col(:,1)), bias,'b.',...
%       log10(sort_col(arr_spc,1)), bias(arr_spc),'r.', ...
%       mean_logR(y), mean_bias(y), 'ko','MarkerFaceColor','k');
%    ylabel('bias')
%    ax(2) = subplot(3,1,3);
%    plot(log10(sort_col(arr_spc,1)), bias(arr_spc),'r.', ...
%       mean_logR(y), mean_bias(y), 'ko','MarkerFaceColor','k');
%    ylabel('bias')
%    linkaxes(ax,'x')
end
figure;
   ax(1) = subplot(2,1,1);
   semilogx((sort_col(:,1)), sort_col(:,2),'b.', ...
      (sort_col(:,1)), fit_dtc,'b', ...
      10.^mean_logR, mean_dtc, 'ko','MarkerFaceColor','k');
   ylabel('dtc')
   ax(2) = subplot(2,1,2);
   semilogx((sort_col(:,1)), bias,'b.',...
      10.^mean_logR, mean_bias, 'ko-','MarkerFaceColor','k');
   ylabel('bias')
   xlabel('R(kHz)')
   linkaxes(ax,'x')
figure;
   ax(1) = subplot(2,1,1);
   semilogx( 10.^mean_logR, std_dev_dtc, 'ko','MarkerFaceColor','k');
   ylabel('std\_dtc')
   ax(2) = subplot(2,1,2);
   semilogx(10.^mean_logR, rel_dev_bias, 'ko-','MarkerFaceColor','k');
   ylabel('rel\_std\_bias')
      xlabel('R(kHz)')

   linkaxes(ax,'x')
 figure;
plot(log10(sort_col(:,1)), sort_col(:,2),'b.',...
   log10(sort_col(:,1)),bias,'g.', ...
   log10(sort_col(:,1)), abs_bias, 'black');
xlabel('R(kHz)');
ylabel('dtc, bias, abs\_bias');

%Plot Histograms of relative difference, abs differences, absolute
%deviations, relative deviations.
%Absolute Difference
[n, xout] = hist(abs_bias);
n_per = (n(:)/sum(n)) * 100
figure;
bar(xout, n_per);
title('Absolute Bias between Generic and Vendor Dtc');
ylabel('Percentage');
xlabel('Absolute Bias of Dtc');
%Standard Deviation
[n, xout] = hist(std_dev_dtc);
n_per = (n(:)/sum(n)) * 100
figure;
bar(xout, n_per);
title('Standard Deviation between Generic and Vendor Dtc');
ylabel('Percentage');
xlabel('Standard Deviation of Dtc');
%Relative Deviation Diff
[n, xout] = hist(rel_dev_bias);
n_per = (n(:)/sum(n)) * 100
figure;
bar(xout, n_per);
title('Relative Deviation between Generic and Vendor Dtc ');
ylabel('Percentage');
xlabel('Relative Bias of Dtc');

