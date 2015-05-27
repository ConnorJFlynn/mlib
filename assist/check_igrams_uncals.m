%%
figure; 
subplot(2,1,1);
plot([1:length(RawIgm.y(1,:))],RawIgm.y(1:2,:),'-')
subplot(2,1,2);
plot([1:length(RawIgm.y(1,:))],[fftshift(RawIgm.y(1,:),2);fftshift(RawIgm.y(2,:),2)],'-')

%%
% First, compute RawIgm2RawSpc from Edgar igram to duplicate existing uncal
% spec.
pos = [-16384:16383]>=0;
f_igram = [IFG.subfiles{1}.subfileData(16382:end),IFG.subfiles{1}.subfileData(1:16381)];
r_igram = [IFG.subfiles{2}.subfileData(16389:end),IFG.subfiles{2}.subfileData(1:16388)];
Sky_F_spc.y = fftshift(fft(fftshift(IFG.subfiles{1}.subfileData, 2), [], 2), 2);
Sky_R_spc.y = fftshift(fft(fftshift(IFG.subfiles{2}.subfileData, 2), [], 2), 2);
Sky_F_spc.y = fftshift(fft(f_igram, [], 2), 2);
Sky_R_spc.y = fftshift(fft(r_igram, [], 2), 2);

figure; 
ax(1) = subplot(2,1,1); 
plot(assist.coad.chA.F.cxs.x,Sky.subfiles{1}.subfileData, 'xk-',...
assist.coad.chA.F.cxs.x, real(Sky_F_spc.y(pos)), 'b',...
      assist.coad.chA.F.cxs.x, imag(Sky_F_spc.y(pos)), 'c',...
      assist.coad.chA.F.cxs.x, abs(Sky_F_spc.y(pos)), '.r',...
      assist.coad.chA.F.cxs.x, abs(Sky.subfiles{1}.subfileData), 'og');
title('Forward coad');
ylabel('raw spc');
legend('edgar','Re(Sky)','Im(Sky)','abs(Sky)','abs(edgar)');
ax(2) = subplot(2,1,2); 
plot(assist.coad.chA.R.cxs.x,Sky.subfiles{2}.subfileData, 'xk-',...
assist.coad.chA.R.cxs.x, real(Sky_R_spc.y(pos)), 'b',...
      assist.coad.chA.R.cxs.x, imag(Sky_R_spc.y(pos)), 'c',...
      assist.coad.chA.R.cxs.x, abs(Sky_R_spc.y(pos)), '.r',...
assist.coad.chA.F.cxs.x, abs(Sky.subfiles{2}.subfileData), 'og');
title('Reverse coad');
ylabel('raw spc');
xlabel('wavenumber [1/cm]')
linkaxes(ax,'xy');
axis(v);

%%
ABB_F_spc.y = fftshift(fft(fftshift(IFG.subfiles{1}.subfileData, 2), [], 2), 2);
ABB_R_spc.y = fftshift(fft(fftshift(fliplr(IFG.subfiles{2}.subfileData), 2), [], 2), 2);
%%
figure; 
ax(1) = subplot(2,1,1); 
plot(assist.coad.chA.F.cxs.x,ABB.subfiles{1}.subfileData, 'xk-',...
assist.coad.chA.F.cxs.x, real(ABB_F_spc.y(pos)), 'b',...
      assist.coad.chA.F.cxs.x, imag(ABB_F_spc.y(pos)), 'c',...
      assist.coad.chA.F.cxs.x, abs(ABB_F_spc.y(pos)), '.r',...
      assist.coad.chA.F.cxs.x, abs(ABB.subfiles{1}.subfileData), 'og');
title('Forward coad');
ylabel('raw spc');
legend('edgar','Re(ABB)','Im(ABB)','abs(ABB)','abs(edgar)');
ax(2) = subplot(2,1,2); 
plot(assist.coad.chA.R.cxs.x,ABB.subfiles{2}.subfileData, 'xk-',...
assist.coad.chA.R.cxs.x, real(ABB_R_spc.y(pos)), 'b',...
      assist.coad.chA.R.cxs.x, imag(ABB_R_spc.y(pos)), 'c',...
      assist.coad.chA.R.cxs.x, abs(ABB_R_spc.y(pos)), '.r',...
assist.coad.chA.F.cxs.x, abs(ABB.subfiles{2}.subfileData), 'og');
title('Reverse coad, flipped left-to-right');
ylabel('raw spc');
xlabel('wavenumber [1/cm]')
linkaxes(ax,'xy');
axis(v);

