function assist = assist_annew_2(pname)% ASSIST annew
% Assess difference between circ shift and reflect shift
% Looking at even reflection yielding an igram of even length.
      
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

assist.F = select_scan_dir(assist,logi.F);
  assist.R = select_scan_dir(assist,logi.R);
  
[zpd_loc,zpd_mag] = find_zpd_edgar(assist.F.chA); zpd_loc = mode(zpd_loc);
  zpd_shift_F = length(assist.F.chA.x)./2 +1 - zpd_loc;
[zpd_loc,zpd_mag] = find_zpd_edgar(assist.R.chA); zpd_loc = mode(zpd_loc);
  zpd_shift_R = length(assist.R.chA.x)./2 +1 - zpd_loc -1;

Laser_wl = 632.8e-7;

circshifted.F.y = fftshift(zpd_circshift(assist.F.chA.x,assist.F.chA.y,zpd_shift_F));
circshifted.R.y = fftshift(zpd_circshift(assist.R.chA.x,assist.R.chA.y,zpd_shift_R));

evenshifted.F.y = fftshift(zpd_reflect_even(assist.F.chA.x,assist.F.chA.y,zpd_shift_F)); 
evenshifted.R.y = fftshift(zpd_reflect_even(assist.R.chA.x,assist.R.chA.y,zpd_shift_R)); 


%%


figure(1);
ax(1) = subplot(2,1,1);
plot(assist.F.chA.x, [assist.F.chA.y(1,:);assist.R.chA.y(1,:)],'-');
legend('forward','reverse')
title('raw unshifted igrams')

ax(2) = subplot(2,1,2);
% plot(assist.F.chA.x, [circshifted.F.y(1,:);fliplr(circshifted.R.y(1,:));circshifted.M.y(1,:)],'-');
% legend('forward','reverse','merged')
plot(assist.F.chA.x, [circshifted.F.y(1,:)-evenshifted.F.y(1,:);fliplr(circshifted.R.y(1,:))-fliplr(evenshifted.R.y(1,:))],'-');

legend(['forward shifted: ',num2str(zpd_shift_F)],['reverse shift: ',num2str(zpd_shift_R)]);
title('Difference between circ-shifted and reflected igrams')
linkaxes(ax,'x')
%%
assist.chA.cxs.x = fftshift(assist.F.chA.x/Laser_wl/length(assist.F.chA.x));

chA_good = assist.chA.cxs.x>550 & assist.chA.cxs.x<1625;
assist_even = assist;
assist.F.chA.cxs.y = fft(zpd_circshift(assist.F.chA.x,assist.F.chA.y,zpd_shift_F),[],2);
assist.R.chA.cxs.y = fft(zpd_circshift(assist.R.chA.x,assist.R.chA.y,zpd_shift_R),[],2);
assist_even.F.chA.cxs.y = fft(zpd_reflect_even(assist.F.chA.x,assist.F.chA.y,zpd_shift_F),[],2);
assist_even.R.chA.cxs.y = fft(zpd_reflect_even(assist.R.chA.x,assist.R.chA.y,zpd_shift_R),[],2);
%%
figure(2); 

s1(1) = subplot(3,1,1);
plot(assist.chA.cxs.x(chA_good), real(assist.F.chA.cxs.y(1,chA_good)), 'r',...
   assist_even.chA.cxs.x(chA_good), real(assist_even.F.chA.cxs.y(1,chA_good)), 'g',...
   assist.chA.cxs.x(chA_good),imag(assist.F.chA.cxs.y(1,chA_good)),'c',...
   assist_even.chA.cxs.x(chA_good),imag(assist_even.F.chA.cxs.y(1,chA_good)),'b');
title('Raw spectra from shifted igrams: circular, even and odd reflections');
ylabel('raw cts')
legend('real circ','real even','imag circ','imag even');
s1(2) = subplot(3,1,2); 
plot(assist.chA.cxs.x(chA_good), 100.*(real(assist.F.chA.cxs.y(1,chA_good)) - ...
   real(assist_even.F.chA.cxs.y(1,chA_good)))./abs(real(assist.F.chA.cxs.y(1,chA_good))), 'r',...
   assist.chA.cxs.x(chA_good),100.*(imag(assist.F.chA.cxs.y(1,chA_good)) - ...
   imag(assist_even.F.chA.cxs.y(1,chA_good)))./abs(real(assist.F.chA.cxs.y(1,chA_good))),'c');
legend('real % diff','imag % diff');
ylabel('%');
xlabel('wavenumber [1/cm]')
s1(3) = subplot(3,1,3); 
SN = 4;
plot(downsample(assist.chA.cxs.x(chA_good),SN), 100.*(downsample(real(assist.F.chA.cxs.y(1,chA_good)),SN) - ...
   downsample(real(assist_even.F.chA.cxs.y(1,chA_good)),SN))./abs(downsample(real(assist.F.chA.cxs.y(1,chA_good)),SN)), 'r');
