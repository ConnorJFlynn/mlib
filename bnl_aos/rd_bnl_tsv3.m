function [bnl,in_str] = rd_bnl_tsv3(infile, in_str)
% bnl = rd_bnl_tsv3(bnl)
% This function reads BNL supplied "cpcf tsv" files for the AOS system and
% assoicated measurements

if ~exist('infile','var')
    infile = getfullname_('*.tsv','bnl_cpcf_tsv','Select a BNL cpcf tsv file.');
end
if exist(infile,'file')
    %   Detailed explanation goes here
    fid = fopen(infile);
else
    disp('No valid file selected.')
    return
end
this = fgetl(fid);
a = 1;
this = []; that = []; thother = [];
while isempty(strfind(this,'yyyy-mm-dd'))&&isempty(strfind(this,'hh:mm:ss.sss'))&&isempty(strfind(this,'YYMMDDhhmmss'))
    %%
    thother = that;
    that = this;
    this = fgetl(fid);
    a = a + 1;
    %%
end
AA = textscan(thother, '%s','delimiter','\t');AA=AA{:};
while a < 39
    tmp = fgetl(fid);
    a = a +1;
end
% Date	Time	Concentration	InstrErrs	Satur Temp	Cond Temp	Optcs Temp	Cab Temp	Ambnt Press	Orifice Press	Nozz Press	Lasr Curr	 Liq Lvl	 Liq Lvl V	Valve position	Flow setpoint	Flow read
% Now iteratively try to compose the format string of
mark = ftell(fid);
Aa = textscan(fid, '%s %s %*[^\n]','delimiter','\t');
len_A = length(Aa{1});
clear Aa
fseek(fid,mark,-1);

if exist('in_str','var')
    A = textscan(fid, [in_str, '%*[^\n]'],'delimiter','\t');
end
if ~exist('A','var') || length(A{end})~=len_A
    in_str = '%s ';
    
    for x = 2:length(AA)
        
        in_str_ = [in_str, '%f '];
        A = textscan(fid, [in_str_, '%*[^\n]'],'delimiter','\t');
        fseek(fid,mark,-1);
        if length(A{end})==len_A
            in_str = in_str_;
        else
            in_str = [in_str, '%s '];
        end
        
    end
end
    fclose(fid);
    D = A{1}; A(1) = [];
%     T = A{1}; A(1) = [];
%     for N = length(A{end}):-1:1
%         DT(N) = {[D{N}, ' ', T{N}]};
%     end
    try
    bnl.time = datenum(D,'yyyy-mm-dd HH:MM:SS.fff'); clear D;
    catch
    bnl.time = datenum(D,'yyyy-mm-dd HH:MM:SS'); clear D;
    end
    for lab = 2:length(AA)
        
        bnl.(legalize_fieldname(AA{lab})) = A{1};
        A(1) = [];
        
    end
if ~isfield(bnl,'pname')&&~isfield(bnl,'fname')
    [pname, fname, ext] = fileparts(infile);
    bnl.pname = [pname, filesep];
    bnl.fname = [fname, ext];
elseif ~isfield(bnl,'filename')
    bnl.filename = infile;
else
    bnl.filename_ = infile;
end
    
    return
    
