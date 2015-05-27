function assist = coad_vs_avg(pname)
plots_default;
close('all')
% Proc assist run
% Read in the black body sequence and corresponding annot file
% % read ASSIST A and B mat files.
while ~exist('pname','var')||~exist(pname, 'dir')
   [pname] = getdir([],'assist');
end

ann_ls = dir([pname, '*ann*.xls']);
for a = length(ann_ls):-1:1
   fname = ann_ls(a).name;
   [xl_num, xl_txt]= xlsread([pname, fname]);
   xl_len = min([length(xl_txt(2,:)),length(xl_num(2,:))]);
   for n = xl_len:-1:1
      if any(isnumeric(xl_num(:,n)))
         lab = legalize(xl_txt{2,n});
         ann.(lab) = xl_num(:,n);
      end
   end
   if ~exist('assist','var')
      assist.ann = ann;
   else
      [scan_nm, ii] = sort([assist.ann.ScanNumber;ann.ScanNumber]);
      ann_fields = (fieldnames(assist.ann));
      for f = length(ann_fields):-1:1
         X = [assist.ann.(ann_fields{f});ann.(ann_fields{f})];
         assist.ann.(ann_fields{f}) = X(ii);
      end
   end
end

chA_ls = dir([pname, '*_chA_*.mat']);
for chA = length(chA_ls):-1:1
   fname = chA_ls(chA).name;
   edgar_mat = loadinto([pname,fname]);
   flynn_mat = repack_edgar(edgar_mat);
   if ~isfield(assist,'chA')
      assist.chA = flynn_mat;
   else
      assist.chA = stitch_mats(assist.chA,flynn_mat);
   end
end

chB_ls = dir([pname, '*_chB_*.mat']);
for chB = length(chB_ls):-1:1
   fname = chB_ls(chB).name;
   edgar_mat = loadinto([pname,fname]);
   flynn_mat = repack_edgar(edgar_mat);
   if ~isfield(assist,'chB')
      assist.chB = flynn_mat;
   else
      assist.chB = stitch_mats(assist.chB,flynn_mat);
   end
end
assist.pname = pname;
assist.time = assist.chA.time;
logi.F = bitget(assist.chA.flags,2)>0;
logi.R = bitget(assist.chA.flags,3)>0;
logi.H = bitget(assist.chA.flags,5)>0;
logi.A = bitget(assist.chA.flags,6)>0;
logi.Sky = ~(logi.H|logi.A);
logi.HBB_F = bitget(assist.chA.flags,2)&bitget(assist.chA.flags,5);
logi.HBB_R = bitget(assist.chA.flags,3)&bitget(assist.chA.flags,5);
logi.ABB_F = bitget(assist.chA.flags,2)&bitget(assist.chA.flags,6);
logi.ABB_R = bitget(assist.chA.flags,3)&bitget(assist.chA.flags,6);
logi.Sky_F = bitget(assist.chA.flags,2)& ~(bitget(assist.chA.flags,5)|bitget(assist.chA.flags,6));
logi.Sky_R = bitget(assist.chA.flags,3)& ~(bitget(assist.chA.flags,5)|bitget(assist.chA.flags,6));

assist.logi = logi;
HBB_off = 0;
ABB_off = 0;
assist.HBB_C = HBB_off+double(assist.chA.HBBRawTemp)./500;
assist.ABB_C = ABB_off+double(assist.chA.CBBRawTemp)./500;

