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
   m300 = parse_tag(m300,t);
end
disp('Done reading all tags.')
[pname, fname, ext] = fileparts(m300.fullname);
disp(['Saving "',fname,'.mat".'])
save([pname,filesep, fname,'.mat'],'m300', '-mat');
disp('Done!')



