function m300 = repack_files(m300)
% Re-assemble files split into multiple parts into single contiguous
% packet.
%%
files = fieldnames(m300.file_packets);
fnum = 1; % new structure
f = 1; % old structure
m300.files.(['file_',num2str(fnum)]).filename = m300.file_packets.(files{f}).filename;
m300.files.(['file_',num2str(fnum)]).start_time = m300.buffer.start_time(m300.packets.buffer(m300.file_packets.(files{f}).packet));
m300.files.(['file_',num2str(fnum)]).end_time = m300.buffer.end_time(m300.packets.buffer(m300.file_packets.(files{f}).packet));
m300.files.(['file_',num2str(fnum)]).filedata = m300.file_packets.(files{f}).filedata;
m300.files.(['file_',num2str(fnum)]).packet = m300.file_packets.(files{f}).packet;
for f = 2:length(files)
   if (strcmp(m300.files.(['file_',num2str(fnum)]).filename, m300.file_packets.(files{f}).filename) && ...
         m300.files.(['file_',num2str(fnum)]).start_time == m300.buffer.start_time(m300.packets.buffer(m300.file_packets.(files{f}).packet)) && ...
         m300.files.(['file_',num2str(fnum)]).end_time == m300.buffer.end_time(m300.packets.buffer(m300.file_packets.(files{f}).packet)))
      m300.files.(['file_',num2str(fnum)]).filedata = [m300.files.(['file_',num2str(fnum)]).filedata, m300.file_packets.(files{f}).filedata];
   else
      fnum = fnum+1;
%       disp(m300.file_packets.(files{f}).filename)
      m300.files.(['file_',num2str(fnum)]).filename = m300.file_packets.(files{f}).filename;
      m300.files.(['file_',num2str(fnum)]).start_time = m300.buffer.start_time(m300.packets.buffer(m300.file_packets.(files{f}).packet));
      m300.files.(['file_',num2str(fnum)]).end_time = m300.buffer.end_time(m300.packets.buffer(m300.file_packets.(files{f}).packet));
      m300.files.(['file_',num2str(fnum)]).filedata = m300.file_packets.(files{f}).filedata;
      m300.files.(['file_',num2str(fnum)]).packet = m300.file_packets.(files{f}).packet;

   end
end
%%

