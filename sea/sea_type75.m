function m300 = sea_type75(m300);
% m300 = sea_type75(m300)
% Loads and parse SEA type 75 packets, storing results in m300
fid = fopen(m300.fullname, 'r');
%%
type75 = (m300.packets.type==75 & m300.packets.actualSamples>0);
reserved = [0,999,65000:65535];
tags = unique([m300.packets.tag(type75),reserved]);
tags = setxor(tags,reserved);

disp('Reading type 75...');
for t =1:length(tags)
   type75 = (m300.packets.type==75 & m300.packets.actualSamples>0 & m300.packets.tag==tags(t));
   ind_type75 = find(type75);
   m300.type_75.(['tag_',num2str(tags(t))]).packet = ind_type75;
   m300.type_75.(['tag_',num2str(tags(t))]).numberBytes = m300.packets.numberBytes(type75);
   m300.type_75.(['tag_',num2str(tags(t))]).actualSamples = m300.packets.actualSamples(type75);
   m300.type_75.(['tag_',num2str(tags(t))]).parameter1 = m300.packets.parameter1(type75);   
   m300.type_75.(['tag_',num2str(tags(t))]).parameter1 = m300.packets.parameter2(type75);
   m300.type_75.(['tag_',num2str(tags(t))]).parameter3 = m300.packets.parameter3(type75);   
   buffers = m300.packets.buffer(type75);
   m300.type_75.(['tag_',num2str(tags(t))]).buffers = buffers; 
   m300.type_75.(['tag_',num2str(tags(t))]).start_time = m300.buffer.start_time(buffers);
   m300.type_75.(['tag_',num2str(tags(t))]).end_time = m300.buffer.end_time(buffers);
   m300.type_75.(['tag_',num2str(tags(t))]).maxSystemFrequency = m300.buffer.maxSystemFrequency(buffers);
   m300.type_75.(['tag_',num2str(tags(t))]).bufferLifetime = m300.buffer.bufferLifetime(buffers);
   buffers = length(m300.type_75.(['tag_',num2str(tags(t))]).buffers);
   for b = buffers:-1:1
%       if (1-b./buffers) > progress
%          disp(['Progress reading type 75: ',num2str(floor(100.*(1-b./buffers))),'%'])
%          progress = progress + 0.01;
%       end
      fseek(fid,m300.packets.bufferBegin(ind_type75(b))+uint32(m300.packets.dataOffset(ind_type75(b))),'bof');
      cur1 = ftell(fid);
      temp = fread(fid, double([m300.packets.bytesPerSample(ind_type75(b)) , m300.packets.actualSamples(ind_type75(b))]),'uint8');
      SPP_data = parse_type75(temp);
      fields = fieldnames(SPP_data);
      for f = length(fields):-1:1
         if ~strcmp(fields{f},'bins')
            m300.type_75.(['tag_',num2str(tags(t))]).(fields{f})(b,:) = SPP_data.(fields{f});
         end
      end
      m300.type_75.(['tag_',num2str(tags(t))]).bins(b) = {SPP_data.bins};
      fseek(fid,cur1,'bof');
   end
end

%%
fclose(fid);
%%
function SPP_data = parse_type75(temp)
%SPP_data = sea_type75(temp);
%Parses a SPP data packet read as type 75 from SEA M300 file
SPP_data.hiGainBaselineV = temp(1,:) + (2.^8).*temp(2,:);
SPP_data.medGainBaselineV = temp(3,:)+ (2.^8).*temp(4,:);
SPP_data.lowGainBaselineV = temp(5,:)+ (2.^8).*temp(6,:);
SPP_data.sampleFlow = temp(7,:)+ (2.^8).*temp(8,:);
SPP_data.laserRefV = temp(9,:)+ (2.^8).*temp(10,:);
SPP_data.auxAnalog = temp(11,:)+ (2.^8).*temp(12,:);
SPP_data.sheathFlow = temp(13,:)+ (2.^8).*temp(14,:);
SPP_data.electronicsTemp = temp(15,:)+ (2.^8).*temp(16,:);
SPP_data.avgTransit = temp(17,:)+ (2.^8).*temp(18,:);
SPP_data.fullFIFO = temp(19,:)+ (2.^8).*temp(20,:);
SPP_data.resetFlag = temp(21,:)+ (2.^8).*temp(22,:);
SPP_data.syncErrorA = temp(23,:)+ (2.^8).*temp(24,:);
SPP_data.syncErrorB = temp(25,:)+ (2.^8).*temp(26,:);
SPP_data.syncErrorC = temp(27,:)+ (2.^8).*temp(28,:);
SPP_data.overflowADC = (2.^16).*(temp(29,:)+ (2.^8).*temp(30,:))+ temp(31,:)+ (2.^8).*temp(32,:);
SPP_data.bins = (2.^16).*(temp(33:4:149,:) + (2.^8).*temp(34:4:150,:))+ temp(35:4:151,:)+ (2.^8).*temp(36:4:152,:);
SPP_data.checksum = temp(153,:)+ (2.^8).*temp(154,:);
checksum = uint16(sum(uint16(temp(1:end-2,:))));
SPP_data.ERROR = (checksum ~= SPP_data.checksum);