legend('real % diff');
ylabel('%');
xlabel('wavenumber [downsampled to 4 cm-1]')
linkaxes(s1,'x')
%%
figure(3)
s2(1) = subplot(2,1,1);

plot(assist.chA.cxs.x(chA_good), real([(assist.F.chA.cxs.y(1,chA_good));assist.R.chA.cxs.y(1,chA_good)]),'-');
title('Real')
legend('forward','reverse');
s2(2) = subplot(2,1,2); 

plot(assist.chA.cxs.x(chA_good), imag([(assist.F.chA.cxs.y(1,chA_good));assist.R.chA.cxs.y(1,chA_good)])./...
 abs([(assist.F.chA.cxs.y(1,chA_good));assist.R.chA.cxs.y(1,chA_good)])  ,'-');
title('Imag fraction = img/abs')
legend('forward','reverse');
linkaxes(s2,'x');
title('No error, but non-definitive.  Compare calibrated radiances, not calibrations.')

%%
%Now for chB
[zpd_loc,zpd_mag] = find_zpd_edgar(assist.F.chB); zpd_loc = mode(zpd_loc);
  zpd_shift_F = length(assist.F.chB.x)./2 +1 - zpd_loc;
%   assist.R.chB.y = fliplr(assist.R.chB.y);
[zpd_loc,zpd_mag] = find_zpd_edgar(assist.R.chB); zpd_loc = mode(zpd_loc);
% Note that there is a subtlety here with the reverse shift and the fliplr
% incurring a 1-index difference since we want the zpd to be the first
% indice of the second half
  zpd_shift_R = length(assist.R.chB.x)./2 +1 - zpd_loc -1;

circshifted.F.y = fftshift(zpd_circshift(assist.F.chB.x,assist.F.chB.y,zpd_shift_F));
circshifted.R.y = fftshift(zpd_circshift(assist.R.chB.x,assist.R.chB.y,zpd_shift_R));
%%

figure(11);
ax(1) = subplot(2,1,1);
plot(assist.F.chB.x, [assist.F.chB.y(1,:);assist.R.chB.y(1,:)],'-');
legend('forward','reverse')
title('Ch B raw unshifted igrams')

ax(2) = subplot(2,1,2);
plot(assist.F.chB.x, [circshifted.F.y(1,:);fliplr(circshifted.R.y(1,:))],'-');
legend(['forward shifted: ',num2str(zpd_shift_F)],['reverse shift: ',num2str(zpd_shift_R)]);
title('shifted igrams')
linkaxes(ax,'x')
%%
assist.chB.cxs.x = fftshift(assist.F.chB.x/Laser_wl/length(assist.F.chB.x));
chB_good = assist.chB.cxs.x>1800 & assist.chB.cxs.x<3000;
assist.F.chB.cxs.y = fft(zpd_circshift(assist.F.chB.x,assist.F.chB.y,zpd_shift_F),[],2);
assist.R.chB.cxs.y = fft(zpd_circshift(assist.R.chB.x,assist.R.chB.y,zpd_shift_R),[],2);


%%
figure(12); 

s1(1) = subplot(2,1,1);
plot(assist.chB.cxs.x(chB_good), real(assist.F.chB.cxs.y(1,chB_good)), 'r', assist.chB.cxs.x(chB_good),imag(assist.F.chB.cxs.y(1,chB_good)),'c');
title('Ch B forward')
legend('real','imag');
s1(2) = subplot(2,1,2); 
plot(assist.chB.cxs.x(chB_good), real(assist.R.chB.cxs.y(1,chB_good)), 'r', assist.chB.cxs.x(chB_good),imag(assist.R.chB.cxs.y(1,chB_good)),'c');
title('reverse')
legend('real','imag');
linkaxes(s1,'x');

%%
figure(3)
s2(1) = subplot(2,1,1);
plot(assist.chB.cxs.x(chB_good), real([(assist.F.chB.cxs.y(1,chB_good));assist.R.chB.cxs.y(1,chB_good)]),'-');
title('Ch B Real')
legend('forward','reverse');
s2(2) = subplot(2,1,2); 

plot(assist.chB.cxs.x(chB_good), imag([(assist.F.chB.cxs.y(1,chB_good));assist.R.chB.cxs.y(1,chB_good)])./...
 abs([(assist.F.chB.cxs.y(1,chB_good));assist.R.chB.cxs.y(1,chB_good)])  ,'-');
