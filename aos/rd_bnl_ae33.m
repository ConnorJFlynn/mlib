function [bnl,in_str] = rd_bnl_ae33(infile, in_str)
% bnl = rd_bnl_ae33 reads BNL supplied "ae33 tsv" files for the AOS system and
% associated measurements

if ~exist('infile','var')
    infile = getfullname_('*ae*.tsv','bnl_ae33_tsv','Select a BNL cpcf tsv file.');
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

if exist('in_str','var')
    A = textscan(fid, [in_str, '%*[^\n]'],'delimiter','\t');
    len_A = length(A{1});
else

Aa = textscan(fid, '%s %s %s %s %*[^\n]','delimiter','\t');
len_A = length(Aa{1});
clear Aa
fseek(fid,mark,-1);
end

if ~exist('A','var') || length(A{end})~=len_A
    in_str = '%s %s %s %s';
    
    for x = 5:length(AA)
        in_str_ = [in_str, '%f '];
        A = textscan(fid, [in_str_, '%*[^\n]'],'delimiter','\t');
        fseek(fid,mark,-1);
        if length(A{end})==len_A
            in_str = [in_str, '%f '];
        else
            in_str = [in_str, '%s '];
        end
        
    end
end
    fclose(fid);
    Dd = A{1}; A(1) = [];
    Ti = A{1}; A(1) = [];
%     Dd_ = datenum(Dd);
%     Ti_ = datenum(Ti);
    for N = length(A{end}):-1:1
        DT(N) = {[Dd{N}, ' ', Ti{N}]};
    end
    bnl.time  = datenum(DT);
%     try
%             bnl.time = datenum(D); clear D;
% %     bnl.time = datenum(D,'yyyy-mm-dd HH:MM:SS.fff'); clear D;
%     catch
%     bnl.time = datenum(D,'yyyy-mm-dd HH:MM:SS'); clear D;
%     end
    for lab = 3:length(AA)
        
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
    
