function mat = cat_time_mats(infiles)

if ~isavar('infiles')
   infiles = getfullname('*.mat','mat_files','Select mat files to concatenate by time');
end

mat_ = load(infiles{1});
mat = mat_;
fields = fieldnames(mat);
fields = fields(~foundstr(fields,'time'));
[rows,cols] = size(mat.time);
if rows==1
   for f = 2:length(infiles)
      mat_ = load(infiles{f});
      [mat.time,ind] = unique([mat.time, mat_.time]);
      for fld = 1:length(fields)
         field = fields{fld};
         tmp = [mat.(field), mat_.(field)];
         mat.(field) = tmp(ind);
      end
   end
elseif cols==1
   for f = 2:length(infiles)
      mat_ = load(infiles{f});
      [mat.time,ind] = unique([mat.time; mat_.time]);
      for fld = 1:length(fields)
         field = fields{fld};
         tmp = [mat.(field); mat_.(field)];
         mat.(field) = tmp(ind);
      end
   end
end

end
