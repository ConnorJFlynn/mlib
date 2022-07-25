function raw = rd_hsr1_raws(fname)

if ~isavar('fname')||~isafile(fname)
    fname = getfullname('*hsr1*.Raw_1.txt','hsr1_raw');
end

coscor = load(getfullname('hsp_coscor.mat', 'hsrl_cals'));
% angle_corrs.zenith_angle, angle_corrs.N
angle_corrs.zenith_angle = [0:90]; 
angle_corrs.N= interp1(coscor.ZA(30:end), coscor.cos_corr(30:end), [0:90],'linear','extrap');
angle_corrs.S = angle_corrs.N;  angle_corrs.E = angle_corrs.N; angle_corrs.W = angle_corrs.N;
difcoscor = difcor(angle_corrs);
fid = fopen(fname, 'r');

A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
D = A{1};A(1) = [];

raw.time = datenum(D,'yyyy-mm-dd HH:MM:SS');
raw.nm = [300:1100];
for p = length(A):-1:1
    ch(:,p) = A{p}; A(p) = [];
end
raw.ch_1 = ch;

fname = strrep(fname, 'Raw_1','Raw_2');
if ~isafile(fname); fname = getfullname('*hsr1*',datestr(raw.time(1),'yyyy-mm-dd'),'.Raw_2.txt','hsr1_raw'); end
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
    ch(:,p) = A{p}; A(p) = [];
end
raw.ch_2 = ch;

fname = strrep(fname, 'Raw_2','Raw_3');
if ~isafile(fname); fname = getfullname('*hsr1*',datestr(raw.time(1),'yyyy-mm-dd'),'.Raw_3.txt','hsr1_raw'); end
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
    ch(:,p) = A{p}; A(p) = [];
end
raw.ch_3 = ch;

fname = strrep(fname, 'Raw_3','Raw_4');
if ~isafile(fname); fname = getfullname('*hsr1*',datestr(raw.time(1),'yyyy-mm-dd'),'.Raw_4.txt','hsr1_raw'); end
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
    ch(:,p) = A{p}; A(p) = [];
end
raw.ch_4 = ch;

fname = strrep(fname, 'Raw_4','Raw_5');
if ~isafile(fname); fname = getfullname('*hsr1*',datestr(raw.time(1),'yyyy-mm-dd'),'.Raw_5.txt','hsr1_raw'); end
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
    ch(:,p) = A{p}; A(p) = [];
end
raw.ch_5 = ch;

fname = strrep(fname, 'Raw_5','Raw_6');
if ~isafile(fname); fname = getfullname('*hsr1*',datestr(raw.time(1),'yyyy-mm-dd'),'.Raw_6.txt','hsr1_raw'); end
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
    ch(:,p) = A{p}; A(p) = [];
end
raw.ch_6 = ch;

fname = strrep(fname, 'Raw_6','Raw_7');
if ~isafile(fname); fname = getfullname('*hsr1*',datestr(raw.time(1),'yyyy-mm-dd'),'.Raw_7.txt','hsr1_raw'); end
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
    ch(:,p) = A{p}; A(p) = [];
end
raw.ch_7 = ch;

fname = strrep(fname, 'Raw_7','Raw_8');
if ~isafile(fname); fname = getfullname('*hsr1*',datestr(raw.time(1),'yyyy-mm-dd'),'.Raw_8.txt','hsr1_raw'); end
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
    ch(:,p) = A{p}; A(p) = [];
end
raw.ch_8 = ch;

cals = rd_hsr1_cal_file('C:\Users\flyn0011\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\dev\sgp\sgphsr1C1.00\Baumer 700004143714 SpectrometerCalibration 2022-03-18.txt');
sens = [.5015,.4925, .4985, .4985,.4925, .4985, .4985];% sensitivity as average of UOC and SOC diffuse fraction
one_time = ones(size(raw.time));
for ch = 1:7
    raw.(['ch_',num2str(ch)]) = raw.(['ch_',num2str(ch)]) .* (one_time*cals.resp(ch,:)) ./ 20./sens(ch); 
    %divide by 20 to account for integration time.  hack solution
end
%  plot([1:801],raw.ch(1:100:end,:),'-')
raw.maxes(1,:) = max(raw.ch_1); raw.maxes(2,:) = max(raw.ch_2); raw.maxes(3,:) = max(raw.ch_3); raw.maxes(4,:) = max(raw.ch_4);
raw.maxes(5,:) = max(raw.ch_5); raw.maxes(6,:) = max(raw.ch_6); raw.maxes(7,:) = max(raw.ch_7); raw.maxes(8,:) = max(raw.ch_8);

% At this point, would be best to determine wavelength registration of each
% channel, then interpolate them onto the same wavelength scale.
% Then, determine mins, maxs, for dirh and diff.  This diff is only some
% fraction of the actual diffuse.  Maybe half?

