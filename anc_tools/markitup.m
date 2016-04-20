function [cfg, dat] = markitup(cfg);
% [cfg, dat] = markit+++up(cfg);
% if cfg is not passed in then prompt to load one.
% If passed in or loaded then use it to load datastream(s), define QA, and 
% generate an initial array of plots.
% If not passed in and not loaded, then do the above manually and define a
% new cfg.

if ~exist('cfg','var')
    cfg_name = getfullname('*.cfg','QA_cfg','Select an existing QA configuration file');
    if exist(cfg_name,'file')
        try
            cfg = load(cfg_name,'-mat');
            cfg.cfg_name = cfg_name;
        catch
            cfg = [];
        end
    else
        cfg = [];
    end    % load an existing saved cfg or cancel to make a new one interactively
end
if isempty(cfg)
    % cfg is empty, so we need to define all relevant elements
    % Get primary datastream and field
    
    filelist = [];
    cfg.ds_manual_mode(1) = true;
    while isempty(filelist)
        filelist = getfullname('*.nc','primary','Select file(s) in datastream directory to review');
    end
    if iscell(filelist)
        cfg.ds_path = [fileparts(filelist{1}) filesep];
    else
        cfg.ds_path = [fileparts(filelist) filesep];
        select_mode = menu('Load all files in selected directory?','Yes,','No');
        if select_mode == 1
            cfg.ds_manual_mode(1) = false;
            [dirlist,pname] = dir_('*.nc;*.cdf','primary');
            filelist = dirlist_to_filelist(dirlist,pname);
        else
            filelist = {filelist};
        end
    end
    [a,b,c] = fileparts(filelist{1});
    [ds, part] = strtok(b,'.'); ds = [ds,'.',strtok(part,'.')];
    cfg.ds(1) = {ds};
    anc = anc_bundle_files(filelist);
    anc = {anc};
    % Now pick a field to review.
    % For  now, limit to 1D time series data
    disp('Select a data field to review.')
    primary_field = pickafield(anc{1});
    cfg.primary_field = primary_field;
    cfg.primary_ds = cfg.ds{1};
    disp(primary_field)
    % obtain qc for primary field
    qc_field = ['qc_',primary_field];
    primary.field = primary_field;
    if isfield(anc{1}.vdata,qc_field);
        primary.qc = anc_qc_impacts(anc{1}.vdata.(qc_field), anc{1}.vatts.(qc_field));
        primary.qc_fields = {qc_field};
    else
        primary.qc = zeros(size(anc{1}.vdata.(primary_field)));
        primary.qc_fields = {};
    end
    
    primary.data = anc{1}.vdata.(primary_field);
    missing = -9999; %might need to handle this differently to respect type of original data.
%     primary.data(primary.data==missing) = NaN;
    primary.time = anc{1}.time;
    
    more_qc = true;
    addt_qc = primary.qc;
    while more_qc
        qc_reply = menu('Roll in QC from another field in the datastream?','Yes','No')==1;
        if qc_reply
            aux_qc_field = pickaqcfield(anc{1});
            aux_qc = anc_qc_impacts(anc{1}.vdata.(aux_qc_field), anc{1}.vatts.(aux_qc_field));
            % here would be the place to plot QA'd data for this field for
            % review before rolling in
            addt_qc = max(primary.qc, aux_qc);
%             accept = menu('Accept or reject this additional QC?', 'accept','reject')
%             if accept < 2
                primary.qc = addt_qc;
                primary.qc_fields(end+1) = {aux_qc_field};
