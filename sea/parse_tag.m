function m300 = parse_tag(m300, tag);
% m300 = parse_tag(m300, tag);
% Parses the specified tag determining appropriate SEA type if known, else stores raw data packet
% Use this instead of parse_type...
% Modified to determine timebase from the record in the acq file defining this tag, rather than from number of
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
tag_str = ['tag_',num2str(tag)];
is_tag = (m300.packets.tag==tag)&(m300.packets.actualSamples>0);
ind_tag = find(is_tag);
sea_type = m300.packets.type(ind_tag(1));
type_str = ['type_',num2str(sea_type)];
fun_str = ['parse_',num2str(sea_type)];
S = which(fun_str);
if ~isempty(S)&&strcmp(S(end),'m')
   type_fun = str2func(fun_str);
else
   type_fun = str2func('untyped');
end

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

acq_line = find(m300.data_acq(1).tag==tag,1,'first');
freq = m300.data_acq(1).freq(acq_line);
m300.(tag_str).freq = ones(size(buffers)).*freq;
for daq = 2:length(m300.data_acq)
   acq_line = find(m300.data_acq(daq).tag==tag,1,'first');
   freq = m300.data_acq(daq).freq(acq_line);
   this_daq = (m300.(tag_str).start_time > m300.data_acq(daq).start_time);
   m300.(tag_str).freq(this_daq) = freq;
end
m300.(tag_str).time_step = 1./double(m300.(tag_str).freq);
m300.(tag_str).time_step = m300.(tag_str).time_step ./(24*60*60);
fid = fopen(m300.fullname, 'r');
disp(['Reading tag ',num2str(tag), ' as ', type_str,'.']);

address = m300.packets.address(ind_tag(1));

if all(m300.packets.address(ind_tag)==address)
   m300.(tag_str).address = address;
else
   disp('Variable address for tag?!')
   m300.(tag_str).address = m300.packets.address(ind_tag);
end
cumsam = cumsum(double(m300.(tag_str).samples));
samples = double(m300.(tag_str).samples);
all_samples = double(unique(m300.(tag_str).samples));
% m300.(tag_str).time(1-samples+cumsam:cumsam) = 0;
% so a continuous time series runs as time(1-samples-cumsam: cumsam)
for s = all_samples
   samp_ind = find(double(m300.(tag_str).samples) ==s);
   clear temp
   for b = length(samp_ind):-1:1
%       display(['Buffer: ',num2str(tb_buf(b))]);
      fseek(fid,m300.packets.bufferBegin(ind_tag(samp_ind(b)))+uint32(m300.packets.dataOffset(ind_tag(samp_ind(b)))),'bof');
      cur1 = ftell(fid);
      temp(b,1:double(m300.packets.bytesPerSample(ind_tag(samp_ind(b)))),1:double(m300.packets.actualSamples(ind_tag(samp_ind(b))))) = ...
         fread(fid, double([m300.packets.bytesPerSample(ind_tag(samp_ind(b))) , m300.packets.actualSamples(ind_tag(samp_ind(b)))]),'*uint8');
      fseek(fid,cur1,'bof');
   end
%    buf = [1:length(samp_ind)];
   for sub = s:-1:1
      m300.(tag_str).time(sub-samples(samp_ind)+cumsam(samp_ind)) = m300.(tag_str).start_time(samp_ind) + (sub-1) .* m300.(tag_str).time_step(samp_ind);
   end
   m300.(tag_str) = type_fun(m300.(tag_str),samp_ind, temp);
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
function tag = untyped(tag, samp_ind, data);
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
samps = double(data.samples);
cumsam = cumsum(samps);
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
         %Might need something like this...
% data_out.(fields{f})(z-samps(samp_ind)+cumsam(samp_ind)) = SPP_data.(fields{f})(buf,s);
      end
   else
         data_out = data;
   end
end

tag.untype_data = data_out;

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
