% %%
% Examining impact of using Michalsky standard deviation criterion on resulting Io values in mfrsr aod VAP.
% Net result is that a more relaxed criteria of lsfitsd = 0.018 or 0.024 appears to not introduce biases 
% compared to the previous default lsfitsd=0.006, and improves smoothness by providing more Io values.

%%

new_dir = 'C:\case_studies\dust\new_ARM_mfrsrlangley\sgpmfrsraod1michC1.lsfitsd018.c1\';
%%
news = dir([new_dir, '*.cdf']);
%%
x = 0;
for f = 1:length(news);
   disp(f);
   mfr = ancload([new_dir, news(f).name]);
   if length(mfr.time)>1
   x = x + 1;
   new_Io.time(x) = mfr.time(1);
   new_Io.filter1(x) = mfr.vars.Io_filter1.data;
   new_Io.filter2(x) = mfr.vars.Io_filter2.data;
   new_Io.filter3(x) = mfr.vars.Io_filter3.data;
   new_Io.filter4(x) = mfr.vars.Io_filter4.data;
   new_Io.filter5(x) = mfr.vars.Io_filter5.data;
   end
end
%%
   
old_dir = 'C:\case_studies\dust\new_ARM_mfrsrlangley\sgpmfrsraod1michC1.c1\';
olds = dir([old_dir, '*.cdf']);
%%
x = 0;
for f = 1:length(olds);
   disp(f);
   mfr = ancload([old_dir, olds(f).name]);
   if length(mfr.time)>1
      x = x +1;
   old_Io.time(x) = mfr.time(1);
   old_Io.filter1(x) = mfr.vars.Io_filter1.data;
   old_Io.filter2(x) = mfr.vars.Io_filter2.data;
   old_Io.filter3(x) = mfr.vars.Io_filter3.data;
   old_Io.filter4(x) = mfr.vars.Io_filter4.data;
   old_Io.filter5(x) = mfr.vars.Io_filter5.data;
   end
   
end
%%

%%

new_Io.filter1_ = new_Io.filter1 / mean(new_Io.filter1);
new_Io.filter2_ = new_Io.filter2 / mean(new_Io.filter2);
new_Io.filter3_ = new_Io.filter3 / mean(new_Io.filter3);
new_Io.filter4_ = new_Io.filter4 / mean(new_Io.filter4);
new_Io.filter5_ = new_Io.filter5 / mean(new_Io.filter5);

figure; plot(serial2doy(new_Io.time), [new_Io.filter1_; new_Io.filter2_; new_Io.filter3_; ...
   new_Io.filter4_; new_Io.filter5_],'.');
legend('415','500','615','673','870');
title('New Io values, normalized to mean.')
xlabel('day of year')
v = axis;
%%

old_Io.filter1_ = old_Io.filter1 / mean(old_Io.filter1);
old_Io.filter2_ = old_Io.filter2 / mean(old_Io.filter2);
old_Io.filter3_ = old_Io.filter3 / mean(old_Io.filter3);
old_Io.filter4_ = old_Io.filter4 / mean(old_Io.filter4);
old_Io.filter5_ = old_Io.filter5 / mean(old_Io.filter5);

figure; plot(serial2doy(old_Io.time), [old_Io.filter1_; old_Io.filter2_; old_Io.filter3_; ...
   old_Io.filter4_; old_Io.filter5_],'.');
legend('415','500','615','673','870');
title('old Io values, normalized to mean.')
xlabel('day of year')
axis(v)
%%

figure; plot(serial2doy(new_Io.time), [new_Io.filter1; new_Io.filter2; new_Io.filter3; ...
   new_Io.filter4; new_Io.filter5],'-');
legend('415','500','615','673','870');
hold('on')
plot(serial2doy(old_Io.time), [old_Io.filter1; old_Io.filter2; old_Io.filter3; ...
   old_Io.filter4; old_Io.filter5],'.');
xlabel('day of year');
title('New data are lines, old are dots.')
xlim([v(1),v(2)])
