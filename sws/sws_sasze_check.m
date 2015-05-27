function sws_sasze_check
% Compare simultaneous SASZe and SWS raw measurements without explicit
% calibration
% sws = cat_sws_raw_2;
sws = bundle_sws_raw_2;
sas_vis = bundle_sas_raw(getfullname__('*_vis_*.csv','sasze_vis','Select a SASZe vis file'));
sas_nir = bundle_sas_raw(getfullname__('*_nir_*.csv','sasze_vis','Select a SASZe nir file'));
[vins, sinv] = nearest(sas_vis.time,sas_nir.time);
sas_vis = sift_raw_sas(sas_vis,vins);
sas_nir = sift_raw_sas(sas_nir,sinv);
% [rate, signal, mean_dark_time, mean_dark_spec] = sasze_raw_to_rate(ze)
[sas_vis.rate] = sasze_raw_to_rate(sas_vis);
[sas_nir.rate] = sasze_raw_to_rate(sas_nir);
[ainb, bina] = nearest(sws.time, sas_vis.time);
[ainb_vis, bina_vis] = nearest(sws.Si_lambda, sas_vis.lambda);
[ainb_nir, bina_nir] = nearest(sws.In_lambda, sas_nir.lambda);

sas_on_sws.time = sws.time(ainb)';
sas_on_sws.sws_shutter = sws.shutter(ainb)';
sas_on_sws.sas_shutter = sas_vis.Shutter_open_TF(bina)==0;
sas_on_sws.Si_lambda = sas_vis.lambda(bina_vis);
sas_on_sws.In_lambda = sas_nir.lambda(bina_nir);
sas_on_sws.sws_Si_rate = sws.Si_rate(ainb_vis, ainb)';
sas_on_sws.sws_In_rate = sws.In_rate(ainb_nir, ainb)';
sas_on_sws.sas_Si_rate = sas_vis.rate(bina,bina_vis);
sas_on_sws.sas_In_rate = sas_nir.rate(bina,bina_nir);
both = sas_on_sws.sws_shutter~=1 & sas_on_sws.sas_shutter~=1;
figure; 
OK = false;
while ~OK
    sws_part = sas_on_sws.sws_Si_rate(both,120)./mean(sas_on_sws.sws_Si_rate(both,120));
    sas_part = sas_on_sws.sas_Si_rate(both,120)./mean(sas_on_sws.sas_Si_rate(both,120));
plot(sas_on_sws.time(both), sws_part,'-',...
    sas_on_sws.time(both), sas_part,'-');
legend('sws','sas');
title('Si variation about mean')
dynamicDateTicks;
done = menu('Select desired times','Try these','Done');
v = axis;
both(both) = both(both)&sas_on_sws.time(both)>=v(1) & ...
    sas_on_sws.time(both)<=v(2)& sws_part>v(3) ...
    & sws_part<v(4) & sas_part>v(3) & sas_part<v(4);
if done==2
    OK = true;
end
end
figure; plot(sas_on_sws.time(both), sas_on_sws.sws_In_rate(both,120)./mean(sas_on_sws.sws_In_rate(both,120)),'-',...;
    sas_on_sws.time(both), sas_on_sws.sas_In_rate(both,120)./mean(sas_on_sws.sas_In_rate(both,120)),'-');
legend('sws','sas');
title('InGaAs variation about mean')

dynamicDateTicks;

figure; 
s(1) = subplot(1,2,1);
plot(sas_on_sws.Si_lambda, ...
    sas_on_sws.sws_Si_rate(both,:)./(ones([size(sas_on_sws.sws_Si_rate(both,:),1),1])*mean(sas_on_sws.sws_Si_rate(both,:))),'-');
title('SWS versus mean');
s(2)=subplot(1,2,2);
plot(sas_on_sws.Si_lambda, ...
    sas_on_sws.sas_Si_rate(both,:)./(ones([size(sas_on_sws.sas_Si_rate(both,:),1),1])*mean(sas_on_sws.sas_Si_rate(both,:))),'-');
title('SAS versus mean');
linkaxes(s,'xy');

figure; plot(sas_on_sws.Si_lambda, [sas_on_sws.sws_Si_rate(both,:)./sas_on_sws.sas_Si_rate(both,:)],'-' ); legend('VIS sws / sasze')
figure; plot(sas_on_sws.In_lambda, [sas_on_sws.sws_In_rate(both,:)./sas_on_sws.sas_In_rate(both,:)],'-' ); legend('NIR sws / sasze')
figure; plot(sas_on_sws.In_lambda, mean(sas_on_sws.sws_In_rate(both,:)),'-',sas_on_sws.In_lambda, mean(sas_on_sws.sas_In_rate(both,:)),'-' ); legend('NIR sws','NIR sasze')
sas_on_sws.both = both;
sas_on_sws.mean_sws_Si_rate = mean(sas_on_sws.sws_Si_rate(both,:));
sas_on_sws.mean_sws_In_rate = mean(sas_on_sws.sws_In_rate(both,:));
sas_on_sws.mean_sas_Si_rate = mean(sas_on_sws.sas_Si_rate(both,:));
sas_on_sws.mean_sas_In_rate = mean(sas_on_sws.sas_In_rate(both,:));
sas_on_sws.sws_over_sas_Si_rate = sas_on_sws.mean_sws_Si_rate./sas_on_sws.mean_sas_Si_rate;
sas_on_sws.sws_over_sas_In_rate = sas_on_sws.mean_sws_In_rate./sas_on_sws.mean_sas_In_rate;

outfile = [sws.pname, '..',filesep,'sws_sasze_check.',datestr(min(sws.time(both)),'yyyymmdd.HHMM'),'.mat'];
save(outfile,'-struct','sas_on_sws');

return