function dqr = nofun(ds_name, fields);

if ~exist('ds_name','var')
   clap = anc_bundle_files;
   [pname, fname, ext] = fileparts(clap.fname);
   
   [fstem,rest] = strtok(fname, '.');
   dlevel = strtok(rest,'.');
   ds_name = [fstem,'.',dlevel];
   ds_name = [fstem,'.a1'];
   
end

if ~exist('fields','var')
   fields = fieldnames(clap.vdata);
end

for f = 1:length(fields)
   var = fields{f};
   if isempty(strfind(var,'base_time')) && isempty(strfind(var,'time_offset')) ...
         && (isempty(strfind(var,'qc_')==1)||(strfind(var,'qc_')~=1))
      tmp = parse_dqr(ds_name,var);
      if ~isempty(tmp)
         dqr.vars.(var).id = tmp.id;
         if ~isfield(dqr,'all')
            dqr.all = tmp;
         else
            dq_fld = fieldnames(tmp);
            for fld = 1:length(dq_fld)
               fld = dq_fld{fld};
               dqr.all.(fld) = [dqr.all.(fld) tmp.(fld)];
            end
         end
      end
   end
end
[dqr.all.id, ij] = unique(dqr.all.id);
dq_fld(2) = [];
for fld = 1:length(dq_fld)
   fld = dq_fld{fld};
   dqr.all.(fld) = dqr.all.(fld)(ij);
end
vars = fieldnames(dqr.vars);
for v = 1:length(vars)
   var = vars{v};
   [ids,ij] = intersect(dqr.all.id, dqr.vars.(var).id);
      dqr.ids_by_var.(var) = ij;
end



return
% https://www.db.arm.gov/cgi-bin/PIFCARDQR2/browse/GetID.pl?id=tmp.id_str{1}