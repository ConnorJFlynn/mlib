function sourceData = getRadiancesFromFiles(inputFileMCT, inputFileINSB, wnCut)

mct = load(inputFileMCT);
insb = load(inputFileINSB);

baseTime = datenum(double(mct.mainHeaderBlock.date.year),...
    double(mct.mainHeaderBlock.date.month),...
    double(mct.mainHeaderBlock.date.day),...
    double(mct.mainHeaderBlock.date.hours),...
    double(mct.mainHeaderBlock.date.minutes),...
    double(mct.mainHeaderBlock.date.seconds));
nbSubfiles = length(mct.subfiles);

sourceData.date = cell(nbSubfiles, 1);

firstX = mct.mainHeaderBlock.firstX;
lastX = mct.mainHeaderBlock.lastX;
nbPoints = double(mct.mainHeaderBlock.nbPoints);
wnMCT = linspace(firstX, lastX, nbPoints);
mctHighestIndex = min(find(round(wnMCT) == wnCut));

firstX = insb.mainHeaderBlock.firstX;
lastX = insb.mainHeaderBlock.lastX;
nbPoints = double(insb.mainHeaderBlock.nbPoints);
wnINSB = linspace(firstX, lastX, nbPoints);
insbLowestIndex = min(find(round(wnINSB) == wnCut))+1;

sourceData.wn = [wnMCT(1:mctHighestIndex) wnINSB(insbLowestIndex:end)];

sourceData.radiance = zeros(nbSubfiles, length(sourceData.wn));

for i = 1: nbSubfiles;
    % Add the time offset for the subfile since the time creation of the
    % file (basetime + subStartingZ)
    subfileTime = datevec(addtodate(baseTime, round(double(mct.subfiles{i}.subfileHeader.subStartingZ)), 'second'));
    subfileTimeStruct = struct('year', subfileTime(1),...
        'month', subfileTime(2),...
        'day', subfileTime(3),...
        'hour', subfileTime(4),...
        'minute', subfileTime(5),...
        'second', subfileTime(6));
    sourceData.date{i} = subfileTimeStruct;
    
sourceData.radiance(i,:) = [mct.subfiles{i}.subfileData(1:mctHighestIndex) insb.subfiles{i}.subfileData(insbLowestIndex:end)];
end