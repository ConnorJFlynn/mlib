function cmp = rd_hsr1_comp(fname)
% Reads an HSR1 solar "component" file, ie "Total" or "Diffuse"

if ~isavar('fname')||~isafile(fname)
   fname = getfullname('*hsr1*.raw.*.txt','hsr1_raw','Select Diffuse or Total file...');
end
fid = fopen(fname, 'r');

A = textscan(fid,['%s ',repmat('%f ',1,801), '%*[^\n]'],'delimiter','\t','HeaderLines',3);
fclose(fid);
D = A{1};A(1) = [];

cmp.time = datenum(D,'yyyy-mm-dd HH:MM:SS');
cmp.nm = [300:1100];

for p = length(A):-1:1
   cmp.ch(:,p) = A{p}; A(p) = [];
end
%  plot([1:801],raw.ch(1:100:end,:),'-')
cmp.mfr_nm = [440, 500, 615, 673, 870];
cmp.mfr_ij = interp1(cmp.nm, [1:length(cmp.nm)], cmp.mfr_nm, 'nearest');

end