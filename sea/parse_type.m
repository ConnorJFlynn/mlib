function m300 = parse_type(m300, sea_type);
% m300 = parse_type(m300, sea_type);
% Parses tags having specified type, if a known type, else stores raw data packet
disp('Deprecated, use parse_tag instead')
fid = fopen(m300.fullname, 'r');
%%
type_str = ['type_',num2str(sea_type)];
is_type = (m300.packets.type==sea_type & m300.packets.actualSamples>0);
ind_type = find(is_type);

reserved = [0,999,65000:65535];
tags = unique([m300.packets.tag(is_type),reserved]);
tags = setxor(tags,reserved);

disp(['Reading type ',num2str(sea_type), '...']);
for t =1:length(tags)
   is_type = (m300.packets.type==sea_type & m300.packets.actualSamples>0 & m300.packets.tag==tags(t));
   ind_type = find(is_type);
   m300.(type_str).(['tag_',num2str(tags(t))]).packet = ind_type;
   m300.(type_str).(['tag_',num2str(tags(t))]).numberBytes = m300.packets.numberBytes(is_type);
   m300.(type_str).(['tag_',num2str(tags(t))]).actualSamples = m300.packets.actualSamples(is_type);
   m300.(type_str).(['tag_',num2str(tags(t))]).parameter1 = m300.packets.parameter1(is_type);   
   m300.(type_str).(['tag_',num2str(tags(t))]).parameter1 = m300.packets.parameter2(is_type);
   m300.(type_str).(['tag_',num2str(tags(t))]).parameter3 = m300.packets.parameter3(is_type);   
   buffers = m300.packets.buffer(is_type);
   m300.(type_str).(['tag_',num2str(tags(t))]).buffers = buffers; 
   m300.(type_str).(['tag_',num2str(tags(t))]).start_time = m300.buffer.start_time(buffers);
   m300.(type_str).(['tag_',num2str(tags(t))]).end_time = m300.buffer.end_time(buffers);
   m300.(type_str).(['tag_',num2str(tags(t))]).maxSystemFrequency = m300.buffer.maxSystemFrequency(buffers);
   m300.(type_str).(['tag_',num2str(tags(t))]).bufferLifetime = m300.buffer.bufferLifetime(buffers);
   buffers = length(m300.(type_str).(['tag_',num2str(tags(t))]).buffers);
   for b = buffers:-1:1
      fseek(fid,m300.packets.bufferBegin(ind_type(b))+uint32(m300.packets.dataOffset(ind_type(b))),'bof');
      cur1 = ftell(fid);
      temp = fread(fid, double([m300.packets.bytesPerSample(ind_type(b)) , m300.packets.actualSamples(ind_type(b))]),'uint8');
      fun_str = ['parse_',num2str(sea_type)];
      S = which(fun_str);
      if ~isempty(S)&&strcmp(S(end),'m')
         type_fun = str2func(fun_str);
         m300.(type_str).(['tag_',num2str(tags(t))]) = type_fun(m300.(type_str).(['tag_',num2str(tags(t))]),b,temp);
      else
         m300.(type_str).(['tag_',num2str(tags(t))]).untype_data(b) = {temp};
      end
      fseek(fid,cur1,'bof');
   end
end

%%
fclose(fid);
%%
