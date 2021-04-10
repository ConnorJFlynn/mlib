function [d2_dup_names, d2_dup_files] = dups_in_d2(d1_, d2_, bin_compare);
% [d2_dup_names, d2_dup_files] = dups_in_d2(d1_, d2_, bin_compare);
% Identify files in directory listing d2_ that are duplicates of files in d1_
% Intended to help reduce redundancy and get better organized

% First identify duplicated filenames
% Next, identify duplicate filenames AND sizes
% Next, identify duplicate byte-for-byte content
if ~isavar('d1_')||isempty(d1_)
   d1_ = dirrec(getdir);
end
if ~isavar('d2_')||isempty(d2_)
   d2_ = dirrec(getdir);
end
if ~isavar('bin_compare')||isempty(bin_compare)
   bin_compare = false;
end
if ischar(bin_compare)||iscell(bin_compare)
   bin_compare = strcmpi(bin_compare,'true');
end
if isnumeric(bin_compare)||islogical(bin_compare)
   bin_compare = logical(bin_compare);
end
if ~islogical(bin_compare)
   bin_compare = false;
end
% Create list of duplicated files in both d1_ and d2_
dup_names = dup_flist([d1_;d2_]);
dup_names_ = structarray_to_arraystruct(dup_names);

% Then remove all the duplicates that exist in d1_
d1 = arraystruct_to_structarray(d1_);
d2_dup_names = dup_names; d2_dup_names_ = dup_names_;
d2 = arraystruct_to_structarray(d2_);
d1_dup_names = dup_names; d1_dup_names_ = dup_names_;

for d = length(d2_dup_names_):-1:1
   name_match = strcmp(d1.name,d2_dup_names.name(d));
   path_match = strcmp(d1.folder,d2_dup_names.folder(d));
   if any(name_match&path_match)
      d2_dup_names_(d) = []; d2_dup_names.bytes(d) = [];
      d2_dup_names.date(d) = []; d2_dup_names.datenum(d) = [];
      d2_dup_names.folder(d) = [];  d2_dup_names.isdir(d) = [];
      d2_dup_names.name(d) = [];
   end
end

for d = length(d1_dup_names_):-1:1
   name_match = strcmp(d2.name,d1_dup_names.name(d));
   path_match = strcmp(d2.folder,d1_dup_names.folder(d));
   if any(name_match&path_match)
      d1_dup_names_(d) = []; d1_dup_names.bytes(d) = [];
      d1_dup_names.date(d) = []; d1_dup_names.datenum(d) = [];
      d1_dup_names.folder(d) = [];  d1_dup_names.isdir(d) = [];
      d1_dup_names.name(d) = [];
   end
end

% Now keep only those with same bytes
d2_dup_files = d2_dup_names;
d2_dup_files_ = d2_dup_names_;
for d = length(d2_dup_files_):-1:1
   %    folder_match = strcmp(dup_names.folder, d2_dup_files.folder(d));
   name_match = strcmp(d1_dup_names.name,d2_dup_files.name(d));
   size_match = d1_dup_names.bytes==d2_dup_files.bytes(d);
   file_match = name_match&size_match;
   if ~any(file_match) % It is the only one
%       disp(['Eliminate ',d2_dup_files.name{d},': not same size']);
      d2_dup_files_(d) = [];
      d2_dup_files.bytes(d) = [];d2_dup_files.date(d) = [];d2_dup_files.datenum(d) = [];
      d2_dup_files.folder(d) = [];d2_dup_files.isdir(d) = [];d2_dup_files.name(d) = [];
   end
end
if bin_compare
   % Now keep only byte-for-byte matches unless aborted with keystroke
   for d = length(d2_dup_files_):-1:1
      disp(['Checking duplicate file #',num2str(d),': ',d2_dup_files.name{d}]);
      name_match = strcmp(d1_dup_names.name,d2_dup_files.name(d));
      size_match = d1_dup_names.bytes==d2_dup_files.bytes(d);
      file_match = name_match&size_match;
      maybe = find(file_match);
      if bin_compare
         for mayb = 1:length(maybe)
            m = maybe(mayb);
            file_match(m) = cmp_files([d2_dup_names.folder{d},filesep,d2_dup_names.name{d}],[d1_dup_names.folder{m},filesep,d1_dup_names.name{m}]);
         end
         
         if ~any(file_match)
            disp(['      ',d2_dup_files.name{d},': not exact']);
            d2_dup_files_(d) = [];
            d2_dup_files.bytes(d) = [];d2_dup_files.date(d) = [];d2_dup_files.datenum(d) = [];
            d2_dup_files.folder(d) = [];d2_dup_files.isdir(d) = [];d2_dup_files.name(d) = [];
         end
      end
   end
end
return