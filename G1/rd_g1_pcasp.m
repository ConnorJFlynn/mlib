function pcasp = rd_g1_pcasp(infile)

if ~exist('infile','var')||~exist(infile,'file')
   infile = getfullname__('*.ict','g1','Select G1 PCASP ICCART file.');
end
ict = rd_ict(infile);
pcasp.time = ict.time;
pcasp.n = [];
pcasp.um = [];
fieldname = fieldnames(ict);
for fld = 1:length(fieldname)
   fld_str = fieldname{fld};
   if strcmp(fld_str(1:2),'n_')
      pcasp.n = [pcasp.n, ict.(fld_str)];
      pcasp.um = [pcasp.um, sscanf(fld_str(3:end),'%f')./1000];     
   end
end      


pcasp.cloud = ict.Cloud_Flag;
pcasp.bad_data = ict.Data_Flag;
Down = 100;
sd = downsample(pcasp.n(pcasp.cloud==0&pcasp.bad_data==0,:),Down);
Vol = pi.*(4./3).*(sd .*(ones([length(downsample(pcasp.time(pcasp.cloud==0&pcasp.bad_data==0),Down)),1])*((pcasp.um./2).^3)));


return