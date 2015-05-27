% Reads PSU sun photometer data

pathname='d:\beat\data\Oklahoma\PSU\version_990304\'
filelist=str2mat('DsgpPSUsunphotometerC1.a1.19970917.183806.02h29m.a0.cdf');
filelist=str2mat(filelist,...
'DsgpPSUsunphotometerC1.a1.19970918.160643.05h35m.a0.cdf',...
'DsgpPSUsunphotometerC1.a1.19970925.185259.03h23m.a0.cdf',...
'DsgpPSUsunphotometerC1.a1.19970927.172248.04h48m.a0.cdf',...
'DsgpPSUsunphotometerC1.a1.19970928.174804.04h32m.a0.cdf',...
'DsgpPSUsunphotometerC1.a1.19970929.175507.04h21m.a0.cdf',...
'DsgpPSUsunphotometerC1.a1.19970930.122458.06h01m.a0.cdf',...
'DsgpPSUsunphotometerC1.a1.19970930.183243.03h33m.a0.cdf',...
'DsgpPSUsunphotometerC1.a1.19971001.170413.03h59m.a0.cdf',...
'DsgpPSUsunphotometerC1.a1.19971002.123105.08h20m.a0.cdf',...
'DsgpPSUsunphotometerC1.a1.19971002.205444.35m06s.a0.cdf');

filename=filelist(ifile,:); 
nc=netcdf((deblank([pathname filename])),'nowrite');
variables=var(nc);
BaseTime=(variables{1}(:));
TimeOffset=(variables{2}(:))';
AOD_PSU(1,:)=(variables{6}(:))';
AOD_PSU(2,:)=(variables{7}(:))';
AOD_PSU(3,:)=(variables{8}(:))';
AOD_PSU(4,:)=(variables{9}(:))';
AOD_PSU(5,:)=(variables{10}(:))';
AOD_PSU(6,:)=(variables{11}(:))';
AOD_PSU(7,:)=(variables{12}(:))';
AOD_PSU(8,:)=(variables{13}(:))';
AOD_PSU(9,:)=(variables{15}(:))';
nc=close(nc);

lambda_PSU=[380.0 400.0 440.8    519.2    608.7    669.5    780.5    871.8    1028.2]/1e3;
O3_xsect_PSU=[0   0     2.687e-3 4.687e-2 1.299e-1 4.472e-2 7.871e-3 1.239e-3 3.768e-5] %per atm-cm
O3_col=0.270 %atm-cm
tau_O3=O3_col*O3_xsect_PSU

[m,n]=size(AOD_PSU);
AOD_PSU=AOD_PSU-(ones(n,1)*tau_O3)';
%determine date from filename
day=str2num(filename(33:34))
month=str2num(filename(31:32))
year=str2num(filename(27:30))
hour=str2num(filename(36:37))
min=str2num(filename(38:39))
sec=str2num(filename(40:41))

%check base time
UT_start=hour+min/60+sec/3600;
BaseTimeComp=(julian(day,month,year,UT_start)-julian(1,1,1970,0))*24*3600;

if BaseTimeComp-BaseTime < 1;
DOY_PSU=julian(day,month,year,UT_start+TimeOffset/3600)-julian(31,12,1996,0);
else
   disp('Base time is wrong. Check')
end   