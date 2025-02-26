% Trying to open MOD5ARI and a new rcod OD file to fix it.

tzr_nc = getnamedpath('tzr_nc')

T10a= load([tzr_nc, 'TWST10_rcods_zrads.mat']); 
T11b = load([tzr_nc, 'TWST11_rcods_zrads.mat']); 
Z1c = load([tzr_nc, 'Ze1_rcods_zrads.mat']); 
Z2d = load([tzr_nc, 'Ze2_rcods_zrads.mat']); 

[AinB, BinA] = nearest(T10a.time,T11b.time);

% %look up the density function
% figure; plot(T10a.cod(AinB), T11b.cod(BinA),'.'); axis('square');
%  sgtitle('TWST10 vs TWST11'); xlabel('TWST10 cod'); ylabel('TWST11 cod');

 T10 = sift_tstruct(T10a,AinB);
 T11 = sift_tstruct(T11b,BinA);

[CinD, DinC] = nearest(Z1c.time, Z2d.time);

% figure; plot(Z1c.cod(CinD), Z2d.cod(DinC),'.'); axis('square');
%  sgtitle('Ze1 vs Ze2'); xlabel('Ze1 cod'); ylabel('Ze2 cod');
 Z1 = sift_tstruct(Z1c,CinD);
 Z2 = sift_tstruct(Z2d,DinC);

 [EinF, FinE] = nearest(T10.time, Z1.time);

 T10 = sift_tstruct(T10,EinF);
 T11 = sift_tstruct(T11,EinF);
 Z1  = sift_tstruct(Z1, FinE);
 Z2  = sift_tstruct(Z2, FinE);
 
 figure; 
 subplot(2,3,1); plot(Z1.cod, T10.cod, '.'); xlabel('Z1 cod');ylabel('T10 cod'); title('Z1 v T10'); axis('square');
 subplot(2,3,2); plot(Z2.cod, T10.cod, '.'); xlabel('Z2 cod'); ylabel('T10 cod'); title('Z2 v T10');axis('square');
 subplot(2,3,3); plot(T11.cod, T10.cod, '.');xlabel('T11 cod'); ylabel('T10 cod'); title('T11 v T10');axis('square');

 subplot(2,3,4); plot(T11.cod,Z1.cod,'.');   ylabel('Z1 cod'); xlabel('T11 cod'); title('Z1 v T11'); axis('square');
 subplot(2,3,5); plot(T11.cod,Z2.cod,  xlabel('T11 cod'); title('Z2 v T11');axis('square');
 subplot(2,3,6); plot(Z1.cod, Z2.cod,'.');  xlabel('Z1 cod'); ylabel('Z2 cod'); title('Z1 v Z2'); axis('square');

% State [0,1,3,4], blue, bluish, thick, thin
thick = Z1.state==3 &Z2.state==3 & T10.state==3 & T11.state==3;sum(thick)
high = T11.sza<70;sum(high&thick)

% We want qc_rcod_valid==0 and liq_success==1 and ice_success==1


figure; plot(tz.time(tz.qc_rcod_valid==0), tz.rcod(tz.qc_rcod_valid==0),'.',...
tz.time(tz.liq_success==1), tz.liq_cod(tz.liq_success==1),'.'); legend('rcod','liq cod'); zoom('on');

D = ptdens3d(T11.cod(thick&high),Z1.cod(thick&high),Z2.cod(thick&high),7.5);
 figure; scatter3(T11.cod(thick&high), Z1.cod(thick&high), Z2.cod(thick&high),4, real(log10(D))); xlabel('T11'); ylabel('Z1'); zlabel('Z2'); colorbar
cm = colormap; cm(1,:) = 1; colormap(cm); caxis([-2,1.5]);

% Thoughts...  Might need to re-generate the T11a, T10b, Z1c, and Z2d sets
% from the original output to identify/flag edges using values bordering
% clear

mwrlos = anc_bundle_files;
mwrret = anc_bundle_files;
[linr, rinl] = nearest(mwrlos.time, mwrret.time);
figure; plot(mwrlos.vdata.liq(linr), mwrret.vdata.be_lwp(rinl),'x')


 try
   anet_cod = rd_cimel_cldod_v1(datenum(2024,06,01), datenum(2024,05,1),'ARM_SGP');
catch
   if ~isavar('anet_cod')||isempty(anet_cod)
      anet_cod.time = NaN;
      anet_cod.Cloud_Optical_Depth = NaN;
   end
 end
 % anet_cods = (anet_cod.Cloud_Optical_Depth>.15&anet_cod.Cloud_Optical_Depth<99);
 [ainb, bina]= nearest(anet_cod.time, Z1.time);

figure; plot(Z1.cod(bina), anet_cod.Cloud_Optical_Depth(ainb),'*'); axis('square'); ylim(xlim); legend('Ze1');
figure; plot(Z2.cod(bina), anet_cod.Cloud_Optical_Depth(ainb),'g*'); axis('square'); ylim(xlim);legend('Ze2');

figure; plot(T10.cod(bina), anet_cod.Cloud_Optical_Depth(ainb),'r*'); axis('square'); ylim(xlim); legend('TWST-10');
figure; plot(T11.cod(bina), anet_cod.Cloud_Optical_Depth(ainb),'m*'); axis('square'); ylim(xlim);legend('TWST-11');
