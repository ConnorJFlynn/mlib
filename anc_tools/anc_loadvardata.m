function cdf = anc_loadvardata(cdf);
% Usage: cdf = anc_loadvardata(cdf)
% Load variable data.
fields = fieldnames(cdf.ncdef.vars);
for q = 1:length(fields)
    vkey = fields{q};
    vval = cdf.ncdef.vars.(vkey);
%     if findstr(vkey,'qc_')
%         disp(vkey)
%     end
    [vdata, status] = anc_getdata(cdf, vval.id);
%     if findstr(vkey,'qc_')
%         unique(vdata)
%     end
    if (status ~= 0)
        return;
    end
    cdf.vdata.(vkey) = vdata;
end

% Create and populate a 'time' field at the base level of cdf
% containing serial date for Matlab use.
% [tok, rest] = strtok(cdf.vars.time_offset.atts.units.data);
% [tok, rest] = strtok(rest);
% cdf.vars.base_time.data  = int32(serial2epoch(datenum(rest,['yyyy-mm-dd HH:MM:SS 0:00'])));
% cdf.time = (epoch2serial(double(cdf.vars.base_time.data) + cdf.vars.time_offset.data));
if ~exist('arm_time','var')
   if isfield(cdf.ncdef.vars,'base_time')&&isfield(cdf.ncdef.vars,'time_offset')
      arm_time = true;
   else
      arm_time = false;
   end
end
if arm_time
   cdf = anc_timesync(cdf);
end

return