% Compare mine to Edgar
% Reading in 20100618_015418_chB_HC.mat to both Matlab and Edgar
% Use my routines to compute raw spc.
% Use edgar to compute raw spc.
% Load output edgar file, compare.
clear
plots_default;
close('all');
% Proc assist run
% Read in the black body sequence and corresponding annot file
% % read ASSIST A and B mat files.
while ~exist('pname','var')||~exist(pname, 'dir')
   [pname] = getdir('assist');
end
%%

chB_ls = dir([pname, '*_chB_*.mat']);
   edgar_mat = loadinto([pname,'20100618_015418_chB_HC.mat']);
   flynn_mat = repack_edgar(edgar_mat);

assist.pname = pname;
assist.time = flynn_mat.time;
logi.F = bitget(flynn_mat.flags,2)>0;
logi.R = bitget(flynn_mat.flags,3)>0;
logi.H = bitget(flynn_mat.flags,5)>0;
logi.A = bitget(flynn_mat.flags,6)>0;
logi.Sky = ~(logi.H|logi.A);
logi.HBB_F = bitget(flynn_mat.flags,2)&bitget(flynn_mat.flags,5);
logi.HBB_R = bitget(flynn_mat.flags,3)&bitget(flynn_mat.flags,5);
logi.ABB_F = bitget(flynn_mat.flags,2)&bitget(flynn_mat.flags,6);
logi.ABB_R = bitget(flynn_mat.flags,3)&bitget(flynn_mat.flags,6);
logi.Sky_F = bitget(flynn_mat.flags,2)& ~(bitget(flynn_mat.flags,5)|bitget(flynn_mat.flags,6));
logi.Sky_R = bitget(flynn_mat.flags,3)& ~(bitget(flynn_mat.flags,5)|bitget(flynn_mat.flags,6));

assist.logi = logi;
HBB_off = 0;
ABB_off = 0;
assist.HBB_C = HBB_off+double(flynn_mat.HBBRawTemp)./500;
assist.ABB_C = ABB_off+double(flynn_mat.CBBRawTemp)./500;

%%
assist.chB = flynn_mat;
%%
% [zpd_loc1, zpd_mag1] = find_zpd_fft(flynn_mat);
%%
[zpd_loc, zpd_mag] = find_zpd_edgar(flynn_mat);
%%

% [zpd_loc, zpd_mag] = find_zpd(flynn_mat);
assist.chB.zpd_loc = zpd_loc; 
assist.chB.zpd_mag = zpd_mag;


%%
% This raw file created from Edgar 
edgar_rawspc = loadinto([pname,'20100618_015418_chB_HC.mat.raw']);
   rawspc = repack_edgar(edgar_rawspc);

   zpd_loc(:) = length(assist.chB.x)./2 + 1;
%%
m = 1;% m = 1, forward, m =2, reverse
   zpd_shift = -6;
%%
zpd_shift = zpd_shift + 1;
assist.chB.laser_wn = 1.57974921e4;
% assist.chB.laser_wn = 1.581090391e4;
assist.chB.zpd_loc = zpd_loc+zpd_shift;
assist.chB.cxs= RawIgm2RawSpc(assist.chB,~assist.logi.F);
% figure; plot(assist.chB.cxs.x, abs(assist.chB.cxs.y(1,:)), 'o', rawspc.x-.5, rawspc.y(1,:), 'x');
% m = m +2;
% figure;
ss(1)=subplot(2,2,1);
plot(assist.chB.cxs.x, [abs(assist.chB.cxs.y(m,:)); rawspc.y(m,:)], '-');
legend('Matlab','Edgar');
title({['Abs magnitude'];['forward']})
ss(3)=subplot(2,2,3);
plot(assist.chB.cxs.x, 100.*(abs(assist.chB.cxs.y(m,:))- rawspc.y(m,:))./abs(assist.chB.cxs.y(m,:)), '.k');
title({['Matlab - Edgar'];['zpd shift: ',num2str(zpd_shift)]})
ylabel('%');
ylim([-.1,.1]);
ss(2)=subplot(2,2,2);
plot(assist.chB.cxs.x, [abs(assist.chB.cxs.y(m+1,:)); rawspc.y(m+1,:)], '-');
legend('Matlab','Edgar');
title({['Abs magnitude'];['reverse']})
ss(4)=subplot(2,2,4);
plot(assist.chB.cxs.x, 100.*(abs(assist.chB.cxs.y(m+1,:))- rawspc.y(m+1,:))./abs(assist.chB.cxs.y(m+1,:)), '.k');
title({['Matlab - Edgar'];['Matlab zpd location: ',num2str(zpd_shift)]})
ylabel('%');

linkaxes(ss,'x');
xlim([2000,2300]);
ylim([-.1,.1]);
saveas(gcf,['C:\Documents and Settings\d3k014\Desktop\shifts\shift_zpd_',num2str(zpd_shift),'.png'])
%  axis(v)
%%
% forward, floating point difference by adding 3 to zpd_loc based on my zpd_find
% can't seem to match reverse spectra with any zpd adjustment.
