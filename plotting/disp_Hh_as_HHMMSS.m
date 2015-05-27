function output_txt = disp_Hh_as_HHMMSS(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');
t = pos(1);
% if t_str==2
%     disp('time in doy');
% end
output_txt = {['X: ',datestr(t./24,'HH:MM:SS')],...
    ['Y: ',num2str(pos(2),4)]};

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
end
