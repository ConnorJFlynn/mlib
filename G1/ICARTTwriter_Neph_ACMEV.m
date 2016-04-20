function ICARTTwriter_PSAP_ACMEV(startDay,Start_UTC,data,info,form,rev,ICTdir)
% function ICARTTwriter_example(startDay,Start_UTC,data,info,form,rev,ICTdir)
% Generates an ICARTT file for field data.
% This example is for flight data from the NASA ISAF formaldehyde instrument.
% For more info on format, see the ICARTT documentation:
% http://www-air.larc.nasa.gov/missions/etc/IcarttDataFormat.htm
% This file is intended to serve as a framework; header and comment information
% should be modified to suit the user's dataset.
% Note that revision and special comments are entered near the top of the file.
%
% INPUTS:
% startDay:     UTC beginning date for data, yyyymmdd
% Start_UTC:    data timestamp. ICARTT format specifies that this is UTC seconds since the beginning of
%                   startDay. Other timestamps can be included as dependent variables. Note that appropriate
%                   timestamps may vary depending on how data is collected or averaged (see ICARTT documenation).
% data:         Structure containing variables to write. All variables should be vectors of the same length at
%                   Start_UTC, and missing values should be NaNs. Field names in this structure will also be
%                   used as varialbe names in the output ICARTT file. Variables will printed in the same order in which they
%                   appear in the structure.
% info:         Structure of information for dependent variables. Field names should be the same as
%                   those in the data structure. Fields should contain short string descriptions of each variable.
% form:         Structure containing format strings for dependent variables. Field names should be the same as
%                   those in the data structure. Default value is '%6.3f'. For more info, see help for fprintf.
% rev:          revision letter (for preliminary data) or number (for final data). MUST BE A STRING!
% ICTdir:       full path for save directory.
%
% EXAMPLE USAGE:
% startDay          = '20130603';
% rev               = 'A';
% ICTdir            = 'C:\Data\ICARTT\';
% Start_UTC         = 0:9;
% 
% data.Stop_UTC     = 1:10;
% info.Stop_UTC     = 'seconds';
% form.Stop_UTC     = '%6.0f';
% 
% data.DOY_UTC      = 154 + Start_UTC/86400;
% info.DOY_UTC      = 'Fractional day of year';
% form.DOY_UTC     = '%6.6f';
% 
% data.HCHO_ppbv    = rand(10,1);
% info.HCHO_ppbv    = 'volume mixing ratio of formaldehyde';
% form.HCHO_ppbv    = '%6.3f';
%
% ICARTTwriter_example(startDay,Start_UTC,data,info,form,rev,ICTdir)
%
% 20130606 GMW; gwolfe@umbc.edu
%
% REVISIONS
% 20130712 GMW  Fixed minor bug with input checking for variable info and formats

%----------------------------------------------------------
%  BEGIN INPUT OF MEASUREMENT-SPECIFIC INFO
%----------------------------------------------------------

% FILENAME INFO
dataID      = 'NEPH';   %DATA ID (1st part of filename)
locID       = 'G1';    %LOCATION ID (2nd part of filename)

HeaderInfo = {...
    'Flynn, Connor';...                     % PI name
    'ARM Aerial Facility - PNNL';...       % Organization
    'Neph';...     % Data Source
    'ACMEV';...                                  % Mission name
    '1, 1';...                                   % volume number, number of file volumes
    '1';...                                      % time interval (see documentation)
    'Start_UTC, seconds';...                     % Independent variable name and description
    };

%%%%% SPECIAL COMMENTS %%%%%
% Enter for each file as needed.
% Remember to end each line with \r\n.
switch startDay
    case '19820123'
        specComments = {...
            'The PSAP O-ring may have a leak...\r\n';...
            };
    otherwise
        specComments = {};
end

