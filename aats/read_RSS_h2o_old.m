function [DOY_RSS,IPWV_RSS]=read_RSS_h2o_old;
% Reads RSS water vapor data "relative technique"
pathname='d:\Beat\Data\Oklahoma\RSS\version_991021\';
filelist=str2mat('rss091597.h2o');
filelist=str2mat(filelist,...
'rss091697.h2o',...
'rss091797.h2o',...
'rss091897.h2o',...
'rss092697.h2o',...
'rss092797.h2o',...
'rss092897.h2o',...
'rss092997.h2o',...
'rss093097.h2o',...
'rss100197.h2o',...
'rss100297.h2o',...
'rss100397.h2o',...
'rss100497.h2o',...
'rss100597.h2o');

IPWV_RSS_all=[];
DOY_RSS_all=[];
for ifile=[1:3,5,14]
 filename=filelist(ifile,:) 
 fid=fopen(deblank([pathname filename]));
 data=fscanf(fid,'%f ',[3 inf]);
 fclose(fid);
 DOY_RSS=data(1,:);
 Airmass_RSS=data(2,:);
 LOS_RSS=data(3,:);
 IPWV_RSS=LOS_RSS./Airmass_RSS;
 IPWV_RSS_all=[IPWV_RSS_all IPWV_RSS];
 DOY_RSS_all=[DOY_RSS_all DOY_RSS];
end 
for ifile=[4,6:13]
 filename=filelist(ifile,:) 
 fid=fopen(deblank([pathname filename]));
 data=fscanf(fid,'%f ',[5 inf]);
 fclose(fid);
 DOY_RSS=data(1,:);
 Airmass_RSS=data(2,:);
 LOS_RSS=data(3,:);
 IPWV_RSS=LOS_RSS./Airmass_RSS;
 IPWV_RSS_all=[IPWV_RSS_all IPWV_RSS];
 DOY_RSS_all=[DOY_RSS_all DOY_RSS];
end 

IPWV_RSS=IPWV_RSS_all;
DOY_RSS=DOY_RSS_all;

[DOY_RSS,index]=sort(DOY_RSS);
IPWV_RSS=IPWV_RSS(index);
clear IPWV_RSS_all;
clear DOY_RSS_all;
