function  found = foundstr(strarr, str)
% found = foundstr(strarr, str)
% Returns true if str is found in any element of strarr
if iscell(str)
   str = str{:};
end
result = strfind(strarr, str);
if isempty(result)
   found = false;
else
   if iscellstr(strarr)
   found = logical(zeros(size(result)));
   for n = 1:length(found)
      found(n) = ~isempty(result{n});
   end
   else
      found = result>0;
   end
end
return

