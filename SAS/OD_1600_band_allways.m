ods = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\ods.mat']);
% ods.intor_a = ods.intor_a ./ (ones(size(ods.nm))*trapz(ods.nm, ods.intor_a));
% ods.intor_b = ods.intor_b ./ (ones(size(ods.nm))*trapz(ods.nm, ods.intor_b));
% ods.intor_c = ods.intor_c ./ (ones(size(ods.nm))*trapz(ods.nm, ods.intor_c));
% ods.intor_d = ods.intor_d ./ (ones(size(ods.nm))*trapz(ods.nm, ods.intor_d));
% save(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\ods.mat'],'-struct','ods')
% ods contains the aer gas OD spectra (rayleigh subtracted) and all the intor
% filters, each unity area.

ch4_tape12 = rd_lblrtm_tape12_od;
ods.ch4_tape12 = interp1(ch4_tape12.nm, ch4_tape12.od, ods.nm,'linear');
whoknows.ray = rayleigh_ht(ods.nm./1000, 1013.25);

intor_a = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_a.mat']);
intor_b = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_b.mat']);
intor_c = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_c.mat']);
intor_d = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\translator\mfrsr_intor_filters\intor_d.mat']);

%Here we interpolate each OD spectra onto the nm scale of each intor filter set
% which are also unity normalized.

intor_a.h2o = interp1(ods.nm, ods.h2o,intor_a.nm,'linear');
nans = isnan(intor_a.h2o); intor_a.h2o(nans) = 0;
intor_a.ch4 = interp1(ods.nm, ods.ch4,intor_a.nm,'linear');
nans = isnan(intor_a.ch4); intor_a.ch4(nans) = 0;
intor_a.co2 = interp1(ods.nm, ods.co2,intor_a.nm,'linear');
nans = isnan(intor_a.co2); intor_a.co2(nans) = 0;

intor_b.h2o = interp1(ods.nm, ods.h2o,intor_b.nm,'linear');
nans = isnan(intor_b.h2o); intor_b.h2o(nans) = 0;
intor_b.ch4 = interp1(ods.nm, ods.ch4,intor_b.nm,'linear');
nans = isnan(intor_b.ch4); intor_b.ch4(nans) = 0;
intor_b.co2 = interp1(ods.nm, ods.co2,intor_b.nm,'linear');
nans = isnan(intor_b.co2); intor_b.co2(nans) = 0;

intor_c.h2o = interp1(ods.nm, ods.h2o,intor_c.nm,'linear');
nans = isnan(intor_c.h2o); intor_c.h2o(nans) = 0;
intor_c.ch4 = interp1(ods.nm, ods.ch4,intor_c.nm,'linear');
nans = isnan(intor_c.ch4); intor_c.ch4(nans) = 0;
intor_c.co2 = interp1(ods.nm, ods.co2,intor_c.nm,'linear');
nans = isnan(intor_c.co2); intor_c.co2(nans) = 0;

intor_d.h2o = interp1(ods.nm, ods.h2o,intor_d.nm,'linear');
nans = isnan(intor_d.h2o); intor_d.h2o(nans) = 0;
intor_d.ch4 = interp1(ods.nm, ods.ch4,intor_d.nm,'linear');
nans = isnan(intor_d.ch4); intor_d.ch4(nans) = 0;
intor_d.co2 = interp1(ods.nm, ods.co2,intor_d.nm,'linear');
nans = isnan(intor_d.co2); intor_d.co2(nans) = 0;

figure; plot(intor_b.nm, intor_b.filts,'-b', ...
    intor_c.nm, intor_c.filts,'-c', intor_d.nm, intor_d.filts,'-g',intor_a.nm, intor_a.filts,'-r'); 
title('Batches a(red), b(blue), c(cyan), d(grn)')


% Now compare convolved OD for same filter but opposite direction stance.

trapz(intor_d.nm, (intor_d.co2*ones([1,12])).*intor_d.filts)
trapz(ods.nm, (ods.co2*ones([1,12])) .* ods.intor_d)
am = 1;     
-log(trapz(intor_d.nm, exp((-intor_d.co2*ones([1,12])).*am).*intor_d.filts))./am
-log(trapz(ods.nm, exp((-ods.co2*ones([1,12])).*am).*ods.intor_d))./am

trapz(intor_d.nm, (intor_d.ch4*ones([1,12])).*intor_d.filts)

-log(trapz(ods.nm, exp((-ods.ch4*ones([1,4])).*am).*ods.intor_a))'./am
-log(trapz(ods.nm, exp((-ods.ch4*ones([1,10])).*am).*ods.intor_b))'./am
-log(trapz(ods.nm, exp((-ods.ch4*ones([1,6])).*am).*ods.intor_c))'./am
-log(trapz(ods.nm, exp((-ods.ch4*ones([1,12])).*am).*ods.intor_d))'./am
disp('CO2')
-log(trapz(ods.nm, exp((-ods.co2*ones([1,4])).*am).*ods.intor_a))'./am
-log(trapz(ods.nm, exp((-ods.co2*ones([1,10])).*am).*ods.intor_b))'./am
-log(trapz(ods.nm, exp((-ods.co2*ones([1,6])).*am).*ods.intor_c))'./am
-log(trapz(ods.nm, exp((-ods.co2*ones([1,12])).*am).*ods.intor_d))'./am
disp('H2O')
-log(trapz(ods.nm, exp((-5.*ods.h2o*ones([1,4])).*am).*ods.intor_a))'./am./5
-log(trapz(ods.nm, exp((-ods.h2o*ones([1,10])).*am).*ods.intor_b))'./am
-log(trapz(ods.nm, exp((-ods.h2o*ones([1,6])).*am).*ods.intor_c))'./am
-log(trapz(ods.nm, exp((-ods.h2o*ones([1,12])).*am).*ods.intor_d))'./am

am = 1; pwv = 5
trapz(intor_d.nm, (intor_d.h2o*ones([1,12])).*intor_d.filts)
trapz(ods.nm, (ods.h2o*ones([1,12])) .* ods.intor_d)

am = 1; pwv = 1;
trapz(intor_d.nm, (pwv./5).*(intor_d.h2o*ones([1,12])).*intor_d.filts).*5
trapz(ods.nm, (pwv./5).*(ods.h2o*ones([1,12])) .* ods.intor_d).*5


