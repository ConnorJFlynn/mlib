function startin_SPARTAN(sdate)
% startin_SPARTAN(sdate)
% sdate can be calendar date from datestr or a serial date from datenum
if ~isavar('sdate')
   sdate = now;
end
if ischar(sdate)
   sdate = datenum(sdate);
end
disp(sprintf(['Cartridge start date: ',datestr(sdate,'ddd mm-dd yyyy')]))
disp(sprintf(['Exchange cartridge on: ', datestr(sdate + 54,'ddd mm-dd yyyy')]))

return