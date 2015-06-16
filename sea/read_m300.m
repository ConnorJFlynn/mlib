function [m300] = read_m300(fullname)
if ~exist('fullname','var')
   fullname = getfullname('*.sea','m300','Select SEA M300 file.');
end
m300.fullname = fullname;
%%
fid = fopen(fullname, 'r');
%%
fseek(fid,0,1);
eof = ftell(fid);
progress = 0;
fseek(fid,0,-1);
buf = 1;
LAST = false;
packets = 0;
%% First pass: finds the total number of packets.
while ~LAST && (eof - ftell(fid))>0
   %%
   if ftell(fid)/eof > progress
      disp(['Progress skimming file: ',num2str(floor(100*progress)),'%']);
      progress = progress + .1;
   end
   packets = packets + 1;
   %    disp(num2str(eof - ftell(fid)))
   tag = fread(fid,1,'*uint16'); %16-bit
   dataOffset = fread(fid,1,'*uint16');%16-bit

   if tag ==0
      bob = uint32(ftell(fid))-4;
   end
   if tag==999
      % skip forward to next buffer
      fseek(fid,bob+uint32(dataOffset),'bof');
      buf = buf +1;
   else
      fseek(fid,12,'cof');
   end
end
disp(['Progress skimming file: 100%']);
disp(['Done skimming file.']);
% Now pre-define packet structure
m300.packets.buffer = zeros([1,packets],'uint32');
m300.packets.tag = zeros([1,packets],'uint16'); %16-bit
m300.packets.bufferBegin = zeros([1,packets],'uint32');%double
m300.packets.dataOffset = zeros([1,packets],'uint16');%16-bit
m300.packets.numberBytes = zeros([1,packets],'uint16');%16-bit
m300.packets.samples = zeros([1,packets],'uint16');%16-bit
m300.packets.bytesPerSample = zeros([1,packets],'uint16');%16-bit
m300.packets.actualSamples = zeros([1,packets],'uint16');%16-bit
m300.packets.type = zeros([1,packets],'uint8');%8-bit
m300.packets.parameter1 = zeros([1,packets],'uint8');%8-bit
m300.packets.parameter2 = zeros([1,packets],'uint8');%8-bit
m300.packets.parameter3 = zeros([1,packets],'uint8');%8-bit
m300.packets.address = zeros([1,packets],'uint16');%16-bit
fseek(fid,0,'bof');
buf = 1;
bob = uint32(0);
LAST = false;
progress = 0;
for p = 1:packets
   if p./packets > progress
     disp(['Progress reading packet headers: ',num2str(floor(100*p./packets)),'%']);
     progress = progress + 0.1;
   end
   tag = fread(fid,1,'*uint16'); %16-bit
   m300.packets.buffer(p) = buf;
   m300.packets.tag(p) = tag;
   %    m300.tags = unique([m300.tags, tag]);
   dataOffset = fread(fid,1,'*uint16');%16-bit
   m300.packets.dataOffset(p) = dataOffset;%16-bit
   m300.packets.numberBytes(p) = fread(fid,1,'*uint16');%16-bit
   m300.packets.samples(p) = fread(fid,1,'*uint16');%16-bit
   m300.packets.bytesPerSample(p) = fread(fid,1,'*uint16');%16-bit
   m300.packets.actualSamples(p) = m300.packets.numberBytes(p) ./ m300.packets.bytesPerSample(p);
   m300.packets.type(p) = fread(fid,1,'*uint8');%8-bit
   m300.packets.parameter1(p) = fread(fid,1,'*uint8');%8-bit
   m300.packets.parameter2(p) = fread(fid,1,'*uint8');%8-bit
   m300.packets.parameter3(p) = fread(fid,1,'*uint8');%8-bit
   m300.packets.address(p) = fread(fid,1,'*uint16');%16-bit
   m300.packets.bufferBegin(p) = uint32(bob);
   if tag == 0
      bob = uint32(ftell(fid)) - 16;
      m300.packets.bufferBegin(p) = uint32(bob);
   elseif tag==65530
      cur = ftell(fid);
      fseek(fid, m300.packets.bufferBegin(p)+uint32( m300.packets.dataOffset(p)),'bof');
      temp1 = fread(fid,double(m300.packets.numberBytes(p)),'*char')';
      if ~isfield(m300, 'file_packets')
         fnum = 1;
