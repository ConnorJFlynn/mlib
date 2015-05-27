%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ReadEdgarFile
% (c) 2007-2009
% Ionetrics, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Data = ReadEdgarFile(fileName, subStart, subEnd)

if exist(fileName, 'file') ~= 2
  return;  %file does not exist
end

file = fopen(fileName,'rb','l');
if file==-1
  error(['Problem opening file ' fileName]);
end

Data.Header = spcReadHeader(file);

if subEnd == -1
  subEnd = Data.Header.fnsub;
end

if (subEnd - subStart < 0)
  error('Wrong start and end subfile numbers');
end

Data.y = zeros(subEnd - subStart + 1, Data.Header.fnpts);

for ll = subStart:subEnd
    %if (ll <= Data.Header.fnsub)
        spcData = spcReadData(file, Data.Header, ll);
        Data.y(ll,:) = spcData.y;
       %   else
       % error('Subfile number out of range');
       %end
end
Data.x = spcData.x;

fclose (file);

return;
