function prefs = set_textport_prefs(anc,prefs)
% pref = set_textport_prefs(anc,prefs);

% Main menu: Delimiter (implies file extension), Time Formats(required), Time Options, QC options,
% file splitting, Header file, fields...
if ~isavar('anc')||isempty(anc)||~isstruct(anc)
    anc = anc_bundle_files;
end
[in_dir, fname,ext] = fileparts(anc.fname); 
in_dir = [in_dir, filesep]; [fmask,rest] = strtok(fname, '.'); 
fmask = [fmask, '.',strtok(rest,'.'),ext];
prefs.in_dir = in_dir; 
prefs.fmask  = fmask;
% Set default preferences
if ~isavar('prefs')
    prefs.in_dir = in_dir;
    prefs.fmask  = fmask;
    prefs.delimiter = ', ';
    prefs.ext = 'csv';
    prefs.qc_mode = 'Only GOOD'; %{'Only GOOD','No BAD','All values'}
    prefs.split = 'no splitting';
    prefs.header = 'same file';
    prefs.time_req = {'Calendar string'};
    prefs.time_opts = {'UTC.d'};
    prefs.format = '%g';    
end
if ~isfield(prefs,'qc_mode')
    prefs.qc_mode = 'Only GOOD';
end
if ~isfield(prefs,'split')
    prefs.split = 'no splitting';
end
if ~isfield(prefs,'header')
    prefs.header = 'same file';
end
if ~isfield(prefs,'delimiter')
    prefs.delimiter = ', ';
end
if ~isfield(prefs,'time_req')
    prefs.time_req = {'Calendar string'};
end
if ~isfield(prefs,'time_opts')
    prefs.time_opts = {'UTC.d'};
end
if ~isfield(prefs,'format')
    prefs.format = '%g';
end
if ~isfield(prefs,'vspec')||isempty(prefs.vspec)
    prefs.vspec = preselect_vars(anc, prefs);
end
if ~isfield(prefs,'missing_in')
    prefs.missing_in.float = -9999;
    prefs.missing_in.unsigned = -9999;
    prefs.missing_in.signed = 9999;
    prefs.missing_in.char = '-9999';
end
if ~isfield(prefs,'missing_out')
    prefs.missing_out.float = NaN;
    prefs.missing_out.unsigned = -9999;
    prefs.missing_out.signed = 9999;
    prefs.missing_out.char = 'NaN';
end
done = false;
while ~done
    del_str = strrep(strrep(prefs.delimiter,',','COMMA '),'\t','TAB ');
    main = menu('Settings:',...
        ['delimiter: ',del_str],... %1
        'Time formats (reqd)',...   %2
        'Time formats (extra)',...  %3
        ['File splitting: ',prefs.split],... %4
        ['Header file: ',prefs.header],...   %5
        ['Default QC output: ',prefs.qc_mode],...  %6
        ['Set default missing values ... '],...   %7
        ['Default format string: < ',prefs.format,' >'], ... %8
        ['Column selection...'],... %9
        ['Done']); %10
    if main == 1
        prefs.delimiter = select_delimiter;
        if ~isempty(strfind(prefs.delimiter, ','))
            prefs.ext = '.csv';
        elseif ~isempty(strfind(prefs.delimiter, '\t'))
            prefs.ext = '.tsv';
        else
            prefs.ext = '.dat';
        end
    elseif main ==2
        prefs.time_req = select_required_time_formats(prefs.time_req);
    elseif main ==3
        prefs.time_opts = select_optional_time_formats(prefs.time_opts);
    elseif main == 4
        prefs.split = set_file_splitting(prefs.split);
    elseif main == 5
        header = {'same file','separate'};
        mn = menu('Meta-data header in: ','Same file as data','Separate file');
        prefs.header = header{mn};
    elseif main ==6
        prefs.qc_mode = set_qc_mode;
    elseif main ==7
        % Default missing in
        if isfield(prefs,'missing_in')
            prefs.miss_in = [];
        end
        prefs = set_default_missings(prefs);
    elsif main == 8
       prefs.format = input(['Enter the default format string : < ',prefs.format,' >'],'s');
    elseif main ==9
        prefs.vspec = order_edit_columns(prefs.vspec); % This sends back vlist as well as units, format, ...
    elseif main == 10
        done = true;
    end
