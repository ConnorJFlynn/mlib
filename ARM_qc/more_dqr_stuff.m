clap = anc_bundle_files;
[pname, fname, ext] = fileparts(clap.fname);

[fstem,rest] = strtok(fname, '.');
dlevel = strtok(rest,'.');
ds = [fstem,'.',dlevel];
ds = [fstem,'.a1'];

fields = fieldnames(clap.vdata);

for f = 1:length(fields)
   var = fields{f};
   if isempty(strfind(var,'base_time')) && isempty(strfind(var,'time_offset')) ...
         && (isempty(strfind(var,'qc_')==1)||(strfind(var,'qc_')~=1))
   dqr.(strrep(ds,'.','_')).(var) = parse_dqr(ds,var);
   end
end
