mfrsrC1 = ancload;
mfrsrE13 = ancload;
nimfr = ancload;
%%

goodC1 = find(mfrsrC1.vars.variability_flag.data<1e-4);
goodE13 = find(mfrsrE13.vars.variability_flag.data<1e-4);
goodnim = find(nimfr.vars.variability_flag.data<1e-4);

%%
%Comparing MFRSR C1 to MFRSR E13
n =0;
[C1toE13.i,E13toC1.i] = nearest(mfrsrC1.time(goodC1), mfrsrE13.time(goodE13));
%%
n =n+1;
f = ['filter',num2str(n)];
C1toE13.(f).bias = mean(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1toE13.i)) - ...
   mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13toC1.i)));
C1toE13.(f).absbias = mean(abs(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1toE13.i)) - ...
   mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13toC1.i))));
C1toE13.(f).std = std(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1toE13.i)) - ...
   mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13toC1.i)));

[C1toE13.(f).P,C1toE13.(f).S] = polyfit(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1toE13.i)), ...
   mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13toC1.i)),1);
this = C1toE13.(f);
%
figure(1); plot(serial2doy(mfrsrC1.time(goodC1(C1toE13.i))), mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1toE13.i)), 'c.',...
   serial2doy(mfrsrE13.time(goodE13(E13toC1.i))), mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13toC1.i)), 'b.');
title(['AOD ',f,' comparison: MFRSR C1 to MFRSR E13']);
legend('MFRSR C1','MFRSR E13');
xlabel('time (day of year)')
ylabel('aod')

figure(2); plot(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1toE13.i)),...
   mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13toC1.i)), 'k.');
xl = xlim;
plot(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1toE13.i)),...
   mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13toC1.i)), 'k.',xl, polyval(C1toE13.(f).P,xl),'k',xl,xl,'r--');
xlabel('MFRSR C1 aod');
ylabel('MFRSR E13 aod');
title(['AOD ',f,' comparison: MFRSR C1 to MFRSR E13']);
text(1.1*xl(1),0.9*xl(2),{['slope = ' sprintf('%1.4f',this.P(1))],['mean bias = ' sprintf('%1.4f', this.bias)],...
['stdev = ' sprintf('%1.4f',this.std)]})

%%
%Comparing MFRSR C1 to NIMFR
n =0;
[C1tonim.i,nimtoC1.i] = nearest(mfrsrC1.time(goodC1), nimfr.time(goodnim));
%%
n =n+1;
f = ['filter',num2str(n)];
C1tonim.(f).bias = mean(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1tonim.i)) - ...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoC1.i)));
C1tonim.(f).absbias = mean(abs(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1tonim.i)) - ...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoC1.i))));
C1tonim.(f).std = std(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1tonim.i)) - ...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoC1.i)));

[C1tonim.(f).P,C1tonim.(f).S] = polyfit(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1tonim.i)), ...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoC1.i)),1);
this = C1tonim.(f);
%
figure(1); subplot(2,1,1);
plot(serial2doy(mfrsrC1.time(goodC1(C1tonim.i))), mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1tonim.i)), 'c.',...
   serial2doy(nimfr.time(goodnim(nimtoC1.i))), nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoC1.i)), 'b.');
title(['AOD ',f,' comparison: MFRSR C1 to NIMFR']);
legend('MFRSR C1','MFRSR nim');
xlabel('time (day of year)')
ylabel('aod')

dtau = (mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1tonim.i)) - ...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoC1.i)));
airmass = mfrsrC1.vars.airmass.data(goodC1(C1tonim.i));
subplot(2,1,2); plot(serial2doy(mfrsrC1.time(goodC1(C1tonim.i))),exp(dtau.*airmass),'.');
xlabel('time (day of year)')
ylabel('exp(dtau*am)')

figure(2); plot(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1tonim.i)),...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoC1.i)), 'k.');
xl = xlim;
plot(mfrsrC1.vars.(['aerosol_optical_depth_',f]).data(goodC1(C1tonim.i)),...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoC1.i)), 'k.',xl, polyval(C1tonim.(f).P,xl),'k',xl,xl,'r--');
xlabel('MFRSR C1 aod');
ylabel('MFRSR nim aod');
title(['AOD ',f,' comparison: MFRSR C1 to NIMFR']);
text(1.1*xl(1),0.9*xl(2),{['slope = ' sprintf('%1.4f',this.P(1))],['mean bias = ' sprintf('%1.4f', this.bias)],...
['stdev = ' sprintf('%1.4f',this.std)]})

%%
%%
%Comparing MFRSR E13 to NIMFR
n =0;
[E13tonim.i,nimtoE13.i] = nearest(mfrsrE13.time(goodE13), nimfr.time(goodnim));
%%
n =n+1;
f = ['filter',num2str(n)];
E13tonim.(f).bias = mean(mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13tonim.i)) - ...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoE13.i)));
E13tonim.(f).absbias = mean(abs(mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13tonim.i)) - ...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoE13.i))));
E13tonim.(f).std = std(mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13tonim.i)) - ...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoE13.i)));

[E13tonim.(f).P,E13tonim.(f).S] = polyfit(mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13tonim.i)), ...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoE13.i)),1);
this = E13tonim.(f);
%
figure(1); subplot(2,1,1); plot(serial2doy(mfrsrE13.time(goodE13(E13tonim.i))), mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13tonim.i)), 'c.',...
   serial2doy(nimfr.time(goodnim(nimtoE13.i))), nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoE13.i)), 'b.');
title(['AOD ',f,' comparison: MFRSR E13 to NIMFR']);
legend('MFRSR E13','MFRSR nim');
xlabel('time (day of year)')
ylabel('aod')
dtau = (mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13tonim.i)) - ...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoE13.i)));
airmass = mfrsrE13.vars.airmass.data(goodE13(E13tonim.i));
subplot(2,1,2); plot(serial2doy(mfrsrE13.time(goodE13(E13tonim.i))),exp(dtau.*airmass),'.');
xlabel('time (day of year)')
ylabel('exp(dtau*am)')

figure(2); plot(mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13tonim.i)),...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoE13.i)), 'k.');
xl = xlim;
plot(mfrsrE13.vars.(['aerosol_optical_depth_',f]).data(goodE13(E13tonim.i)),...
   nimfr.vars.(['aerosol_optical_depth_',f]).data(goodnim(nimtoE13.i)), 'k.',xl, polyval(E13tonim.(f).P,xl),'k',xl,xl,'r--');
xlabel('MFRSR E13 aod');
ylabel('MFRSR nim aod');
title(['AOD ',f,' comparison: MFRSR E13 to NIMFR']);
text(1.1*xl(1),0.9*xl(2),{['slope = ' sprintf('%1.4f',this.P(1))],['mean bias = ' sprintf('%1.4f', this.bias)],...
['stdev = ' sprintf('%1.4f',this.std)]})

%%
