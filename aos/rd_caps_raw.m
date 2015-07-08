function caps = rd_caps_raw(in_file);

if ~exist('in_file','var') || ~exist(in_file,'file')
   in_file = getfullname('*.caps.*.00.*.raw.*','caps','select raw CAPS file');
end
% tic
fid = fopen(in_file);
in = [];
while (isempty(strfind(in,'Date'))||isempty(strfind(in,'Time')))&&~feof(fid)
   in = fgetl(fid);
end
cols = textscan(in,'%s','delimiter','\t'); cols = cols{:};
in = fgetl(fid);in = fgetl(fid);in = fgetl(fid);in = fgetl(fid);
data = textscan(fid,['%s %s ',repmat('%f ',[1,length(cols)-3]),'%f'],'delimiter','\t');
date = data{1}; UTC = data{2};
for r = length(date):-1:1
   dates(r) = {[date{r}, ' ',UTC{r}]};
end
caps.time = datenum(dates,'yyyy-mm-dd HH:MM:SS.fff');

for c = length(cols):-1:4
   if ~strcmp(cols{c},'Comments')&&~strcmp(cols{c},'Unused')
   caps.(cols{c}) = data{end};
   end
   data(end) = [];
end

fclose(fid);
% toc

return