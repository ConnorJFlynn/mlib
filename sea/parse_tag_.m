function m300 = parse_tag(m300, tag);
% m300 = parse_tag(m300, tag);
% Parses the specified tag determining appropriate SEA type if known, else stores raw data packet
% Use this instead of parse_type...
% Probably want to modify this function to determine timebase from the
% record in the acq file defining this tag, rather than from number of
% records reported.  

% Currently parsing type 35 (AD) and type 75 (PCASP SPP)
% Need to parse 14 (Loran C/GPS), 37 (Serial ASCII), 76 (CAS Serial), 77 (CIP Serial), and 254 (sec acq)
if ~exist('m300','var')
   m300 = read_m300(getfullname('*.sea','m300'));
end
if ~exist('tag','var')
   tags = fieldnames(m300.tag_types); tags(1) = [];
   mm = menu('Select a tag to parse',tags);
   tag = str2num(tags{mm}(5:end));
end
   
fid = fopen(m300.fullname, 'r');
%%
is_tag = (m300.packets.tag==tag& m300.packets.actualSamples>0);
ind_tag = find(is_tag);
address = m300.packets.address(ind_tag(1));
tag_str = ['tag_',num2str(tag)];

if all(m300.packets.address(ind_tag)==address)
   m300.(tag_str).address = address;
else
   disp('Variable address for tag?!')
   m300.(tag_str).address = m300.packets.address(ind_tag);
end
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
m300.(tag_str).parameter2 = m300.packets.parameter2(is_tag);
m300.(tag_str).parameter3 = m300.packets.parameter3(is_tag);
buffers = m300.packets.buffer(is_tag);
m300.(tag_str).buffers = buffers;
m300.(tag_str).start_time = m300.buffer.start_time(buffers);
m300.(tag_str).end_time = m300.buffer.end_time(buffers);
m300.(tag_str).maxSystemFrequency = m300.buffer.maxSystemFrequency(buffers);
m300.(tag_str).bufferLifetime = m300.buffer.bufferLifetime(buffers);
%m300.(tag_str).time_step = (m300.(tag_str).end_time - m300.(tag_str).start_time)./double(m300.(tag_str).samples);
% The above has an error in that (end_time - start_time) is less than the
% full interval between points.
delta_t = diff(m300.(tag_str).start_time);
delta_t = [delta_t (m300.(tag_str).end_time(end) - m300.(tag_str).start_time(end))];
m300.(tag_str).time_step = (delta_t)./double(m300.(tag_str).samples);
buffers = length(m300.(tag_str).buffers);
%  temp = NaN(buffers,double(m300.packets.bytesPerSample(ind_tag(1))),double(m300.packets.actualSamples(ind_tag(1))));
dt = unique(round(etime(datevec(m300.(tag_str).start_time(2:end)), datevec(m300.(tag_str).start_time(1:end-1)))*1000)/1000);

if length(dt)>1
   disp('Delta t changes for this tag but was assumed to be constant.');
   dt = mean(dt);
end
m300.(tag_str).time_base = (double(m300.(tag_str).samples)./dt);
time_base = unique(double(m300.(tag_str).samples)./dt);
% if size(time_base,1)==1 && size(time_base,2)>1
%    time_base = time_base';
% end
for tb = time_base
%    tb_str = ['Timebase_',num2str(time_base),'_Hz'];
   tb_str = ['Timebase_',num2str(tb),'_Hz'];
   tb_buf = find(double(m300.(tag_str).samples)./dt ==tb); %
   for b = length(tb_buf):-1:1
%       display(['Buffer: ',num2str(tb_buf(b))]);
      fseek(fid,m300.packets.bufferBegin(ind_tag(tb_buf(b)))+uint32(m300.packets.dataOffset(ind_tag(tb_buf(b)))),'bof');
      cur1 = ftell(fid);
      temp(b,1:double(m300.packets.bytesPerSample(ind_tag(tb_buf(b)))),1:double(m300.packets.actualSamples(ind_tag(tb_buf(b))))) = ...
         fread(fid, double([m300.packets.bytesPerSample(ind_tag(tb_buf(b))) , m300.packets.actualSamples(ind_tag(tb_buf(b)))]),'*uint8');
      fseek(fid,cur1,'bof');
   end
   %assume that samples is constant for tag