%             end
        else
            more_qc = false;
        end
    end    
    
    % Populate data block, replace missing with  NaN.
            
    condition.label{1} = 'qc_BAD';
    condition.impact(1) = 2;
    condition.True(1,:) = primary.qc ==2;
    condition.label{2} = 'qc_INDET';
    condition.impact(2) = 1;
    condition.True(2,:) = primary.qc==1;
    
    % Replace bad values (based on initial qc) with missing
    

    
    % Define mentor_bad and mentor_suspect flags
    condition.label{3} = 'marked_BAD';
    condition.impact(3) = 2;
    condition.True(3,:) = false;
    condition.label{4} = 'marked_SUSPECT';
    condition.impact(4) = 1;
    condition.True(4,:) = false;
    

    % Future, fold in DQR info.  Lot of potential here, lots of potential
    % trouble too.
    
    more_tests = true;
    while more_tests
        more_tests = menu('Define additional events and tests to use for visually flagging data?','Yes','No, done')==1
        if more_tests
            new_test = define_mentor_test;
            condition.label(end+1) = {new_test.label};
            condition.impact(end+1) = new_test.impact;
            condition.True(end+1,:) = false;
        end
    end
    
    condition.label{end+1} = 'determined_GOOD';
    condition.impact(end+1) = -2;
    condition.True(end+1,:) = false;
    
    primary.hide_bad = zeros(size(primary.data));
    primary.hide_bad(any(condition.True(condition.impact==2,:),1)) = NaN;
    
    cfg.primary_fig_A = figure;
    % this gets tricky.  
    bad = any(condition.True(condition.impact==2,:),1) & ~(any(condition.True(condition.impact==-2,:),1));
    good = any(condition.True(condition.impact==-2,:),1) | (~(any(condition.True(condition.impact==2,:),1)|any(condition.True(condition.impact==1,:),1)));
    grn = any(condition.True(condition.impact==-2,:),1) | ~any(condition.True(condition.impact==1,:),1); % this relies on bad being hidden as NaN
    yel = any(condition.True(condition.impact==1,:),1);
    blue = any(condition.True(condition.impact==0,:),1) & grn; % "noted" but not suspect
    cyan = any(condition.True(condition.impact==0,:),1) & yel; % "noted"
    br_grn = any(condition.True(condition.impact==-2,:),1) &any(condition.True(condition.impact==1,:),1);
    events = any(condition.True(condition.impact==-1,:),1);
    mint = min(primary.time); maxt = max(primary.time);
    plot([mint,primary.time(good),maxt],[NaN,primary.data(good),NaN],'go'); yl = ylim;
    ax(1) = gca;

    these = plot( ...
        [mint,primary.time(grn|br_grn),maxt],[NaN,primary.data(grn|br_grn), NaN]+[NaN,primary.hide_bad(grn|br_grn),NaN],'g.',...
        [mint,primary.time(yel),maxt],[NaN,primary.data(yel), NaN]+[NaN,primary.hide_bad(yel),NaN],'y.',...
        [mint,primary.time(bad),maxt],[NaN,primary.data(bad), NaN]+[NaN,primary.hide_bad(bad),NaN],'r.');
    yyll = ylim; 
    st = [primary.time(events); primary.time(events);primary.time(events)];
    st3 = st(:);
    evs = repmat([NaN;-top;top],[sum(events),1]);
    hold('on'), plot([mint,st3,maxt], [NaN,evs,NaN],'m--'); hold('off'); ylim(yyll)
    legend('good','suspect','bad','events')
    set(these(1),'color',[0, .7, 0]);
    set(these(2),'color',[1, .8, 0]);
    dynamicDateTicks;
    % br_g=-2, blue=-1, g = 0, yel = 1, red = 2];
    
    ryg =      [0     1     0; 0 0 1; 0 .7 0; 1 .8 0 ; 1 0 0 ];
ryg_w = [[1,1,1];ryg];
    QA = double(condition.True).*(condition.impact'*ones([1,length(primary.time)]));
    QA(~condition.True) = 0;
    figure; imagegap(primary.time, [1:length(condition.impact)],QA); colorbar;
        colormap(ryg_w);
    caxis([-2,2]);
    ax(2) = gca; dynamicDateTicks;
    

    %     these = plot([mint,primary.time,maxt],[NaN,primary.data, NaN]+[NaN,primary.hide_bad,NaN],'r.',...
%         [mint,primary.time(grn),maxt],[NaN,primary.data(grn), NaN]+[NaN,primary.hide_bad(grn),NaN],'g.',...
%         [mint,primary.time(yel),maxt],[NaN,primary.data(yel), NaN]+[NaN,primary.hide_bad(yel),NaN],'y.',...
%         [mint,primary.time(blue),maxt],[NaN,primary.data(blue), NaN]+[NaN,primary.hide_bad(blue),NaN],'b.',...
%         [mint,primary.time(cyan),maxt],[NaN,primary.data(cyan), NaN]+[NaN,primary.hide_bad(cyan),NaN],'c.',...
%         [mint,primary.time(br_grn),maxt],[NaN,primary.data(br_grn), NaN]+[NaN,primary.hide_bad(br_grn),NaN],'go');
%         legend('bad','good','suspect','noted','noted but suspect','suspect but assigned good', 'events')
%     set(these(2),'color',[0, .7, 0]);
%     set(these(3),'color',[1, .8, 0]);
    

    

    
    
    
else
    % if no supplied cfg then proceed to generate one by selecting a
    % datastream, primary field, defining flags/marks, and auxiliary
    % figures    
end

% At this point, we have a populated cfg, loaded ds, selected primary,
% defined initial QA, and generated plots.

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
    % We could test for dimensionality here to strip n-dimensioned
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
% test = define_mentor_test;
% Events have impact = -1
% Notable has impact = 0
% Suspect has impact = 1
% BAD has impact = 2
label = input('Enter a label for the flag or test.','s')
while ~isempty(label)&&strcmp(label(1),' ')
    label(1) = [];
end
while ~isempty(label)&&strcmp(label(end),' ')
    label(end) = [];
end
label = deblank(label);
label = strrep(label,' ','_');
test.label = label;
if ~isempty(test.label)
    test.impact = menu('Assign an impact to this test: Event, Notable Condition(not bad or suspect), Suspect, or BAD','Event','Notable','Suspect','BAD')-2;
end


return