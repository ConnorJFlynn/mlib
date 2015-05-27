function mat = repack_edgar_nc(edgar)
if ~exist('edgar','var')
   edgar =anc_load(getfullname_('*.nc','edgar_nc','Select an Edgar nc file.'));
end
if ~isstruct(edgar)&&exist(edgar,'file')
   edgar =anc_load(edgar);
end
    mat.time = epoch2serial([double(edgar.vdata.base_time)./1000+double(edgar.vdata.time)]);
%     nbPoints = edgar.vars.x_axis.data;
    % xStep = (edgar.mainHeaderBlock.lastX-edgar.mainHeaderBlock.firstX)./(nbPoints-1);
    mat.x = edgar.vdata.x_axis';
    if isfield(edgar.vdata,'laserFrequency')
        mat.laserFrequency = edgar.vdata.laserFrequency;
    end
flags = uint16(zeros(size(mat.time)));
flags = bitset(flags, 6, edgar.vdata.isCBB);
flags = bitset(flags, 5, edgar.vdata.isHBB);
flags = bitset(flags, 3, edgar.vdata.isReverseScan);
flags = bitset(flags, 2, ~edgar.vdata.isReverseScan);
mat.flags = flags;
    
if isfield(edgar.vdata,'nbCoaddedScans')
   mat.coads = edgar.vdata.nbCoaddedScans;
end
mat.scanNb = edgar.vdata.scanNumber;
mat.HBBRawTemp = edgar.vdata.hbbTempRaw;
mat.CBBRawTemp = edgar.vdata.cbbTempRaw;
mat.y = edgar.vdata.y_data';
if isfield(edgar.vdata,'dcLevel')
   mat.Vdc = edgar.vdata.dcLevel;
end


return

