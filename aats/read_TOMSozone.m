%read_TOMSozone.m
clear
close all

flag_mission='SOLVE2'; %'ACEASIA'; %'SAFARI'; %'PRIDE'
flag_write='yes';
flag_plotmap='no';

if strcmp(flag_mission,'PRIDE')   
   %Roosevelt Roads lat,lon
	rlonincenter=-65.6;
	rlatincenter=18.2;
	nbinslat=2;
	nbinslon=2;

	%for PRIDE
	imoda=[0628 0629 0630 0701 0702 0703 0704 0705 0706 0707 0708 0709 0710 ...
         0711 0712 0713 0714 0715 0716 0717 0718 0719 0720 0721 0722 0723 0724];
	iproc_day=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
	%iproc_day=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0];
   
   path='c:\johnmatlab\PRIDE TOMS data\';
   filewrite='Toms_ozone_summary_PRIDE.txt';   
elseif strcmp(flag_mission,'SAFARI')      
      %approx Pietersburg lat,lon
	rlonincenter=26.875;
	rlatincenter=-25.5;
	nbinslat=3;
	nbinslon=4;

	%for SAFARI
	imoda=[0814 0815 0816 0817 0818 0819 0820 0821 0822 0823 0824 0825 0826 ...
         0827 0828 0829 0830 0831 0901 0902 0903 0904 0905 0906 0907 0908 0911 ...
         0912 0913 0914 0915 0916];
	iproc_day=[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1];
   
	path='c:\johnmatlab\SAFARI TOMS data\';
   filewrite='Toms_summary_SAFARI.txt';
elseif strcmp(flag_mission,'ACEASIA')
    rlonincenter=136; %135  %132.6;
    rlatincenter=38;  %35   %34.5;
    nbinslat=8; %5
    nbinslon=8; %5
    imoda=[0412 0413 0413 0419 0420 0421 0422 0423 0425 0426 0427 0428 0430 0501 0502 0503 0504];
    %iproc_day=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
    iproc_day=[0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
	path='c:\johnmatlab\ACEASIA TOMS data\';
   filewrite='Toms_ozone_summary_ACEASIA.txt';
elseif strcmp(flag_mission,'SOLVE2')
    rlonincenter=-118; %-123; %135  %132.6;
    rlatincenter= 28; %37; %26;  %35   %34.5;
    nbinslat=7; %5
    nbinslon=2; %5
    imoda=[1218 1219 1220]; %[1217 1218 1219];
    %iproc_day=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
    iproc_day=[1 1 1];
	path='c:\johnmatlab\SOLVE2 TOMS ozone\';
   filewrite='Toms_ozone_summary_SOLVE2_19Dec02.txt';
end

if strcmp(flag_write,'yes')
 fid_write=fopen([path filewrite],'a');
end

latitude=-89.5:1:89.5;
longitude=-179.375:1.25:179.375;

for ifile=1:size(imoda,2),
   
if(iproc_day(ifile)==1)   
filename=strcat('ga02',num2str(imoda(ifile)),'.ept');  %010 for 2001; 000 for 2000; 02 for 2002
fid=fopen([path filename]);

%skip 3 lines
for i=1:3,
   line = fgetl(fid);		%skip end-of-line character
end

for j=1:180,
kend=25;
for lines=1:12,  
   linedata = fgets(fid);
   if lines==12
      kend=13;
   end
   datain=linedata(2:kend*3+1);
	for kk=1:kend,
      ibeg=3*(kk-1)+1;
      idx=25*(lines-1)+kk;
      datause(idx)=str2num(datain(ibeg:ibeg+2));
   end
end

data(:,j)=datause(1,:)';%/10;
end
fclose(fid);


latinterp=interp1(latitude,latitude,rlatincenter,'nearest');
idxlat=find(latitude==latinterp);
loninterp=interp1(longitude,longitude,rlonincenter,'nearest');
idxlon=find(longitude==loninterp);

if strcmp(flag_write,'yes')
 fprintf(fid_write,'TOMS ozone file: %s\n',filename)
 fprintf(fid_write,'lat/lon: %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f %7.3f',longitude(idxlon-nbinslon:idxlon+nbinslon));
 fprintf(fid_write,'\n')
 fprintf(fid_write,'-------- ------- ------- ------- ------- ------- ------- ------- ------- ------- ------- -------\n')
 for jlat=idxlat-nbinslat:idxlat+nbinslat,
   fprintf(fid_write,' %5.1f  %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f %7.0f',latitude(jlat),data(idxlon-nbinslon:idxlon+nbinslon,jlat));
   fprintf(fid_write,'\n');
 end
end

end
end

if strcmp(flag_write,'yes')
   fclose(fid_write);
end

if strcmp(flag_plotmap,'yes')
datareal=fliplr(data);
figure(1)
imagesc(longitude,latitude,datareal');%,[0 4])

lat2=latitude'*ones(1,288);
lon2=ones(180,1)*longitude;

dataadj=data;
[n,m]=size(dataadj);
for i=1:n,
   jskip=find(data(i,:)==0);
   dataadj(i,jskip)=NaN;
end

klat=idxlat-nbinslat:idxlat+nbinslat;
klon=idxlon-nbinslon:idxlon+nbinslon;
datafinal=dataadj(klon,klat);
latfinal=lat2(klat,klon);
lonfinal=lon2(klat,klon);

figure(2)
latlim=[30 45]; lonlim=[120 150];
s= worldhi({'korea','japan','china'});%worldlo
%axesm('Mapprojection','gstereo',...%'MapParallels',[],...
   %'FLatLimit',[30 40],'FLonLimit',[130 140],...
   %'MapLatLimit',[-70 70],'MapLonLimit',[-180 180],...
   %'MLabelLocation',2,'MLineLocation',2,...
   %'PLabelLocation',2,'PLineLocation',2,...
   %'GColor',[0 0 0],'GLineStyle',':','MeridianLabel','on',...
   %'ParallelLabel','on');
axesm('Mapprojection','gstereo',...%'MapParallels',[],...
   'FLatLimit',[30 46],'FLonLimit',[128 146],...
   'MapLatLimit',[-70 70],'MapLonLimit',[-180 180],...
   'MLabelLocation',2,'MLineLocation',2,...
   'PLabelLocation',2,'PLineLocation',2,...
   'GColor',[0 0 0],'GLineStyle',':','MeridianLabel','on',...
   'ParallelLabel','on');
framem; gridm;
h=displaym(s);
%h=displaym(POline);
%set(h,'Color','k')
%surfm(-lat2,lon2,dataadj',0);%,dataadj');
surfm(latfinal,lonfinal,datafinal',0);%,dataadj');
%%demcmap(datafinal',16);
%%colormap('jet')
%%colorbar
contourcmap([280 290 300 310 320 330 340 350 360 370 380 390 400 410 420],'jet','colorbar','on','location','horizontal')
%hold on
%plotm(lat,long,'k')
end