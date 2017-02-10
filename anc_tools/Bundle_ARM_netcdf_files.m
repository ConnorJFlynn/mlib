function Bundle_ARM_netcdf_files
% Bundle_ARM_netcdf_files: select one or more ARM netcdf files of the same
% type and save a single bundled file as either netcdf or mat.
try
anc = anc_bundle_files;
catch
   error('All selected files must be netcdf files of the same type.');
end
[pname, fname, ext] = fileparts(anc.fname);
pname = [pname,filesep]; 
[tok,fname] = strtok(fname,'.'); tok_ = [tok,'.']; [tok,fname] = strtok(fname,'.');
tok_tok = [tok_ tok];
ext = ext;
if strcmp(datestr(anc.time(1),'.yyyymmdd'),datestr(anc.time(end),'.yyyymmdd'))
   dstr = datestr(anc.time(1),'.yyyymmdd');
else
   dstr = [datestr(anc.time(1),'.yyyymmdd'),datestr(anc.time(end),'_yyyymmdd')];
end

[FILENAME, PATHNAME] = uiputfile([pname, tok_tok,dstr,ext], 'Save bundled file...');
[~, fname, ext] = fileparts([PATHNAME, FILENAME]);
if strcmp(ext,'.nc')||strcmp(ext,'.cdf')
   anc.fname = [PATHNAME,FILENAME];
   anc.clobber = true;
   anc_save(anc);
elseif strcmp(ext,'.mat')
   anc.fname = [PATHNAME,fname, '.nc'];
   save([PATHNAME FILENAME],'-struct','anc');
else
   disp('Invalid file extension. Select ".nc", ".cdf", or ".mat".')
end
return