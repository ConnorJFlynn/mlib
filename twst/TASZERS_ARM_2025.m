twst10_rcod_qc_all = twst4_cod_qcstate;
twst10_rcod_qc_all.sza(end) = [];
twst10_rcod_qc_all.cod(end) = [];
twst10_rcod_qc_all.cod_qc(end) = [];
twst10_rcod_qc_all.rcod_state(end) = [];
twst10_rcod_qc_all.epoch(end) = [];
twst10_rcod_qc_all.time(end) = [];
qc10 = twst10_rcod_qc_all.cod_qc~=0;
figure; plot(twst10_rcod_qc_all.time(~qc10), twst10_rcod_qc_all.cod(~qc10),'b.',...
   twst10_rcod_qc_all.time(qc10), twst10_rcod_qc_all.cod(qc10),'r.')
dynamicDateTicks
legend('TWST-10 good','TWST-10 bad')

twst11_rcod_qc_all = twst4_cod_qcstate;
twst11_rcod_qc_all.sza(end) = [];
twst11_rcod_qc_all.cod(end) = [];
twst11_rcod_qc_all.cod_qc(end) = [];
twst11_rcod_qc_all.rcod_state(end) = [];
twst11_rcod_qc_all.epoch(end) = [];
twst11_rcod_qc_all.time(end) = [];
qc11 = twst11_rcod_qc_all.cod_qc~=0;
figure; plot(twst11_rcod_qc_all.time(qc11), twst11_rcod_qc_all.cod(qc11),'k.',...
   twst11_rcod_qc_all.time(~qc11), twst11_rcod_qc_all.cod(~qc11),'.',...
   twst11_rcod_qc_all.time(qc11), twst11_rcod_qc_all.cod(qc11),'k.')
dynamicDateTicks
legend('', 'TWST-11 good','TWST-11 bad')



tzr_10 = tzrcod_to_catmat; 
tzr_10.rcod_qc = false(size(tzr_10.time));
[ainb, bina] = nearest(tzr_10.time, twst10_rcod_qc_all.time(twst10_rcod_qc_all.cod_qc==1));
tzr_10.rcod_qc(ainb) = true;
% tzr_10.rcod_qc = interp1(twst10_rcod_qc_all.time, double(twst10_rcod_qc_all.cod_qc), tzr_10.time, 'nearest');
tzr_11 = tzrcod_to_catmat;
tze_1 = tzrcod_to_catmat;
tze_2 = tzrcod_to_catmat;

figure; plot(tzr_10.time, tzr_10.rcod,'b.', tzr_10.time(tzr_10.rcod_qc), tzr_10.rcod(tzr_10.rcod_qc), 'r.'); dynamicDateTicks; legend('tzr10 rcod')
figure; plot(tzr_11.time, tzr_11.rcod,'g.'); dynamicDateTicks; legend('tzr11 rcod')
figure; plot(tze_1.time, tze_1.rcod,'c.'); dynamicDateTicks; legend('ze1 rcod')

tze_2.rcod_qc = false(size(tze_2.time));
[ainb, bina] = nearest(tze_2.time, twst10_rcod_qc_all.time(twst10_rcod_qc_all.cod_qc==1));
tze_2.rcod_qc(ainb) = true;
figure; plot(tze_2.time, tze_2.rcod,'m.', tze_2.time(tze_2.rcod_qc), tze_2.rcod(tze_2.rcod_qc), 'k.'); dynamicDateTicks; legend('ze2 rcod')
v = axis;
linkves; 
axis(v)