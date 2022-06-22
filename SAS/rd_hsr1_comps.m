function cmp = rd_hsr1_comps(fname)
% Reads an HSR1 solar "component" file, ie "Total" or "Diffuse"

if ~isavar('fname')||~isafile(fname)
   fname = getfullname('*hsr1*.raw.*Total.txt','hsr1_raw','Select Total file...');
end
fid = fopen(fname, 'r');

A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',3);
fclose(fid);
D = A{1};A(1) = [];

cmp.time = datenum(D,'yyyy-mm-dd HH:MM:SS');
cmp.nm = [300:1100];

for p = length(A):-1:1
   cmp.toth(:,p) = A{p}; A(p) = [];
end
%  plot([1:801],raw.ch(1:100:end,:),'-')

fname = strrep(fname,'Total.txt','Diffuse.txt');
if ~isafile(fname)
   fname = getfullname('*hsr1*.raw.*Diffuse.txt','hsr1_raw','Select Diffuse file...');
end
fid = fopen(fname, 'r');

A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',3);
fclose(fid);
D = A{1};A(1) = [];


for p = length(A):-1:1
   cmp.difh(:,p) = A{p}; A(p) = [];
end

cmp.dirh = cmp.toth - cmp.difh;
cmp.mfr_nm = [440, 500, 615, 673, 870];
cmp.mfr_ij = interp1(cmp.nm, [1:length(cmp.nm)], cmp.mfr_nm, 'nearest');
cmp.DhDf = cmp.dirh(:,cmp.mfr_ij)./cmp.difh(:,cmp.mfr_ij);
cmp.DhDf(cmp.dirh(:,cmp.mfr_ij)>=0 | cmp.difh(:,cmp.mfr_ij)<=0) = NaN;

end