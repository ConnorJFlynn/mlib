function V = ICARTTreader(ICTname)
% function V = ICARTTreader(ICTname)
% Parses an ICARTT-formatted file (.ict) into matlab variables.
%
% INPUTS:
% ICTname: name of .ict file to parse, INCLUDING extension.
%
% OUTPUTS:
% V: a structure containing all variables and the header info.
%    Use struct2var to put these variables into your workspace, if desired.
%
% 20130424 GMW
% 20130810 GMW  Modifed data-reading to use textscan instead of fscanf. This helps deal with files
%               that contain white space between values and commas.
% 20130811 GMW  Added to list of invalid characters for variable names.
% 20131219 GMW  Added some code to modify variable names that start with a number, as these are
%               invalid names for matlab. In these cases, the letter "n" is tacked onto the front
%               of the variable name.
% 20140612 GMW  Added try-catch statement to use fscanf is textscan fails to read data.

%%%%%OPEN FILE%%%%%
[fid,message] = fopen(ICTname);
if fid==-1
    error(message)
end

%%%%%GRAB HEADER%%%%%
numlines=fscanf(fid,'%f',1);
frewind(fid);
header = cell(numlines,1);
for i=1:numlines
    header{i} = fgetl(fid);
end
numvar = str2num(header{10})+1; %number of variables, including independent variable

%%%%%GRAB DATA, CLOSE FILE%%%%%
fstr = repmat('%f, ',1,numvar); %format string
fstr = fstr(1:end-2);
floc = ftell(fid);
try
    data = textscan(fid,fstr,inf);
    data = cell2mat(data);
catch
    disp('ICARTTreader: textscan failed. Using fscanf.')
    fseek(fid,floc,'bof');
    data=fscanf(fid,fstr,[numvar,inf]); %old method
    data=data';
end
[nrow,ncol] = size(data);

status = fclose(fid);
if status
    disp('Problem closing file.');
end

%%%%%PARSE HEADER%%%%%
scale = [1 str2num(header{11})]; %scaling factors
miss  = str2num(header{12}); %missing data indicators
miss = [-9999 miss]; %extend for independent variable
miss = repmat(miss,nrow,1);

i = strmatch('LLOD_FLAG',header); %lower detection limit
if ~isempty(i)
    llod = str2num(header{i}(12:end));
end

i = strmatch('ULOD_FLAG',header); %upper detection limit
if ~isempty(i)
    ulod = str2num(header{i}(12:end));
end

%filter variable names
varnames = textscan(header{end},'%s','Delimiter',',');
varnames = varnames{1};
badchar = '()[]{}/\+-<>;:!@#$%^&*|?.'' '; %invalid characters
for i=1:numvar
    var = varnames{i};
    bad = ismember(var,badchar);
    var(bad)=[];
    
    %if first character is not a letter, make it so
    if ~isletter(var(1))
        var = ['n' var];
    end
    
    varnames{i} = var;
end

%%%%%PARSE DATA%%%%%
data(data==miss | data==llod | data==ulod) = NaN; %replace bad data
data = data.*repmat(scale,size(data,1),1); %scale

V.header = header;
for i=1:numvar
    V.(varnames{i}) = data(:,i);
end
V.data=data;


