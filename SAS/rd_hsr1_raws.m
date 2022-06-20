function raw = rd_hsr1_raws(fname)

if ~isavar('fname')||~isafile(fname)
   fname = getfullname('*hsr1*.Raw_1.txt','hsr1_raw');
end


fid = fopen(fname, 'r');

A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
D = A{1};A(1) = [];

raw.time = datenum(D,'yyyy-mm-dd HH:MM:SS');
for p = length(A):-1:1
   ch(:,p) = A{p}; A(p) = [];
end
raw.ch_1 = ch;

fname = strrep(fname, 'Raw_1','Raw_2');
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
   ch(:,p) = A{p}; A(p) = [];
end
raw.ch_2 = ch;

fname = strrep(fname, 'Raw_2','Raw_3');
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
   ch(:,p) = A{p}; A(p) = [];
end
raw.ch_3 = ch;

fname = strrep(fname, 'Raw_3','Raw_4');
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
   ch(:,p) = A{p}; A(p) = [];
end
raw.ch_4 = ch;

fname = strrep(fname, 'Raw_4','Raw_5');
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
   ch(:,p) = A{p}; A(p) = [];
end
raw.ch_5 = ch;

fname = strrep(fname, 'Raw_5','Raw_6');
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
   ch(:,p) = A{p}; A(p) = [];
end
raw.ch_6 = ch;

fname = strrep(fname, 'Raw_6','Raw_7');
fid = fopen(fname, 'r')
A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
A(1) = [];
for p = length(A):-1:1
   ch(:,p) = A{p}; A(p) = [];
end
raw.ch_7 = ch;

fname = strrep(fname, 'Raw_7','Raw_8');
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
for t = length(raw.time):-1:1
   max_str = ['ch_',num2str(raw.max_ch(t))]; min_str = ['ch_',num2str(raw.min_ch(t))];
   raw.dirh(t,:) = raw.(max_str)(t,:)-raw.(min_str)(t,:); raw.diff(t,:) = 2.*raw.(min_str)(t,:);
end
raw.nm = [300:1100];



end