end
% prefs.qc_mode = {'Only "GOOD"', 'No "BAD"', 'No QC','Summary','Detailed'}

% prefs.rec_vars, menu options: 'Toggle','Toggle ALL','Clear ALL', 'Move
% UP','Move DOWN', 'Page down','Page up', 'DONE')

% prefs.units menu options: ''

% prefs.fmt_str
%nested function isavar

end

function delimit = select_delimiter
% prefs.delimiter = {', ',',','; ', ';', '\t', 'User supplied'}
dels = {',', ', ', ';', '; ', '\t', ' *custom* '};
del = menu('Delimiter:', '","', '", "','";"', '"; "', 'Tab','* Custom *');
if del==6
    delimit = input('Type a character sequence to be used as the field delimiter and hit enter.','s');
else
    delimit = dels{del};
end
end

function time_req = select_required_time_formats(time_req)
done = false;
TFS = {'Calendar string', 'Date and Time Columns','Columns of YYYY MM DD hh mm ss.mmm','Matlab (days since Jan 1 0 AD)','Igor (seconds since Jan 1 00:00, 1904)','epoch (sec since Jan 1 00:00, 1970)'};
n_formats = length(TFS);
N_Y = {': No',': Yes'};
if ~isavar('time_req')
    yes = false(1,n_formats);
else
    for Y = 1:n_formats
        yes(Y) = any(strcmp(time_req,TFS(Y)));
    end
end
UP = true;
flip = true;
done_str = {'','DONE'};
while ~done
    time_menu = menu({'At least one of these time formats is required.';'Toggle ON/OFF, arrange order, and then select DONE.'},...
        [TFS{1} N_Y{yes(1)+1}],[TFS{2} N_Y{yes(2)+1}],[TFS{3} N_Y{yes(3)+1}],...
        [TFS{4} N_Y{yes(4)+1}],[TFS{5} N_Y{yes(5)+1}],[TFS{6} N_Y{yes(6)+1}],...
        '','Toggle','Move up','Move down',done_str(any(yes(1:n_formats))+1));
    if time_menu < (n_formats+1)
        if flip
            yes(time_menu) = ~yes(time_menu);
        elseif UP
            if time_menu>1
                tmp = TFS(time_menu-1); TFS(time_menu-1) = TFS(time_menu); TFS(time_menu) = tmp;clear tmp;
                tmp = yes(time_menu-1); yes(time_menu-1) = yes(time_menu); yes(time_menu) = tmp;clear tmp;
            end
        else
            if time_menu<(n_formats)
                tmp = TFS(time_menu+1); TFS(time_menu+1) = TFS(time_menu); TFS(time_menu) = tmp;clear tmp;
                tmp = yes(time_menu+1); yes(time_menu+1) = yes(time_menu); yes(time_menu) = tmp;clear tmp;
            end
        end
    elseif time_menu==(n_formats+2)
        flip = true;
    elseif time_menu==(n_formats+3)
        UP = true; flip = false;
    elseif time_menu==(n_formats+4)
        UP = false; flip = false;
    elseif time_menu==(n_formats+5) && any(yes(1:n_formats))
        done = true;
    end
end
time_req = TFS(yes);
    function TF = isavar(var)
        TF = false;
        if ~isempty(who('var'))
            TF = ~isempty(who(var));
        end
    end
end