%         m300.file_packets.file1.filename = temp1; 
      else
         fnum = length(fieldnames(m300.file_packets))+1;
%          m300.file_packets.(['file',num2str(fnum)]).filename = temp1;
      end
      m300.file_packets.(['file',num2str(fnum)]).filename = temp1;
      m300.file_packets.(['file',num2str(fnum)]).packet = p;
      fseek(fid,cur,'bof');
   elseif tag==65531
      cur = ftell(fid);
      fseek(fid, m300.packets.bufferBegin(p)+uint32( m300.packets.dataOffset(p)),'bof');
      if exist('temp1','var')
         temp2 = fread(fid,double(m300.packets.numberBytes(p)),'*char')';
         fnum = length(fieldnames(m300.file_packets));
         m300.file_packets.(['file',num2str(fnum)]).filedata = temp2;
         clear temp1 temp2
      else
         disp('Found data file before or without data file name.')
      end
      fseek(fid,cur,'bof');
   elseif tag==999
      % skip forward to next buffer
      buf = buf + 1;
      fseek(fid, m300.packets.bufferBegin(p)+uint32( m300.packets.dataOffset(p)),'bof');
   end
end
disp(['Progress reading packet headers: 100%']);
disp(['Done reading packet headers.']);
% % Now we have the configuration files read in, so we _could_ make a table
% % of defined data tags along with defined time base.
% % The idea would be to find the acq.300 file, parse non-commented tag lines
% %  "Tag_Name", tag, freq, state, size, type, par1, par2, par3, and brd
% 
% files = fieldnames(m300.file_packets);
% for f = 1:length(files)
%    if ~isempty(strfind(m300.file_packets.(files{f}).filename,'acq.300')) %We've got the acquisition file
%       % header:  Name  Tag  Freq State Size Type Par1 Par2 Par3 Address
%        C = textscan(m300.file_packets.(files{f}).filedata, '%s %f %f %f %f %f 0x%s 0x%s 0x%s %s %*[^\n]', 'commentStyle',';');
%        m300.data_acq.tag = C{2};
%        m300.data_acq.name = C{1};
%        m300.data_acq.freq = C{3};
%        m300.data_acq.state = C{4};
%        m300.data_acq.size = C{5};
%        m300.data_acq.type = C{6};
%        m300.data_acq.par1 = hex2dec(C{7});
%        m300.data_acq.par2 = hex2dec(C{8});
%        m300.data_acq.par3 = hex2dec(C{9});
%        m300.data_acq.brd = C{10};
%    end
% end

reserved = [0,999,65000:65535];
tags = unique([m300.packets.tag(m300.packets.actualSamples>0),reserved]);
tags = setxor(tags,reserved);
% find the data types corresponding to these tags
types = [];
m300.tag_types.tags = tags;
m300.tag_types.all_types = types;
m300.tag_types.desc = 'Col 1 = tag number, col 2 = type, col 3 = address, col 4 = packets found, col 5 = total bytes';
for t = tags
   num = find(m300.packets.tag==t);
   m300.tag_types.(['tag_',num2str(t)]) = [t, double(m300.packets.type(num(1))),m300.packets.address(num(1)), length(num),sum(double(m300.packets.numberBytes(num)))];
   types = unique([types,m300.packets.type(num(1))]);
end
m300.tag_types.all_types = types;

% Now segregate into buffers and get time stamps
m300.packets.buffer = cumsum(m300.packets.tag==0);
buffers = max(m300.packets.buffer);
tag0 = find(m300.packets.tag==0);
progress = 0;
begins = uint16(ones([buffers,9]));
ends = uint16(ones([buffers,9]));

