function [bnl,in_str_] = rd_bnl_tsv4(infile, in_str)
% [bnl,in_str_] = rd_bnl_tsv4(bnl)
% This function reads BNL supplied "cpcf tsv" files for the AOS system and
% assoicated measurements. % it returns a struct containing the read measurements and format string

error('Currently broken!!')
% Need to more robustly distinguish between BNL files that have either one
% or two leading strings.
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
while isempty(strfind(this,'yyyy-mm-dd'))&&isempty(strfind(this,'hh:mm:ss.sss'))&&isempty(strfind(this,'YYMMDDhhmmss'))&&~feof(fid)
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
end
if length(A{1}) ~= length(A{end})
   fseek(fid,mark,-1);

Aa = textscan(fid, '%s %s %*[^\n]','delimiter','\t');
len_A = length(Aa{1});
clear Aa


if ~exist('A','var') || length(A{end})~=len_A
   in_str = '%s ';
   A = textscan(fid,[repmat(in_str, [1,length(AA)]), '%*[^\n]'],'delimiter','\t');
   in_str_ = [];
   for x = length(AA):-1:1
      this_col = A{x};
      this_col = this_col(~strcmp(upper(this_col),'NAN'));
      is_string(x) = ~iscolnumeric(this_col);
      if is_string(x)
         in_str_ = ['%s ',in_str_];
      else
         in_str_ = ['%f ',in_str_];
      end
   end
   fseek(fid,mark,-1);
   A = textscan(fid,[in_str_ , '%*[^\n]'],'delimiter','\t');
   
end

fclose(fid);
D = A{1}; A(1) = [];
T = A{1}; A(1) = [];
for N = length(A{end}):-1:1
   DT(N) = {[D{N}, ' ', T{N}]};
end
try
   bnl.time = datenum(D,'yyyy-mm-dd HH:MM:SS.fff'); clear D;
catch
   try
      bnl.time = datenum(D,'yyyy-mm-dd HH:MM:SS'); clear D;
   catch
      try
         bnl.time = datenum(DT,'yyyy-mm-dd HH:MM:SS.fff'); clear DT;
      catch
         bnl.time = datenum(DT,'yyyy-mm-dd HH:MM:SS'); clear DT;
      end
   end
end
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

