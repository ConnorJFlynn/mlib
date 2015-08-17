function h = createButton
% typical syntax: 
%     h = createButton; finishup = onCleanup(@() deleteButton(h));
% Creates a button allowing user to pause execution
% type 'return' to resume
% follow this function with finishup = onCleanup(@() deleteButton(h));
% to remove button after parent function terminates.
h = figure;
set(h,'MenuBar','none','Units','Normalized');
set(h,'Position',[0.5 0.5 0.15 0.05]);
uicontrol(... % Button for updating selected plot
   'Parent', h, ...
   'Units','normalized',...
   'HandleVisibility','callback', ...
   'Position',[0.05 0.05 0.9 0.9],...
   'String','Pause. Type "return" to resume.',...
   'BackgroundColor',[1 0.6 0.6],...
   'Callback', 'eval(''keyboard'')');

return