NormalComments = {...
    'PI_CONTACT_INFO: Connor J. Flynn, Connor.Flynn@pnnl.gov, 509-375-2041 (cell: 509-554-7791), Duli Chand, Duli.Chand@pnnl.gov';...
    'PLATFORM: Gulfstream G1, N701BN, data from PSAP operating in cabin sampling air through isokinetic inlet.';...
    'LOCATION: The ARM Gulfstream-159 (G-1) research aircraft flying over the North Slope of Alaska, with occasional vertical profiling to measure trace-gas concentrations between Prudhoe Bay, Oliktok Point, Barrow, Atqasuk, Ivotuk, and Toolik Lake.';...
    'ASSOCIATED_DATA: This file contains the data from the 3-wavelength TSI 3563 nephelometer and includes correction to ambient conditions requiring IWG1 files.';...
    'INSTRUMENT_INFO: The Nephelometer is after iso-kinetic inlet. Truncation corrections described in anderson & Ogren 1998 are applied';...
    'DATA_INFO: Data reported at 1-s interval but smoothed with a 60-s boxcar filter.';...
    'UNCERTAINTY: Calibration uncertainty is +/-5 percent.';...
    'ULOD_FLAG: -7777';...
    'ULOD_VALUE: N/A';...
    'LLOD_FLAG: -8888';...
    'LLOD_VALUE: N/A';...
    'DM_CONTACT_INFO: Connor Flynn; email Connor.Flynn@pnnl.gov';...
    'PROJECT_INFO: ACMEV field campaign';...
    'STIPULATIONS_ON_USE: Please notify the PI(s) before using.';...
    'OTHER_COMMENTS: Scattering coefficients have been corrected to represent outside aircraft ambient temperature and pressure.';...
    };

%%%%% REVISION COMMENTS %%%%%
% Latest revision should appear at top of list.
% Remember to end each line with \r\n.
if isletter(rev(end))
    % preliminary data
    revComments = {...
        'RA: Preliminary field data.\r\n';...
        };
else
    % final data
    revComments = {...
        'R0: Final data.\r\n';...
        };
end

%----------------------------------------------------------
%  END INPUT OF MEASUREMENT-SPECIFIC INFO
%----------------------------------------------------------

%%%%% INPUT CHECKING %%%%%
if ~ischar(rev)
    error('Input rev must be a string.');
elseif length(rev)==1
    rev = ['R' rev];
end

if ~isstruct(data)
    error('Input data must be a structure.')
end

L = length(Start_UTC);
names = fieldnames(data);
numvar = length(names);
for i=1:numvar
    %check lengths
    d = data.(names{i});
    if ~isvector(d) || length(d)~=L
        error(['Data field ' names{i} ' must be same size as Start_UTC.'])
    end
    data.(names{i}) = d(:); %make column vector
    
    %check info
    if ~isfield(info,names{i}) || all(isNaN(info.(names{i}))) || isempty(info.(names{i}))
        disp(['CAUTION: Info missing for variable ' names{i}])
        info.(names{i}) = 'no decription.';
    end
    
    % check format
    if ~isfield(form,names{i}) || all(isnan(form.(names{i}))) || isempty(form.(names{i}))
        disp(['CAUTION: Format string missing for variable ' names{i}])
        form.(names{i}) = '%6.3f';
    end
end

%check directory
if ~isdir(ICTdir)
    yn = input(['ICTdir ' ICTdir ' does not exist. Create? y/n [y]: '],'s');
    if isempty(yn) || yn=='y'
        mkdir(ICTdir)
    else
        error(['Invalid save path ' ICTdir '. File not saved.']);
    end
end

