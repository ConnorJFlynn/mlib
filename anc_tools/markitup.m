function [cfg, dat] = markitup(cfg);
% [cfg, dat] = markit+++up(cfg);
if ~exist('cfg','var')
   % Get primary datastream and field
   while ~exist('datafiles','var')||isempty(datafiles)
      datafiles = getfullname('*.nc', 'primary','Select primary data files');
      if ~iscell(datafiles)&&ischar(datafiles)
          dfile{1} = datafiles;
          datafiles = dfile;
      end
   end
   
   [pname, fstem, ext] = fileparts(datafiles{1});
   primary_ds.pname = [pname, filesep];
   [ds, rest] = strtok(fstem,'.'); dl = strtok(rest,'.');
   primary_ds.datastream = [ds,'.',dl];
   cfg.primary_ds = primary_ds;
   anc_1 = anc_bundle_files(datafiles);
   primary_field = pickafield(anc_1);
   disp(primary_field)
   % obtain qc for primary field
   qc_field = ['qc_',primary_field];
   
   if isfield(anc_1.vdata,qc_field);
       primary_qc = anc_qc_impacts(anc_1.vdata.(qc_field), anc_1.vatts.(qc_field));
   else
      primary_qc = zeros(size(anc_1.vdata.(primary_field)));
   end
   more_qc = true;
   while more_qc
       qc_reply = menu('Roll in QC from another field?','Yes','No')==1;
       if qc_reply
           aux_qc_field = pickaqcfield(anc_1);
           aux_qc = anc_qc_impacts(anc_1.vdata.(aux_qc_field), anc_1.vatts.(aux_qc_field));
           primary_qc = max(primary_qc, aux_qc);
       else
           more_qc = false;
       end
   end
   % Future, fold in DQR info.  Lot of potential here, lots of potential
   % trouble too.

   % Populate data block, replace missing with  NaN.

   primary_datablock = anc_1.vdata.(primary_field);
   missing = -9999; %might need to handle this differently to respect type of original data.
   primary_datablock(primary_datablock==missing) = NaN;   
   
   condition.label{1} = 'qc_BAD';
   condition.impact(1) = 2;
   condition.True(1,:) = primary_qc==2;
   condition.label{2} = 'qc_INDET';
   condition.impact(2) = 1;
   condition.True(2,:) = primary_qc==1;
   
   % Replace bad values (based on initial qc) with missing
      primary_datablock(condition.True(condition.impact==2,:)) = NaN;

   % Define mentor_bad and mentor_suspect flags
   condition.label{3} = 'marked_BAD';
   condition.impact(3) = 2;
   condition.True(3,:) = false;
   condition.label{4} = 'marked_SUSPECT';
   condition.impact(4) = 1;
   condition.True(4,:) = false;

   more_tests = true;
   while more_tests
     more_tests = menu('Define additional tests for visually flagging data (BAD, Suspect, Noted)?','Yes','No, done')==1
     if more_tests
         new_test = define_mentor_test;
         condition.label(end+1) = new_test.label;
         condition.impact(end+1) = new_test.impact;
         condition.True(end+1,:) = false;
     end
   end
   
   % OK, what are we trying to do?  
   % For the primary field being assessed we'll have two sets of figure windows.
   % One set has two figures with linked x-axes
   %     The first shows all originally supplied data with color coding.
   %     The second is a QA color image (generated from "condition")
   % Second set has N-figures with linked x-axes
   %     The first shows only non-bad values of primary with yellow, blue, cyan,
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
   % window then QC is applied for all fields. 
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
   
   cfg.primary_fig = figure;

   
end




return

function field = pickafield(anc);
 % Strip out the qc fields with matching fields.
   fields = fieldnames(anc.vdata);
   recdim = anc.ncdef.recdim.name;
   if isempty(recdim) && isfield(anc.ncdef.dims,'time')
       recdim = 'time'; % if no recdim but time exists, use time anyway
   end
   for i = length(fields):-1:1
      blah = strfind(fields{i},'qc_');
      norecdim = ~any(strcmp(anc.ncdef.vars.(fields{i}).dims,recdim));
      if norecdim || strcmp(fields{i},recdim) || strcmp(fields{i},'time_bounds') ...
              || strcmp(fields{i},'time_offset') || (~isempty(blah)&&isfield(anc.vdata, fields{i}((blah+3):end))) 
         fields(i) = [];
      end
   end
f = menu_list(fields);   
field = fields{f};
return

function field = pickaqcfield(anc);
 % Keep only field names for which qc fields also exist. 
   fields = fieldnames(anc.vdata);
   recdim = anc.ncdef.recdim.name;
   if isempty(recdim) && isfield(anc.ncdef.dims,'time')
       recdim = 'time'; % if no recdim but time exists, use time anyway
   end
   for i = length(fields):-1:1

      norecdim = ~any(strcmp(anc.ncdef.vars.(fields{i}).dims,recdim));
      if norecdim || ~isfield(anc.vdata,['qc_',fields{i}])
         fields(i) = [];
      end
   end
f = menu_list(fields);   
field = ['qc_',fields{f}];
return

function f = menu_list(fields,f);
if ~exist('f','var')
   f= 1;
end
fields_order = fields;
[fields_az,id_to_az] = sort(upper(fields)); fields_az = fields(id_to_az);
[dump, az_to_id] = sort(id_to_az);
first = f;
listed = 1;
byID = true;
while listed >= 0
   
   page = 15;
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
         byID = false;
      end
   elseif listed==4
      if strcmp(fields{f},fields_az{f})
         fields = fields_order;
         first = id_to_az(f);
         byID = true;
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
if ~byID
    f = az_to_id(f);
end
return


function test = define_mentor_test;
label = input('Enter a label for the flag or test.','s')
while ~isempty(label)&&strcmp(label(1),' ')
    label(1) = [];
end
label = deblank(label);
test.label = label;
if ~isempty(test.label)
    impact = menu('Assign an impact to this test: Notable (not bad or suspect), Suspect, or BAD','Notable','Suspect','BAD')-1;
end

return