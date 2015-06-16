%%
% Read in Edgar mat files for 1 complete sequence.
% Produce derived products.
% Compare to related products from Andre'.



%%
% Cycle through degraded resolution chA looking for clear sky
pname = ['C:\case_studies\assist\data\post_Feb_repair\20110215_143855\'];
files = dir([pname, '*.mat']);
f = 1;
a = 1;
close('all');
clear ax
%%
if ~isempty(findstr(files(f+17).name,'_chB_'))
   disp(['plotting ',files(f+17).name])
   figure;
   infileA = [pname, files(f+17).name];
[~, fname, ext] = fileparts(infileA);
matA = repack_edgar(infileA); 
%
ax(a) = subplot(2,1,1); a = a+1;
plot(matA.x, matA.y,'ok-');

[tl_str,tl_tail] = strtok(fname,'.');
tl = title({tl_str;tl_tail(2:end)}); set(tl,'interp','none');
ax(a) = subplot(2,1,2); a = a+1;
semilogy(matA.x, matA.y,'ok-');
linkaxes(ax,'x')
f = f+1;
else
   disp(['skipping ',files(f+17).name]);
   f = 1;
   
end
   %%
   
%assist.chA.cal_F
%%
figure; 
xx(1) = subplot(2,1,1);
plot(assist.chA.cal_F.x, [real(assist.chA.cal_F.Resp);imag(assist.chA.cal_F.Resp)],'-');
xlabel('wavenumbers');
ylabel(['cts/mW-sr-m^2_cm^-1']);
legend('real(resp)','imag(resp)')


xx(2) = subplot(2,1,2);
plot(assist.chA.cal_F.x, [real(assist.chA.cal_F.Offset_cts);imag(assist.chA.cal_F.Offset_cts)],'-');
xlabel('wavenumbers');
ylabel(['cts']);
xlim([500,1800]);
legend('real(offset cts)','imag(offset cts)');
linkaxes(xx,'x');
xlim([500,1800]);

%%
% 
% 
% assist.degraded.chA.mrad.x = downsample(assist.chA.cxs.x,50);
% assist.degraded.chA.mrad.F = downsample(assist.down.chA.mrad.F,50,2);
% assist.degraded.chA.Resp_F = downsample(assist.chA.cal_F.Resp,50,2);
% assist.degraded.chA.Offset_ru_F = downsample(assist.chA.cal_F.Offset_ru,50,2);
% assist.degraded.chA.Resp_R = downsample(assist.chA.cal_R.Resp,50,2);
% assist.degraded.chA.Offset_ru_R = downsample(assist.chA.cal_R.Offset_ru,50,2);
% assist.degraded.chA.T_bt = BrightnessTemperature(assist.degraded.chA.mrad.x, ...
%    real(assist.degraded.chA.mrad.F ));
%%
n = 2;
N = 0;
figure;
%%
%
N = N+1;
n = n+1;

apos = assist.down.chA.mrad.x>550 & assist.down.chA.mrad.x<2000;
bpos = assist.down.chA.mrad.x>1600 & assist.down.chB.mrad.x<3000;
adeg = assist.degraded.chA.mrad.x>550 & assist.degraded.chA.mrad.x<2000;
bdeg = assist.degraded.chA.mrad.x>1600 & assist.degraded.chB.mrad.x<3000;
s(1) = subplot(2,1,1);
plot(assist.down.chA.mrad.x(apos), assist.down.chA.mrad.F(n,apos), 'b.',...
   assist.down.chB.mrad.x(bpos), assist.down.chB.mrad.F(n,bpos), 'k.',...
   assist.degraded.chA.mrad.x(adeg), assist.degraded.chA.mrad.F(n,adeg), 'ro',...
   assist.degraded.chB.mrad.x(bdeg), assist.degraded.chB.mrad.F(n,bdeg), 'gx')
s(2) = subplot(2,1,2);
plot(A_mrad.x, A_mrad.y(N,:),'b.',B_mrad.x, B_mrad.y(N,:),'k.',...
   A_mrad_deg.x, A_mrad_deg.y(N,:),'ro',B_mrad_deg.x, B_mrad_deg.y(N,:),'gx');
linkaxes(s,'xy')
%%
   %%
   
infileA = getfullname('*_chA_SKY.coad.mrad.coad.merged.truncated.mat','edgar_mat','Select an Edgar mat file.');
[pname, fname, ext] = fileparts(infileA);
A_mrad = repack_edgar(infileA); 
infileA = getfullname('*_chA_SKY.coad.mrad.coad.merged.truncated.degraded.mat','edgar_mat','Select an Edgar mat file.');
[pname, fname, ext] = fileparts(infileA);
A_mrad_deg = repack_edgar(infileA);    
   
infileA = getfullname('*_chB_SKY.coad.mrad.coad.merged.truncated.mat','edgar_mat','Select an Edgar mat file.');
[pname, fname, ext] = fileparts(infileA);
B_mrad = repack_edgar(infileA); 
infileA = getfullname('*_chB_SKY.coad.mrad.coad.merged.truncated.degraded.mat','edgar_mat','Select an Edgar mat file.');
[pname, fname, ext] = fileparts(infileA);
B_mrad_deg = repack_edgar(infileA); 

%%

%%
BT = BrightnessTemperature(B_mrad.x, B_mrad.y);
BT_deg = BrightnessTemperature(B_mrad_deg.x, B_mrad_deg.y);
BT_deg2.x = downsample(B_mrad.x,50,2);
BT_deg2.y = downsample(BT,50,2);
figure;
plot(B_mrad.x, BT(1,:), 'k',B_BT.x, B_BT.y(1,:), 'r.',B_mrad_deg.x, BT_deg(1,:),'go',BT_deg2.x,BT_deg2.y(1,:),'bx')
figure; plot(B_mrad.x, B_mrad.y(1,:), 'k',B_mrad_deg.x, B_mrad_deg.y(1,:),'go')
%%
infileA = getfullname('*_chB_SkyNEN*.mat','edgar_mat','Select an Edgar mat file.');
[pname, fname, ext] = fileparts(infileA);
NEN = repack_edgar(infileA); 
%%
figure; 
s(1) = subplot(2,1,1);
semilogy(B_mrad.x, B_mrad.y(1,:), 'k',NEN.x, NEN.y(1,:),'.-')
s(2) = subplot(2,1,2);
plot(B_mrad.x, BT(1,:), 'k',B_BT.x, B_BT.y(1,:), 'r.');
linkaxes(s,'x')
%
%%
figure;
%
semilogy(matA.x, matA.y,'k-')
[tl_str,tl_tail] = strtok(fname,'.');
tl = title({tl_str;tl_tail(2:end)}); set(tl,'interp','none');
%%
infileA = getfullname('*_chA_BTemp_SKY*.mat','edgar_mat','Select an Edgar mat file.');
[pname, fname, ext] = fileparts(infileA);
%

BTA = repack_edgar(infileA); 
%%
rad = matA;
figure; plot(rad.x, BrightnessTemperature(rad.x, 1e3.*real(rad.y)),'r-',BTA.x,BTA.y,'k.')

%%

%%
infileB = strrep(infileA, '_chA_','_chB_');
%%
matB = repack_edgar(infileB);
%
figure;
%
semilogy(matA.x, matA.y,'k-',matB.x, matB.y,'-')
[tl_str,tl_tail] = strtok(fname,'.');
tl = title({tl_str;tl_tail(2:end)}); set(tl,'interp','none')
%%
figure;
subplot(2,1,1); plot(sky_A.x, sky_A.y(1,:)-sky_A.y(2,:), 'k-',matA.x, matA.y(1,:),'r-');
subplot(2,1,2); plot(sky_A.x,sky_A.y(1,:)-sky_A.y(2,:) - matA.y(1,:),'-o')

%%
infileA = getfullname('*_chA_*RESP_REAL_SKY1*.mat','edgar_mat','Select Re Resp')
chA_resp_Re = repack_edgar(infileA); 
%
infileA = getfullname('*_chA_*RESP_IMA_SKY1*.mat','edgar_mat','Select Im Resp.');
chA_resp_Im = repack_edgar(infileA); 
%

infileA = getfullname('*_chA_*OFF_REAL_SKY1*.mat','edgar_mat','Select Re Offset cts')
chA_offset_Re = repack_edgar(infileA); 
%
infileA = getfullname('*_chA_*OFF_IMA_SKY1*.mat','edgar_mat','Select Im Offset cts.');
chA_offset_Im = repack_edgar(infileA); 
%%

clear s
figure;
s(1)=subplot(2,2,1);
plot(chA_resp_Re.x, chA_resp_Re.y(1,:), 'b');
legend('Re(ch A Resp)');
s(2)=subplot(2,2,2);
plot(chA_offset_Re.x,chA_resp_Im.y(1,:),'g');
legend('Im(ch A Resp)');
s(3)=subplot(2,2,3);
plot(chA_offset_Re.x, chA_offset_Re.y(1,:), 'b');
legend('Re(ch A offset)')
s(4)=subplot(2,2,4);
plot(chA_offset_Re.x,chA_offset_Im.y(1,:),'g');
legend('Im(ch A offset)');

linkaxes(s,'x')
%%
semilogy(matA.x, matA.y,'k-')
[tl_str,tl_tail] = strtok(fname,'.');
tl = title({tl_str;tl_tail(2:end)}); set(tl,'interp','none')
%%