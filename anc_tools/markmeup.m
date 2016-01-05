function [cfg, dat] = markmeup(cfg);
% [cfg, dat] = markmeup(cfg);
if ~exist('cfg','var')
   % Get primary datastream and field
   while ~exist('primary_ds','var')||isempty(primary_ds)
      primary_ds = getfullname('*.nc', 'primary','Select primary data files');
   end
   [pname, fstem, ext] = fileparts(primary_ds{1});
   primary_ds.pname = [pname, filesep];
   [ds, rest] = strtok(fstem,'.'); dl = strtok(rest,'.');
   primary_ds.datastream = [ds,'.',dl];
   cfg.primary_ds = primary_ds;
   anc = anc_bundle_files(primary_ds);
   primary_field = pickafield(anc);
   % obtain qc for primary field
   % check for existing of qc_field, express as summarized missing, bad,
   % and indeterminate tests.  
   % Option to fold in qc from other qc_fields
   % Define other bad and suspect flags
   % Replace all bad and missing with NaN.
   % Define mentor_bad and mentor_suspect flags
   
   cfg.primary_fig = figure;

   
end




return

function field = pickafield(anc);
 % Strip out the qc fields with matching fields.
   fields = fieldnames(anc.vdata);
   for i = length(fields):-1:1
      blah = findstr(fields{i},'qc_');
      if (~isempty(blah)&&isfield(anc.vdata, fields{i}((blah+3):end)))||strcmp(fields{i},'time_bounds')
         fields(i) = [];
      end
   end
f = menu_list(fields);   
field = fields{f};
return

function f = menu_list(fields,f);
if ~exist('f','var')
   f= 1;
end
fields_order = fields;
[fields_az,id_to_az] = sort(upper(fields));
[dump, az_to_id] = sort(id_to_az);
first = f;
listed = 1;
while listed >= 0
   
   page = 10;
   last = min([first+page,length(fields)]);
   first = max([1,(last -page)]); %makes sure that we have a full page menu listing
   menu_str = fields(first:last)';
   listed = menu(' ',['Page up','Page down','A-Z','by ID', ' ',menu_str]);
   if listed==1
      %page up list
      if (first ==1)
         first = length(fields) - page;
      elseif first<=page
         first=1;
      else
         first = first - page;
      end
   elseif listed==2
      first = first + page;
      %page down list
      if first == (length(fields))
         first = 1;
      elseif first > (length(fields)-page)
         first = (length(fields)-page);
      end
   elseif listed==3
      %sort list alphabetically
      if strcmp(fields{f},fields_order{f})
         fields = fields_az;
         first = az_to_id(f);
      end
   elseif listed==4
      if strcmp(fields{f},fields_az{f})
         fields = fields_order;
         first = id_to_az(f);
      end
      %sort list by var id
   elseif listed==5
      listed=0;
   else
      %identify selected field
      % Need to fix this to keep track of pages.
      f = first  + listed - 6;
      listed = -1;
      field_str = fields{f};
   end
end
return
