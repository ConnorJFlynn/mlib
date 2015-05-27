function m300 = parse_tag_notb(m300, tag);
% m300 = parse_tag(m300, tag);
% Parses the specified tag determining appropriate SEA type if known, else stores raw data packet
% Use this instead of parse_type...

fid = fopen(m300.fullname, 'r');
%%
is_tag = (m300.packets.tag==tag& m300.packets.actualSamples>0);
ind_tag = find(is_tag);
tag_str = ['tag_',num2str(tag)];
buffers = m300.packets.buffer(is_tag);
sea_type = m300.packets.type(find(is_tag,1,'first'));
type_str = ['type_',num2str(sea_type)];
      fun_str = ['parse_',num2str(sea_type)];
      S = which(fun_str);
      if ~isempty(S)&&strcmp(S(end),'m')
         type_fun = str2func(fun_str);
      else
         type_fun = str2func('untyped');
      end

disp(['Reading tag ',num2str(tag), ' as ', type_str,'.']);
   m300.(tag_str).packet = ind_tag;
   m300.(tag_str).numberBytes = m300.packets.numberBytes(is_tag);
   m300.(tag_str).actualSamples = m300.packets.actualSamples(is_tag);
   m300.(tag_str).samples = m300.packets.samples(is_tag);
   m300.(tag_str).parameter1 = m300.packets.parameter1(is_tag);   
   m300.(tag_str).parameter1 = m300.packets.parameter2(is_tag);
   m300.(tag_str).parameter3 = m300.packets.parameter3(is_tag);   
   buffers = m300.packets.buffer(is_tag);
   m300.(tag_str).buffers = buffers; 
   m300.(tag_str).start_time = m300.buffer.start_time(buffers);
   m300.(tag_str).end_time = m300.buffer.end_time(buffers);
   m300.(tag_str).maxSystemFrequency = m300.buffer.maxSystemFrequency(buffers);
   m300.(tag_str).bufferLifetime = m300.buffer.bufferLifetime(buffers);
   m300.(tag_str).time_step = (m300.(tag_str).end_time - m300.(tag_str).start_time)./double(m300.(tag_str).samples); 
   buffers = length(m300.(tag_str).buffers);
%     temp = NaN(buffers,double(m300.packets.bytesPerSample(ind_tag(1))),double(m300.packets.actualSamples(ind_tag(1))));
% dt = unique(round(etime(datevec(m300.(tag_str).start_time(2:end)), datevec(m300.(tag_str).start_time(1:end-1)))*1000)/1000);
% time_base = unique(double(m300.(tag_str).samples)./dt);
% for tb = time_base
% tb_str = 'Timebase_',num2str(time_base),'_Hz');
   for b = buffers:-1:1
      display(['Buffer: ',num2str(b)]);
      fseek(fid,m300.packets.bufferBegin(ind_tag(b))+uint32(m300.packets.dataOffset(ind_tag(b))),'bof');
      cur1 = ftell(fid);
      temp(b,1:double(m300.packets.bytesPerSample(ind_tag(b))),1:double(m300.packets.actualSamples(ind_tag(b)))) = fread(fid, double([m300.packets.bytesPerSample(ind_tag(b)) , m300.packets.actualSamples(ind_tag(b))]),'*uint8');
%       m300.(tag_str) = type_fun(m300.(tag_str),b,temp);
%       m300.(tag_str)s.temp(b,1:154,1:10) = temp;
%       m300.(tag_str) = untyped(m300.(tag_str),b,temp);
      fseek(fid,cur1,'bof');
   end
      %assume that samples is constant for tag
   buf = [1:length(m300.(tag_str).start_time)];
   samples = double(m300.(tag_str).samples(1));
   for s = samples:-1:1
      m300.(tag_str).time(s +samples.*(buf-1)) = m300.(tag_str).start_time(buf) + (s-1) .* m300.(tag_str).time_step(1); 
   end
    m300.(tag_str) = type_fun(m300.(tag_str),temp);

%%
fclose(fid);
%%
function tag = untyped(tag, data);
samples = double(tag.samples(1));
sizes = size(data);
if samples>1
   for s = samples:-1:1
      tag.untype_data(s) = data(:,s);
   end
else
   tag.untype_data = data';
end




