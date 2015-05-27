function [hkp] = cat_hkp(hkp, hkp_);
if ~exist('hkp','var')
   hkp = rd_hkp;
end
if ~exist('hkp_','var')
   hkp_ = rd_hkp;
end
if ~isstruct(hkp)&&exist(hkp,'file')
      hkp = rd_hkp(hkp);
end
if ~isstruct(hkp_)&&exist(hkp_,'file')
      hkp_ = rd_hkp(hkp_);
end

[hkp.time, inds] = unique([hkp.time, hkp_.time]);
fields = fieldnames(hkp);
for f = 2:length(fields)
   tmp = [hkp.(fields{f}), hkp_.(fields{f})];
   hkp.(fields{f}) = tmp(inds);
%    if isempty(findstr(fields{f},'_status'))&&isempty(findstr(fields{f},'_time_lag'))
%       good = hkp.([fields{f},'_status'])==0;
%       if any(good)
%    plot(serial2Hh(hkp.time(good)), hkp.(fields{f})(good), 'og-');
%       end
%       if any(~good)
%          hold('on');
%       plot(serial2Hh(hkp.time(~good)), hkp.(fields{f})(~good), 'or');
%       hold('off')
%       end
%    title(fields{f},'interp','none')
%    end
   
end



return;
