function [cfg, dat] = markmeup(cfg);
% [cfg, dat] = markmeup(cfg);

   % OK, what are we trying to do?  
   % For the primary field being assessed we'll have two sets of figure windows.
   % One set has two figures with linked x-axes
   %     The first shows all originally supplied data with color coding.
   %     The second is a QA color image
   % Second set has N-figures with linked x-axes
   %     The first shows only non-bad values with yellow, blue, cyan,
   %     green, and maybe bright green for indet, noted, noted&indet, not
   %     (noted or indet), re-good
   %     Arbitrary number of other aux plots from this or other DS
   % One showing only non-bad values.
   % Another showing all originally supplied data values with 
   % color coding as follows
   % for each flag: bad, suspect, notable
   % first plot all non-missing as green dots or solid circles
   % next plot all non-missing and non-bad as yellow dots or solid circles
   % next plot all bad as red or gray dots or solid circles
   % lastly plot all notables as blue circles.
   % And another showing the QC color image with black for missing, red for
   % bad, yellow for suspect, cyan for notable but suspect, blue for suspect
   % and not bad or suspect, and green for not bad, suspect, or notable,
   % and maybe bright green for mentor-reassigned good.
   
   % Incoming QC info is rolled up into bad (and cast to missing), indet,
   % notable, re-assigned good.  
   % Then this is potentially augmented with QC from other fields (rolled
   % into these same categories), QC from DQRs, and mentor-defined flags
   % and marks. 
   % Each mentor defined flag needs assessments of bad, indet, notable
   % Possibly will support re-good which will clear incoming indet states

   % The user may also specify an arbitrary number of auxiliary plots, each
   % containing one or more traces from any loaded datastream.
   % Zooming into these plots and then selecting defined flags will permit
   % mentor assessment.  
   % Possible approach: If zooming into the primary assessed field, then
   % the QC is assigned to that field only, but if zooming into an aux
   % window then QC is applied to "time" in the primary datastream which is 
   % equivalent to applying it for all fields. 
   % How to do the selecting?  
   %  1. Define flag mode ([toggle], set, clear)
   %  2. Define selection mode ([inside], outside, before, during, after, above, between, below)
   %  3. Select the desired flag. (With flag mode of toggle, two clicks on
   %  flag will act like undo.)
   
   % Operationally, the user will supply QA for a given field until
   % satisfied.  Then they can export the QA for the primary field and if
   % desired any others in the datastream as mark files.
   % At any point, the user may opt to change to another field from any DS, existng or new.
   % They will be prompted to output the current QA.
   
   % Current primary displays are preserved and will be regenerated if the
   % user deletes them. Aux displays are not preserved and may be deleted
   % or added at will.
   
   % Data from datastreams are copied into figure-specific structures so
   % can be deleted to free space.  Similarly, the displayed x-limits of
   % the current figure can be used to trim the datastreams and figure data
   % sets. 
   
   %main operational menus:
   % SETUP:
   %   1. Select primary field
   %   2. Add aux figure
   %   3. Add plot to selected aux figure.
   %   4. Define flag: label and assessment
   %   5. Define mark
   %   6. Import DQR (used for iniital time range and assessment, but applied to
   %   current primary field irrespective if listed)
   %   7. Export QA to marks (select from list of flags/marks or all)
   %   8. Export as DQR (by QA states "Bad", "Suspect","Noted/transparent")   
   %   9. Save configuration (datastreams, primary fields, aux plots,
   %   flags, marks)
   % Assess:
   %  1. Setup figs and menus
   %  2. Select timeframe: years, mmm, doys, hs, ii, or dynamic
   %  3. Flag mode: TOGGLE/set/clear
   %  4. Selection mode: INSIDE, outside, before, during, after, above, between, below
   %  5. Mentor BAD
   %  6. Mentor Suspect
   %  7. Mentor Noted
   %  8. Mentor NOT Suspect
   
      
   % any element that has a "bad" flag will be colored red or black.
   % any element that has no
   % For primary figure, allow 1 primary field color data values initially
   % as grey dots, then overlay with ~bad as yellow, then ~bad | 
   
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
   cfg.primary_fig.h = figure;
   cfg.primary_fig.ds = primary_ds.datastream;
   cfg.primary_fig.field = primary_field;

   
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
