function [a,b] = getl(b)
[matchstart,matchend,tokenindices,matchstring,tokenstring, tokenname,splitstring] = regexp(b,[char(13), char(10)]);
a = splitstring{1};
b = b(matchend(1):end);
end