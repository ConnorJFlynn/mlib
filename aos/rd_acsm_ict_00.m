function acsm = rd_acsm_ict_00(infile)
% acsm = rd_acsm_ict_00(infile)
if ~exist('infile','var')||~exist(infile,'file')
   infile = getfullname('*.ict','acsm_itx','Select ACSM ict 00 file.');
end

fid = fopen(infile);

while isempty(strfind(fgetl(fid),'Begin'))&&~feof(fid); end

mark = ftell(fid);
MS = textscan(fid,'%f %f','delimiter',',');
mark2 =ftell(fid);

while isempty(strfind(fgetl(fid),'Begin'))&&~feof(fid); end

mark3 = ftell(fid);
daq_vals = textscan(fid,'%f');
daq_vals = daq_vals{1};
while daq_vals(end)==0 && length(daq_vals>0) 
   daq_vals(end) = [];
end

acsm.MS_filtered = MS{1};
acsm.MS_unfiltered = MS{2};
acsm.daq_vals = daq_vals;

fclose(fid);

return