%    buf = [1:length(m300.(tag_str).start_time)];
   buf = [1:length(tb_buf)];
   samples = double(m300.(tag_str).samples(tb_buf(1)));
   for s = samples:-1:1
      m300.(tag_str).(tb_str).time(s +samples.*(buf-1)) = m300.(tag_str).start_time(tb_buf) + (s-1) .* m300.(tag_str).time_step(tb_buf);
%       m300.(tag_str).(tb_str).time(s +samples.*(buf-1)) = m300.(tag_str).start_time(buf) + (s-1) .* m300.(tag_str).time_step(1);
   end
   m300.(tag_str) = type_fun(m300.(tag_str),temp,tb_str);
end
%%
fclose(fid);
[pname, fname, ext] = fileparts(m300.fullname);
outpath = [pname,fname];
if ~exist(outpath,'dir')
   mkdir(outpath);
end

% disp(['Saving "',fname,'.mat".']);
% save([outpath,filesep, fname,'.mat'],'m300', '-mat');
%%
function tag = untyped(tag, data,tb_str);
% This function needs work to handle N-dim data 
% In general, the data packets have the buffer index first, and sample
% index last. Additional indices (if any) are sandwiched between
% A(buffer, Ndim, samples)
% The first dimension is time.  If a data packets has multiple samples, the
% sample dim is last. We want to conflate the time and sample dims to
% create a new longer time dim of length time*samples.
% Trying to do this generically by re-ordering the dims and reading the
% resulting data chunks with single column calls. 

% dims = [1:length(sizes)];
% dims = [dims(1) dims(end) dims(2:end-1)]; %put last dim in second position
% sizes = size(data);
%    data = permute(data, dims);
%   data = shiftdim(data,length(sizes)-1);%= 650x10x10 = AxBxC..XxYxZ
% So we want final data to be of length A*Z with each data chunk of size
% BxC..XxY 

samples = double(tag.samples(1));
sizes = size(data); 
dims = [1:length(sizes)];
dims = [dims(2:end-1) dims(1) dims(end)]; %put last dim in second position
data = permute(data, dims);
sizes = size(data);

if length(sizes)<3
   data_out = uint8(zeros(sizes));
   if samples>1
      for s = samples:-1:1
         data_out(s) = data(s,:);
      end
   else
         data_out = data;
   end
else
   data_out = uint8(zeros([sizes(1:end-2) sizes(end-1)*sizes(end)]));
   if samples > 1
      for z = 1:sizes(end)
         z_chunk = data([1:prod(sizes(1:end-1))]+(z-1)*prod(sizes(1:end-1)));
         data_out([1:prod(sizes(1:end-1))]+(z-1)*prod(sizes(1:end-1))) = z_chunk(:);
      end
   else
         data_out = data;
   end
end

tag.(tb_str).untype_data = data_out;

%!! The code below is used by downsample to adjust the order of dimensions
%in a general way.  
% if ~exist('dim','var')
%    dim = find(size(D)~=1,1,'first');
% end
% [D,NSHIFTS] = shiftdim(D,dim-1);
% 
% 
% % !! The code below handles N-dim data for SPP.  Can be a model for how to
% % handle N-dim unknown data. Need to find relevant code for anctools that
% % adjusts order of dims.
% buf = [1:packets];
% fields = fieldnames(SPP_data);
% SPP.(tb_str).bins = NaN(bins,samples*packets);
% for s = samples:-1:1
%    for f = length(fields):-1:1
%       if ~strcmp(fields{f},'bins')
%          SPP.(tb_str).(fields{f})(s +samples.*(buf-1)) = SPP_data.(fields{f})(buf,s);
%       end
%    end
%    SPP.(tb_str).bins(1:bins,(s +samples.*(buf-1))) = SPP_data.bins(buf,1:bins,s)';
% %    m300.(tag_str).time(s +samples.*(buf-1)) = m300.(tag_str).start_time(buf) + (s-1) .* m300.(tag_str).time_step(1);
% end
% 
% 
