function nc = anctimegrid(nc,dt,first,last,missing);
%nc = anctimegrid(nc,dt,first,last,missing);
% nc is required.
% dt will be assigned to minimum delta-t unless provided
% first (last) will be assigned to nc.time(1(end)) unless provided 
% Outputs contents of nc on a regular time grid with spacing dt.
% If a missing value is specified, any missing elements  
% will be replaced with the nearest valid value.  
% Uses interp1 to nearest value.  
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
tind = interp1(nc.time, [1:length(nc.time)],tv,'nearest','extrap');
nc.time = tv; nc = timesync(nc);
fields = fieldnames(nc.vars);
for f = length(fields):-1:1
   disp(fields{f})
   time_dim = find(strcmp(nc.vars.(fields{f}).dims,nc.recdim.name));
   if ~isempty(time_dim)
      if time_dim==1
         if isfloat(nc.vars.(fields{f}).data)
            nc.vars.(fields{f}).data = nc.vars.(fields{f}).data(tind);
            if exist('missing','var')
               NaNs = ((nc.vars.(fields{f}).data > (missing -1) )&(nc.vars.(fields{f}).data < (missing+1)))|~isfinite(nc.vars.(fields{f}).data);
               if sum(~NaNs)>=2
                  nc.vars.(fields{f}).data(NaNs) = interp1(nc.time(~NaNs),nc.vars.(fields{f}).data(~NaNs),nc.time(NaNs),'nearest','extrap');
               elseif sum(~NaNs)==1
                  nc.vars.(fields{f}).data(NaNs) = nc.vars.(fields{f}).data(~NaNs);
               else
                  nc.vars.(fields{f}).data(NaNs)=NaN;
               end
            end
         else
            reclass = class(nc.vars.(fields{f}).data);
            nc.vars.(fields{f}).data = double(nc.vars.(fields{f}).data);
            nc.vars.(fields{f}).data = nc.vars.(fields{f}).data(tind);
            if exist('missing','var')
               NaNs = (nc.vars.(fields{f}).data ==missing)|~isfinite(nc.vars.(fields{f}).data);
               if sum(~NaNs)>=2
                  nc.vars.(fields{f}).data(NaNs) = interp1(nc.time(~NaNs),nc.vars.(fields{f}).data(~NaNs),nc.time(NaNs),'nearest','extrap');
               elseif sum(~NaNs)==1
                  nc.vars.(fields{f}).data(NaNs) = nc.vars.(fields{f}).data(~NaNs);
               else
                  nc.vars.(fields{f}).data(NaNs)=NaN;
               end
            end
            nc.vars.(fields{f}).data = eval([reclass,'(nc.vars.(fields{f}).data);']);
         end
      else
      [nc.vars.(fields{f}).data,NSHIFTS] = shiftdim(nc.vars.(fields{f}).data,time_dim-1);
      nc.vars.(fields{f}).data = nc.vars.(fields{f}).data(tind,:);
      [nc.vars.(fields{f}).data,NSHIFTS] = shiftdim(nc.vars.(fields{f}).data,NSHIFTS);
      end
   end
end

