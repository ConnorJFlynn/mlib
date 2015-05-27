function m300 = load_tags(m300);
% m300 = load_tags(m300);
% Finds unique un-reserved tags and loads them into the m300 struc using
% supported type functions if found.
reserved = [0,999,65000:65535];
tags = unique([m300.packets.tag(m300.packets.actualSamples>0),reserved]);
tags = setxor(tags,reserved);

% find the data types corresponding to these tags
types = [];
for t = tags
   num = find(m300.packets.tag==t,1,'first');
%    m300.tag_types.(['tag_',num2str(t)]) = m300.packets.type(num);
   types = [types,m300.packets.type(num)];
end
types = unique(types);
disp(['Reading all packet types...'])
for t = types
   m300 = parse_type(m300,t);
end
disp('Done reading all types.')
[pname, fname, ext] = fileparts(m300.fullname);
disp(['Saving "',fname,'.mat".'])
save([pname,filesep, fname,'.mat'],'m300', '-mat');
disp('Done!')