function time_req = select_optional_time_formats(time_req)
done = false;
TFS = {'UTC.d','LST.d','doy (Jan 1 00:00 = 1)','YYYY.y (float)','User-specified'};
n_formats = length(TFS);
N_Y = {': No',': Yes'};
if ~isavar('time_req')
    yes = false(1,n_formats);
else
    for Y = 1:n_formats
        yes(Y) = any(strcmp(time_req,TFS(Y)));
    end
end
UP = true;
flip = true;
done_str = {'','DONE'};
user_str = '';
while ~done
    time_menu = menu('Toggle and arrange order of one or more time formats:',...
        [TFS{1} N_Y{yes(1)+1}],[TFS{2} N_Y{yes(2)+1}],[TFS{3} N_Y{yes(3)+1}],...
        [TFS{4} N_Y{yes(4)+1}],[TFS{5} N_Y{yes(5)+1}],...
        '','Toggle','Move up','Move down',done_str(any(yes(1:n_formats))+1));
    if time_menu < (n_formats)
        if flip
            yes(time_menu) = ~yes(time_menu);
        elseif UP
            if time_menu>1
                tmp = TFS(time_menu-1); TFS(time_menu-1) = TFS(time_menu); TFS(time_menu) = tmp;clear tmp;
                tmp = yes(time_menu-1); yes(time_menu-1) = yes(time_menu); yes(time_menu) = tmp;clear tmp;
            end
        else
            if time_menu<(n_formats)
                tmp = TFS(time_menu+1); TFS(time_menu+1) = TFS(time_menu); TFS(time_menu) = tmp;clear tmp;
                tmp = yes(time_menu+1); yes(time_menu+1) = yes(time_menu); yes(time_menu) = tmp;clear tmp;
            end
        end
    elseif time_menu == (n_formats)
        if flip && yes(time_menu)
            yes(time_menu) = ~yes(time_menu);
        elseif flip && ~yes(time_menu)
            good = false;
            while ~good
                try
                    user_str = input(['Enter a time format: <', user_str, '> '],'s');
                    disp(datestr(now,user_str))
                    good = true;
                    TFS(time_menu) = {['User-specified: ',user_str]};
                catch
                    disp(['The string "',user_str,'" is not a valid time format.'])
                    disp('Try >> help datestr')
                end
            end
            yes(time_menu) = ~yes(time_menu);
        elseif UP
            if time_menu>1
                tmp = TFS(time_menu-1); TFS(time_menu-1) = TFS(time_menu); TFS(time_menu) = tmp;clear tmp;
                tmp = yes(time_menu-1); yes(time_menu-1) = yes(time_menu); yes(time_menu) = tmp;clear tmp;
            end
        else
            if time_menu<(n_formats)
                tmp = TFS(time_menu+1); TFS(time_menu+1) = TFS(time_menu); TFS(time_menu) = tmp;clear tmp;
                tmp = yes(time_menu+1); yes(time_menu+1) = yes(time_menu); yes(time_menu) = tmp;clear tmp;
            end
        end
    elseif time_menu==(n_formats+2)
        flip = true;
    elseif time_menu==(n_formats+3)
        UP = true; flip = false;
    elseif time_menu==(n_formats+4)
        UP = false; flip = false;
    elseif time_menu==(n_formats+5) && any(yes(1:n_formats))
        done = true;
    end
end
time_req = TFS(yes);
    function TF = isavar(var)
        TF = false;
        if ~isempty(who('var'))
            TF = ~isempty(who(var));
        end
    end
end

function qc_mode = set_qc_mode;
opts = {'Only GOOD','No BAD','All values'};
mn = menu('Select the level of QC to include in the export:','Only GOOD','No BAD','All values');
qc_mode = opts{mn};
end

function splits = set_file_splitting;
opts = {'no splitting','yearly','monthly','daily (UTC)','daily (LST)','hourly'};
mn = menu('Select the file splitting mode:','no splitting','yearly','monthly','daily (UTC)','daily (LST)','hourly');
splits = opts{mn};
end


