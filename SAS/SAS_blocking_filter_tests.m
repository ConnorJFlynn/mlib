function SAS_blocking_filter_tests

dark = mean(ins.spec(~ins.Shutter_open_TF, :),1);
% figure; plot(ins.lambda, dark,'-');
lights = ins.spec - ones(size(ins.time))*dark;
%
figure(1); plot(serial2Hh(ins.time), lights(:,ins.lambda>475&ins.lambda<500) ,'-')
%%
xl = xlim;
xa = serial2Hh(ins.time)>= xl(1) & serial2Hh(ins.time)<(xl(1)+(xl(2)-xl(1))./2); 
xb = serial2Hh(ins.time)> (xl(1)+(xl(2)-xl(1))./2) & serial2Hh(ins.time)<=xl(2); 
%%
xl = xlim;
xxa = serial2Hh(ins.time)>= xl(1) & serial2Hh(ins.time)<(xl(1)+(xl(2)-xl(1))./2); 
xxb = serial2Hh(ins.time)> (xl(1)+(xl(2)-xl(1))./2) & serial2Hh(ins.time)<=xl(2); 
%
%%
f = max(mean(lights(xa,:)))./max(mean(lights(xb,:)));
figure; plot(ins.lambda, f.*mean(lights(xb,:)), 'k-', ins.lambda ,  mean(lights(xa,:)),'r-' )

%%
% ff = max(mean(lights(xxa,:)))./max(mean(lights(xxb,:)));
figure; plot(ins.lambda, (ff-.07).*mean(lights(xxb,:)), 'r-', ins.lambda ,  mean(lights(xxa,:)),'k-' );
xlim(xll)
% figure; plot(ins.Inner_band_angle_deg, ins.spec(:,200:100:900),'o-')


return