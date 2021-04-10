close('all');
tof_last = rd_acsm_tof_00;

figure_; plot([1:length(tof_last.time)], serial2hs(tof_last.time),'o-');
figure_; subplot(2,1,1); plot(serial2hs(tof_last.time), tof_last.filtered, 'o-'); 
subplot(2,1,2); plot([1:length(tof_last.time)], tof_last.filtered, 'o-'); 

pos_amu = tof_last.amu>=1; first = find(pos_amu==1,1,'first');
amu_ii = interp1(tof_last.amu(pos_amu), first+[0:sum(pos_amu)-1], ...
   [1:.1:max(floor(tof_last.amu))],'nearest','extrap');

figure_; imagesc(serial2hs(tof_last.time), tof_last.amu(amu_ii), ...
   real(log10(tof_last.tof_ms_raw(amu_ii,:))));axis('xy');


figure; sb(1) = subplot(2,1,1); 
plot(tof_last.amu, mean(tof_last.tof_ms_raw(:,tof_last.filtered),2), '-',...
  tof_last.amu, mean(tof_last.tof_ms_raw(:,~tof_last.filtered),2), 'r-'); 
legend('filtered','not filtered')
sb(2) = subplot(2,1,2); 
plot(tof_last.amu, mean(tof_last.tof_ms_raw(:,~tof_last.filtered),2)-...
   mean(tof_last.tof_ms_raw(:,tof_last.filtered),2), 'k-'); legend('unfilt - filt')
linkaxes(sb,'x')

figure; these = plot(tof_last.amu, mean(tof_last.tof_ms_raw(:,~tof_last.filtered)-...
   tof_last.tof_ms_raw(:,tof_last.filtered),2), 'k-'); legend('mean(unfilt - filt)');
filts = tof_last.tof_ms_raw(amu_ii,tof_last.filtered);
samps = tof_last.tof_ms_raw(amu_ii,~tof_last.filtered);
diffs = samps-filts;

figure; plot(find(tof_last.filtered), std(filts(2100:2120,:)),'.',...
   find(~tof_last.filtered), std(samps(2100:2120,:)),'r.');
legend('filtered','sample')
figure; these = plot(tof_last.amu(amu_ii), mean(diffs(:,101:1700),2)./mean(filts(:,101:1700),2), '-'); 
