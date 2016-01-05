function nc = ancloadpart(nc, rec_start, rec_count);

if ~exist('nc','var')
   nc = ancload(nc.fname);
end
if ~exist('rec_start','var')
   rec_start = nc.recdim.length;
else 
   rec_start = min([rec_start,nc.recdim.length]);
end
if ~exist('rec_count','var')
   rec_count = nc.recdim.length - rec_start +1;
else
   rec_count = min([rec_count, (nc.recdim.length - rec_start +1)]);
end
varname = fieldnames(nc.vars);
for v = length(varname):-1:1
   if any(strcmp(nc.vars.(varname{v}).dims,nc.recdim.name))
%       disp(varname{v})
      nc.vars.(varname{v}).data = ancgetrecslab(nc,varname{v},rec_start,rec_count);
%       varname(v) = [];
   end
end
nc.time = nc.time(rec_start:rec_start+rec_count-1);
nc.recdim.length = rec_count;
nc.dims.(nc.recdim.name).length = rec_count;


if ~exist('arm_time','var')
   if isfield(nc.vars,'base_time')&&isfield(nc.vars,'time_offset')
      arm_time = true;
   else
      arm_time = false;
   end
end
if arm_time
   nc = timesync(nc);
end

