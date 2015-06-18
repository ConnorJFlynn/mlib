function bnl = rd_bnl_tsv2(infile)
% bnl = rd_bnl_tsv(bnl)
% This function reads BNL supplied "tsv" files for the AOS system and
% assoicated measurements

if ~exist('bnl','var')
    infile = getfullname_('*.tsv','bnl_tsv','Select a BNL tsv file.');
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

A = textscan(fid, ['%s %s ' repmat('%f ',[1,length(AA)-2]) ' %*[^\n]'],'delimiter','\t');
fclose(fid);
DT = A{1};A(1) = [];
bnl.time = datenum(DT,'yy-mm-dd HH:MM:SS');clear DT 
for lab = 2:length(AA)
    bnl.(legalize_fieldname(AA{lab})) = A{1};A(1) = [];
end


return

