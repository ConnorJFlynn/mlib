files = getfullname('housashenir*.nc','hou')

for f = length(files):-1:1
anc = anc_loadcoords(files{f});
sas.time(f) = anc.time(1);
sas.proc(f) = sscanf(anc.gatts.process_version,'ingest-sashe-%f');
disp(f)
end
unique(sas.proc)