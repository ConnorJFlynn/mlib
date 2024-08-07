function [DOY_CART_MWR,IPWV_CART_MWR]=read_CART_MWR;

%read CART MWR
IPWV_CART_MWR_all=[];
DOY_CART_MWR_all=[];

% Reads CART MWR data
pathname='d:\beat\data\Oklahoma\cart_mwr\version_991028\'
filelist=str2mat('sgpmwrlosC1.b2.970901.000020.cdf');
filelist=str2mat(filelist,...
'sgpmwrlosC1.b2.970902.000020.cdf',...
'sgpmwrlosC1.b2.970903.000020.cdf',...
'sgpmwrlosC1.b2.970904.000020.cdf',...
'sgpmwrlosC1.b2.970905.000020.cdf',...
'sgpmwrlosC1.b2.970906.000020.cdf',...
'sgpmwrlosC1.b2.970907.000020.cdf',...
'sgpmwrlosC1.b2.970908.000020.cdf',...
'sgpmwrlosC1.b2.970909.000020.cdf',...
'sgpmwrlosC1.b2.970910.000020.cdf',...
'sgpmwrlosC1.b2.970911.000020.cdf',...
'sgpmwrlosC1.b2.970912.000020.cdf',...
'sgpmwrlosC1.b2.970913.000020.cdf',...
'sgpmwrlosC1.b2.970914.000020.cdf',...
'sgpmwrlosC1.b2.970915.001920.cdf',...
'sgpmwrlosC1.b2.970916.000020.cdf',...
'sgpmwrlosC1.b2.970917.000020.cdf',...
'sgpmwrlosC1.b2.970918.000020.cdf',...
'sgpmwrlosC1.b2.970919.000020.cdf',...
'sgpmwrlosC1.b2.970920.000020.cdf',...
'sgpmwrlosC1.b2.970921.000020.cdf',...
'sgpmwrlosC1.b2.970922.000020.cdf',...
'sgpmwrlosC1.b2.970923.000020.cdf',...
'sgpmwrlosC1.b2.970924.000020.cdf',...
'sgpmwrlosC1.b2.970925.000020.cdf',...
'sgpmwrlosC1.b2.970926.000044.cdf',...
'sgpmwrlosC1.b2.970927.000020.cdf',...
'sgpmwrlosC1.b2.970928.000020.cdf',...
'sgpmwrlosC1.b2.970929.000020.cdf',...
'sgpmwrlosC1.b2.970930.000433.cdf',...
'sgpmwrlosC1.b2.971001.000020.cdf',...
'sgpmwrlosC1.b2.971002.000020.cdf',...
'sgpmwrlosC1.b2.971003.000020.cdf',...
'sgpmwrlosC1.b2.971004.000020.cdf',...
'sgpmwrlosC1.b2.971005.000020.cdf',...
'sgpmwrlosC1.b2.971006.000020.cdf',...
'sgpmwrlosC1.b2.971007.000020.cdf',...
'sgpmwrlosC1.b2.971008.000020.cdf',...
'sgpmwrlosC1.b2.971009.003720.cdf',...
'sgpmwrlosC1.b2.971010.000020.cdf',...
'sgpmwrlosC1.b2.971011.000020.cdf',...
'sgpmwrlosC1.b2.971012.000020.cdf',...
'sgpmwrlosC1.b2.971013.000640.cdf',...
'sgpmwrlosC1.b2.971014.000840.cdf',...
'sgpmwrlosC1.b2.971015.000020.cdf',...
'sgpmwrlosC1.b2.971016.000020.cdf',...
'sgpmwrlosC1.b2.971017.000020.cdf',...
'sgpmwrlosC1.b2.971018.000020.cdf',...
'sgpmwrlosC1.b2.971019.000020.cdf',...
'sgpmwrlosC1.b2.971020.000020.cdf',...
'sgpmwrlosC1.b2.971021.000020.cdf',...
'sgpmwrlosC1.b2.971022.000020.cdf',...
'sgpmwrlosC1.b2.971023.003640.cdf',...
'sgpmwrlosC1.b2.971024.000020.cdf',...
'sgpmwrlosC1.b2.971025.000020.cdf',...
'sgpmwrlosC1.b2.971026.000020.cdf',...
'sgpmwrlosC1.b2.971027.000020.cdf',...
'sgpmwrlosC1.b2.971028.000020.cdf',...
'sgpmwrlosC1.b2.971029.000020.cdf',...
'sgpmwrlosC1.b2.971030.000020.cdf',...
'sgpmwrlosC1.b2.971031.000020.cdf');

for ifile=1:61
  filename=filelist(ifile,:) 
  nc=netcdf((deblank([pathname filename])),'nowrite');
  variables=var(nc);
  BaseTime=(variables{1}(:));
  TimeOffset=(variables{2}(:))';
  IPWV_CART_MWR=(variables{5}(:))';
  QC_Flag=(variables{8}(:))';
  nc=close(nc);

  %determine date from filename
  day=str2num(filename(20:21));
  month=str2num(filename(18:19));
  year=str2num(filename(16:17))+1900;
  hour=str2num(filename(23:24));
  min=str2num(filename(25:26));
  sec=str2num(filename(27:28));

  %check base time
  UT_start=hour+min/60+sec/3600;
  BaseTimeComp=(julian(day,month,year,UT_start)-julian(1,1,1970,0))*24*3600; 
  if BaseTimeComp-BaseTime < 1;
   DOY_CART_MWR=julian(day,month,year,UT_start+TimeOffset/3600)-julian(31,12,1996,0);
   ii=find(QC_Flag==0); %use only if quality flag is 0
    %plot(DOY_CART_MWR(ii),IPWV_CART_MWR(ii))
   IPWV_CART_MWR_all=[IPWV_CART_MWR_all IPWV_CART_MWR(ii)];
   DOY_CART_MWR_all=[DOY_CART_MWR_all DOY_CART_MWR(ii)];
  else
    disp('Base time is wrong. Check')
  end   

end 
IPWV_CART_MWR=IPWV_CART_MWR_all;
DOY_CART_MWR=DOY_CART_MWR_all;
clear IPWV_CART_MWR_all;
clear DOY_CART_MWR_all;
