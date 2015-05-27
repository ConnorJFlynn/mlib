function d = pcasp_AD_cal(d);

if ~exist('d','var')
   d = rd_pcasp_dat;
end
if ~isfield(d,'cal')
   d.cal.AD = (double(d.AD) + double(d.setup.offsets')*ones([1,length(d.time)])).*(double(d.setup.calcCoeffs)'*ones([1,length(d.time)]));
   d.cal.avgTransit = double(d.avgTransit)./10;
   d.cal.sampleFlow = d.cal.AD(4,:) .* ((double(d.setup.temperature)+273.2) ./ 300) .* (1013 ./ double(d.setup.pressure));
   d.cal.sheathFlow = d.cal.AD(7,:) .* ((double(d.setup.temperature)+273.2) ./ 300) .* (1013 ./ double(d.setup.pressure));   
end
