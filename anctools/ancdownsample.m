function nc = ancdownsample(nc,n,dim);
% nc = ancdownsample(nc,n,dim);
% creates downsampled version of input nc struct
% nc is a required netcdf struct
% n is a required integer downsample factor.
% optional dim is dimension along which to downsample.  Default is recdim
%
if ~exist('dim','var')
   if ~isempty(nc.recdim.name)
      dim = nc.recdim.name;
   elseif ~isempty(nc.dims)
      dimnames = fieldnames(nc.dims);
      dim = dimnames{1};
   else
      disp('No dimensions in this file?')
      return
   end
end
if strcmp(dim,'time')
   nc.time = downsample(nc.time, n);
end

fields = fieldnames(nc.vars);
for f = length(fields):-1:1
   dim_spot = find(strcmp(nc.vars.(fields{f}).dims,dim));
   if any(dim_spot)
      disp(['Downsampling ',fields{f}]);
      if any(~dim_spot)
         nc.vars.(fields{f}).data = downsample(nc.vars.(fields{f}).data,n,dim_spot);
      else
         nc.vars.(fields{f}).data = downsample(nc.vars.(fields{f}).data,n);
      end
   end
end
nc = timesync(nc);