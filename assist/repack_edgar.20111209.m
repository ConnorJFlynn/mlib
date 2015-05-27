function mat = repack_edgar(edgar)
if ~exist('edgar','var')
   edgar =loadinto(getfullname_('*.mat','edgar_mat','Select an Edgar mat file.'));
end
if ~isstruct(edgar)&&exist(edgar,'file')
   edgar =loadinto(edgar);
end
if isfield(edgar,'mainHeaderBlock')
    V = double([edgar.mainHeaderBlock.date.year,edgar.mainHeaderBlock.date.month,...
        edgar.mainHeaderBlock.date.day,edgar.mainHeaderBlock.date.hours,...
        edgar.mainHeaderBlock.date.minutes,edgar.mainHeaderBlock.date.seconds]);
    nbPoints = edgar.mainHeaderBlock.nbPoints;
    % xStep = (edgar.mainHeaderBlock.lastX-edgar.mainHeaderBlock.firstX)./(nbPoints-1);
    mat.x = linspace(edgar.mainHeaderBlock.firstX, (edgar.mainHeaderBlock.lastX), double(nbPoints));
    if isfield(edgar.mainHeaderBlock,'laserFrequency')
        mat.laserFrequency = edgar.mainHeaderBlock.laserFrequency;
    end
    
    base_time = datenum(V);
end
if ~isfield(edgar,'subfiles')&isfield(edgar,'subfileData')
    edgar.subfiles{1}.subfileHeader = edgar.subfileHeader;
    edgar.subfiles{1}.subfileData = edgar.subfileData;
    edgar = rmfield(edgar, 'subfileHeader');
    edgar = rmfield(edgar, 'subfileData');
end
subs = length(edgar.subfiles);
for s = subs:-1:1
if exist('base_time','var')
mat.time(s) = base_time +  double(edgar.subfiles{s}.subfileHeader.subStartingZ)./(24*60*60);
end
mat.flags(s) = edgar.subfiles{s}.subfileHeader.subFlags;
if isfield(edgar.subfiles{s}.subfileHeader,'nbCoaddedScans')
   mat.coads(s) = edgar.subfiles{s}.subfileHeader.nbCoaddedScans;
end
mat.subIndex(s) = edgar.subfiles{s}.subfileHeader.subIndex;
mat.scanNb(s) = edgar.subfiles{s}.subfileHeader.scanNb;
mat.HBBRawTemp(s) = edgar.subfiles{s}.subfileHeader.subHBBRawTemp;
mat.CBBRawTemp(s) = edgar.subfiles{s}.subfileHeader.subCBBRawTemp;
if isfield(edgar.subfiles{s}.subfileHeader,'zpdLocation')
mat.zpdLocation(s) = edgar.subfiles{s}.subfileHeader.zpdLocation;
end
if isfield(edgar.subfiles{s}.subfileHeader,'zpdValue')
mat.zpdValue(s) = edgar.subfiles{s}.subfileHeader.zpdValue;
end
mat.y(s,:) = edgar.subfiles{s}.subfileData;
end
mat.flags = uint8(mat.flags);
return
