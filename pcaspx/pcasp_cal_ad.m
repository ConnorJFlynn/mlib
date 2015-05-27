function d = pcasp_cal(d);

if ~exist('d','var')
d = rd_pcasp_dat;
end
if ~isfield(d,'cal')
   d.cal.AD = (double(d.AD) + double(d.setup.offsets')*ones([1,length(d.time)])).*(double(d.setup.calcCoeffs)'*ones([1,length(d.time)]));
   d.cal.avgTransit = double(d.avgTransit)./10;
end