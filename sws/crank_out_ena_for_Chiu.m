sws_a0_files = getfullname('enasws*.a0.*','sws_a0','Select sws a0 files to process');
resp_fname = (getfullname('*sws*resp_func*.si.*.dat', 'sws_resp'));
% resp_fname = (getfullname('*sws*resp_func*.ir.*.dat', 'sws_resp'));
   try
      resp = load(resp_fname); lambda_nm = resp(:,1); resp_ = resp(:,2); clear resp
      resp.lambda_nm = lambda_nm; clear lambda_nm
      resp.resp = resp_; clear resp_
   catch
      resp = rd_sasze_resp_file(resp_fname);
   end
      
for f = 234:length(sws_a0_files) 

   if foundstr(sws_a0_files(f), 'swsvisC1.a0.')
      out_file = strrep(sws_a0_files(f),'swsvisC1.a0.','swsvisradC1.a1.');
   elseif foundstr(sws_a0_files(f), 'swsnirC1.a0.')
      out_file = strrep(sws_a0_files(f),'swsnirC1.a0.','swsnirradC1.a1.');
   else
      out_file = [];
   end
   out_file = out_file{1};
   close('all')
   sprintf('File %d of %d: %s',f, length(sws_a0_files),sws_a0_files{f})
   
   if ~isafile(out_file)
      tic; proc_sws_a0(anc_load(sws_a0_files{f}), resp);toc
      pause(3);
   else
      [pn, out_file,ext] = fileparts(out_file); out_file = [out_file, ext];
      sprintf('Skipping existing file %s',out_file)
   end
end