for b = 1:buffers
      if (b./buffers) > progress
         disp(['Progress reading date/time: ',num2str(floor(100.*(b./buffers))),'%'])
         progress = progress + 0.1;
      end
   fseek(fid,m300.packets.bufferBegin(tag0(b))+uint32(m300.packets.dataOffset(tag0(b))),'bof');
   begins(b,:) = (fread(fid,[1,9],'uint16=>uint16'));
   ends(b,:) = (fread(fid,[1,9],'uint16=>uint16'));
%    V = double(fread(fid, [9,2],'uint16'))';
%    V(:,6) = V(:,6) + V(:,7)./V(:,8); % Absorb fraction of second
%    m300.buffer.start_time(b) = datenum(V(1,1:6));
%    m300.buffer.end_time(b) = datenum(V(end,1:6));
%    m300.buffer.maxSystemFrequency(b) = V(1,8);
%    m300.buffer.bufferLifetime(b) = V(1,9);
end
fclose(fid);
m300.buffer.begins = begins;
m300.buffer.ends = ends;
begins = double(begins);
ends = double(ends);
   begins(:,6) = begins(:,6) + begins(:,7)./begins(:,8); % Absorb fraction of second
   ends(:,6) = ends(:,6) + ends(:,7)./ends(:,8); % Absorb fraction of second
   m300.buffer.start_time = datenum(begins(:,1:6))';
   m300.buffer.end_time = datenum(ends(:,1:6))';
   m300.buffer.maxSystemFrequency = begins(:,8)';
   m300.buffer.bufferLifetime = begins(:,9)';
disp(['Progress reading date/time: 100%'])
% reserved = [0,999,65000:65535];
% tags = unique([m300.packets.tag(m300.packets.actualSamples>0),reserved]);
% tags = setxor(tags,reserved);
% fclose(fid);


% This function takes the "file_packets" field and rejoins files that have
% been split across multiple packets, putting the contents into the "files"
% field.
m300 = repack_files(m300);

[pname, fname, ext] = fileparts(m300.fullname);
outpath = [pname,fname];
if ~exist(outpath,'dir')
   mkdir(outpath);
end

disp(['Saving "',fname,'.mat".']);
save([outpath,filesep, fname,'.mat'],'m300', '-mat');



% Now we have the configuration files read in, so we _could_ make a table
% of defined data tags along with defined time base.
% The idea would be to find the acq.300 file, parse non-commented tag lines
%  "Tag_Name", tag, freq, state, size, type, par1, par2, par3, and brd

files = fieldnames(m300.files);
f = 1;
found = [];
while f <=length(files)
% for f = 1:length(files)
   if ~isempty(strfind(m300.files.(files{f}).filename,'acq.300')) %We've got the acquisition file
      % header:  Name  Tag  Freq State Size Type Par1 Par2 Par3 Address
 found = [found f];
   end
   f = f+1;
end
for f = length(found):-1:1
      % header:  Name  Tag  Freq State Size Type Par1 Par2 Par3 Address
      m300.data_acq(f).start_time = m300.files.(files{found(f)}).start_time;
      m300.data_acq(f).end_time = m300.files.(files{found(f)}).end_time;
      m300.data_acq(f).packet = m300.files.(files{found(f)}).packet;
      
       C = textscan(m300.files.(files{found(f)}).filedata, '%s %f %f %f %f %f 0x%s 0x%s 0x%s %s %*[^\n]', 'commentStyle',';');
       m300.data_acq(f).tag = C{2};
       m300.data_acq(f).name = C{1};
       m300.data_acq(f).freq = C{3};
       m300.data_acq(f).state = C{4};
       m300.data_acq(f).size = C{5};
       m300.data_acq(f).type = C{6};
       m300.data_acq(f).par1 = hex2dec(C{7});
       m300.data_acq(f).par2 = hex2dec(C{8});
       m300.data_acq(f).par3 = hex2dec(C{9});
       m300.data_acq(f).brd = C{10};
end

disp(['Saving "',fname,'.mat". (again)']);
save([outpath,filesep, fname,'.mat'],'m300', '-mat');


% for tag = m300.tag_types.tags;
%    m300 = parse_tag(m300,tag);
% end
%%