function dearmify

   infile = getfullname('*.*','arm_raw');

   if ischar(infile)
      infile = {infile};
   end
   for f = 1:length(infile)
      if isafile(infile{f})&&~isadir(infile{f})
         [pname, fname, ext] = fileparts(infile{f});
         pname = [pname, filesep]; 
         emanf = fliplr(fname); eman = strtok(emanf,'.');
         name = fliplr(eman);
         movefile(infile{f}, [pname,name, ext],'f');
      end
   end

end