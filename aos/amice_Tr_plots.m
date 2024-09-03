infile = getfullname('*AP*.dat','xap_amice','Select TAP or CLAP from AMICE.');

tic; tap = rd_xap2(infile); tap = proc_xap(tap);     tap12=tap; toc;
% First, we need to look at filter signals over time to see if reference filters show
% evidence of deposition.  Then, normalize against reference filters to look at
% (presumed) filter spot attenuation over time.
% Then load flow cals and compare Bab for different instruments

figure; plot(tap.time, tap.signal_blue, '-');  dynamicDateTicks; legend('1','2','3','4','5','6','7','8','9','0')
figure; plot(xap.time, xap.Tr_blu(:,1:8), '-',xap.time, xap.Tr_blu(:,9:10), '--'); dynamicDateTicks;
figure; plot(tap.time, tap.norm_blue,'-'); dynamicDateTicks; legend('1','2','3','4','5','6','7','8','9','0')
figure; plot(tap.time, tap.signal_blue./tap.signal_blue(:,1),'-'); dynamicDateTicks; legend('1','2','3','4','5','6','7','8','9','0')
%Next would be normalizing against the active spot, flow-rate, and spot area

figure; plot(xap.time, xap.Tr_blu(:,1:8), '-',xap.time, xap.Tr_blu(:,9:10), '--'); dynamicDateTicks;
figure; plot(xap.time, xap.flow_LPM,'-');dynamicDateTicks
linkexes;


tic; clap92 = rd_xap; toc
figure; plot(clap92.time, clap92.signal_blue, '-'); legend('1','2','3','4','5','6','7','8','9','0');  dynamicDateTicks;
figure; plot(clap92.time, clap92.norm_blue,'-'); dynamicDateTicks; legend('1','2','3','4','5','6','7','8','9','0')


tic; clap10 = rd_xap; toc
figure; plot(clap10.time, clap10.signal_blue, '-'); legend('1','2','3','4','5','6','7','8','9','0');  dynamicDateTicks;
sgtitle('CLAP10')

tic; tap13 = rd_xap; toc
figure; plot(tap13.time, tap13.signal_blue, '-');  dynamicDateTicks; legend('1','2','3','4','5','6','7','8','9','0')
sgtitle('TAP13')


tic; ae33 = pack_ae33; toc

tic; [ma_92] = rd_ma ; toc
figure; sb(1) = subplot(2,1,1); plot(ma_92.time, ma_92.Tr1./ma_92.Tr1(1,:),'-'); sb(2) = subplot(2,1,2); plot(ma_92.time, ma_92.Tr2./ma_92.Tr2(1,:),'-'); dynamicDateTicks;
dynamicDateTicks;
linkaxes(sb,'xy')


tic; [ma_94] = rd_ma ; toc
figure; sb(1) = subplot(2,1,1); plot(ma_94.time, ma_94.Tr1./ma_94.Tr1(1,:),'-'); 
sb(2) = subplot(2,1,2); plot(ma_94.time, ma_94.Tr2./ma_94.Tr2(1,:),'-'); dynamicDateTicks;
dynamicDateTicks;
linkaxes(sb,'xy')