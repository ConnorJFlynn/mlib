function anc = fill_mt_anc_vars(anc)
% anc = fill_mt_vars(anc)
% this function takes a anc struct lacking a vdata element and populates an 
% empty vdata shell with appropriately classed but empty data fields. 

vars = fieldnames(anc.ncdef.vars);
dtype_to_class = {'uint8','char','int16','int32','single','double'};
for v = vars'
   disp(['Populating ',v])
   v = char(v);
   dims =  anc.ncdef.vars.(v).dims; 
   if iscell(dims)&&isempty(dims{1})
      dims = [];
   end
   vdim = [];
   for d = 1:length(dims)
      vdim = [vdim,anc.ncdef.dims.(char(dims(d))).length];
   end
   if isempty(vdim)
      vdim = 0;
   end
   if length(dims)==1
      if strcmp(anc.ncdef.recdim.name,dims)
         vdim = [vdim,0];
      else
         vdim = [0,vdim];
      end
   end
   vdim = fliplr(vdim);
   vclass = dtype_to_class(anc.ncdef.vars.(v).datatype);
   vclass = vclass{:};
   if strcmp(vclass,'char')
      vdata = [];
   else
      vdata = zeros(vdim,vclass);
   end
anc.vdata.(v) = vdata;
end
vatts = anc.vatts; anc = rmfield(anc, 'vatts');anc.vatts = vatts; clear vatts;
vdata = anc.vdata; anc = rmfield(anc, 'vdata'); anc.vdata = vdata; clear vdata;

return

