function nc = anc_loadpart(nc, rec_start, rec_count);

if ~exist('nc','var')
   nc = anc_load;
end
if ~exist('rec_start','var')
   rec_start = nc.ncdef.recdim.length;
else 
   rec_start = min([rec_start,nc.ncdef.recdim.length]);
end
if ~exist('rec_count','var')
   rec_count = nc.ncdef.recdim.length - rec_start +1;
else
   rec_count = min([rec_count, (nc.ncdef.recdim.length - rec_start +1)]);
end
varname = fieldnames(nc.ncdef.vars);
for v = length(varname):-1:1
   if any(strcmp(nc.ncdef.vars.(varname{v}).dims,nc.ncdef.recdim.name))
%       disp(varname{v})
      nc.vdata.(varname{v}) = anc_getrecslab(nc,varname{v},rec_start,rec_count);
%       varname(v) = [];
   end
end
nc.time = nc.time(rec_start:rec_start+rec_count-1);
nc.ncdef.recdim.length = rec_count;
nc.ncdef.dims.(nc.ncdef.recdim.name).length = rec_count;


if ~exist('arm_time','var')
   if isfield(nc.ncdef.vars,'base_time')&&isfield(nc.ncdef.vars,'time_offset')
      arm_time = true;
   else
      arm_time = false;
   end
end
if arm_time
   nc = anc_timesync(nc);
end

