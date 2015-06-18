function nc = anc_downsample_nomiss(nc,n,dim);
% nc = anc_downsample_nomiss(nc,n,dim);
% creates downsampled version of input nc struct
% nc is a required netcdf struct
% n is a required integer downsample factor.
% optional dim is dimension along which to downsample.  Default is recdim
% Excludes values that are "missing" or "NaN"
%
if ~exist('dim','var')
   if ~isempty(nc.ncdef.recdim.name)
      dim = nc.ncdef.recdim.name;
   elseif ~isempty(nc.ncdef.dims)
      dimnames = fieldnames(nc.ncdef.dims);
      dim = dimnames{1};
   else
      disp('No dimensions in this file?')
      return
   end
end
if strcmp(dim,'time')
   nc.time = downsample(nc.time, n);
end

fields = fieldnames(nc.ncdef.vars);
for f = length(fields):-1:1
   dim_spot = find(strcmp(nc.ncdef.vars.(fields{f}).dims,dim));
   if any(dim_spot)
%       disp(['Downsampling ',fields{f}]);
      miss = nc.vdata.(fields{f})<-9990 & nc.vdata.(fields{f})>-10000;
      nc.vdata.(fields{f})(miss) = NaN;
      if any(dim_spot>1)
         nc.vdata.(fields{f}) = downsample(nc.vdata.(fields{f}),n,dim_spot);
      else
         nc.vdata.(fields{f}) = downsample(nc.vdata.(fields{f}),n);
      end
   end
end
nc = anc_timesync(nc);