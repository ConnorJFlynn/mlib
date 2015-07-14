function anc = anc_from_pcm
% anc = anc_from_pcm
% This function parses the text output from the PCM into a valid anc
% structure which can then be populated with data, manipulated, and saved
% as a netcdf file.
in_file = 'tmp.20150711.110744602.txt';
in_path = 'C:\Users\d3k014\Documents\MATLAB\';
fid = fopen([in_path, in_file],'r');
fnow = datestr(now,'yyyymmdd.HHMMSSfff');
upath = userpath; upath(end) = [];
fid = fopen([upath,filesep,'tmp.',fnow,'.txt'],'w');
fwrite(fid,'% Paste text output from PCM.  Then save and exit.');
fclose(fid);
anc.fname = ['tmp.',fnow,'.nc'];
open([upath,filesep,'tmp.',fnow,'.txt']);
menu('Select OK when file is ready.','OK')
fid = fopen([upath,filesep,'tmp.',fnow,'.txt'],'r');
% 

in_line = deblank(fgetl(fid));
while isempty(in_line)||strcmp(in_line(1),'%')
   in_line = deblank(fgetl(fid));
end

% define dims
dim_id = 0;
while ~isempty(in_line)
   [dim,len_str] = strtok(in_line,'='); len_str = strtok(len_str,'='); len_str(len_str==' ') = [];
   anc.ncdef.dims.(legalize_fieldname(dim)).id = dim_id; dim_id = dim_id + 1;
   dimname = legalize_fieldname(dim);
   if ~isempty(strfind(len_str,'UNLIMITED'))
      anc.ncdef.dims.(dimname).isunlim = 1;
      anc.ncdef.dims.(dimname).length = 0;
      anc.ncdef.recdim.id = dim_id;
      anc.ncdef.recdim.name = dimname;
      anc.ncdef.recdim.length = anc.ncdef.dims.(dimname).length;
   else
      anc.ncdef.dims.(dimname).isunlim = 0;
      anc.ncdef.dims.(dimname).length = sscanf(len_str,'%d');
   end
   in_line = deblank(fgetl(fid));
end
disp('done defining dims')

% Now define vars (and underlying var attributes)
in_vars = true;
var_id =0;
while in_vars   
   while isempty(in_line)
      in_line = deblank(fgetl(fid));
   end
   if ~isempty(findstr(in_line,':'))&&isempty(findstr(in_line,'='))
      [vname,rest] = strtok(in_line,'()'); vname = legalize_fieldname(deblank(vname));
      ii = findstr(rest,'(')+1; jj = findstr(rest,')')-1;
      vdim_str = rest(ii:jj);
      dtype = rest(findstr(rest,':')+1:end);
      if ~isempty(vdim_str)
         vdims = textscan(vdim_str, '%s','delimiter',',');
      else
         vdims = [];
      end
      anc.ncdef.vars.(vname).id = var_id; var_id = var_id +1;
      anc.ncdef.vars.(vname).datatype = datatype_to_id(dtype);
      if iscell(vdims)
         vdims = vdims{:};
      end
      anc.ncdef.vars.(vname).dims = vdims;
      in_line = deblank(fgetl(fid));
      % Now define vatts
      % define vatts, tricky part might be assigning datatype. 
      % if no colon found, then it is text (char), else parse dtype.
      at_id = 0;
      while ~isempty(in_line)
         [att_name,attdata] = strtok(in_line,'=');
         if ~isempty(attdata)
            att_data = strtok(attdata,'='); len_str(len_str==' ') = [];
         else
            att_data = [];
         end
         [attname, rest] = strtok(att_name,':');
         attname = legalize_fieldname(attname);
         dtype = rest(findstr(rest,':')+1:end);
         if isempty(dtype)
            dtype = 'char';
         end
         
         anc.ncdef.vars.(vname).atts.(attname).id = dim_id;
         anc.ncdef.vars.(vname).atts.(attname).datatype = datatype_to_id(dtype);
         anc.vatts.(vname).(attname) = att_data;
         in_line = deblank(fgetl(fid));
      end
      disp('done defining vatts')
      % done defining vatts

      
   else
      in_vars = false;
   end
   
   
   
end

% define gatts
      in_line = deblank(fgetl(fid));
      % Now define vatts
      % define vatts, tricky part might be assigning datatype. 
      % if no colon found, then it is text (char), else parse dtype.
      at_id = 0;
      while ~isempty(in_line)&&~feof(fid)
         [att_name,attdata] = strtok(in_line,'=');
         if ~isempty(attdata)
            att_data = strtok(attdata,'='); len_str(len_str==' ') = [];
         else
            att_data = [];
         end
         [attname, rest] = strtok(att_name,':');
         attname = legalize_fieldname(attname);
         dtype = rest(findstr(rest,':')+1:end);
         if isempty(dtype)
            dtype = 'char';
         end
         
         anc.ncdef.atts.(attname).id = dim_id;
         anc.ncdef.atts.(attname).datatype = datatype_to_id(dtype);
         anc.gatts.(attname) = att_data;
         in_line = deblank(fgetl(fid));
      end
      disp('done defining gatts')

% done defining gatts

% define aats

fclose(fid); 
delete([upath,filesep,'tmp.',fnow,'.txt']);
anc = fill_mt_anc_vars(anc);

anc = anc_timesync(anc);


return

