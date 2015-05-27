function restart_clean

started = now-1;
while true
    % restart every 15 minutes.
    if etime(datevec(now),datevec(started))> 15*60 
        system('C:\Program Files\MATLAB\clean_assist.bat');
        started = now;
        % pause for 5 minutes
        pause(300);
    end
    
end

return
