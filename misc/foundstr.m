function  found = foundstr(strarr, str)
% found = foundstr(strarr, str)
% Returns the number of teims str is found in strarr
if iscell(str)
   str = str{:};
end
result = strfind(strarr, str);
if isempty(result)
   found = length(result);
else
   if iscellstr(strarr)
   found = logical(zeros(size(result)));
   for n = 1:length(found)
      found(n) = length(result{n});
   end
   else
      found = length(result);
   end
end
return