%%
[assist.chA.zpd_loc, assist.chA.zpd_mag] = find_zpd_abs(assist.chA);
[assist.chA.zpd_loc, assist.chA.zpd_mag] = find_zpd(assist.chA);
assist.chA.laser_wn = 1.580098469e4;
% assist.chA.laser_wn = 1.582098469e4;
assist.chA.cxs= RawIgm2RawSpc(assist.chA,assist.logi.F);
%%
% plot([1:120],[assist.chA.zpd_loc,zpd_loc'],'o',[1:120],[assist.ann.MaxALoc,assist.ann.MinALoc], 'x');
% legend('prev loc','new loc','MaxALoc','MinALoc')
%%

[assist.chB.zpd_loc, assist.chB.zpd_mag] = find_zpd_abs(assist.chB);
[zpd_loc, zpd_mag] = find_zpd(assist.chB);
assist.chB.zpd_loc = zpd_loc; 
assist.chB.zpd_mag = zpd_mag;

assist.chB.laser_wn = 1.579990391e4;
% assist.chB.laser_wn = 1.581090391e4;
assist.chB.cxs= RawIgm2RawSpc(assist.chB,assist.logi.F);

%% NLC code
% non-linear correction parameters:
% correction factor (1+2*a2*V)

nlc.a2 = 4.*1.2276e-8;
% nlc.a2 = nlc.a2./4;
a2_str = sprintf('%2.5g',nlc.a2);
a2_str = strrep(a2_str,'-0','-');a2_str = strrep(a2_str,'-0','-');

nlc.MF=(0.7);
nlc.fBACK=(1.0);
nlc.IHLAB=(-80443);
nlc.ICLAB=(96455);     

%These values provided by Luc just prior to June 18 comparisons.
% nlc.a2 = 1.2276e-6;
a2_str = sprintf('%2.5g',nlc.a2);
a2_str = strrep(a2_str,'-0','-');a2_str = strrep(a2_str,'-0','-');

nlc.MF=(0.7);
nlc.fBACK=(1.0);
nlc.IHLAB=(-80443);
nlc.ICLAB=(96455);   
     %%
IH0 = mean(assist.chA.zpd_mag(assist.logi.HBB_F|assist.logi.HBB_R));
nlc.Vdc = (assist.chA.zpd_mag+(2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IH0))./(-nlc.MF);
nlc.nonlinearity_factor = 1+ 2.*nlc.a2.*nlc.Vdc;
igm2.x = assist.chA.x;
igm2.y = assist.chA.y.^2;
igm2.laser_wn = assist.chA.laser_wn;
igm2.zpd_loc = assist.chA.zpd_loc;
tmp = RawIgm2RawSpc(igm2, assist.logi.F);
nlc.nonlinearity_offset = nlc.a2.*tmp.y;
 %
 figure; 
 subplot(2,1,1);
 plot([1:length(assist.time)],nlc.Vdc,'-x');
 title('DC voltage computed as V_D_C (also called V_m)');
 ylabel('V');
 subplot(2,1,2);
plot([1:length(assist.time)],nlc.nonlinearity_factor,'-o');
 title('NLC = 1+ 2*a2*V_m');
 ylabel('unitless factor');
 xlabel('record number');
 v = axis;
 txt_nlc = text(0.7.*mean(v(1:2)),mean(v(3:4)),{['a2 = ',a2_str];['HBB offset = ',num2str(HBB_off)];...
['ABB offset = ',num2str(ABB_off)]});
%%
assist.chA.nlc =nlc;
assist.chA.nlc.x = assist.chA.cxs.x;
assist.chA.nlc.y = (assist.chA.cxs.y .* (nlc.nonlinearity_factor'*ones(size(assist.chA.cxs.x))));
% assist.chA.nlc.y = assist.chA.nlc.y + assist.chA.nlc.nonlinearity_offset;
%%
% figure; 
% plot(assist.chA.cxs.x,assist.chA.nlc.nonlinearity_offset(assist.logi.H,:) ./assist.chA.cxs.y(assist.logi.H,:),'r-',...
%    assist.chA.cxs.x,assist.chA.nlc.nonlinearity_offset(assist.logi.A,:)./assist.chA.cxs.y(assist.logi.A,:),'b-',...
%    assist.chA.cxs.x,assist.chA.nlc.nonlinearity_offset(assist.logi.Sky,:) ./assist.chA.cxs.y(assist.logi.Sky,:),'g-');
% xlabel('wavenumber [1/cm]');
% ylabel('non-linear correction offset')
% lg = legend('red is HBB','blue is ABB','green is Sky');
% xlim([650,1450]);
% ylim([-1e-3,1.5e-3]);

%% end NLC code

%Determine radiance calibration
assist = rad_cal_def1(assist);
assist = rad_cal_def2(assist);

%%

% andre_dir = ['C:\case_studies\assist\integration\data_integration\remote_SGP\processedData\2010_06_18\R50_02_13_53\'];
edgar_file = getdir([],'edgar');
%%
proc_mat = loadinto(edgar_file)

%%
[proc_A_mat,edgar_aname] = loadinto(edgar_file);
[pname, aname, ext] = fileparts(edgar_aname);
[proc_B_mat,edgar_bname] = loadinto(edgar_file);
[pname, bname, ext] = fileparts(edgar_bname);
%
%this block used for checking IFGs
figure; 
subplot(2,2,1);
plot([1:length(assist.coad.chA.F.y)],mean(assist.coad.chA.F.y([1 10],:),1)-proc_mat.subfiles{1}.subfileData, 'r.');
legend('Ch A, Forward');
title(aname,'interp','none')
subplot(2,2,2);
plot([1:length(assist.coad.chA.F.y)],assist.coad.chA.R.y(9,:)-proc_A_mat.subfiles{2}.subfileData, 'r.');
legend('Ch A, Reverse');
subplot(2,2,3);
plot([1:length(assist.coad.chB.F.y)],assist.coad.chB.F.y(9,:)-proc_B_mat.subfiles{1}.subfileData, 'r.');
legend('Ch B, Forward');
title(bname,'interp','none')
subplot(2,2,4);
plot([1:length(assist.coad.chB.F.y)],assist.coad.chB.R.y(9,:)-proc_B_mat.subfiles{2}.subfileData, 'r.');
legend('Ch B, Reverse');
%this block used for checking uncalibrated spectra
% Check ABB forward and reverse
%%
[ABB,edgar_fname] = loadinto(edgar_file);
%%
[HBB,edgar_fname] = loadinto(edgar_file);
%%
[Sky,edgar_fname] = loadinto(edgar_file);
%%
figure; subplot(2,1,1);
plot(assist.coad.chA.F.cxs.x,ABB.subfiles{1}.subfileData,'-b.',...
   assist.coad.chA.F.cxs.x,ABB.subfiles{2}.subfileData, 'r.');
title('ABB Edgar raw');legend('Forward','Reverse')
subplot(2,1,2);
plot(assist.coad.chA.F.cxs.x,HBB.subfiles{1}.subfileData,'-b.',...
   assist.coad.chA.F.cxs.x,HBB.subfiles{2}.subfileData, 'r.');
title('HBB Edgar raw');legend('Forward','Reverse')
%%

figure; subplot(2,1,1);
plot(assist.coad.chA.F.cxs.x,mean(assist.coad.chA.F.cxs.y([2 9],:),1),'-b.',...
   assist.coad.chA.R.cxs.x,mean(assist.coad.chA.R.cxs.y([2 9],:),1), 'r.');
title('ABB Matlab raw');legend('Forward','Reverse')
subplot(2,1,2);
plot(assist.coad.chA.F.cxs.x,mean(assist.coad.chA.F.cxs.y([1 10],:),1),'-b.',...
   assist.coad.chA.R.cxs.x,mean(assist.coad.chA.R.cxs.y([1 10],:),1), 'r.');
title('HBB Matlab raw');legend('Forward','Reverse')
%%
figure; subplot(2,1,1);
plot(assist.coad.chA.F.cxs.x,mean(assist.coad.chA.F.cxs.y([2 9],:),1),'-b.',...
   assist.coad.chA.F.cxs.x,ABB.subfiles{1}.subfileData, 'r.');
title('ABB Forward');legend('Matlab','Edgar')
subplot(2,1,2);
plot(assist.coad.chA.R.cxs.x,mean(assist.coad.chA.R.cxs.y([2 9],:),1),'-b.',...
   assist.coad.chA.R.cxs.x, ABB.subfiles{2}.subfileData, 'r.');
title('ABB Reverse');legend('Matlab','Edgar')
%%

figure; subplot(2,1,1);
plot(assist.coad.chA.F.cxs.x,mean(assist.coad.chA.F.cxs.y([1 10],:),1),'-b.',...
   assist.coad.chA.F.cxs.x,HBB.subfiles{1}.subfileData, 'r.');
title('HBB Forward');legend('Matlab','Edgar')
subplot(2,1,2);
plot(assist.coad.chA.R.cxs.x,mean(assist.coad.chA.R.cxs.y([1 10],:),1),'-b.',...
   assist.coad.chA.R.cxs.x, HBB.subfiles{2}.subfileData, 'r.');
title('HBB Reverse');legend('Matlab','Edgar')
%%

figure; subplot(2,1,1);
plot(assist.coad.chA.F.cxs.x,mean(assist.coad.chA.F.cxs.y([3],:),1),'-b.',...
   assist.coad.chA.F.cxs.x,Sky.subfiles{1}.subfileData, 'r.');
title('SKY Forward');legend('Matlab','Edgar')
subplot(2,1,2);
plot(assist.coad.chA.R.cxs.x,mean(assist.coad.chA.R.cxs.y([3],:),1),'-b.',...
   assist.coad.chA.R.cxs.x, Sky.subfiles{2}.subfileData, 'r.');
title('SKY Reverse');legend('Matlab','Edgar')

%%
%%
figure; subplot(2,1,1);
plot([1:length(assist.coad.chA.F.y)],mean(assist.coad.chA.F.cxs.y([2 9],:),1)-ABB.subfiles{1}.subfileData, 'r.');
legend('Forward');
subplot(2,1,2);
plot([1:length(assist.coad.chA.F.y)],mean(assist.coad.chA.R.cxs.y([2 9],:),1)-ABB.subfiles{2}.subfileData, 'r.');
legend('Reverse');

%%
%%
figure; subplot(2,1,1);
plot([1:length(assist.coad.chB.mrad.F.y)],mean(assist.coad.chB.mrad.F.y([3],:),1)-ABB.subfiles{1}.subfileData, 'r.');
legend('Forward');
subplot(2,1,2);
plot([1:length(assist.coad.chB.mrad.F.y)],mean(assist.coad.chB.mrad.R.y([3],:),1)-ABB.subfiles{2}.subfileData, 'r.');
legend('Reverse')


%%
figure; 
ifs(1) = subplot(2,2,1); 
plot([1:length(assist.coad.chA.F.y)],assist.coad.chA.F.y(1,:), '.r-',...
   [1:length(proc_A_mat.subfiles{1}.subfileData)], proc_A_mat.subfiles{1}.subfileData, '.b-');
ifs(2) = subplot(2,2,2); 
plot([1:length(assist.coad.chA.F.y)],mean(assist.coad.chA.F.y([2 9],:),1)-proc_A_mat.subfiles{1}.subfileData, 'r.');
ifs(3) = subplot(2,2,3); 
plot([1:length(assist.coad.chB.F.y)],assist.coad.chB.F.y(9,:), '.r-',...
   [1:length(proc_B_mat.subfiles{1}.subfileData)], proc_B_mat.subfiles{1}.subfileData, '.b-');
ifs(4) = subplot(2,2,4); 
plot([1:length(assist.coad.chB.F.y)],mean(assist.coad.chB.F.y([2 9],:),1)-proc_B_mat.subfiles{1}.subfileData, 'r.');
linkaxes(ifs,'x')
% checking HC_HBB
% F.y(1,:) matches subfile{1}
% R.y(1,:) matches subfile{2}
% checking HC_ABB
% F.y(2,:) matches subfile{1}
% R.y(2,:) matches subfile{2}
% checking CH_HBB
% F.y(10,:) matches subfile{1}
% R.y(10,:) matches subfile{2}
% checking CH_ABB
% F.y(9,:) matches subfile{1}
% R.y(9,:) matches subfile{2}

% checking HBB.coad.coad
% mean(F.y([1 10],:),1) matches subfile{1}
% mean(R.y([1 10],:),1) matches subfile{2}

% checking ABB.coad.coad
% mean(F.y([2 9],:),1) matches subfile{1}
% mean(R.y([2 9],:),1) matches subfile{2}


%%

assist = rad_cal_def_nlc(assist);

%Apply radiance calibration to cxs spectra

assist.chA.rad.x = assist.chA.cxs.x;
assist.chA.rad.y = NaN(size(assist.chA.cxs.y));
assist.chA.nlc.rad.x = assist.chA.cxs.x;
assist.chA.nlc.rad.y = NaN(size(assist.chA.cxs.y));

assist.chB.rad.x = assist.chB.cxs.x;
assist.chB.rad.y = NaN(size(assist.chB.cxs.y));

in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.F,:);
% out_spec = RadiometricCalibration_(in_spec, assist.chA.cal_F);
out_spec = RadiometricCalibration(in_spec, assist.chA.cal_F);
assist.chA.rad.y(assist.logi.F,:)= out_spec.y;
in_spec.y = assist.chA.cxs.y(assist.logi.R,:);
% out_spec = RadiometricCalibration_(in_spec, assist.chA.cal_R);
out_spec = RadiometricCalibration(in_spec, assist.chA.cal_R);
assist.chA.rad.y(assist.logi.R,:)= out_spec.y;
%%

%%
in_spec.x = assist.chA.nlc.x;
in_spec.y = assist.chA.nlc.y(assist.logi.F,:);
out_spec = RadiometricCalibration_(in_spec, assist.chA.nlc.cal_F);
assist.chA.nlc.rad.y(assist.logi.F,:)= out_spec.y;
in_spec.y = assist.chA.nlc.y(assist.logi.R,:);
out_spec = RadiometricCalibration_(in_spec, assist.chA.nlc.cal_R);
assist.chA.nlc.rad.y(assist.logi.R,:)= out_spec.y;

in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.F,:);
out_spec = RadiometricCalibration_(in_spec, assist.chB.cal_F);
assist.chB.rad.y(assist.logi.F,:)= out_spec.y;
in_spec.y = assist.chB.cxs.y(assist.logi.R,:);
out_spec = RadiometricCalibration_(in_spec, assist.chB.cal_R);
assist.chB.rad.y(assist.logi.R,:)= out_spec.y;

% downsample to N mono-directional scans
N = 6; % downsample over 6 
%%
[rows,cols]= size(assist.time);
retime = zeros([2.*N.*rows,cols./(2.*N)]);
retime(:) = assist.time;
%%
   % retime = 
assist.down.time = retime(1,:);
assist.down.isSky = downsample(assist.logi.Sky,2.*N)>0;
assist.down.Sky_ii = find(assist.down.isSky);
assist.down.chA.mrad.x = assist.chA.rad.x;
assist.down.chA.mrad.F = downsample(assist.chA.rad.y(assist.logi.F,:),N);
assist.down.chA.mrad.R = downsample(assist.chA.rad.y(assist.logi.R,:),N);
assist.down.chA.mrad.y = (assist.down.chA.mrad.F + assist.down.chA.mrad.R)./2;
%%
assist.down.chA.nlc.mrad.x = assist.chA.nlc.rad.x;
assist.down.chA.nlc.mrad.F = downsample(assist.chA.nlc.rad.y(assist.logi.F,:),N);
assist.down.chA.nlc.mrad.R = downsample(assist.chA.nlc.rad.y(assist.logi.R,:),N);
assist.down.chA.nlc.mrad.y = (assist.down.chA.nlc.mrad.F + assist.down.chA.nlc.mrad.R)./2;
%%
assist.down.chB.mrad.x = assist.chB.rad.x;
assist.down.chB.mrad.F = downsample(assist.chB.rad.y(assist.logi.F,:),N);
assist.down.chB.mrad.R = downsample(assist.chB.rad.y(assist.logi.R,:),N);
assist.down.chB.mrad.y = (assist.down.chB.mrad.F + assist.down.chB.mrad.R)./2;
%%
figure; ix(1) = subplot(2,1,1);
plot(assist.down.chA.mrad.x, assist.down.chA.mrad.y(3,:), '-r.',...
   assist.coad.chA.mrad.x,  assist.coad.chA.mrad.y(3,:), '-k.');
legend('fft before coad', 'coad before fft')
ylabel('radiance');
title('ch A')
ix(2) = subplot(2,1,2);
plot(assist.down.chA.mrad.x, assist.down.chA.mrad.y(3,:)- assist.coad.chA.mrad.y(3,:), '-r.');
title('fft before - coad before')
xlabel('wavenumber');
ylabel('radiance');
linkaxes(ix,'x');
figure; iix(1) = subplot(2,1,1);
plot(assist.down.chB.mrad.x, assist.down.chB.mrad.y(3,:), '-r.',...
   assist.coad.chB.mrad.x,  assist.coad.chB.mrad.y(3,:), '-k.');
ylabel('radiance');
legend('fft before coad', 'coad before fft')
title('ch B')
iix(2) = subplot(2,1,2);
plot(assist.down.chB.mrad.x, assist.down.chB.mrad.y(3,:)- assist.coad.chB.mrad.y(3,:), '-r.');
xlabel('wavenumber');
ylabel('radiance');
title('fft before - coad before')
linkaxes(iix,'x');
%%
figure; plot(assist.down.chA.mrad.x, [assist.down.chA.mrad.F(assist.down.Sky_ii(1),:);...
   assist.down.chA.mrad.R(assist.down.Sky_ii(1),:)],'.',...
   assist.down.chA.mrad.x,assist.down.chA.mrad.y(assist.down.Sky_ii(1),:),'-');
title('no NLC')
figure; plot(assist.down.chA.nlc.mrad.x, [assist.down.chA.nlc.mrad.F(assist.down.Sky_ii(1),:);...
   assist.down.chA.nlc.mrad.R(assist.down.Sky_ii(1),:)],'.',...
   assist.down.chA.nlc.mrad.x,assist.down.chA.nlc.mrad.y(assist.down.Sky_ii(1),:),'-')
title('with NLC')


% Compute brightness temperatures
assist.down.chA.mrad.Tb = BrightnessTemperature(assist.down.chA.mrad.x, assist.down.chA.mrad.y);
assist.down.chA.nlc.mrad.Tb = BrightnessTemperature(assist.down.chA.nlc.mrad.x, assist.down.chA.nlc.mrad.y);
assist.down.chB.mrad.Tb = BrightnessTemperature(assist.down.chB.mrad.x, assist.down.chB.mrad.y);



assist.chA.good_wn = assist.chA.rad.x>500 &assist.chA.rad.x<1800;
assist.chB.good_wn = assist.chB.rad.x>1700 &assist.chB.rad.x<3000;
%%
figure;  
ax(1) = subplot(2,1,1); 
plot(assist.chA.rad.x(assist.chA.good_wn), assist.chA.rad.y(assist.logi.F&assist.logi.Sky,assist.chA.good_wn),'r-',...
   assist.chA.rad.x(assist.chA.good_wn), assist.chA.nlc.rad.y(assist.logi.F&assist.logi.Sky,assist.chA.good_wn),'k-');
title('Difference in ASSIST ch A spectra from nonlinear correction');
ylabel('radiance [mW(m^2 sr cm^-1)]');
xlim([600,1600]);
ylim([-10,200]);
tx1 = text(1400,155,'raw');
tx2 = text(1400, 130,'nlc');

set(tx1,'color','r','units','normalized','fontweight','demi','fontname','tahoma','fontsize',10)
set(tx2,'color','k','units','normalized','fontweight','demi','fontname','tahoma','fontsize',10)

ax(2) = subplot(2,1,2); 
plot(assist.chA.rad.x(assist.chA.good_wn), assist.chA.rad.y(assist.logi.F&assist.logi.Sky,assist.chA.good_wn)- ...
   assist.chA.nlc.rad.y(assist.logi.F&assist.logi.Sky,assist.chA.good_wn),'r-');
tl = title({['raw - nlc:  a2 = ',a2_str, ' ,HBB offset = ',num2str(HBB_off), ' ,ABB offset = ',num2str(ABB_off)]})
set(tl,'fontname','tahoma')
ylabel('radiance [mW(m^2 sr cm^-1)]');
xlabel('wavenumber [1/cm]');
linkaxes(ax,'x');zoom('on')
%% difference in brightness temperatures with and without NLC
figure;  
ax(1) = subplot(2,1,1); 
plot(assist.down.chA.mrad.x(assist.chA.good_wn),assist.down.chA.mrad.Tb(assist.down.isSky,assist.chA.good_wn),'r-',...
   assist.down.chA.nlc.mrad.x(assist.chA.good_wn), assist.down.chA.nlc.mrad.Tb(assist.down.isSky,assist.chA.good_wn),'k-');
title('Difference in ASSIST ch A brightness temperatures from nonlinear correction');
ylabel('T_b');
xlabel('wavenumber [1/cm]');
xlim([600,1600]);
% ylim([-10,200]);
% tx1 = text(1400,155,'raw');
% tx2 = text(1400, 130,'nlc');

set(tx1,'color','r','units','normalized','fontweight','demi','fontname','tahoma','fontsize',10)
set(tx2,'color','k','units','normalized','fontweight','demi','fontname','tahoma','fontsize',10)

ax(2) = subplot(2,1,2); 
plot(assist.down.chA.mrad.x(assist.chA.good_wn), assist.down.chA.mrad.Tb(assist.down.isSky,assist.chA.good_wn)- ...
   assist.down.chA.nlc.mrad.Tb(assist.down.isSky,assist.chA.good_wn),'r-');
title('raw - nlc')
ylabel('T_b');
xlabel('wavenumber [1/cm]');
linkaxes(ax,'x');zoom('on')
% ylim('auto');
%%
% 
% figure;  ax(1) = subplot(3,1,1); 
% semilogy(assist.chB.rad.x(assist.chB.good_wn), assist.chB.rad.y(assist.logi.F&assist.logi.Sky,assist.chB.good_wn),'-');
% title('Ch B, forward scans')
% ax(2) = subplot(3,1,2); 
% semilogy(assist.down.chB.mrad.x(assist.chB.good_wn), assist.down.chB.mrad.F(assist.down.isSky,assist.chB.good_wn),'-');
% ax(3) = subplot(3,1,3); 
% semilogy(assist.down.chB.mrad.x(assist.chB.good_wn), assist.down.chB.mrad.y(assist.down.isSky,assist.chB.good_wn),'-');
% 
% linkaxes(ax,'xy');zoom('on')
% ylim('auto');

%%
%%
% Next, check against Luc's calibration
%%
while ~exist('andre_dir','var')||~exist(pname, 'dir')
   andre_dir = getdir([],'edgar');
end

% andre_dir = ['C:\case_studies\assist\integration\data_integration\remote_SGP\processedData\2010_06_18\R50_02_13_53\'];
A_file = dir([andre_dir,filesep,'*chA_SKY1*.mat']);
proc_A_mat = loadinto([andre_dir, A_file(1).name]);
B_file = dir([andre_dir,filesep,'*chB_SKY1*.mat']);
proc_B_mat = loadinto([andre_dir, B_file(1).name]);

%%
andre_wn_offset = 0;

%%

nbPoints = proc_A_mat.mainHeaderBlock.nbPoints;
proc_A_mat.x = linspace(proc_A_mat.mainHeaderBlock.firstX, proc_A_mat.mainHeaderBlock.lastX, double(nbPoints)); 
proc_A_mat.good_wn = proc_A_mat.x>525 & proc_A_mat.x<1800;
proc_A_mat.Tb = BrightnessTemperature(proc_A_mat.x, 1000*proc_A_mat.subfiles{1}.subfileData);

nbPoints = proc_B_mat.mainHeaderBlock.nbPoints;
proc_B_mat.x = linspace(proc_B_mat.mainHeaderBlock.firstX, proc_B_mat.mainHeaderBlock.lastX, double(nbPoints)); 
proc_B_mat.good_wn = proc_B_mat.x>1700 & proc_B_mat.x<3000;
proc_B_mat.Tb = BrightnessTemperature(proc_B_mat.x, 1000*proc_B_mat.subfiles{1}.subfileData);

% andre_wn_offset = (proc_B_mat.x(2)-proc_B_mat.x(1))./2
%%
figure;
plot(proc_A_mat.x(proc_A_mat.good_wn)-andre_wn_offset, 1000*proc_A_mat.subfiles{1}.subfileData(proc_A_mat.good_wn),'k.',...
   proc_B_mat.x(proc_B_mat.good_wn)-andre_wn_offset,1000*proc_B_mat.subfiles{1}.subfileData(proc_B_mat.good_wn),'k+',...
   assist.down.chA.mrad.x(assist.chA.good_wn), assist.down.chA.nlc.mrad.y(assist.down.Sky_ii(1),assist.chA.good_wn),'r.',...
   assist.down.chB.mrad.x(assist.chB.good_wn), assist.down.chB.mrad.y(assist.down.Sky_ii(1),assist.chB.good_wn),'r+');
   legend('Andre A','Andre B','Flynn A','Flynn B');
   ylabel('radiance');
   xlabel('wavenumber');
   %%
 figure
   an(1) = subplot(2,1,1);
plot(proc_A_mat.x, 1000*proc_A_mat.subfiles{1}.subfileData,'k.',...
   assist.down.chA.mrad.x, assist.down.chA.nlc.mrad.y(assist.down.Sky_ii(1),:),'r.');
   legend('Andre A','Flynn A');
   title('Edgar and Flynn differences, ch A')
   ylabel('radiance');
   xlabel('wavenumber');
an(2) = subplot(2,1,2);
plot(proc_A_mat.x, 1000*proc_A_mat.subfiles{1}.subfileData - assist.down.chA.nlc.mrad.y(assist.down.Sky_ii(1),:),'r.');
   legend('Andre - Flynn A');
   ylabel('radiance');
   xlabel('wavenumber');
   linkaxes(an,'x')
   xlim([575,1725])
   %%
   figure; plot(assist.chA.cal_F.x,assist.chA.cal_F.Offset,'b-',...
      assist.chA.cal_R.x,assist.chA.cal_R.Offset,'g-',...
      assist.chB.cal_F.x,assist.chB.cal_F.Offset,'r-',...
      assist.chB.cal_R.x,assist.chB.cal_R.Offset,'k-') ;
   title('calibration offset')
   legend('chA F','chA R','chB F','chB R')
   a12(3) = gca;
      figure; a12(1) = subplot(2,1,1);
      plot(assist.chA.cal_F.x,assist.chA.cal_F.Gain,'b-',...
      assist.chA.cal_R.x,assist.chA.cal_R.Gain,'g-');
   title('calibration gains ch A')
   legend('chA F','chA R')
   a12(2) = subplot(2,1,2);
   plot(assist.chB.cal_F.x,assist.chB.cal_F.Gain,'r-',...
      assist.chB.cal_R.x,assist.chB.cal_R.Gain,'k-') ;
   title('calibration gains ch B');
   legend('chB F','chB R')
   linkaxes(a12,'x')
   %%
 figure
   bn(1) = subplot(2,1,1);
plot(proc_B_mat.x, 1000*proc_B_mat.subfiles{1}.subfileData,'k.',...
   assist.down.chB.mrad.x, assist.down.chB.mrad.y(assist.down.Sky_ii(1),:),'r.');
   title('Edgar and Flynn differences, ch B')
   legend('Andre B','Flynn B');
   ylabel('radiance');
   xlabel('wavenumber');
bn(2) = subplot(2,1,2);
plot(proc_B_mat.x, 1000*proc_B_mat.subfiles{1}.subfileData - assist.down.chB.mrad.y(assist.down.Sky_ii(1),:),'r.');
   legend('Andre - Flynn B');
   ylabel('radiance');
   xlabel('wavenumber');
   linkaxes(bn,'x');
   xlim([1800,3000]);
   
   %%
figure;
plot(proc_A_mat.x(proc_A_mat.good_wn)-andre_wn_offset, proc_A_mat.Tb(proc_A_mat.good_wn),'k.',...
   proc_B_mat.x(proc_B_mat.good_wn)-andre_wn_offset,proc_B_mat.Tb(proc_B_mat.good_wn),'k+',...
   assist.down.chA.mrad.x(assist.chA.good_wn), assist.down.chA.nlc.mrad.Tb(assist.down.Sky_ii(1),assist.chA.good_wn),'r.',...
   assist.down.chB.mrad.x(assist.chB.good_wn), assist.down.chB.mrad.Tb(assist.down.Sky_ii(1),assist.chB.good_wn),'r+');
   legend('Andre A','Andre B','Flynn A','Flynn B');
   ylabel('T_b [K]');
   xlabel('wavenumber');

   %%
   figure;
s1 = subplot(2,1,1) 
plot(proc_A_mat.x(proc_A_mat.good_wn)-andre_wn_offset, 1000*proc_A_mat.subfiles{1}.subfileData(proc_A_mat.good_wn),'k.',...
   proc_B_mat.x(proc_B_mat.good_wn)-andre_wn_offset,1000*proc_B_mat.subfiles{1}.subfileData(proc_B_mat.good_wn),'k+');
title('Andre');
s2 = subplot(2,1,2);
plot(assist.down.chA.mrad.x(assist.chA.good_wn), assist.down.chA.nlc.mrad.y(assist.down.Sky_ii(1),assist.chA.good_wn),'r.',...
   assist.down.chB.mrad.x(assist.chB.good_wn), assist.down.chB.mrad.y(assist.down.Sky_ii(1),assist.chB.good_wn),'r+');
title('Connor')
linkaxes([s1,s2],'xy')
%%
xl = xlim;
and_xl =  proc_B_mat.x>=xl(1) & proc_B_mat.x<=xl(2);
and_peak =find(proc_B_mat.subfiles{1}.subfileData == max(proc_B_mat.subfiles{1}.subfileData(and_xl)))
asst_xl =  assist.down.chB.mrad.x>=xl(1) & assist.down.chB.mrad.x<=xl(2);
asst_peak =find(assist.down.chB.mrad.y(assist.down.Sky_ii(1),:) == max(assist.down.chB.mrad.y(assist.down.Sky_ii(1),asst_xl)))
assist.down.chB.mrad.y(assist.down.Sky_ii(1),asst_peak)
andre_wn_offset = [proc_B_mat.x(and_peak)-assist.down.chB.mrad.x(asst_peak)]

%%
   %% Now compare to AERI
   aeri_pname = ['C:\case_studies\assist\integration\data_integration\at_SGP\aeri_data\hourly\'];
dstr = datestr(assist.down.time(1),'yyyymmdd.HH');
tmp = dir([aeri_pname,'sgpaerich1E14.b1.',dstr,'*.cdf']);
aeri_ch1 = ancload([aeri_pname,tmp(1).name]);
tmp = dir([aeri_pname,'sgpaerich2E14.b1.',dstr,'*.cdf']);
aeri_ch2 = ancload([aeri_pname,tmp(1).name]);
%%
aeri_ch2.good_wn = aeri_ch1.vars.wnum.data>500 &aeri_ch1.vars.wnum.data<1800;
[ainb, bina] = nearest(aeri_ch1.time, assist.down.time(assist.down.isSky));
%%
andre_wn_offset = 0;

andre_chA_on_aeri_wn = interp1(proc_A_mat.x(proc_A_mat.good_wn)-andre_wn_offset,1000*proc_A_mat.subfiles{1}.subfileData(proc_A_mat.good_wn)',aeri_ch1.vars.wnum.data,'linear');
andre_chB_on_aeri_wn = interp1(proc_B_mat.x(proc_B_mat.good_wn)-andre_wn_offset,1000*proc_B_mat.subfiles{1}.subfileData(proc_B_mat.good_wn)',aeri_ch2.vars.wnum.data,'linear');

assist_chA_on_aeri_wn = interp1(assist.down.chA.mrad.x(assist.chA.good_wn),assist.down.chA.nlc.mrad.y(:,assist.chA.good_wn)',aeri_ch1.vars.wnum.data,'linear');
assist_chB_on_aeri_wn = interp1(assist.down.chB.mrad.x(assist.chB.good_wn),assist.down.chB.mrad.y(:,assist.chB.good_wn)',aeri_ch2.vars.wnum.data,'linear');
figure; 
plot(aeri_ch1.vars.wnum.data, aeri_ch1.vars.mean_rad.data(:,ainb(1)), 'k-',...
   assist.down.chA.mrad.x(assist.chA.good_wn),assist.down.chA.mrad.y(assist.down.Sky_ii(bina(1)),assist.chA.good_wn),'-r',...
   assist.down.chA.mrad.x(assist.chA.good_wn),assist.down.chA.nlc.mrad.y(assist.down.Sky_ii(bina(1)),assist.chA.good_wn),'-g',...
aeri_ch1.vars.wnum.data, aeri_ch1.vars.mean_rad.data(:,ainb), 'k-',...
   assist.down.chA.mrad.x(assist.chA.good_wn),assist.down.chA.mrad.y(assist.down.Sky_ii(bina),assist.chA.good_wn),'-r',...
   assist.down.chA.mrad.x(assist.chA.good_wn),assist.down.chA.nlc.mrad.y(assist.down.Sky_ii(bina),assist.chA.good_wn),'-g',...
   aeri_ch2.vars.wnum.data, aeri_ch2.vars.mean_rad.data(:,ainb), '.k-',...
assist.down.chB.mrad.x(assist.chB.good_wn),assist.down.chB.mrad.y(assist.down.Sky_ii(bina),assist.chB.good_wn),'-r.');

% semilogy(aeri_ch1.vars.wnum.data, aeri_ch1.vars.mean_rad.data(:,ainb), '.k-',...
%    assist.down.chA.mrad.x(assist.chA.good_wn),assist.down.chA.mrad.y(assist.down.Sky_ii(bina),assist.chA.good_wn),'-r.',...
%    proc_A_mat.x(proc_A_mat.good_wn)-andre_wn_offset,1000*proc_A_mat.subfiles{1}.subfileData(proc_A_mat.good_wn),'-g.',...
% aeri_ch2.vars.wnum.data, aeri_ch2.vars.mean_rad.data(:,ainb), '.k-',...
% assist.down.chB.mrad.x(assist.chB.good_wn),assist.down.chB.mrad.y(assist.down.Sky_ii(bina),assist.chB.good_wn),'-r.',...
% proc_B_mat.x(proc_B_mat.good_wn)-andre_wn_offset,1000*proc_B_mat.subfiles{1}.subfileData(proc_B_mat.good_wn),'-g.');
tl=title({['AERI E14 and ASSIST comparison:',datestr(aeri_ch1.time(ainb(1)),'yyyy-mm-dd HH:MM')];...
['a2=',a2_str, ' HBB offset=',num2str(HBB_off), ' ABB offset=',num2str(ABB_off)]})
set(tl,'fontname','tahoma');
xlabel('wavenumber [1/cm]');
ylabel('radiance [mW(m^2 sr cm^-1)]');
xlim([600,2500]);
yl = ylim;
ylim([0,180])
legend('AERI','ASSIST raw','ASSIST nlc');
grid('on');
lin1 = line(xlim,[0,0],'color','k');
set(lin1,'color','k','linestyle','--','linewidth',2)
 v = axis;
 fig_ls = dir([assist.pname,'AERI_ASSIST_nlc.*.fig']);
 n = length(fig_ls)+1;
 saveas(gcf,[assist.pname,'AERI_ASSIST_nlc.',num2str(n),'.fig' ],'fig')
% %%
% m = menu('zoom in to select a peak to fit over then select OK','OK')
% xl = xlim;
% aeri_x = aeri_ch1.vars.wnum.data> xl(1) & aeri_ch1.vars.wnum.data<xl(2);
% assist_x =assist.down.chA.mrad.x>xl(1) & assist.down.chA.mrad.x< xl(2);
% [aeri_P_hat,aeri_S,aeri_mu] = polyfit(aeri_ch1.vars.wnum.data(aeri_x),aeri_ch1.vars.mean_rad.data(aeri_x,ainb(1)),2);
% aeri_P_hat_prime = [2.*aeri_P_hat(1), aeri_P_hat(2)];
% xhat_root = roots(aeri_P_hat_prime);
% aeri_root = xhat_root.*aeri_mu(2) + aeri_mu(1);
% [assist_P_hat,assist_S,assist_mu] = polyfit(assist.down.chA.mrad.x(assist_x),real(assist.down.chA.mrad.y(assist.down.Sky_ii(bina(1)),assist_x)),2);
% assist_P_hat_prime = [2.*assist_P_hat(1), assist_P_hat(2)];
% xhat_root = roots(assist_P_hat_prime);
% assist_root = xhat_root.*assist_mu(2) + assist_mu(1);
% rats = aeri_root./assist_root -1
% 
% %%
% m = menu('zoom in to select a peak to fit over then select OK','OK')
% xl = xlim;
% aeri_x = aeri_ch2.vars.wnum.data> xl(1) & aeri_ch2.vars.wnum.data<xl(2);
% assist_x =assist.down.chB.mrad.x>xl(1) & assist.down.chB.mrad.x< xl(2);
% [aeri_P_hat,aeri_S,aeri_mu] = polyfit(aeri_ch2.vars.wnum.data(aeri_x),aeri_ch2.vars.mean_rad.data(aeri_x,ainb(1)),2);
% aeri_P_hat_prime = [2.*aeri_P_hat(1), aeri_P_hat(2)];
% xhat_root = roots(aeri_P_hat_prime);
% aeri_root = xhat_root.*aeri_mu(2) + aeri_mu(1);
% [assist_P_hat,assist_S,assist_mu] = polyfit(assist.down.chB.mrad.x(assist_x),real(assist.down.chB.mrad.y(assist.down.Sky_ii(bina(1)),assist_x)),2);
% assist_P_hat_prime = [2.*assist_P_hat(1), assist_P_hat(2)];
% xhat_root = roots(assist_P_hat_prime);
% assist_root = xhat_root.*assist_mu(2) + assist_mu(1);
% rats = aeri_root./assist_root
%%
figure; 
ax1(1) = subplot(2,1,1);
plot(aeri_ch1.vars.wnum.data, aeri_ch1.vars.mean_rad.data(:,ainb(1)), 'r-',...
   aeri_ch1.vars.wnum.data,assist_chA_on_aeri_wn(:,assist.down.Sky_ii(bina(1))),'-k',...
   aeri_ch1.vars.wnum.data, aeri_ch1.vars.mean_rad.data(:,ainb), 'r-',...
   aeri_ch1.vars.wnum.data,assist_chA_on_aeri_wn(:,assist.down.Sky_ii(bina)),'-k',...
aeri_ch2.vars.wnum.data, aeri_ch2.vars.mean_rad.data(:,ainb), 'r-',...
aeri_ch2.vars.wnum.data,assist_chB_on_aeri_wn(:,assist.down.Sky_ii(bina)),'-k');
tl=title({['AERI E14 and ASSIST comparison:',datestr(aeri_ch1.time(ainb(1)),'yyyy-mm-dd HH:MM')];...
['a2 = ',sprintf('%1.4e',nlc.a2), ',HBB offset = ',num2str(HBB_off), ' ,ABB offset = ',num2str(ABB_off)]});
ylabel('mW(m^2 sr cm^-^1)');
xlim([600,3000]);
ylim([0,180])
legend('AERI','ASSIST nlc')


grid('on');
lin1 = line(xlim,[0,0],'color','k');
set(lin1,'color','k','linestyle','--','linewidth',2)

ax1(2) = subplot(2,1,2);
plot(aeri_ch1.vars.wnum.data, aeri_ch1.vars.mean_rad.data(:,ainb)-assist_chA_on_aeri_wn(:,assist.down.Sky_ii(bina)),'-r',...
aeri_ch2.vars.wnum.data, aeri_ch2.vars.mean_rad.data(:,ainb)-assist_chB_on_aeri_wn(:,assist.down.Sky_ii(bina)),'-r');
title(['difference (AERI E14 - ASSIST)']);
xlabel('wavenumber [1/cm]');
ylabel('radiance');
xlim([600,3000]);
ylim('auto')
grid('on');
lin1 = line(xlim,[0,0],'color','k');
set(lin1,'color','k','linestyle','--','linewidth',2)
linkaxes(ax1,'x');
xlim([600    1400]);
ylim([-4,9]);
 fig_ls = dir([assist.pname,'AERI_ASSIST_diff_liny.*.fig']);
 n = length(fig_ls)+1;
saveas(gcf,[assist.pname,'AERI_ASSIST_diff_liny.',num2str(n),'.fig' ],'fig');
axes(ax1(1));logy;


 saveas(gcf,[assist.pname,'AERI_ASSIST_diff_logy.',num2str(n),'.fig' ],'fig');
 
%%
wl = aeri_ch1.vars.wnum.data>600 & aeri_ch1.vars.wnum.data<1350;
wl2 = assist.down.chA.mrad.x>600 & assist.down.chA.mrad.x<1350;

trapz(aeri_ch1.vars.wnum.data(wl), aeri_ch1.vars.mean_rad.data(wl,ainb(1)))
trapz(assist.down.chA.mrad.x(wl2),assist.down.chA.mrad.y(assist.down.Sky_ii(bina(1)),wl2))
trapz(assist.down.chA.nlc.mrad.x(wl2),assist.down.chA.nlc.mrad.y(assist.down.Sky_ii(bina(1)),wl2))
%%
wlb = aeri_ch2.vars.wnum.data>2000 & aeri_ch2.vars.wnum.data<2180;
wlb2 = assist.down.chB.mrad.x>2000 & assist.down.chB.mrad.x<2180;

trapz(aeri_ch2.vars.wnum.data(wlb), aeri_ch2.vars.mean_rad.data(wlb,ainb(1)))
trapz(assist.down.chB.mrad.x(wlb2),assist.down.chB.mrad.y(assist.down.Sky_ii(bina(1)),wlb2))
%%

return

function lab = legalize(lab)
lab = strrep(lab,' ','');
lab = strrep(lab,'-','');
lab = strrep(lab,'.','');
return

function mat = repack_edgar(edgar)
V = double([edgar.mainHeaderBlock.date.year,edgar.mainHeaderBlock.date.month,...
   edgar.mainHeaderBlock.date.day,edgar.mainHeaderBlock.date.hours,...
   edgar.mainHeaderBlock.date.minutes,edgar.mainHeaderBlock.date.seconds]);
nbPoints = edgar.mainHeaderBlock.nbPoints;
% xStep = (edgar.mainHeaderBlock.lastX-edgar.mainHeaderBlock.firstX)./(nbPoints-1);
mat.x = linspace(edgar.mainHeaderBlock.firstX, (edgar.mainHeaderBlock.lastX), double(nbPoints)); 
if isfield(edgar.mainHeaderBlock,'laser_wn')
mat.laser_wn = edgar.mainHeaderBlock.laser_wn;
end
base_time = datenum(V);
subs = length(edgar.subfiles);
for s = subs:-1:1
mat.time(s) = base_time +  double(edgar.subfiles{s}.subfileHeader.subStartingZ)./(24*60*60);
mat.flags(s) = edgar.subfiles{s}.subfileHeader.subFlags;
mat.coads(s) = edgar.subfiles{s}.subfileHeader.nbCoaddedScans;
mat.subIndex(s) = edgar.subfiles{s}.subfileHeader.subIndex;
mat.scanNb(s) = edgar.subfiles{s}.subfileHeader.scanNb;
mat.HBBRawTemp(s) = edgar.subfiles{s}.subfileHeader.subHBBRawTemp;
mat.CBBRawTemp(s) = edgar.subfiles{s}.subfileHeader.subCBBRawTemp;
if isfield(edgar.subfiles{s}.subfileHeader,'zpdLocation')
mat.zpdLocation(s) = edgar.subfiles{s}.subfileHeader.zpdLocation;
end
if isfield(edgar.subfiles{s}.subfileHeader,'zpdValue')
mat.zpdValue(s) = edgar.subfiles{s}.subfileHeader.zpdValue;
end
mat.y(s,:) = edgar.subfiles{s}.subfileData;
end
mat.flags = uint8(mat.flags);
return

function mat1 = stitch_mats(mat1, mat2)
time_len = length(mat1.time);
[~, ii] = sort([mat1.scanNb,mat2.scanNb]);
mat_fields = (fieldnames(mat1));

for f = length(mat_fields):-1:1
   jj = find(size(mat1.(mat_fields{f}))==time_len);
   if jj==1
      X = [mat1.(mat_fields{f});mat2.(mat_fields{f})];
      mat1.(mat_fields{f}) = X(ii,:);
   elseif jj==2
      X = [mat1.(mat_fields{f}),mat2.(mat_fields{f})];
      mat1.(mat_fields{f}) = X(ii);
   end
end

return

function assist = rad_cal_def1(assist)
% simplest, use mean temperatures and BB spectra over entire measurement
% compute cals from coadded spectra.
T_hot_F = mean(assist.HBB_C(assist.logi.HBB_F));
T_cold_F = mean(assist.ABB_C(assist.logi.ABB_F));
T_hot_R = mean(assist.HBB_C(assist.logi.HBB_R));
T_cold_R = mean(assist.ABB_C(assist.logi.ABB_R));

% Coad the mono-directional BB spectra to improve robustness of calibration
% Compute uncalibrated variance spectra of BB mono-scans
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.HBB_F,:);
HBB_F = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.HBB_R,:);
HBB_R = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.ABB_F,:);
ABB_F = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.ABB_R,:);
ABB_R = CoaddData(in_spec);

% assist.chA.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
% assist.chA.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
assist.chA.cal_F = CreateCalibrationFromCXS(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
assist.chA.cal_R = CreateCalibrationFromCXS(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.HBB_F,:);
HBB_F = CoaddData(in_spec);
 
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.HBB_R,:);
HBB_R = CoaddData(in_spec);
 
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.ABB_F,:);
ABB_F = CoaddData(in_spec);
 
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.ABB_R,:);
ABB_R = CoaddData(in_spec);

% assist.chB.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
% assist.chB.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
assist.chB.cal_F = CreateCalibrationFromCXS(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
assist.chB.cal_R = CreateCalibrationFromCXS(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
return

function assist = rad_cal_def2(assist)
% simplest, use mean temperatures and BB spectra over entire measurement
% Computes cals from coadded IFGs

assist.coad.isHBB = downsample(assist.logi.H(assist.logi.F)|assist.logi.H(assist.logi.R),6)>0;
assist.coad.isABB = downsample(assist.logi.A(assist.logi.F)|assist.logi.A(assist.logi.R),6)>0;
assist.coad.isSky = downsample(assist.logi.Sky(assist.logi.F)|assist.logi.Sky(assist.logi.R),6)>0;

% Ch A
assist.chA.F.y = assist.chA.y(assist.logi.F,:);
assist.chA.R.y = assist.chA.y(assist.logi.R,:);
assist.coad.chA.F.y = downsample(assist.chA.F.y,6);
assist.coad.chA.R.y = downsample(assist.chA.R.y,6);

inspec.x = assist.chA.x;
inspec.laser_wn = assist.chA.laser_wn;
inspec.zpd_loc = assist.chA.zpd_loc;

inspec.y = assist.coad.chA.F.y;
assist.coad.chA.F.cxs= RawIgm2RawSpc(inspec);
inspec.y = assist.coad.chA.R.y;
assist.coad.chA.R.cxs= RawIgm2RawSpc(inspec);


T_hot_F = mean(assist.HBB_C(assist.logi.HBB_F));
T_cold_F = mean(assist.ABB_C(assist.logi.ABB_F));
T_hot_R = mean(assist.HBB_C(assist.logi.HBB_R));
T_cold_R = mean(assist.ABB_C(assist.logi.ABB_R));

% Coad the mono-directional BB IFGs to improve robustness of calibration
HBB_F.x = assist.coad.chA.R.cxs.x;
HBB_F.y = mean(assist.coad.chA.F.cxs.y(assist.coad.isHBB,:));
HBB_R.x = assist.coad.chA.R.cxs.x;
HBB_R.y = mean(assist.coad.chA.R.cxs.y(assist.coad.isHBB,:));
ABB_F.x = assist.coad.chA.R.cxs.x;
ABB_F.y = mean(assist.coad.chA.F.cxs.y(assist.coad.isABB,:));
ABB_R.x = assist.coad.chA.R.cxs.x;
ABB_R.y = mean(assist.coad.chA.R.cxs.y(assist.coad.isABB,:));

assist.coad.chA.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
assist.coad.chA.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
assist.coad.chA.mrad.F = RadiometricCalibration_(assist.coad.chA.F.cxs, assist.coad.chA.cal_F);
assist.coad.chA.mrad.R = RadiometricCalibration_(assist.coad.chA.R.cxs, assist.coad.chA.cal_R);
assist.coad.chA.mrad.y = (assist.coad.chA.mrad.F.y + assist.coad.chA.mrad.R.y)./2;
assist.coad.chA.mrad.x = assist.coad.chA.mrad.F.x;

%ch B
assist.chB.F.y = assist.chB.y(assist.logi.F,:);
assist.chB.R.y = assist.chB.y(assist.logi.R,:);
assist.coad.chB.F.y = downsample(assist.chB.F.y,6);
assist.coad.chB.R.y = downsample(assist.chB.R.y,6);

inspec.x = assist.chB.x;
inspec.laser_wn = assist.chB.laser_wn;
inspec.zpd_loc = assist.chB.zpd_loc;

inspec.y = assist.coad.chB.F.y;
assist.coad.chB.F.cxs= RawIgm2RawSpc(inspec);
inspec.y = assist.coad.chB.R.y;
assist.coad.chB.R.cxs= RawIgm2RawSpc(inspec);


T_hot_F = mean(assist.HBB_C(assist.logi.HBB_F));
T_cold_F = mean(assist.ABB_C(assist.logi.ABB_F));
T_hot_R = mean(assist.HBB_C(assist.logi.HBB_R));
T_cold_R = mean(assist.ABB_C(assist.logi.ABB_R));

% Coad the mono-directional BB IFGs to improve robustness of calibration
HBB_F.x = assist.coad.chB.R.cxs.x;
HBB_F.y = mean(assist.coad.chB.F.cxs.y(assist.coad.isHBB,:));
HBB_R.x = assist.coad.chB.R.cxs.x;
HBB_R.y = mean(assist.coad.chB.R.cxs.y(assist.coad.isHBB,:));
ABB_F.x = assist.coad.chB.R.cxs.x;
ABB_F.y = mean(assist.coad.chB.F.cxs.y(assist.coad.isABB,:));
ABB_R.x = assist.coad.chB.R.cxs.x;
ABB_R.y = mean(assist.coad.chB.R.cxs.y(assist.coad.isABB,:));

assist.coad.chB.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
assist.coad.chB.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
assist.coad.chB.mrad.F = RadiometricCalibration_(assist.coad.chB.F.cxs, assist.coad.chB.cal_F);
assist.coad.chB.mrad.R = RadiometricCalibration_(assist.coad.chB.R.cxs, assist.coad.chB.cal_R);
assist.coad.chB.mrad.y = (assist.coad.chB.mrad.F.y + assist.coad.chB.mrad.R.y)./2;
assist.coad.chB.mrad.x = assist.coad.chB.mrad.F.x;
return %from cal_rad_def2

function assist = rad_cal_def_nlc(assist)
% simplest, use mean temperatures and BB spectra over entire measurement
T_hot_F = mean(assist.HBB_C(assist.logi.HBB_F));
T_cold_F = mean(assist.ABB_C(assist.logi.ABB_F));
T_hot_R = mean(assist.HBB_C(assist.logi.HBB_R));
T_cold_R = mean(assist.ABB_C(assist.logi.ABB_R));

% Coad the mono-directional BB spectra to improve robustness of calibration
% Compute uncalibrated variance spectra of BB mono-scans
in_spec.x = assist.chA.nlc.x;
in_spec.y = assist.chA.nlc.y(assist.logi.HBB_F,:);
HBB_F = CoaddData(in_spec);
 
in_spec.x = assist.chA.nlc.x;
in_spec.y = assist.chA.nlc.y(assist.logi.HBB_R,:);
HBB_R = CoaddData(in_spec);
 
in_spec.x = assist.chA.nlc.x;
in_spec.y = assist.chA.nlc.y(assist.logi.ABB_F,:);
ABB_F = CoaddData(in_spec);
 
in_spec.x = assist.chA.nlc.x;
in_spec.y = assist.chA.nlc.y(assist.logi.ABB_R,:);
ABB_R = CoaddData(in_spec);

assist.chA.nlc.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
assist.chA.nlc.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
