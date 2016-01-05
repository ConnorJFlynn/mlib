function nc = ancdownsample_nomiss(nc,n,dim);
% nc = ancdownsample_nomiss(nc,n,dim);
% creates downsampled version of input nc struct
% nc is a required netcdf struct
% n is a required integer downsample factor.
% optional dim is dimension along which to downsample.  Default is recdim
% Excludes values that are "missing" or "NaN"
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
%       disp(['Downsampling ',fields{f}]);
      miss = nc.vars.(fields{f}).data<-9990 & nc.vars.(fields{f}).data>-10000;
      nc.vars.(fields{f}).data(miss) = NaN;
      if any(~dim_spot)
         nc.vars.(fields{f}).data = downsample(nc.vars.(fields{f}).data,n,dim_spot);
      else
         nc.vars.(fields{f}).data = downsample(nc.vars.(fields{f}).data,n);
      end
   end
end
nc = timesync(nc);