function txt = anc_vdata_dump(anc, prefs)
% txt = anc_vdata_dump(anc, prefs)
% This function is expected to be preceeded by another menu-driven function
% that lets the user select/exclude vlist, time_format, delimiter, vspec

% The philosophy for how this should run and construction of conf files
% should be to 1) provide useful global defaults and 2) defaults are
% inherited by fields but may be subsequently over-written.

% We will still perform an additional check to make sure relevant dims and
% coordinate fields are provide, and output global atts and header.
if ~isavar('anc')||isempty(anc)
    anc = anc_bundle_files;
end
if ~isavar('prefs')||isempty(prefs)
    prefs = set_textport_prefs(anc)
end
if ~isfield(prefs,'missing_in')
    prefs.missing_in.float = -9999;
    prefs.missing_in.signed = -9999;
    prefs.missing_in.unsigned = 9999;
    prefs.missing_in.char = '-9999';
end
if ~isfield(prefs, 'missing_out')
    prefs.missing_out.float = NaN;
    prefs.missing_out.signed = -9999;
    prefs.missing_out.unsigned = 9999;
    prefs.missing_out.char = 'NaN';
end
if ~isfield(prefs,'format')
    prefs.format = '%g';
end

outline = sprintf('! delimiter = ''%s'';',prefs.delimiter);
outline = sprintf('! file extension = ''%s'';',prefs.ext);
outline = sprintf('! file bundles: ''%s'';',prefs.split);
outline = sprintf('! header info: ''%s'';',prefs.header);

