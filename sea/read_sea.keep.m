function sea = read_sea(fullfile)
if ~exist('fullfile','var')
   fullfile = getfullname('*.sea','sea','Select SEA file.');
end
%%

fid = fopen(fullfile, 'r');
%%
fseek(fid,0,1);
eof = ftell(fid);
fseek(fid,0,-1);
buf = 0;
LAST = false;
tags = [];
%%
while (eof - ftell(fid))>0 && ~LAST
   NEXT = false;
   buf = buf + 1;
   bob = ftell(fid);
   while ~NEXT && ~LAST && (eof - ftell(fid))>0 
      %%
      datadir.tagNumber = fread(fid,1,'*uint16'); %16-bit
      tags = unique([tags, datadir.tagNumber]);
      datadir.dataOffset = fread(fid,1,'*uint16');%16-bit
      datadir.numberBytes = fread(fid,1,'*uint16');%16-bit
      datadir.samples = fread(fid,1,'*uint16');%16-bit
      datadir.bytesPerSample = fread(fid,1,'*uint16');%16-bit
      datadir.actualSamples = datadir.numberBytes ./ datadir.bytesPerSample;
      datadir.type = fread(fid,1,'*uint8');%8-bit
      datadir.parameter1 = fread(fid,1,'*uint8');%8-bit
      datadir.parameter2 = fread(fid,1,'*uint8');%8-bit
      datadir.parameter3 = fread(fid,1,'*uint8');%8-bit
      datadir.address = fread(fid,1,'*uint16');%16-bit
      cur = ftell(fid);
      tag_str = ['tag_',num2str(datadir.tagNumber)];
      if datadir.tagNumber==0
         % read and store date stamp
         % Parse data/buffer type from tagNumber and type
         fseek(fid,bob+datadir.dataOffset,'bof');
         V = double(fread(fid, [9,double(datadir.actualSamples)],'uint16'))';
         V(:,6) = V(:,6) + V(:,7)./V(:,8); % Absorb fraction of second
         sea(buf).time = datenum(V(:,1:6));
         sea(buf).maxSystemFrequency = V(:,8);
         sea(buf).bufferLifetime = V(:,9);
         fseek(fid,cur,'bof');
      elseif datadir.tagNumber==65530
         fseek(fid,bob+datadir.dataOffset,'bof');
         temp = char(fread(fid, double(datadir.bytesPerSample .* datadir.actualSamples),'uchar'))';
         sea(buf).filename = temp;
         fseek(fid,cur,'bof');
         % read and store filename
      elseif datadir.tagNumber==65531
         fseek(fid,bob+datadir.dataOffset,'bof');
         temp = char(fread(fid, double(datadir.bytesPerSample .* datadir.actualSamples),'uchar'))';
         sea(buf).data = temp;
         fseek(fid,cur,'bof');
      elseif datadir.tagNumber==65533
         fseek(fid,bob+datadir.dataOffset,'bof');
         % read and store command
         temp = char(fread(fid, double(datadir.bytesPerSample .* datadir.actualSamples),'uchar'))';
         sea(buf).command = temp;
         fseek(fid,cur,'bof');
      elseif datadir.tagNumber==65534
         fseek(fid,bob+datadir.dataOffset,'bof');
                  % read and store error message
                  temp = char(fread(fid, double(datadir.bytesPerSample .* datadir.actualSamples),'uchar'))';
         sea(buf).error = temp;
         fseek(fid,cur,'bof');
      elseif datadir.tagNumber==65535
         % read and store filename
         LAST = true;
      elseif datadir.tagNumber==999
         % skip forward to next buffer
         fseek(fid,bob+double(datadir.dataOffset),'bof');
         NEXT = true;
      else
         if datadir.type==75 && datadir.actualSamples>0
         sea(buf).(tag_str) = datadir;
         fseek(fid,bob+double(datadir.dataOffset),'bof');
         cur1 = ftell(fid);
         temp = fread(fid, double(datadir.bytesPerSample .* datadir.actualSamples),'uint8');
         SPP_data = cnv_spp200(temp);
         fseek(fid,cur,'bof');
         end
      end
%       fseek(fid,bob+double(datadir.dataOffset)+double(datadir.numberBytes),'bof');
      end
end
fclose(fid);
      %%
function   SPP_data = cnv_spp200(temp);
% SPP_data.hiGainBaselineV = temp(1);
% SPP_data.medGainBaselineV = temp(2);
% SPP_data.lowGainBaselineV = temp(3);
% SPP_data.sampleFlow = temp(4);
% SPP_data.laserRefV = temp(5);
% SPP_data.auxAnalog = temp(6);
% SPP_data.sheathFlow = temp(7);
% SPP_data.electronicsTemp = temp(8);
% SPP_data.avgTransit = temp(9);
% SPP_data.fullFIFO = temp(10);
% SPP_data.resetFlag = temp(11);
% SPP_data.syncErrorA = temp(12);
% SPP_data.syncErrorB = temp(13);
% SPP_data.syncErrorC = temp(14);
% SPP_data.overflowADC = temp(15)+ (2.^16).*temp(16);
% SPP_data.bins = temp(17:2:75) + (2.^16).*temp(18:2:76);
% SPP_data.checksum = temp(77);

%
SPP_data.hiGainBaselineV = temp(1) + (2.^8).*temp(2);
SPP_data.medGainBaselineV = temp(3)+ (2.^8).*temp(4);
SPP_data.lowGainBaselineV = temp(5)+ (2.^8).*temp(6);
SPP_data.sampleFlow = temp(7)+ (2.^8).*temp(8);
SPP_data.laserRefV = temp(9)+ (2.^8).*temp(10);
SPP_data.auxAnalog = temp(11)+ (2.^8).*temp(12);
SPP_data.sheathFlow = temp(13)+ (2.^8).*temp(14);
SPP_data.electronicsTemp = temp(15)+ (2.^8).*temp(16);
SPP_data.avgTransit = temp(17)+ (2.^8).*temp(18);
SPP_data.fullFIFO = temp(19)+ (2.^8).*temp(20);
SPP_data.resetFlag = temp(21)+ (2.^8).*temp(22);
SPP_data.syncErrorA = temp(23)+ (2.^8).*temp(24);
SPP_data.syncErrorB = temp(25)+ (2.^8).*temp(26);
SPP_data.syncErrorC = temp(27)+ (2.^8).*temp(28);
SPP_data.overflowADC = (2.^16).*(temp(29)+ (2.^8).*temp(30))+ temp(31)+ (2.^8).*temp(32);
SPP_data.bins = (2.^16).*(temp(33:4:149) + (2.^8).*temp(34:4:150))+ temp(35:4:151)+ (2.^8).*temp(36:4:152);
SPP_data.checksum = temp(153)+ (2.^8).*temp(154);
checksum = uint16(sum(uint16(temp(1:end-2))));
if checksum ~= SPP_data.checksum
   SPP_data.ERROR = true;
else
   SPP_data.ERROR = false;
end
