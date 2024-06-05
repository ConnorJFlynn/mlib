function hsrl = bundlen_gvhsrl(in_file, N)
% Reads selected gvhsrl files, downsamples in time by N then cats result
if ~isavar('in_file')||isempty(in_file)
   in_file = getfullname('*GVHSRL*.nc','GVHSRL');
end

if ~iscell(in_file)&&isafile(in_file)
   hsrl = rd_gvhsrl(in_file);
elseif iscell(in_file)&&~isempty(in_file)&&isafile(in_file{1})
   hsrl = rd_gvhsrl(in_file{1});
   in_file(1) = [];
end

if isavar('N')
   hsrl = anc_downsample_nomiss(hsrl,N,'time');
end

for f = 2:length(in_file)
   hsrl_ = rd_gvhsrl(in_file{f});
   if isavar('N')
      hsrl_ = anc_downsample_nomiss(hsrl_,N,'time');
   end
   hsrl = cat_gvhsrl(hsrl, hsrl_);
   length(in_file)-f

end

end

function hsrl = cat_gvhsrl(hsrl, hsrl_);
[hsrl.time, ij] = unique([hsrl.time, hsrl_.time]);
hsrl.ncdef.dims.time.length = length(hsrl.time);

vars = fieldnames(hsrl.vdata);
for v = 1:length(vars)
   var = vars{v}; 
   if ~strcmp(var,'time_offset')&&~strcmp(var,'base_time')
   if find(strcmp(hsrl.ncdef.vars.(var).dims,'time'))==1
      tmp = [hsrl.vdata.(var);hsrl_.vdata.(var)];
      hsrl.vdata.(var) = tmp(ij,:);
   elseif find(strcmp(hsrl.ncdef.vars.(var).dims,'time'))==2
      tmp = [hsrl.vdata.(var),hsrl_.vdata.(var)];
      hsrl.vdata.(var) = tmp(:,ij);
   end
   end
end

end