%%%%% DATA HANDLING %%%%%
data = struct2cell(data);
data = cell2mat(data'); %single matrix, with one column for each variable
data(isnan(data)) = -9999; %replace missing data

%%%%% NUMBERS AND FORMATTING BS %%%%%
numhead  = length(HeaderInfo);                  %number of beginning header lines
numrev   = length(revComments);                 %number of revisions
numspec  = length(specComments);                %number of special comments
numnorm  = length(NormalComments) + numrev;     %number of normal comments
numlines = numhead + numvar + numspec + numnorm;%number of lines in header

missStr = repmat('-9999, ',1,numvar);         %missing data flag
missStr = [missStr(1:end-2) '\r\n'];

scaleStr = repmat('1, ',1,numvar);            %scaling factor
scaleStr = [scaleStr(1:end-2) '\r\n'];

%%%%% DATES %%%%%
fltDateForm = datestr(datenum(startDay,'yyyymmdd'),'yyyy, mm, dd'); %formatted
revDate     = datestr(now,'yyyy, mm, dd'); %revision date

%%%%% FILENAMING %%%%%
filename    = [dataID '_' locID '_' startDay '_' rev '.ict'];
filepath    = fullfile(ICTdir,filename);
[fid,message] = fopen(filepath,'w'); %open file and overwrite if it exists
if fid==-1
    disp(message)
    return
end

%%%%% START HEADER PRINTING %%%%%
fprintf(fid,[int2str(numlines) ', 1001\r\n']);    % Number of header lines, file format index
fprintf(fid, [HeaderInfo{1} '\r\n']);               % PI name
fprintf(fid, [HeaderInfo{2} '\r\n']);               % Organization
fprintf(fid, [HeaderInfo{3} '\r\n']);               % Data Source
fprintf(fid, [HeaderInfo{4} '\r\n']);               % Mission name
fprintf(fid, [HeaderInfo{5} '\r\n']);               % volume number, number of file volumes
fprintf(fid,[fltDateForm ', ' revDate '\r\n']);   % data date, revision date
fprintf(fid, [HeaderInfo{6} '\r\n']);               % time interval (see documentation)
fprintf(fid, [HeaderInfo{7} '\r\n']);               % Independent variable
fprintf(fid,[int2str(numvar),'\r\n']);            % Number of dependent variables
fprintf(fid,scaleStr);                          % Scaling factors
fprintf(fid,missStr);                           % Missing data indicator

%%%%% DEPENDENT VARIABLE NAMES/DESCRIPTIONS %%%%%
for i=1:numvar
    fprintf(fid,[names{i} ', ' info.(names{i}) '\r\n']);
end

%%%%% SPECIAL COMMENTS %%%%%
fprintf(fid,[int2str(numspec) '\r\n']); % Number of special comment lines
for i=1:numspec
    fprintf(fid,specComments{i});
end

%%%%% NORMAL COMMENTS %%%%%
fprintf(fid,[int2str(numnorm) '\r\n']); % Number of normal comment lines
fprintf(fid, [NormalComments{1} '\r\n']);
fprintf(fid, [NormalComments{2} '\r\n']);
fprintf(fid, [NormalComments{3} '\r\n']);
fprintf(fid, [NormalComments{4} '\r\n']);
fprintf(fid, [NormalComments{5} '\r\n']);
fprintf(fid, [NormalComments{6} '\r\n']);
fprintf(fid, [NormalComments{7} '\r\n']);
fprintf(fid, [NormalComments{8} '\r\n']);
fprintf(fid, [NormalComments{9} '\r\n']);
fprintf(fid, [NormalComments{10} '\r\n']);
fprintf(fid, [NormalComments{11} '\r\n']);
fprintf(fid, [NormalComments{12} '\r\n']);
fprintf(fid, [NormalComments{13} '\r\n']);
fprintf(fid, [NormalComments{14} '\r\n']);
fprintf(fid, [NormalComments{15} '\r\n']);
fprintf(fid,['REVISION:' rev '\r\n']);
for i=1:numrev, fprintf(fid,revComments{i}); end %revision comments

%%%%% PRINT DATA %%%%%%
%build variable names string and formatting string
nameStr = strtok(HeaderInfo{7},','); %start with independent variable name
fStr = '%6.0f'; %format for independent variable
for i=1:numvar
    nameStr = [nameStr ', ' names{i}];
    fStr = [fStr ', ' form.(names{i})];
end
fStr = [fStr '\r\n'];

%print it
fprintf(fid,[nameStr '\r\n']);
for i=1:L
    fprintf(fid,fStr,Start_UTC(i),data(i,:));
end

status = fclose(fid);
if status
    disp('Problem closing file.');
end
disp(['ICARTT file written: ' filepath]);


