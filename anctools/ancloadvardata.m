function cdf = ancloadvardata(cdf);
% Usage: cdf = ancloadvardata(cdf)
% Load variable data.
fields = fieldnames(cdf.vars);
for q = 1:length(fields)
    vkey = fields{q};
    vval = cdf.vars.(vkey);
%     if findstr(vkey,'qc_')
%         disp(vkey)
%     end
    [vdata, status] = ancgetdata(cdf, vval.id);
%     if findstr(vkey,'qc_')
%         unique(vdata)
%     end
    if (status ~= 0)
        return;
    end
    cdf.vars.(vkey).data = vdata;
end

% Create and populate a 'time' field at the base level of cdf
% containing serial date for Matlab use.
% [tok, rest] = strtok(cdf.vars.time_offset.atts.units.data);
% [tok, rest] = strtok(rest);
% cdf.vars.base_time.data  = int32(serial2epoch(datenum(rest,['yyyy-mm-dd HH:MM:SS 0:00'])));
% cdf.time = (epoch2serial(double(cdf.vars.base_time.data) + cdf.vars.time_offset.data));
if ~exist('arm_time','var')
   if isfield(cdf.vars,'base_time')&&isfield(cdf.vars,'time_offset')
      arm_time = true;
   else
      arm_time = false;
   end
end
if arm_time
   cdf = timesync(cdf);
end

return