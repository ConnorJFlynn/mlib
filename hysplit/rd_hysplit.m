function traj = rd_hysplit(in_file)

if ~isavar('in_file')||~isafile(in_file)
   in_file = getfullname('tdump*','hys_traj');
end

fid = fopen(in_file);
inline = fgetl(fid); skip = sscanf(inline, '%d %*d ')
for n = 1:skip
   fgetl(fid);
end
inline = fgetl(fid);
Ntraj = textscan(inline,'%d %s %s');
for n = 1:Ntraj{1}
   fgetl(fid);
end
inline = fgetl(fid);
[metlab, ind] = textscan(inline,'%d'); metlab = metlab{1};
metlabs = textscan(inline(metlab:end),'%s'); metlabs = metlabs{1}; metlabs = metlabs';
lab = {'N','Hmm','yy','mm','dd','HH','MM','SS','age_hs','lat','lon','alt',metlabs{:}};
fmt = repmat('%f ',size(lab));
A = textscan(fid,fmt);
for L = 1:length(lab)
   traj.(lab{L}) = A{L};
end

fclose(fid)