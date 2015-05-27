%Compare Prede to NIMFR
prede = read_prede_sun;
nimfr = read_barn_nimfr_cosnorm;

%%
xl2 = xlim;
%%
figure; 
ax(1) = subplot(2,1,1); plot(serial2Hh(prede.time(pinn))-prede.LST_offset-1, prede.filter_3(pinn)./mean(prede.filter_3(prede.xl)),'r.', serial2Hh(nimfr.time_LST(ninp)), nimfr.filter_500(ninp)./mean(nimfr.filter_500(nimfr.xl)),'b.'); 
xlabel('LST'); legend('Prede','NIMFR')
title('Prede filter 3 (500 nm), NIMFR 500 nm')
ax(2) = subplot(2,1,2); plot(serial2Hh(nimfr.time_LST(ninp)), 100*((nimfr.filter_500(ninp)./mean(nimfr.filter_500(nimfr.xl)))-(prede.filter_3(pinn)./mean(prede.filter_3(prede.xl))))./(nimfr.filter_500(ninp)./mean(nimfr.filter_500(nimfr.xl))),'k.'); 
xlabel('LST'); ylabel('(NIMFR-Prede)%');
linkaxes(ax,'x'); xlim(xl2);
%%
figure; 
ax(1) = subplot(2,1,1); plot(serial2Hh(prede.time(pinn))-prede.LST_offset-1, prede.filter_4(pinn)./mean(prede.filter_4(prede.xl)),'r.', serial2Hh(nimfr.time_LST(ninp)), nimfr.filter_673(ninp)./mean(nimfr.filter_673(nimfr.xl)),'b.'); xlabel('LST'); legend('Prede','NIMFR')
title('Prede filter 4 (675 nm), NIMFR 673 nm')
ax(2) = subplot(2,1,2); plot(serial2Hh(nimfr.time_LST(ninp)), 100*((nimfr.filter_673(ninp)./mean(nimfr.filter_673(nimfr.xl)))-(prede.filter_4(pinn)./mean(prede.filter_4(prede.xl))))./(nimfr.filter_673(ninp)./mean(nimfr.filter_673(nimfr.xl))),'k.'); 
xlabel('LST'); ylabel('(NIMFR-Prede)%');
linkaxes(ax,'x'); xlim(xl2);
%%
figure; 
ax(1) = subplot(2,1,1); plot(serial2Hh(prede.time(pinn))-prede.LST_offset-1, prede.filter_5(pinn)./mean(prede.filter_5(prede.xl)),'r.', serial2Hh(nimfr.time_LST(ninp)), nimfr.filter_870(ninp)./mean(nimfr.filter_870(nimfr.xl)),'b.'); xlabel('LST'); legend('Prede','NIMFR')
title('Prede filter 5 (870 nm), NIMFR 870 nm')
ax(2) = subplot(2,1,2); plot(serial2Hh(nimfr.time_LST(ninp)), 100*((nimfr.filter_870(ninp)./mean(nimfr.filter_870(nimfr.xl)))-(prede.filter_5(pinn)./mean(prede.filter_5(prede.xl))))./(nimfr.filter_870(ninp)./mean(nimfr.filter_870(nimfr.xl))),'k.'); 
xlabel('LST'); ylabel('(NIMFR-Prede)%');
linkaxes(ax,'x'); xlim(xl2);
