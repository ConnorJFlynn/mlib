function nc_ = anctimegrid2(nc,dt,first,last,missing);
%nc = anctimegrid(nc,dt,first,last,missing);
% nc is required.
% dt will be assigned to minimum delta-t unless provided
% first (last) will be assigned to nc.time(1(end)) unless provided 
% Outputs contents of nc on a regular time grid with spacing dt.
% If a missing value is specified, any missing elements  
% will be replaced with the nearest valid value.  
% Uses interp1 to nearest value.  
nc_ = nc;
if ~exist('dt','var')
   tmp = unique(diff(unique(nc.time)));
   dt = tmp(1);
end
if ~exist('first','var')
   first = nc.time(1);
end
if ~exist('last','var')
   last = nc.time(end);
end
tv = [first:dt:last];
tind = interp1(tv, [1:length(tv)],nc.time,'nearest','extrap');
% tind = unique(tind);
nc_.time = tv; nc_ = timesync(nc_);

fields = fieldnames(nc.vars);

for f = fields(:)'
    f = char(f);
    disp(f)
   nc_.vars.(f) = nc_.vars.(f);
   time_dim = find(strcmp(nc.vars.(f).dims,nc.recdim.name));
   if ~isempty(time_dim)
      if time_dim==1
          nc_.vars.(f).data = NaN(size(tv));
         if isfloat(nc.vars.(f).data)
            if exist('missing','var')
               NaNs = ((nc.vars.(f).data > (missing -1) )&(nc.vars.(f).data < (missing+1)))|~isfinite(nc.vars.(f).data);
               if sum(~NaNs)>=2
                  nc.vars.(f).data(NaNs) = interp1(nc.time(~NaNs),nc.vars.(f).data(~NaNs),nc.time(NaNs),'nearest','extrap');
               elseif sum(~NaNs)==1
                  nc.vars.(f).data(NaNs) = nc.vars.(f).data(~NaNs);
               else
                  nc.vars.(f).data(NaNs)=NaN;
               end
            end
%             nc_.vars.(f).data(tind) = nc.vars.(f).data;
         else
            reclass = class(nc.vars.(f).data);
            nc.vars.(f).data(~NaNs) = double(nc.vars.(f).data(~NaNs));
            if exist('missing','var')
               NaNs = (nc.vars.(f).data ==missing)|~isfinite(nc.vars.(f).data)|isNaN(nc.vars.(f).data);
               if sum(~NaNs)>=2
                  nc.vars.(f).data(NaNs) = interp1(nc.time(~NaNs),double(nc.vars.(f).data(~NaNs)),nc.time(NaNs),'nearest','extrap');
               elseif sum(~NaNs)==1
                  nc.vars.(f).data(NaNs) = nc.vars.(f).data(~NaNs);
               else
                  nc.vars.(f).data(NaNs)=NaN;
               end
            end
            nc.vars.(f).data = cast(nc.vars.(f).data, reclass);
         end
%             nc.vars.(f).data = double(nc.vars.(f).data);
            nc_.vars.(f).data(tind) = nc.vars.(f).data;

      else
      [nc.vars.(f).data,NSHIFTS] = shiftdim(nc.vars.(f).data,time_dim-1);
      nc.vars.(f).data(tind,:) = nc.vars.(f).data;
      [nc.vars.(f).data,NSHIFTS] = shiftdim(nc.vars.(f).data,NSHIFTS);
      end
   end
end

