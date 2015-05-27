function [DOY_AATS6,IPWV_AATS6,AOD_flag,AOD_AATS6,AOD_Error_AATS6,alpha_AATS6,lambda_AATS6]=read_AATS6(mode);

%reads AATS-6 data
% mode 1: 1997 WVIOP2 data
% mode 2: 2000 WVIOP3 data submitted during IOP release 0.0
% mode 3: 2000 WVIOP3 data submitted after  IOP release 0.1


lambda_AATS6=[0.3801  0.4507  0.5253  0.8639  1.0207];%wavelengths
alpha_AATS6_all=[];
AOD_AATS6_all=[];
AOD_Error_AATS6_all=[];
IPWV_AATS6_all=[];
DOY_AATS6_all=[];
AOD_flag_all=[];

switch mode
 case 1
   %pathname='c:\Beat\Data\Oklahoma\WVIOP2\AATS6\version_990507\'; %MODTRAN 3.5
   pathname='c:\Beat\Data\Oklahoma\WVIOP2\AATS6\version_06\'; %LBLRTM 5.10
   filelist=str2mat('AATS6_14sep97.asc');
   filelist=str2mat(filelist,...
   'AATS6_15sep97.asc',...
   'AATS6_16sep97.asc',...
   'AATS6_17sep97.asc',...
   'AATS6_18sep97.asc',...
   'AATS6_25sep97.asc',...
   'AATS6_26sep97.asc',...
   'AATS6_27sep97.asc',...
   'AATS6_28sep97.asc',...
   'AATS6_29sep97.asc',...
   'AATS6_30sep97.asc',...   
   'AATS6_01oct97.asc',...
   'AATS6_02oct97.asc',...
   'AATS6_03oct97.asc',...
   'AATS6_04oct97.asc');
   for ifile=1:15
    filename=filelist(ifile,:) 
    fid=fopen(deblank([pathname filename]));
    for i=1:6
     fgetl(fid);
    end
    data=fscanf(fid,'%f',[19,inf]);
    fclose(fid);
    UT_AATS6=data(1,:);
    Latitude_AATS6=data(2,:);
    Longitude_AATS6=data(3,:);
    Press_Alt_AATS6=data(4,:);
    Pressure_AATS6=data(5,:);
    IPWV_AATS6=data(6,:);
    O3_AATS6=data(7,:);
    alpha_AATS6=data(8,:);
    AOD_AATS6=data(9:13,:);
    AOD_Error_AATS6=data(14:18,:);
    CWV_Error_AATS6=data(19,:);

    %determine date from filename
    months=['jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec'];
    day=str2num(filename(7:8));
    month=ceil(findstr(months,lower(filename(9:11)))/3);
    year=str2num(filename(12:13))+1900;
    DOY_AATS6=julian(day,month,year,UT_AATS6)-julian(31,12,1996,0);
    alpha_AATS6_all=[alpha_AATS6_all alpha_AATS6];
    AOD_AATS6_all=[AOD_AATS6_all AOD_AATS6];
    AOD_Error_AATS6_all=[AOD_Error_AATS6_all AOD_Error_AATS6];
    IPWV_AATS6_all=[IPWV_AATS6_all IPWV_AATS6];
    DOY_AATS6_all=[DOY_AATS6_all DOY_AATS6];
end 

case 2
   pathname='c:\Beat\Data\Oklahoma\Wviop3\AFWEX_Share_Archive\'; %LBLRTM 5.10
   direc=dir(fullfile(pathname,'*sep00.asc')); 
   [filenames1{1:length(direc),1}] = deal(direc.name);
   direc=dir(fullfile(pathname,'*oct00.asc')); 
   [filenames2{1:length(direc),1}] = deal(direc.name);  
   filelist =[filenames1', filenames2']';
  for i=1:length(filelist)
	 disp(sprintf('Processing %s (No. %i of %i)',char(filelist(i,:)),i,length(filelist)))
    fid=fopen(deblank([pathname,char(filelist(i,:))]));
    fgetl(fid);
    site=fscanf(fid,'%21c',[1 1]);
    date=fscanf(fid,'%2i/%2i/%4i\n',[3,1]);
    for i=1:16
     fgetl(fid);
    end   
    data=fscanf(fid,'%f',[18,inf]);
    fclose(fid);
   
    UT_AATS6=data(1,:);
    UT_GPS_AATS6=data(2,:);
    Latitude_AATS6=data(3,:);
    Longitude_AATS6=data(4,:);
    Pressure_AATS6=data(5,:);
    IPWV_AATS6=data(6,:);
    alpha_AATS6=data(7,:);
    AOD_AATS6=data(8:12,:);
    AOD_Error_AATS6=data(13:17,:);
    CWV_Error_AATS6=data(18,:);
    
    day=date(2); month=date(1); year=date(3);
    DOY_AATS6=julian(day,month,year,UT_AATS6)-julian(31,12,1999,0);
    
    alpha_AATS6_all=[alpha_AATS6_all alpha_AATS6];
    AOD_AATS6_all=[AOD_AATS6_all AOD_AATS6];
    AOD_Error_AATS6_all=[AOD_Error_AATS6_all AOD_Error_AATS6];
    IPWV_AATS6_all=[IPWV_AATS6_all IPWV_AATS6];
    DOY_AATS6_all=[DOY_AATS6_all DOY_AATS6];
  end



