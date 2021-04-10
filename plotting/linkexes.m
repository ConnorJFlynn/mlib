function ax = linkexes(ax);

if ~exist('ax','var')
   ax = [];
end

done = false;
while ~done
   mn = menu('Select axes to link...', 'OK','Done');
   if mn ==1
      ax = [ax, gca];
   else
      done = true;
   end
end
if ~isempty(ax)
   linkaxes(ax,'x');
end

return