title('Imag fraction = img/abs')
legend('forward','reverse');
linkaxes(s2,'x');
% End chB
assist = rad_cal_def_M(assist);
%%
% Now apply calibrations to chA F, R, and M
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.F.chA.cxs.y;
out_spec_F = RadiometricCalibration_3(in_spec, assist.chA.cal_F);
in_spec.y = assist.R.chA.cxs.y;
out_spec_R = RadiometricCalibration_3(in_spec, assist.chA.cal_R);

in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.F.chB.cxs.y;
out_spec_F = RadiometricCalibration_3(in_spec, assist.chB.cal_F);
in_spec.y = assist.R.chB.cxs.y;
out_spec_R = RadiometricCalibration_3(in_spec, assist.chB.cal_R);
%%
posA = assist.chA.cxs.x>400&assist.chA.cxs.x<2000;
posB = assist.chB.cxs.x>1800&assist.chB.cxs.x<3000;
ind = 1;
%%
return



% 
% 
% [zpd_loc,zpd_mag] = find_zpd_edgar(RawIgm);
% %    [tmp,zpd_loc] = max(abs(RawIgm.y - mean(RawIgm.y)));
%     zpd_loc = zpd_loc - length(RawIgm.x)./2-1;
%     zpd_loc = mode(zpd_loc);
% 
% RawSpc.y = fft(zpd_circshift(RawIgm.x,RawIgm.y,-zpd_loc),[],2);
% RawSpc.y = fftshift(RawSpc.y,2);
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
if isfield(edgar.mainHeaderBlock,'laserFrequency')
mat.laserFrequency = edgar.mainHeaderBlock.laserFrequency;
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

function assist = select_scan_dir(assist,strip);
fields = fieldnames(assist);
for f = length(fields):-1:1
   scan_dim = find(size(assist.(fields{f}))==length(strip),1,'first')-1;
   if ~isempty(scan_dim)
      tmp = shiftdim(assist.(fields{f}),scan_dim);
      assist.(fields{f}) = shiftdim(tmp(strip,:),-scan_dim);
   elseif isstruct(assist.(fields{f}))
      assist.(fields{f}) = select_scan_dir(assist.(fields{f}),strip);
   end
end

return

function assist = rad_cal_def_M(assist)
% Just looking at chA right now to assess calibration from pre-merged data 
% simplest, use mean temperatures and BB spectra over entire measurement
% Determines seperate calibrations from F, R, and premerged data set.
T_hot_F = mean(assist.HBB_C(assist.logi.HBB_F));
T_cold_F = mean(assist.ABB_C(assist.logi.ABB_F));
T_hot_R = mean(assist.HBB_C(assist.logi.HBB_R));
T_cold_R = mean(assist.ABB_C(assist.logi.ABB_R));

% Coad the mono-directional BB spectra to improve robustness of calibration
% Compute uncalibrated variance spectra of BB mono-scans
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.F.chA.cxs.y(assist.F.logi.H,:);
HBB_F = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.R.chA.cxs.y(assist.R.logi.H,:);
HBB_R = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.F.chA.cxs.y(assist.F.logi.A,:);
ABB_F = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.R.chA.cxs.y(assist.R.logi.A,:);
ABB_R = CoaddData(in_spec);

assist.chA.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
assist.chA.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);

%%
% pos = in_spec.x>450&in_spec.x<2000;
% figure; 
% sb3(1)= subplot(2,1,1); 
% plot(in_spec.x(pos), real([assist.chA.cal_F.Resp(pos);assist.chA.cal_R.Resp(pos);assist.chA.cal_M.Resp(pos)]), '-')
% title('real(Resp)')
% legend('F','R', 'M');
% sb3(2)= subplot(2,1,2); 
% plot(in_spec.x(pos), real([assist.chA.cal_F.Resp(pos);assist.chA.cal_R.Resp(pos);assist.chA.cal_M.Resp(pos)])...
%    - ones([3,1])*mean(real([assist.chA.cal_F.Resp(pos);assist.chA.cal_R.Resp(pos);assist.chA.cal_M.Resp(pos)]),1), '-')
% title('real(Resp)-mean(Resp)')
% legend('F','R', 'M');
% linkaxes(sb3,'x');
%%
% And now we do chB

% Coad the mono-directional BB spectra to improve robustness of calibration
% Compute uncalibrated variance spectra of BB mono-scans
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.F.chB.cxs.y(assist.F.logi.H,:);
HBB_F = CoaddData(in_spec);
 
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.R.chB.cxs.y(assist.R.logi.H,:);
HBB_R = CoaddData(in_spec);
 
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.F.chB.cxs.y(assist.F.logi.A,:);
ABB_F = CoaddData(in_spec);
 
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.R.chB.cxs.y(assist.R.logi.A,:);
ABB_R = CoaddData(in_spec);

assist.chB.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
assist.chB.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);

return