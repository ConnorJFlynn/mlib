function status = write_out_bsrn(outdir, mfr)
% Write out monthly BSRN file from monthly mfr file
if ~exist('outdir','var')||~exist(outdir,'dir')
   outdir = uigetdir;
end
if ~exist('mfr','var')
   mfr = ancload;
end
bsrn = cnv_mfr2bsrn(mfr);
SSS = sprintf('%03d',sscanf(bsrn.header.bsrnidnumber,'%d'));
YYYY = sprintf('%04d',sscanf(bsrn.header.year,'%d'));
MM= sprintf('%02d',sscanf(bsrn.header.month,'%d'));
fid = fopen([outdir,filesep,SSS,YYYY,MM,'.trntxtl'],'w');

% Open ascii file for output in outdir

%Output header info:
fprintf(fid,'%s\n','[HEADER]');
header_fields = fieldnames(bsrn.header);
for h = 1:length(header_fields)
   hstr = ['%',upper(header_fields{h}),'=',bsrn.header.(header_fields{h})];
   fprintf(fid,'%s\n',hstr);
end
fprintf(fid,'%s\n','[/HEADER]');   

%Output calib info:
fprintf(fid,'%s\n','[SUNCALIB]');
calib_fields = fieldnames(bsrn.calib);
for h = 1:length(calib_fields)
   cstr = ['%',upper(calib_fields{h}),'=',bsrn.calib.(calib_fields{h})];
   fprintf(fid,'%s\n',cstr);
end
fprintf(fid,'%s\n','[/SUNCALIB]');  

%Output data:
fprintf(fid,'%s\n','[SUNTRANS]');
format_str = [' %2d %4d-%02d-%02d %5d %5.1f %6.3f %6.1f %6.1f %6.1f '];
trn_str = ['%6d '];
trn_str = repmat(trn_str,[1,sscanf(bsrn.calib.sunnochannels1,'%d')]);
format_str = [format_str, trn_str,' \n'];
status = fprintf(fid,format_str,bsrn.data');
fprintf(fid,'%s\n','[/SUNTRANS]');  

fclose(fid);