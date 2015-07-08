function caps = rd_caps_m02(in_file);

if ~exist('in_file','var') || ~exist(in_file,'file')
   in_file = getfullname('*.caps.*.m02*','caps','select mentor-edited CAPS file');
end
% tic
fid = fopen(in_file);

in = fgetl(fid);
cols = textscan(in,'%s','delimiter','\t'); cols = cols{:};
data = textscan(fid,['%*s %s ',repmat('%f ',[1,length(cols)-2])],'delimiter','\t');
caps.time = data{1}; data(1) = [];
caps.time = datenum(caps.time, 'mm/dd/yy HH:MM:SS');
cols(1) = []; cols(1) = [];
for c = length(cols):-1:1
   caps.(cols{c}) = data{end};
   data(end) = [];
end

fclose(fid);
% toc

return