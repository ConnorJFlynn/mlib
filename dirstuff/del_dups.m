function del_dups(dup_files,sure)
if ~isavar('sure')||isempty(sure)
   sure = false;
end
if ischar(sure)||iscell(sure)
   sure = strcmpi(sure,'true');
end
if isnumeric(sure)||islogical(sure)
   sure = logical(sure);
end
if ~islogical(sure)
   sure = false;
end

if isavar('dup_files')&&~isempty(dup_files)
   N= length(dup_files);    
   if N == 1
      N = length(dup_files.bytes)
      if N>1
         dup_files = structarray_to_arraystruct(dup_files);
      end
   end
   del = 1;   
   for n = N:-1:1
      delfile = [dup_files(n).folder{:},filesep,dup_files(n).name{:}];
      if ~sure
         del = menu({['Delete file ',dup_files(n).folder{:},];['  ',dup_files(n).name{:}]},'No','Yes', 'Sure')-1;
         if del>1
            sure = true;
         end
      end
         if del>0
            delete(delfile);
         end
      end
   end


return