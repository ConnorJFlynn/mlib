function y = myFcn(u)
if ~exist('u','var')
   u = 100;
end
h = createButton; finishup = onCleanup(@() deleteButton(h));
pause(0.01); % To create the button.

% This is your really long operating function/software, which you want to
% stop and view every now and then.
y = 0;
while y < 100000
    y = y+u;
    pause(1e-5);
end
disp('all done with myFcn')
% delete(h);
return

