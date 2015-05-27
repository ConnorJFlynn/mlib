function [day,month,year,LT,UT,data,format,azi,ele]=fluke_rd(name);

% Written 14.7.1995 by B. Schmid
% 21. 7.1995 determines format from file extension reads formats 001 and 002
%  9.10.1995 supports new format 003
% 17.10.1995 supports new format 004
% 12. 3.1996 supports new formats 005,006,100,101
% 17. 5.1996 supports new format 007
% 20.10.1996 supports new format 008
%  3. 3.1997 supports new format 009

% Description of Formats
% 100: Data from Bern, 12 channels HP and old Prema
% 101: Data from Bern, 12 channels HP and old Prema (one column more)
% 001: Data from Jungfraujoch, 12 channels, Local time is PC-clock (adjusted by DCF-77 in Germany)
% 002: Data from Jungfraujoch, 12 channels, Local time is PC-clock (not adjusted), UT is from the BRUSAG tracker
% 003: Data from Tucson, 15 channels, LT is from PC-Clock, UT, azimuth and elevation is from BRUSAG Sun tracker
% 004: Data from Mt. Lemmon ,15 channels, LT is from PC-Clock, UT, azimuth and elevation is from BRUSAG Sun tracker, 
%      air pressure is from RSG Barometer
% 005: Data from Tucson, 15 channels, LT is from PC-Clock, UT, azimuth and elevation is from BRUSAG Sun tracker, 
%      air pressure is from RSG Barometer
% 006: Data from Bern, 15 channels, LT is from PC-Clock, UT, azimuth and elevation is from BRUSAG Sun tracker 
% 007: Data from Bern, 18 channels, LT is from PC-Clock, UT, azimuth and elevation is from BRUSAG Sun tracker      
% 008: Data from Zugspitze, 18 channels, LT is from PC-Clock, UT, azimuth and elevation is from BRUSAG Sun tracker
% 009: Data from Jungfraujoch (Prema 8017) 18 channels, LT is from PC-Clock, UT, azimuth and elevation is from BRUSAG Sun tracker

[filename,path]=uigetfile(name, 'Choose a File', 0, 0);
fid=fopen([path filename]);

% determine format from file extension
format=filename(length(filename)-2:length(filename));
months=['Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'];

first=fgetl(fid);
B=[str2num(first(5:6));str2num(first(12:15))];
C=first(8:10);
frewind(fid);

day=B(1);
month=ceil(findstr(months,C)/3);
year=B(2);

%=========================================================================================
if format=='100'
 % reads time and data
 A=fscanf(fid,'%*s %*s %2d : %2d : %2d %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g',[22 inf]);
 % computes time of observation
 LT=A(1,:)+A(2,:)/60+A(3,:)/3600;
 UT=LT-2;
 data=A(4:22,:);
 azi=[];
 ele=[];
end
%=========================================================================================
if (format=='001' | format=='101')
 % reads time and data
 A=fscanf(fid,'%*s %*s %2d : %2d : %2d %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g',[23 inf]);
 % computes time of observation
 LT=A(1,:)+A(2,:)/60+A(3,:)/3600;
 UT=LT-2;
 data=A(4:23,:);
 azi=[];
 ele=[];
end
%=============================================================================================================
if format=='002' %time is from BRUSAG Sun tracker
 % reads time from BRUSAG Sun tracker and data
 A=fscanf(fid,'%*s %*s %*s %6d %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g',[21 inf]);
 seconds=rem(A(1,:),100);
 minutes=rem(floor(A(1,:)/100),100);
 hours=floor(A(1,:)/10000);
 UT=hours+minutes/60+seconds/3600;
 LT=rem(UT+2,24);
 data=A(2:21,:);
 azi=[];
 ele=[];
end
%=============================================================================================================
if (format=='003' | format=='006')
 % reads time from BRUSAG Sun tracker and data
 A=fscanf(fid,'%*s %*s  %2d : %2d : %2d  %6d %*s : %g %*s : %g %*s %*s %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g',[26 inf]);
 LT=A(1,:)+A(2,:)/60+A(3,:)/3600;
 seconds=rem(A(4,:),100);
 minutes=rem(floor(A(4,:)/100),100);
 hours=floor(A(4,:)/10000);
 UT=hours+minutes/60+seconds/3600;
 azi=A(5,:);
 ele=A(6,:);
 data=A(7:26,:);
end
%=============================================================================================================
if (format=='004' | format=='005')
% reads time from BRUSAG Sun tracker and data
 A=fscanf(fid,'%*s %*s  %2d : %2d : %2d  %6d %*s : %g %*s : %g %*s %*s %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g',[27 inf]);
 LT=A(1,:)+A(2,:)/60+A(3,:)/3600;
 seconds=rem(A(4,:),100);
 minutes=rem(floor(A(4,:)/100),100);
 hours=floor(A(4,:)/10000);
 UT=hours+minutes/60+seconds/3600;
 azi=A(5,:);
 ele=A(6,:);
 data=A(7:27,:);
end
%=============================================================================================================
if (format=='007' | format=='008' | format=='009')
 % reads time from BRUSAG Sun tracker and data
 A=fscanf(fid,'%*s %*s  %2d : %2d : %2d  %6d %*s : %g %*s : %g %*s %*s %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g %g',[36 inf]);
 LT=A(1,:)+A(2,:)/60+A(3,:)/3600;
 seconds=rem(A(4,:),100);
 minutes=rem(floor(A(4,:)/100),100);
 hours=floor(A(4,:)/10000);
 UT=hours+minutes/60+seconds/3600;
 azi=A(5,:);
 ele=A(6,:);
 data=A(7:36,:);
end
%=============================================================================================================

fclose(fid);
