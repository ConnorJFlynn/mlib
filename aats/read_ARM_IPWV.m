%reads IPWV Data during Fall97 ARM SGP IOP
clear

%read CART MWR
[DOY_CART_MWR,IPWV_CART_MWR]=read_CART_MWR;

% reads AATS-6 data
[DOY_AATS6,IPWV_AATS6]=read_AATS6

%read Cimel data
[DOY_Cimel,IPWV_Cimel]=read_Cimel;

%read mfrsr as produced by Jim Barnard
[DOY_MFRSR,IPWV_MFRSR]=read_MFRSR;


%reads GPS data
read_gps_cf
read_gps_lamont


% reads radiosonde data
IPWV_bbss_all=[];
DOY_bbss_all=[];
for ifile=1:20
 read_bbss  
 IPWV_bbss_all=[IPWV_bbss_all IPWV_bbss];
 DOY_bbss_all=[DOY_bbss_all DOY_bbss];
end 
IPWV_bbss=IPWV_bbss_all;
DOY_bbss=DOY_bbss_all;
clear IPWV_bbss_all;
clear DOY_bbss_all;


%read mfrsr as produced by Joe Michalsky
IPWV_mfrsr_all=[];
DOY_mfrsr_all=[];
for ifile=1:4
 read_mfrsr_Joe_H2O 
 IPWV_mfrsr_all=[IPWV_mfrsr_all IPWV_mfrsr_Joe];
 DOY_mfrsr_all=[DOY_mfrsr_all DOY_mfrsr_Joe];
end 
IPWV_mfrsr_Joe=IPWV_mfrsr_all;
DOY_mfrsr_Joe=DOY_mfrsr_all;
clear IPWV_mfrsr_all;
clear DOY_mfrsr_all;

%read ETL MWR1
IPWV_etl1_all=[];
ILW_etl1_all=[];
DOY_etl1_all=[];
for ifile=1:21
 read_etl1
 IPWV_etl1_all=[IPWV_etl1_all IPWV_etl1];
 ILW_etl1_all=[ILW_etl1_all ILW_etl1];
 DOY_etl1_all=[DOY_etl1_all DOY_etl1];
end 
IPWV_etl1=IPWV_etl1_all;
ILW_etl1=ILW_etl1_all;
DOY_etl1=DOY_etl1_all;
clear IPWV_etl1_all;
clear ILW_etl1_all;
clear DOY_etl1_all;

i=find(IPWV_etl1~=-9.99 & ILW_etl1<0.2);
DOY_etl1=DOY_etl1(i);
IPWV_etl1=IPWV_etl1(i);
ILW_etl1=ILW_etl1(i);


%read ETL MWR2
IPWV_etl2_all=[];
ILW_etl2_all=[];
DOY_etl2_all=[];
for ifile=1:9
 read_etl2
 IPWV_etl2_all=[IPWV_etl2_all IPWV_etl2];
 ILW_etl2_all=[ILW_etl2_all ILW_etl2];
 DOY_etl2_all=[DOY_etl2_all DOY_etl2];
end 
IPWV_etl2=IPWV_etl2_all;
ILW_etl2=ILW_etl2_all;
DOY_etl2=DOY_etl2_all;
clear IPWV_etl2_all;
clear ILW_etl2_all;
clear DOY_etl2_all;

i=find(IPWV_etl2~=-9.99 & ILW_etl2<0.2);
DOY_etl2=DOY_etl2(i);
IPWV_etl2=IPWV_etl2(i);
ILW_etl2=ILW_etl2(i);

%read GSFC Lidar
IPWV_GSFC_lidar_all=[];
DOY_GSFC_lidar_all=[];
for ifile=1:10
 read_GSFC_lidar
 IPWV_GSFC_lidar_all=[IPWV_GSFC_lidar_all IPWV_GSFC_lidar];
 DOY_GSFC_lidar_all=[DOY_GSFC_lidar_all DOY_GSFC_lidar];
end 
IPWV_GSFC_lidar=IPWV_GSFC_lidar_all;
DOY_GSFC_lidar=DOY_GSFC_lidar_all;
clear IPWV_GSFC_lidar_all;
clear DOY_GSFC_lidar_all;

i=find(IPWV_GSFC_lidar <6);
DOY_GSFC_lidar=DOY_GSFC_lidar(i);
IPWV_GSFC_lidar=IPWV_GSFC_lidar(i);

%read CART Lidar
IPWV_CART_lidar_all=[];
DOY_CART_lidar_all=[];
for ifile=1:12
 read_CART_lidar
 IPWV_CART_lidar_all=[IPWV_CART_lidar_all IPWV_CART_lidar];
 DOY_CART_lidar_all=[DOY_CART_lidar_all DOY_CART_lidar];
end 
IPWV_CART_lidar=IPWV_CART_lidar_all;
DOY_CART_lidar=DOY_CART_lidar_all;
clear IPWV_CART_lidar_all;
clear DOY_CART_lidar_all;

i=find(IPWV_CART_lidar <6);
DOY_CART_lidar=DOY_CART_lidar(i);
IPWV_CART_lidar=IPWV_CART_lidar(i);

clear data




