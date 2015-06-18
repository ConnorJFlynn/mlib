function buffer = read_L3_grid_file(filename,content_flag,content_list,gridname)

%   function buffer = read_L3_grid_file(filename,content_flag,content_list,gridname)
%
% Created by Stephen Licata on 03-17-2005.
%
% DESCRIPTION:
% This function reads a Level 1 or 2 granule data file in the HDF-EOS format
% and extracts one of the following information types into a data buffer:
%
% DESCRIPTION:
% This function reads a Level 3 granule data file in the HDF-EOS format
% and extracts one of the following information types into a data buffer:
%
% INPUT ARGUMENTS (REQUIRED)
%
% filename  - The fully qualified path to a Level 3 EOS-HDF grid format granule file.
%
% content_flag - An integer (0-3) that specifies the type of data to be extracted, as follows:
%                0: A text string showing the name of the grid(s) in that file.
%                1: The name and values of the grid's dimension parameters.
%                2: The name and values of the grid's attribute parameters.
%                3: The name and values of the grid's data field parameters.
%
% INPUT ARGUMENTS [OPTIONAL]:
%
% content_list - An array of names for the content items to be returned. If left unspecified,
%                the function will return ALL the parameters in that content category.
% gridname     - A text expression for the data grid within the granule file that is to be
%                examined. This function will only process one data grid at a time. In the
%                (typical) case that there is only ONE data grid in the granule file, this
%                argument can be left unspecified.
%
% RETURN VALUES:
%
% buffer       - IDL data structure with fields of parameter name/parameter value.
%                Type "help,buffer,/struct" at the IDL command line for details.
%                The buffer parameter will be empty ([]) if the function fails.
%
% SIDE EFFECTS:
%
%              Parameter names in the input file containing with a period character will be saved
%              in the output data structure buffer) with an underscore in place of the period.

   prog_name = 'read_L3_grid_file';

   buffer = [];

   if ~exist('gridname','var')
      gridname = [];
   end

   if ~exist('content_list','var')
      content_list = {};
   end

   if ischar(content_list)
      tmp = content_list;
      content_list = {tmp};
      clear tmp
   end

% Abort the program if no data file has been provided.
   if isempty(filename)
      disp([prog_name ': ERROR - No input filename was specified.'])
      return
   end

% Abort the program if no data type has been specified.
   if isempty(content_flag)
      disp([prog_name ': ERROR - No content code (type) was provided.'])
      return
   end

% Set up a set of names (labels) for the different types of data queries.
   type_list = {'grid','dimension','attribute','field'};

% Get a file id value.
   fid   = hdfgd('open',filename,'read');

% Abort the program if the file does not exist or cannot be read.
   if fid == -1
      disp([prog_name ': ERROR - ' filename ' could not be opened.'])
      status = hdfgd('close', fid);
      return
   end

% Get the number of data grids in the file (normally just 1)
   [ngrid,gridlist] = hdfgd('inqgrid',filename);

% Abort the program if no data grid(s) is/are found.
   if ngrid == 0 | isempty(gridlist)
      disp([prog_name ': ERROR - ' filename ' has no data grid.'])
      status = hdfgd('close', fid);
      return;
   end

% If only the grid list is requested, return that text string and end the program.
   if content_flag == 0
      buffer = gridlist;
      status = hdfgd('close', fid);
      return;
   end

% Accept a user-specified data grid name or the first (and only) available grid within the file.
% Only continue processing if the data set is confined to a single grid.
   if ~isempty(gridname)
      gridname = gridname;
   else
      gridname = gridlist;
   end

% Abort the program if more than one data grid can be extracted from 'gridname'.
   if ~isempty(findstr(gridname,','))
      disp([prog_name ': ERROR - This file contains multiple data grids - Choose just one.'])
      disp([prog_name ': Swath List = ' gridname])
      status = hdfgd('close', fid);
      return;
   end

% Attach an ID to this grid.
   grid_id = hdfgd('attach', fid, gridname);
   if (grid_id == -1)
      disp([prog_name ': ERROR - Unable to open grid ' gridname])
      status = hdfgd('detach',grid_id);
      status = hdfgd('close', fid);
      return;
   end

% Select the content list (i.e., set of parameter names) from the grid itself
% unless these names are specified directly by the user.
   var_list1 = [];
   list1     = {};
   if isempty(content_list)
      switch content_flag
         case {1}
            [ndims,var_list1,dims] = hdfgd('inqdims',grid_id);
            if ndims == 0
               disp([prog_name ': ERROR - No data dimensions were located.'])
               status = hdfgd('detach',grid_id);
               status = hdfgd('close', fid);
            end
         case {2}
            [nattrib,var_list1]    = hdfgd('inqattrs',grid_id);
            if nattrib == 0
               disp([prog_name ': ERROR - No data attributes were located.'])
               status = hdfgd('detach',grid_id);
               status = hdfgd('close', fid);
            end
         case {3}
            [nfields,var_list1,rank,ntype] = hdfgd('inqfields',grid_id);
            if nfields == 0
               disp([prog_name ': ERROR - No data fields were located.'])
               status = hdfgd('detach',grid_id);
               status = hdfgd('close', fid);
            end
         otherwise
            disp([prog_name ': ERROR - No content list (based on content flag) was generated.'])
            status = hdfgd('detach',grid_id);
            status = hdfgd('close', fid);
            return;
      end
   end

% Now convert one or both comma-delimited text strings (var_list1 and/or var_list2)
% into a cell array of parameter names.
   if isempty(content_list)
      if ~isempty(var_list1)
         list1 = {};
         rem   = var_list1;
         while ~isempty(rem)
            [part_name,rem] = strtok(rem,',');
            list1 = cat(2,list1,{part_name});
         end
      end
      content_list = list1;
   end
   
% Abort the program if the content list is just a single blank string entry.
   if length(content_list) == 1 & length(content_list{1}) == 0
      disp([prog_name ': ERROR - No set of ' type_list{content_flag} ' parameter names was specified.'])
      status = hdfgd('detach',grid_id);
      status = hdfgd('close', fid);
      return
   end

% Abort the program if the content list is still undefined.
   if isempty(content_list)
      disp([prog_name ': ERROR - No set of ' type_list{content_flag} ' parameter names was specified.'])
      status = hdfgd('detach',grid_id);
      status = hdfgd('close', fid);
      return
   end

   buffer = [];

   for i = 1:length(content_list)

      item_name = content_list{i};

% Discard any parameter names that have a '=' sign in the name.
% NOTE: This is an optional feature based on experience with these data files.
      if ~isempty(findstr(item_name,'=')) 
         continue;
      end

% Extract the data value based on the parameter name and data type.
      switch content_flag
         case {1}
            [item_val     ] = hdfgd('diminfo',grid_id,item_name);
         case {2}
            [item_val,fail] = hdfgd('readattr',grid_id,item_name);
         case {3}
            [item_val,fail] = hdfgd('readfield',grid_id,item_name,[],[],[]);
         otherwise
            disp([prog_name ': ERROR - No valid content flag was specified.'])
            status = hdfgd('detach',grid_id);
            status = hdfgd('close', fid);
            return;
      end

      if ~isempty(item_val) 

% Now replace any '.' characters in the parameter name with '_'.
         if ~isempty(findstr(item_name,'.'))
            new_name  = strrep(item_name,'.','_');
            item_name = new_name;
         end

% Now add that parameter data set as a field to the buffer structure.
         if ~isfield(buffer,item_name)
            eval(['buffer.' item_name ' = item_val;'])
         end

      end

   end

   status = hdfgd('detach',grid_id);
   status = hdfgd('close', fid);


