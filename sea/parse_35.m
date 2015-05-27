function SEA_AD = parse_35(SEA_AD, samp_ind,temp)
%SEA_AD = parse_35(SEA_AD, samp_ind,temp);

[packets,bytes,samples] = size(temp);
samps = double(SEA_AD.samples);
cumsam = cumsum(samps);
SEA_AD.box_id = double(SEA_AD.parameter1(1));
SEA_AD.ch = double(SEA_AD.parameter2(1));
if SEA_AD.parameter3(1)==0
   SEA_AD.gain =1;
elseif SEA_AD.parameter3(1)==1
   SEA_AD.gain =2;
elseif SEA_AD.parameter3(1)==2
   SEA_AD.gain =4;
elseif SEA_AD.parameter3(1)==3
   SEA_AD.gain =8;
else
   disp(['Unexpected SEA_AD.parameter value = ',num2str(SEA_AD.parameter3(1))])
   SEA_AD.gain =NaN;
end
AD_data.V = NaN(packets,samples);
% temp = double(temp);

for s = samples:-1:1
   X = [temp(:,1,s), temp(:,2,s)]'; %stitch bytes back together and make row vector
   xx = typecast([X(:)],'int16'); %Convert to signed int.
   AD_data.V(:,s) = xx;
end
AD_data.V = AD_data.V * 10 ./ (SEA_AD.gain * 32768);
% SEA_AD..V = NaN(1,samples*packets);
buf = [1:packets];
for s = samples:-1:1
   SEA_AD.V(s-samps(samp_ind)+cumsam(samp_ind)) = AD_data.V(buf,s);
end

%          SPP.(fields{f})(s-samps(samp_ind)+cumsam(samp_ind)) = SPP_data.(fields{f})(buf,s);
%    SPP.bins(1:bins,(s-samps(samp_ind)+cumsam(samp_ind))) = SPP_data.bins(buf,1:bins,s)';
