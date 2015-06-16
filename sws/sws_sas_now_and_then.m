function sws_sas_now_and_then

older = load(getfullname('sws_sasze_check*.mat','sws_sasze_compares','Select previous comparison'));
newer = load(getfullname('sws_sasze_check*.mat','sws_sasze_compares','Select newer comparison'));

figure; plot(older.Si_lambda, older.sws_over_sas_Si_rate,'-',newer.Si_lambda, newer.sws_over_sas_Si_rate,'-');
legend('older','newer');
title('Si sws over sas, before and after');

figure; plot(older.In_lambda, older.sws_over_sas_In_rate,'-',newer.In_lambda, newer.sws_over_sas_In_rate,'-');
legend('older','newer');
title('InGaAs sws over sas, before and after');

figure; 
sa(1) = subplot(2,1,1);
plot(older.Si_lambda, older.mean_sws_Si_rate,'b-',older.In_lambda, older.mean_sws_In_rate,'b-',...
    newer.Si_lambda, newer.mean_sws_Si_rate,'r-',newer.In_lambda, newer.mean_sws_In_rate,'r-');
legend('older Si','older InGaAS', 'newer Si','newer InGaAs');
title('sws rate, before and after');zoom('on')
sa(2) = subplot(2,1,2);
plot(older.Si_lambda, newer.mean_sws_Si_rate./older.mean_sws_Si_rate,'k-',older.In_lambda, newer.mean_sws_In_rate./older.mean_sws_In_rate,'m-');
legend('Si newer/older','InGaAS newer/older');
linkaxes(sa,'x');zoom('on')

figure; 
sb(1) = subplot(2,1,1);
plot(older.Si_lambda, older.mean_sas_Si_rate,'b-',older.In_lambda, older.mean_sas_In_rate,'b-',...
    newer.Si_lambda, newer.mean_sas_Si_rate,'r-',newer.In_lambda, newer.mean_sas_In_rate,'r-');
legend('older Si','older InGaAS', 'newer Si','newer InGaAs');
title('SAS rate, before and after');zoom('on')
sb(2) = subplot(2,1,2);
plot(older.Si_lambda, newer.mean_sas_Si_rate./older.mean_sas_Si_rate,'k-',older.In_lambda, newer.mean_sas_In_rate./older.mean_sas_In_rate,'m-');
legend('Si newer/older','InGaAS newer/older');
linkaxes(sb,'x');zoom('on')




return