outline = sprintf('! Default values below are applied unless superceded by field-level exceptions');
outline = sprintf('! incoming missing for type (float): ''%s'';',prefs.missing_in.float);
outline = sprintf('! incoming missing for type (signed int): ''%s'';',prefs.missing_in.signed);
outline = sprintf('! incoming missing for type (unsigned int): ''%s'';',prefs.missing_in.unsigned);
outline = sprintf('! incoming missing for type (char): ''%s'';',prefs.missing_in.unsigned);
outline = sprintf('! output missing for type (float): ''%s'';',prefs.missing_in.float);
outline = sprintf('! output missing for type (signed int) as: ''%s'';',prefs.missing_in.signed);
outline = sprintf('! output missing for type (unsigned int): ''%s'';',prefs.missing_in.unsigned);
outline = sprintf('! output missing in (char): ''%s'';',prefs.missing_in.unsigned);
outline = sprintf('! qc mode: ''%s'';',prefs.qc_mode);
outline = sprintf('! Time fields: '); 
outline = [outline sprintf('''%s '' ',prefs.time_req{:}, prefs.time_opts{:})];

% Start with the defaults as the root-level elements of prefs
% Then list vars from vspec but only output those attributes that differ
% from the default
outline = sprintf('! Record-dimensioned columns:');

vlist = fieldnames(prefs.vspec);
for v = 1:length(vlist)
outline = sprintf('!%4s %s','var: ', vlist{v});  
if isfield(prefs.vspec.(vlist{v}),'format') && ~strcmp(prefs.vspec.(vlist{v}).format,prefs.format)
    outline = sprintf('!%8s %s','format:',prefs.vspec.(vlist{v}).format);
end
outline = sprintf('!%8s %s',' ',prefs.vspec.(vlist{v}).units);
if isfield(prefs.vspec.(vlist{v}),'format') && ~strcmp(prefs.vspec.(vlist{v}).format,prefs.format)
    outline = sprintf('!%8s %s',' ',prefs.vspec.(vlist{v}).format);
end

% finish with input path, maybe a filemask, and output path (either full,
% or relative to the input path)


% So, we want to output a "header" that contains the netcdf filename
% all global atts, all static non-dimensioned fields, and relevant non-record dimensioned fields,
% "relevant" means they share a dimension with another field selected for
% extraction.


% Lastly, a delimited column-header row

% Ultimately, 

% And we'll need to build the hooks to use such a config file


% fixed-dimension fields 
if ~isavar('anc')
   anc = anc_bundle_files;
end
if ~isstruct(anc)&&isafile(anc)
   anc = anc_load(anc);
end

[~,fname,ex]= fileparts(anc.fname); fname = [fname, ex];
vars = fieldnames(anc.vdata);
vlist = fieldnames(prefs.vspec);
if isavar('vlist')&&isavar('vars')&&~isempty(vlist)
   xvars = intersect(vars, vlist); % only valid vars from vlist survive this.
   xvars = setxor(vars,xvars); % This is the set of vars that was NOT selected
end
if isavar('xvars')
   vdata = rmfield(anc.vdata, xvars);
else
   vdata = anc.vdata;
end
% Somewhere around here we need to step through the variable list desired
% for output. Check each for whether an associated QC field exists.  If one 
% exists, then we'll output it and a corresponding qs field and we'll filter 
% and replace missing values as per miss_in and miss_out, and mask data 
% values as per qc_mode (ONLY good or no BAD)

% Check to see if any output fields have qc_mode = summary AND a
% corresponding QC field exists.  If so, then output the summary
% description: 
% qs_*: column labels beginning with "qs_" contain summary QC. The values should be interpreted as:
% 0 = Good: Data passed all qc tests.
% 1 = Indeterminate: Data is supsect, use with caution.
% 2 = Bad: Data failed critical QC test.
% 3 = Missing: Data was missing in input file.

% Then, field by field, check qc_mode.  
% If (~no_QC)&&(isfield(qc_*)), then 
% Replace miss_in with miss_out.
% Then create and populate qs_.  Set qs_ to 3 for values == miss_out;
% If (detailed)&&(isfield(qc_*)), then create qc_* with stored values from
% anc AND output % attributes for qc_* in header
% If no_bad replace data values with qs_==2 with miss_out
% if only_good replace data values with (qs_==1)|(qs_==2) with miss_out 


if ~isempty(fieldnames(vdata))
   sprintf('%% filename: %s',fname)
end
% Identify and retain dims pertaining to remaining vars
coord = {};
for v = length(vlist):-1:1
   vdims = anc.ncdef.vars.(vlist{v}).dims;
   coord = unique({coord{:},vdims{:}});
end
coord(strcmp(coord,'')) = [];% remove empty dims
coord(strcmp(coord,anc.ncdef.recdim.name)) = [];
svars = {};
for v = 1:length(vars)
    blah = anc.ncdef.vars.(vars{v}).dims; 
    if isempty(blah{1}) || ...
            ((length(blah)==1)&&(any(strcmp(coord,blah))))
        svars = unique([svars, vars(v)]);
    end
end
for c = 1:length(coord)
   sprintf('%% dimension ''%s'' : %d \n', coord{c}, anc.ncdef.dims.(coord{c}).length)
end

for d = 1:length(coord)
   dim = coord{d};
   outline = sprintf('%s \n',['% dim: ', dim, ', length = ',sprintf('%d',anc.ncdef.dims.(dim).length)])
   if ~anc.ncdef.dims.(dim).isunlim && isfield(anc.vdata,dim)
      vatts = fieldnames(anc.vatts.(dim));
      for v = 1:length(vatts)
         vatt = vatts{v};
         outline = sprintf('%s \n',['% ',dim, '.',vatt, ': ',anc.vatts.(dim).(vatt)])
      end
   end
end
time_format = prefs.time_req;
time_format = [time_format prefs.time_opts];

if any(strcmp(time_format,'Date and Time Columns'))
   V = datevec(anc.time);
   year = textscan(sprintf('%d \n', V(:,1)),'%s'); tdata.year = year{:}'; 
   month = textscan(sprintf('%d \n',V(:,2)),'%s'); tdata.month = month{:}';
   day_of_month = textscan(sprintf('%d \n',V(:,3)),'%s'); tdata.day_of_month = day_of_month{:}';
   hour_of_day = textscan(sprintf('%d \n',V(:,4)),'%s'); tdata.hour_of_day = hour_of_day{:}';
   minute_of_hour = textscan(sprintf('%d \n',V(:,5)),'%s'); tdata.minute_of_hour = minute_of_hour{:}';
   second_of_minute =textscan(sprintf('%d \n',V(:,6)),'%s'); tdata.second_of_minute = second_of_minute{:}';
   time_format = time_format(~strcmp(time_format,'Date and Time Columns'));
end
% if ~any(strcmp(lower(time_format),'doy'))
%    time_format(end+1) = {'doy'};
% end
if any(strcmp(time_format,'doy'))
   doy = textscan(sprintf('%3.9f \n', serial2doys(anc.time)),'%s'); doy = doy{:}; tdata.doy = doy';
   time_format = time_format(~strcmp(time_format,'doy'));
end
if ~any(strcmp(upper(time_format),'UTC'))&&~any(strcmp(upper(time_format),'UT'))&&~any(strcmp(time_format,'UTC.d'))
   time_format(end+1) = {'UTC'};
end
if any(strcmp(time_format,'UTC'))
   UTC = textscan(sprintf('%2.8f \n', serial2Hh(anc.time)),'%s'); UTC = UTC{:}; tdata.UTC = UTC';
   time_format = time_format(~strcmp(time_format,'UTC'));
end
   
for i = length(time_format):-1:1
   label = time_format{i}; 
   label = strrep(label,'-',''); label = strrep(label,'/','');label = strrep(label,':','');
   user_time = datestr(anc.time, time_format{i});
   for t = length(anc.time):-1:1
      tdata.(label)(t) = {user_time(t,:)};
   end      
end
% sprintf(['%s', delimiter] ,tdata.year{12}, tdata.month{12})

flds = fieldnames(vdata);

json_pref = savejson([],prefs,putfullname('*.json','json'));
% pref_no_root = loadjson(getfullname('*.json','json'));
% pref_json_root = loadjson(getfullname('*.json','json'));
end