figure; plot([1:801],raw.maxes,'-')
% raw.pix200 = [raw.ch_1(:,200), raw.ch_2(:,200), raw.ch_3(:,200), raw.ch_4(:,200), raw.ch_5(:,200), raw.ch_6(:,200), raw.ch_7(:,200)];
% [~, raw.max_ch] = max(raw.pix200,[],2); [~, raw.min_ch] = min(raw.pix200,[],2);
raw.intg = [trapz(raw.nm, raw.ch_1,2),trapz(raw.nm, raw.ch_2,2),trapz(raw.nm, raw.ch_3,2),...
    trapz(raw.nm, raw.ch_4,2),trapz(raw.nm, raw.ch_5,2),trapz(raw.nm, raw.ch_6,2),...
    trapz(raw.nm, raw.ch_7,2)];
[~, raw.max_ch] = max(raw.intg,[],2); [~, raw.min_ch] = min(raw.intg,[],2);
lat = 36.605; lon = -97.485; 
[SZA, SAZ, AU, ~, ~, ~, airmass] = sunae(lat, lon, raw.time);
hpn_cosine_cor = cos_correction(angle_corrs,SAZ,SZA);
figure;
% Right in here apply cosine correction to dirh and diff.
for t = length(raw.time):-1:1
    max_str = ['ch_',num2str(raw.max_ch(t))]; min_str = ['ch_',num2str(raw.min_ch(t))];
    raw.dirh(t,:) = (raw.(max_str)(t,:)-raw.(min_str)(t,:))./2; 
    raw.diff(t,:) = raw.(min_str)(t,:);

    % if mod(t,20)==0
    %       sb(1) = subplot(3,1,1); plot([300:1100],[raw.ch_1(t,:);raw.ch_2(t,:);raw.ch_3(t,:);raw.ch_4(t,:);raw.ch_5(t,:);raw.ch_6(t,:);raw.ch_7(t,:)],'-'); legend
    %       title(['t = ', num2str(t)])
    %       sb(2) = subplot(3,1,2); plot([300:1100],raw.(min_str)(t,:),'-',[300:1100],raw.(max_str)(t,:),'-r'); lg = legend('min_ch', 'max_ch'); set(lg,'interp','none')
    %       title(['max:', max_str, '  min:',min_str])
    %
    %       sb(3) = subplot(3,1,3); plot([300:1100],raw.diff(t,:),'-',[300:1100],raw.dirh(t,:),'r-'); logy;
    %       yl = ylim; hold('on'); plot([300:1100], raw.dirh(t,:)./raw.diff(t,:),'k-'); ylim(yl); legend('difh', 'dirh','DhDf'); hold('off');
    %       xlabel('wavelength [nm]')
    %       pause(.01)
    % end
end
raw.dirh_cor = raw.dirh./(hpn_cosine_cor'*ones(size(raw.nm))); raw.dirn = raw.dirh_cor./(cosd(SZA)*ones(size(raw.nm)));  raw.diff = raw.diff./difcoscor.mean_all;
raw.DhDf = raw.dirn./raw.diff; raw.DhDf(raw.dirh<=0 |raw.diff<=0) = NaN;
raw.mfr_nm = [440, 500, 615, 673, 870];
raw.mfr_ij = interp1(raw.nm, [1:length(raw.nm)], raw.mfr_nm, 'nearest');

guey =load('guey.mat'); ESR = guey.guey;
TOA = interp1(ESR(:,1), ESR(:,3),raw.nm','linear')'./(mean(AU).^2);
raw.T = raw.dirn ./ (ones(size(raw.time))*TOA); 
raw.ray = rayleigh(raw.nm./1000,2);
raw.tod = -log(.9.*raw.T)./(airmass.*ones(size(raw.nm)));
raw.aod = raw.tod - ones(size(raw.time))*raw.ray;
raw.xsun = ones(size(raw.max_ch1)); raw.xsun(2:end) =  raw.max_ch(1:end-1)==raw.max_ch(2:end);
raw.xsun(2:end) = raw.xsun(1:end-1)|raw.xsun(2:end); % 
raw.xshd = raw.xsun;
end

function plotme
figure; subplot(2,1,1); plot(raw.time, raw.T(:,raw.mfr_ij),'-',raw.time, raw.diff(:,raw.mfr_ij),'--'); dynamicDateTicks; title(datestr(raw.time(1),'yyyy-mm-dd'));
subplot(2,1,2); plot(raw.time, raw.DhDf(:,raw.mfr_ij),'-');dynamicDateTicks;

figure; sp(1) = subplot(2,1,1);
   scatter(raw.time, raw.aod(:,raw.mfr_ij(2)),6,raw.max_ch); dynamicDateTicks; ylabel('AOD 500 nm'); colorbar
   sp(2) = subplot(2,1,2);
 scatter(raw.time, raw.aod(:,raw.mfr_ij(2)),6,raw.min_ch); dynamicDateTicks; ylabel('AOD 500 nm'); colorbar
   linkaxes(sp,'xy');
   lin = colormap(lines); colormap(lin(1:7,:))

figure; plot(raw.time, raw.T(:,raw.mfr_ij),'-');logy
figure; plot(raw.time, raw.aod(:,raw.mfr_ij(2)),'k-'); dynamicDateTicks
figure; plot(raw.nm, raw.tod(5000:1000:8000,:),'-')
figure; scatter(raw.time, raw.aod(:,raw.mfr_ij(2)),6,raw.max_ch); 

figure; plot(ESR(:,1), ESR(:,3),'-'); logy; liny;
end
