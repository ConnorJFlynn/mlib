function  found = anystrfind(strarr, str)
if iscell(str) 
    str = str{:};
end
result = strfind(strarr, str);
nlen = length(result);
found = false;
 n = 1;
 while ~found && n<=nlen
found = ~isempty(result{n});
n = n +1;
 end

return

