function raw = rd_hsr1_raw(fname)

if ~isavar('fname')&&~isafile(fname)
   fname = getfullname('*hsr1*.Raw_*.txt','hsr1_raw');
end
fid = fopen(fname, 'r');

A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',1);
fclose(fid);
D = A{1};A(1) = [];

raw.time = datenum(D,'yyyy-mm-dd HH:MM:SS');
for p = length(A):-1:1
   raw.ch(:,p) = A{p}; A(p) = [];
end
%  plot([1:801],raw.ch(1:100:end,:),'-')


end