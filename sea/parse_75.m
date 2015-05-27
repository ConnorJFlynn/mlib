function SPP = parse_75(SPP, samp_ind, temp)
%SPP_data = sea_type75(temp);

% Need a loop kind of like this around this whole mess...
%    samples = double(m300.(tag_str).samples(1));
%    for s = samples:-1:1
%       m300.(tag_str).time(s.*buf) = m300.(tag_str).start_time(buf)+ (s-1) .* m300.(tag_str).time_step(buf);
%    end
% samples = double(SPP.samples(1));

[packets,bytes,samples] = size(temp);
if bytes == 154
   bins = 30;
end
   SPP_data.hiGainBaselineV = NaN(packets,samples);
   SPP_data.medGainBaselineV = NaN(packets,samples);
   SPP_data.lowGainBaselineV = NaN(packets,samples);
   SPP_data.sampleFlow = NaN(packets,samples);
   SPP_data.laserRefV = NaN(packets,samples);
   SPP_data.auxAnalog = NaN(packets,samples);
   SPP_data.sheathFlow = NaN(packets,samples);
   SPP_data.electronicsTemp = NaN(packets,samples);
   SPP_data.avgTransit = NaN(packets,samples);
   SPP_data.fullFIFO = NaN(packets,samples);
   SPP_data.resetFlag = NaN(packets,samples);
   SPP_data.syncErrorA = NaN(packets,samples);
   SPP_data.syncErrorB = NaN(packets,samples);
   SPP_data.syncErrorC = NaN(packets,samples);
   SPP_data.overflowADC = NaN(packets,samples);
   SPP_data.bins = NaN(packets,bins,samples);
   SPP_data.checksum = NaN(packets,samples);
   SPP_data.ERROR = NaN(packets,samples);

   temp = double(temp);

for s = samples:-1:1
   %Parses a SPP data packet read as type 75 from SEA M300 file
   SPP_data.hiGainBaselineV(:,s) = temp(:,1,s) + (2.^8).*temp(:,2,s);
   SPP_data.medGainBaselineV(:,s) = temp(:,3,s)+ (2.^8).*temp(:,4,s);
   SPP_data.lowGainBaselineV(:,s) = temp(:,5,s)+ (2.^8).*temp(:,6,s);
   SPP_data.sampleFlow(:,s) = temp(:,7,s)+ (2.^8).*temp(:,8,s);
   SPP_data.laserRefV(:,s) = temp(:,9,s)+ (2.^8).*temp(:,10,s);
   SPP_data.auxAnalog(:,s) = temp(:,11,s)+ (2.^8).*temp(:,12,s);
   SPP_data.sheathFlow(:,s) = temp(:,13,s)+ (2.^8).*temp(:,14,s);
   SPP_data.electronicsTemp(:,s) = temp(:,15,s)+ (2.^8).*temp(:,16,s);
   SPP_data.avgTransit(:,s) = temp(:,17,s)+ (2.^8).*temp(:,18,s);
   SPP_data.fullFIFO(:,s) = temp(:,19,s)+ (2.^8).*temp(:,20,s);
   SPP_data.resetFlag(:,s) = temp(:,21,s)+ (2.^8).*temp(:,22,s);
   SPP_data.syncErrorA(:,s) = temp(:,23,s)+ (2.^8).*temp(:,24,s);
   SPP_data.syncErrorB(:,s) = temp(:,25,s)+ (2.^8).*temp(:,26,s);
   SPP_data.syncErrorC(:,s) = temp(:,27,s)+ (2.^8).*temp(:,28,s);
   SPP_data.overflowADC(:,s) = (2.^16).*(temp(:,29,s)+ (2.^8).*temp(:,30,s))+ temp(:,31,s)+ (2.^8).*temp(:,32,s);
   SPP_data.bins(:,1:bins,s) = (2.^16).*(temp(:,33:4:149,s) + (2.^8).*temp(:,34:4:150,s))+ temp(:,35:4:151,s)+ (2.^8).*temp(:,36:4:152,s);
   SPP_data.checksum(:,s) = temp(:,153,s)+ (2.^8).*temp(:,154,s);
   SPP_data.ERROR(:,s) = (SPP_data.checksum(:,s) ~= uint16(sum(uint16(temp(:,1:end-2,s)),2)));
end
% AD = fieldnames(SPP_data);
% AD = AD(1:8);
% AD.offsets = [-2048 -2048 -2048 -2295 -2048 -2048 -2750 -2328];
% AD.coefs = [[48.8281   48.8281   48.8281   35.5371   48.8281   48.8281  465.5612]./10000 .9765625]; 

buf = [1:packets];
fields = fieldnames(SPP_data);
% if ~isfield(SPP,'bins')
%    SPP.bins = NaN(bins,samples*packets);
% end
samps = double(SPP.samples);
cumsam = cumsum(samps);
for s = samples:-1:1
   for f = length(fields):-1:1
      if ~strcmp(fields{f},'bins')
%          SPP.(fields{f})(s +samples.*(buf-1)) = SPP_data.(fields{f})(buf,s);
% disp(fields(f))
         SPP.(fields{f})(s-samps(samp_ind)+cumsam(samp_ind)) = SPP_data.(fields{f})(buf,s);
      end
   end
%    SPP.bins(1:bins,(s +samples.*(buf-1))) = SPP_data.bins(buf,1:bins,s)';
   SPP.bins(1:bins,(s-samps(samp_ind)+cumsam(samp_ind))) = SPP_data.bins(buf,1:bins,s)';
   %SPP.bins(1:bins,(s-samps(samp_ind)+cumsam(samp_ind)) = SPP_data.bins((samp_ind) + (s-1) .* m300.(tag_str).time_step(samp_ind);

%    m300.(tag_str).time(s +samples.*(buf-1)) = m300.(tag_str).start_time(buf) + (s-1) .* m300.(tag_str).time_step(1);
end

%          SPP.(fields{f})(s-samps(samp_ind)+cumsam(samp_ind)) = SPP_data.(fields{f})(buf,s);
%    SPP.bins(1:bins,(s-samps(samp_ind)+cumsam(samp_ind))) = SPP_data.bins(buf,1:bins,s)';