case 3
   pathname='c:\Beat\Data\Oklahoma\Wviop3\Version_22Nov2000\'; %LBLRTM 5.10
   direc=dir(fullfile(pathname,'*sep00.asc')); 
   [filenames1{1:length(direc),1}] = deal(direc.name);
   direc=dir(fullfile(pathname,'*oct00.asc')); 
   [filenames2{1:length(direc),1}] = deal(direc.name);  
   filelist =[filenames1', filenames2']';
  for i=1:length(filelist)
	 disp(sprintf('Processing %s (No. %i of %i)',char(filelist(i,:)),i,length(filelist)))
    fid=fopen(deblank([pathname,char(filelist(i,:))]));
    for i=1:2
     fgetl(fid);
    end
    site=fscanf(fid,'%s',[1,1]);
    date=fscanf(fid,'%2i/%2i/%4i\n',[3,1]);
    for i=1:11
     fgetl(fid);
    end   
    data=fscanf(fid,'%f',[16,inf]);
    fclose(fid);

    UT_AATS6=data(1,:);
    Pressure_AATS6=data(2,:);
    IPWV_AATS6=data(3,:);
    IPWV_Error_AATS6=data(4,:);
    AOD_flag=data(5,:);
    alpha_AATS6=data(6,:);
    AOD_AATS6=data(7:11,:);
    AOD_Error_AATS6=data(12:16,:);
    day=date(2); month=date(1); year=date(3);
    DOY_AATS6=julian(day,month,year,UT_AATS6)-julian(31,12,1999,0);
    
    alpha_AATS6_all=[alpha_AATS6_all alpha_AATS6];
    AOD_AATS6_all=[AOD_AATS6_all AOD_AATS6];
    AOD_Error_AATS6_all=[AOD_Error_AATS6_all AOD_Error_AATS6];
    IPWV_AATS6_all=[IPWV_AATS6_all IPWV_AATS6];
    DOY_AATS6_all=[DOY_AATS6_all DOY_AATS6];
    AOD_flag_all=[AOD_flag_all AOD_flag];
  end

case 4
   pathname='c:\Beat\Data\Oklahoma\Wviop3\Version_22Feb2001\'; %LBLRTM 5.21
   direc=dir(fullfile(pathname,'*sep00.asc')); 
   [filenames1{1:length(direc),1}] = deal(direc.name);
   direc=dir(fullfile(pathname,'*oct00.asc')); 
   [filenames2{1:length(direc),1}] = deal(direc.name);  
   filelist =[filenames1', filenames2']';
  for i=1:length(filelist)
	 disp(sprintf('Processing %s (No. %i of %i)',char(filelist(i,:)),i,length(filelist)))
    fid=fopen(deblank([pathname,char(filelist(i,:))]));
    for i=1:2
     fgetl(fid);
    end
    site=fscanf(fid,'%s',[1,1]);
    date=fscanf(fid,'%2i/%2i/%4i\n',[3,1]);
    for i=1:11
     fgetl(fid);
    end   
    data=fscanf(fid,'%f',[16,inf]);
    fclose(fid);

    UT_AATS6=data(1,:);
    Pressure_AATS6=data(2,:);
    IPWV_AATS6=data(3,:);
    IPWV_Error_AATS6=data(4,:);
    AOD_flag=data(5,:);
    alpha_AATS6=data(6,:);
    AOD_AATS6=data(7:11,:);
    AOD_Error_AATS6=data(12:16,:);
    day=date(2); month=date(1); year=date(3);
    DOY_AATS6=julian(day,month,year,UT_AATS6)-julian(31,12,1999,0);
    
    alpha_AATS6_all=[alpha_AATS6_all alpha_AATS6];
    AOD_AATS6_all=[AOD_AATS6_all AOD_AATS6];
    AOD_Error_AATS6_all=[AOD_Error_AATS6_all AOD_Error_AATS6];
    IPWV_AATS6_all=[IPWV_AATS6_all IPWV_AATS6];
    DOY_AATS6_all=[DOY_AATS6_all DOY_AATS6];
    AOD_flag_all=[AOD_flag_all AOD_flag];
  end
end

alpha_AATS6=alpha_AATS6_all;
AOD_AATS6=AOD_AATS6_all;
AOD_Error_AATS6=AOD_Error_AATS6_all;
IPWV_AATS6=IPWV_AATS6_all;
DOY_AATS6=DOY_AATS6_all;
AOD_flag=AOD_flag_all;

clear alpha_AATS6_all;
clear AOD_AATS6_all;
clear AOD_Error_AATS6_all;
clear IPWV_AATS6_all;
clear DOY_AATS6_all;
clear AOD_flag_all;