function mfr = ingest_mfr(filename);
if ~exist('filename', 'var')
   [fname, pname] = uigetfile('*.*');
   filename = fullfile(pname, fname);
end
if ~exist(filename, 'file')|(exist(filename, 'dir'))
   if exist(filename, 'dir')
     [fname, pname] = uigetfile([filename,'/','*.*']);
   else
      [fname, pname] = uigetfile(['*.*']);
   end;
   filename = [pname, fname];
end

if exist(filename, 'file')&~exist(filename, 'dir')
   mfr = read_rsr_v4(filename);
   mfr.recdim.name = 'time';
   mfr.recdim.id = 0;
   mfr.recdim.length = length(mfr.time);
   mfr = timesync(mfr);
   mfr = anccheck(mfr);
   mfr = rmfield(mfr,'atts');
   mfr.clobber = true;
   [pname, fname, ext] = fileparts(mfr.fname);
   mfr.fname = [pname,'\' fname, '.nc'];
   status = ancsave(mfr);
end

   %cleanup rsr header
   %timesync
   %anc_check
   %What else?