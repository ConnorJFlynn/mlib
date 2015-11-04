% Fix header names to remove invalid characters
function ftx = fixtext(tx)
   if iscell(tx)       % get rid of the cell array
       ftx=cell2mat(tx);
   else
       ftx=tx;
   end
   
   % remove anything in brackets
   brk1 = strfind(ftx, '(');
   if length(brk1) > 0
       brk2 = strfind(ftx, ')');
       if length(brk2)>0
           ftx = ftx([1:(min(brk1)-1) (max(brk2)+1):length(ftx)]);
       end
   end

   ftx = strtrim(ftx);      % strip leading/trailing
   ftx(strfind(ftx, ' '))='_';      % remove spaces
   ftx(strfind(ftx, '.'))='_';      % remove periods
   ftx(strfind(ftx, '-'))='_';      % remove dashes
   ftx(strfind(ftx, '/'))='_';      % remove slashes

return
   