%%
HBB_F_spc.y = fftshift(fft(fftshift(IFG.subfiles{1}.subfileData, 2), [], 2), 2);
HBB_R_spc.y = fftshift(fft(fftshift(fliplr(IFG.subfiles{2}.subfileData), 2), [], 2), 2);
%
%%
figure; 
ax(1) = subplot(2,1,1); 
plot(assist.coad.chA.F.cxs.x,HBB.subfiles{1}.subfileData, 'xk-',...
assist.coad.chA.F.cxs.x, real(HBB_F_spc.y(pos)), 'b',...
      assist.coad.chA.F.cxs.x, imag(HBB_F_spc.y(pos)), 'c',...
      assist.coad.chA.F.cxs.x, abs(HBB_F_spc.y(pos)), '.r',...
      assist.coad.chA.F.cxs.x, abs(HBB.subfiles{1}.subfileData), 'og');
title('Forward coad');
ylabel('raw spc');
legend('edgar','Re(HBB)','Im(HBB)','abs(HBB)','abs(edgar)');
ax(2) = subplot(2,1,2); 
plot(assist.coad.chA.R.cxs.x,HBB.subfiles{2}.subfileData, 'xk-',...
assist.coad.chA.R.cxs.x, real(HBB_R_spc.y(pos)), 'b',...
      assist.coad.chA.R.cxs.x, imag(HBB_R_spc.y(pos)), 'c',...
      assist.coad.chA.R.cxs.x, abs(HBB_R_spc.y(pos)), '.r',...
assist.coad.chA.F.cxs.x, abs(HBB.subfiles{2}.subfileData), 'og');
title('Reverse coad, flipped left-to-right');
ylabel('raw spc');
xlabel('wavenumber [1/cm]')
linkaxes(ax,'xy');
axis(v);
%%
%this block used for checking IFGs
figure; subplot(2,1,1);
plot([1:length(assist.coad.chA.F.y)],mean(assist.coad.chA.F.y([2 9],:),1)-IFG.subfiles{1}.subfileData, 'r.');
legend('Forward');
subplot(2,1,2);
plot([1:length(assist.coad.chA.F.y)],mean(assist.coad.chA.R.y([2 9],:),1)-IFG.subfiles{2}.subfileData, 'r.');
legend('Reverse')
%%
figure; subplot(2,1,1);
plot(assist.coad.chA.F.cxs.x,ABB_F_spc.y,'-b.',...
   assist.coad.chA.F.cxs.x,ABB.subfiles{1}.subfileData, 'r.');
title('ABB Forward');legend('new Matlab','Edgar')
subplot(2,1,2);
plot(assist.coad.chA.R.cxs.x,ABB_R_spc.y,'-b.',...
   assist.coad.chA.R.cxs.x, ABB.subfiles{2}.subfileData, 'r.');
title('ABB Reverse');legend('new Matlab','Edgar')
%%
figure; 
ax(1) = subplot(2,1,1); plot(assist.coad.chA.F.cxs.x, real(ABB_F_spc.y), 'r',...
   assist.coad.chA.F.cxs.x, imag(ABB_F_spc.y), 'c',...
   assist.coad.chA.F.cxs.x,ABB.subfiles{1}.subfileData, 'k',...
   assist.coad.chA.R.cxs.x, abs(ABB_F_spc.y), 'b');
title('forward with i-shift');
legend('real','imag','edgar','abs');
ax(2) = subplot(2,1,2); plot(assist.coad.chA.F.cxs.x, real(ABB_R_spc.y), 'r',...
   assist.coad.chA.R.cxs.x, imag(ABB_R_spc.y), 'c',...
   assist.coad.chA.F.cxs.x,ABB.subfiles{2}.subfileData, 'k',...
   assist.coad.chA.R.cxs.x, abs(ABB_R_spc.y), 'b');
title('reverse');
legend('real','imag','edgar','abs');
linkaxes(ax,'xy');
axis(v);
%%
v = axis;
