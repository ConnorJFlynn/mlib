function raw = rd_hsr1_raws(fname)

if ~isavar('fname')||~isafile(fname)
   fname = getfullname('*hsr1*.Raw_1.txt','hsr1_raw');
end


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
%  plot([1:801],raw.ch(1:100:end,:),'-')
raw.maxes(1,:) = max(raw.ch_1); raw.maxes(2,:) = max(raw.ch_2); raw.maxes(3,:) = max(raw.ch_3); raw.maxes(4,:) = max(raw.ch_4);
raw.maxes(5,:) = max(raw.ch_5); raw.maxes(6,:) = max(raw.ch_6); raw.maxes(7,:) = max(raw.ch_7); raw.maxes(8,:) = max(raw.ch_8);

% At this point, would be best to determine wavelength registration of each
% channel, then interpolate them onto the same wavelength scale.
% Then, determine mins, maxs, for dirh and diff.  This diff is only some
% fraction of the actual diffuse.  Maybe half?

figure; plot([1:801],raw.maxes,'-')
raw.pix200 = [raw.ch_1(:,200), raw.ch_2(:,200), raw.ch_3(:,200), raw.ch_4(:,200), raw.ch_5(:,200), raw.ch_6(:,200), raw.ch_7(:,200)];
[~, raw.max_ch] = max(raw.pix200,[],2); [~, raw.min_ch] = min(raw.pix200,[],2);
figure;
for t = length(raw.time):-1:1
   max_str = ['ch_',num2str(raw.max_ch(t))]; min_str = ['ch_',num2str(raw.min_ch(t))];
   raw.dirh(t,:) = raw.(max_str)(t,:)-raw.(min_str)(t,:); raw.diff(t,:) = 2.*raw.(min_str)(t,:);

   %    sb(1) = subplot(3,1,1); plot([300:1100],[raw.ch_1(t,:);raw.ch_2(t,:);raw.ch_3(t,:);raw.ch_4(t,:);raw.ch_5(t,:);raw.ch_6(t,:);raw.ch_7(t,:)],'-'); legend
   %    title(['t = ', num2str(t)])
   %    sb(2) = subplot(3,1,2); plot([300:1100],raw.(min_str)(t,:),'-',[300:1100],raw.(max_str)(t,:),'-r'); lg = legend('min_ch', 'max_ch'); set(lg,'interp','none')
   %    title(['max:', max_str, '  min:',min_str])
   %
   %    sb(3) = subplot(3,1,3); plot([300:1100],raw.diff(t,:),'-',[300:1100],raw.dirh(t,:),'r-'); logy;
   %    yl = ylim; hold('on'); plot([300:1100], raw.dirh(t,:)./raw.diff(t,:),'k-'); ylim(yl); legend('difh', 'dirh','DhDf'); hold('off');
   %    xlabel('wavelength [nm]')
   %    pause(.1)

end
raw.DhDf = raw.dirh./raw.diff; raw.DhDf(raw.dirh<=0 |raw.diff<=0) = NaN;
raw.mfr_nm = [440, 500, 615, 673, 870];
raw.mfr_ij = interp1(raw.nm, [1:length(raw.nm)], raw.mfr_nm, 'nearest');
% figure; plot(raw.nm, raw.dirh(200:100:800,:), 'r-',raw.nm, raw.diff(200:100:800,:),'b-');
% figure; plot(raw.nm, raw.dirh(200,:)./raw.diff(200,:),'-');
end

function plotme
figure; subplot(2,1,1); plot(raw.time, raw.dirh(:,raw.mfr_ij),'-',raw.time, raw.diff(:,raw.mfr_ij),'--'); dynamicDateTicks; title(datestr(raw.time(1),'yyyy-mm-dd'));
subplot(2,1,2); plot(raw.time, raw.DhDf(:,raw.mfr_ij),'-');dynamicDateTicks;
end