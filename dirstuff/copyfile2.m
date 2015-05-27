function status = copyfile2(infile,outfile);
if exist('infile','var')&&exist(infile,'file')&&~exist(infile,'dir')
   %Then infile is a proper input filename
   if exist('outfile','var')&&~exist(outfile,'file')
      fid_in = fopen(infile);
      fid_out = fopen(outfile,'w');
      last = fseek(fid_in,0,1);
      last = ftell(fid_in); fseek(fid_in,0,-1);
      if fid_in>0&&fid_out>0
         for b = 1:1e6:last
            status = fwrite(fid_out,fread(fid_in,1e6,'uchar'),'uchar');
         end
         cur = ftell(fid_in);
         status = fwrite(fid_out,fread(fid_in,'uchar'),'uchar');
      end
         fclose(fid_in);
         fclose(fid_out);
   end
end
         