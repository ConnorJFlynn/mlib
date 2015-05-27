
function [move_time, theta] = scanner_move(theta_deg);
% [move_time, theta] = scanner_move(theta_deg);
% Opens COM1 to connect to IDC SmartStep
% Issues a move command, waits for done string
% Returns move_time and theta (zenith angle
% with negative CW, or NaNs if timed out
time_limit = 20;
s1 = serial('COM1');
fopen(s1);

getpos = [' PA1 '];
done = false;
tic;
while ~done
  movestr = sprintf(' S AC10 VE10 DA%g GO "done"',theta_deg);  
  count = fprintf(s1,movestr);
  done = (findstr(fscanf(s1), 'done')|(toc>time_limit));
end
if toc>time_limit
   move_time = NaN;
   theta = NaN;
else
   status = now;
   count = fprintf(s1,' PA1 ');
   theta_str = fscanf(s1);
   theta = sscanf(theta_str(2:end),'%g');
end
fclose(s1);
