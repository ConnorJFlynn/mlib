function mat = enc2mat(nc)
% Populated a mat struct from Edgar generated netcdf
mat.time = now +  double(nc.vars.time.data)./(24*60*60);
mat.coads = nc.vars.nbCoaddedScans.data;
mat.scanNb = nc.vars.scanNumber.data;
mat.HBBRawTemp = nc.vars.hbbTempRaw.data;
mat.HBB_C =mat.HBBRawTemp./nc.vars.BBTempDivider.data;
mat.CBBRawTemp = nc.vars.cbbTempRaw.data;
mat.CBB_C =mat.CBBRawTemp./nc.vars.BBTempDivider.data;
mat.laserFrequency = nc.vars.laserFrequency.data;
mat.y = nc.vars.y_data.data;
mat.flags = zeros(size(mat.time), 'uint8');
mat.flags = bitset(mat.flags,2,nc.vars.isForwardScan.data);
mat.flags = bitset(mat.flags,3,nc.vars.isReverseScan.data);
mat.flags = bitset(mat.flags,5,nc.vars.isHBB.data);
mat.flags = bitset(mat.flags,6,nc.vars.isCBB.data);

return
