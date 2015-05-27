%plot_zAOD_multiframe.m
clear
close all

global teelength
teelength=.015;

flag_process_SPAWAR='yes';
flag_overplot_FSSPSA='yes';

%Wvl_microns=[380.1  450.7  525.3  863.9  1020.7]/1000;
Wvl_microns=[380.05  450.90  525.68  864.54  1021.28]/1000;  %941.93 from Beat 1/31/2001
legendwvl=[' 380.1';' 450.9';' 525.7';' 864.5';'1021.3']

for j=1:21
 file=strcat('PRIDEarc_NavF',num2str(j),'.asc30');
 filename(j,1:size(file,2))=file(1,:); 
end

%jprofile_proc=[1 2 2 6 7 12 14 14 14 18 18 19 20 20 21 21]; %3 13 13 21  
%jprofile_proc=[3 5 11 13 15 16];
%jprofile_proc=[1 2 2 6 7 12 14 14 16 18 18 19 20 20 21 21]; %3 13 13 21  
%jprofile_proc=[13];
%jprofile_proc=[1 2 2 6 7 12 14 14 16 18 18 19 20 20 21 21]; %include 7/19  
jprofile_proc=[1 2 2 6 7 12 13 14 14 18 18 19 20 20 21 21]; %include 7/15, exclude 7/19  
nprofiles_proc=length(jprofile_proc);

aod=zeros(5,1000,nprofiles_proc);
zkmgps=zeros(1000,nprofiles_proc);
UTsav=zeros(1000,nprofiles_proc);
iflag=zeros(21);

for jprof=1:nprofiles_proc,

fileread=deblank(filename(jprofile_proc(jprof),:));
%[UTdechr,Latitude,Longitude,GPSalt_km,Press_alt_km,Pressmb,Watvapcolcm,Reluncwatvap,cloud_flag,...
      %alpharead,Taupart,Unctaup,FlightNo,FlightDate]=read_PRIDE_AATS6_archive_2001_n(fileread);

[UTdechr,Latitude,Longitude,GPSalt_km,Press_alt_km,Pressmb,Watvapcolcm,Reluncwatvap,cloud_flag,alpharead,...
        Taupart,uncaodbot,uncaodtop,dirttransmission,FlightNo,FlightDate]=readmerge_PRIDE_AATS6_arc_2002(fileread);

L_cloud=cloud_flag;

%Note that the unc in CWV that I archived was actually the relative unc
Uncwatvapcol=Reluncwatvap.*Watvapcolcm;
   
dateyr=2000;
dechrskipbeg=0;
dechrskipend=0;

iflag(FlightNo)=iflag(FlightNo)+1;

switch FlightNo
 case 1
   datemon=6; dateday=28;
   direction='ascent1';
   dechrbeg = 13.41;dechrend = 13.79;  %ascent1 
 case 2
   datemon=6; dateday=30;
  switch iflag(FlightNo)
   case 1
    direction='descent';
    dechrbeg = 13.75; dechrend = 14.50;
   case 2
    direction='ascent2';
    dechrbeg = 15.27; dechrend = 15.97;  
  end  
 case 3
   datemon=7; dateday=1;
   direction='ascent1';
   dechrbeg = 13.175; dechrend = 13.75;
 case 4
   dechrbeg = 18.68611; dechrend = 19.16861;  
 case 5
   datemon=7; dateday=4;  %don't use this one for  multiframe
   dechrbeg = 13.925; dechrend = 14.52;
   direction='ascent1';
 case 6
    datemon=7; dateday=5;  
    dechrbeg = 13.249; dechrend = 13.772;  %7/5/2000
    dechrskipbeg = 13.522; dechrskipend = 13.54; %7/5/2000
    direction='ascent1';
 case 7
    datemon=7; dateday=6;
    %direction='ascent1';  %ascent2
    %dechrbeg=13.125; dechrend=13.745;  %ascent1
    direction='ascent2';
    dechrbeg = 14.7; dechrend = 15.5;  %ascent2  use this one for multiframe
 case 8
   dechrbeg = 18.68611; dechrend = 19.16861;  
 case 9
   dechrbeg = 18.68611; dechrend = 19.16861;  
 case 10
   dechrbeg = 18.68611; dechrend = 19.16861;  
 case 11
    datemon=7; dateday=12;
    direction='ascent1';  %don't use this one for multiframe
    dechrbeg = 13.099; dechrend = 13.70;  %13.17???
 case 12
    direction='ascent1';
    datemon=7; dateday=13;  
    dechrbeg = 13.879; dechrend = 14.362; %7/13/2000
 case 13
   datemon=7; dateday=15;
  switch iflag(FlightNo)
   case 2
    dechrbeg = 14.41; dechrend = 14.94; %7/15/2000 ascent1
    direction='ascent ';
   case 1
    dechrbeg = 15.21; dechrend = 16.52; %7/15/2000 descent1  14.94
    direction='descent';
  end  
 case 14
   datemon=7; dateday=16;  
  switch iflag(FlightNo)
   case 1
    direction='ascent1';
    dechrbeg = 13.165; dechrend = 13.73;  %7/16/2000 ascent1
   case 2
    direction='descent';
    dechrbeg = 13.968; dechrend = 14.514;  %7/16/2000 descent
   case 3
    direction='ascent2';
    dechrbeg = 14.85; dechrend = 15.98;  %7/16/2000 ascent2 don't use this for multiframe
  end   
 case 15
   datemon=7; dateday=17;  %don't use this one for multiframe
   direction='ascent1';
   dechrbeg = 12.91; dechrend = 13.5;  
 case 16
   datemon=7; dateday=19;  %use this one for multiframe
   direction='ascent1';
   dechrbeg = 14.21; dechrend = 14.76;  
 case 17
   dechrbeg = 18.68611; dechrend = 19.16861;  
 case 18
  switch iflag(FlightNo)
   case 1
    datemon=7; dateday=21;
    direction='ascent1';
    dechrbeg = 13.2207; dechrend = 13.91;  %7/21/2000
   case 2
    dechrskipbeg = 13.835; dechrskipend = 13.854; %7/21/2000
    direction='descent';
    dechrbeg = 13.95; dechrend = 14.85; %7/21/2000
  end 
 case 19
   datemon=7; dateday=22;  
   direction='ascent1';
   dechrbeg = 13.43; dechrend = 13.9;   %7/22/2000
 case 20
   datemon=7; dateday=23;
  switch iflag(FlightNo)
   case 1
    direction='descent';
    dechrbeg = 13.13; dechrend = 14.41;  %7/23/00 %descent
   case 2
    direction='ascent2';
    dechrbeg = 14.83; dechrend = 15.47;  %7/23/00 ascent2
  end 
 case 21
  switch iflag(FlightNo)
   case 1
    datemon=7; dateday=24;
    direction='ascent1';
    dechrbeg = 13.25; dechrend = 13.79;  %7/24/00 ascent1
   case 2
    direction='descent';
    dechrbeg = 14.56; dechrend = 15.10;  %7/24/00 descent
  end
end

if (dechrskipbeg>0 & dechrskipend>0)
	idxtim = [find(UTdechr>=dechrbeg & UTdechr<dechrskipbeg)  find(UTdechr>dechrskipend & UTdechr<=dechrend)]'; 
else
	idxtim = find(UTdechr>=dechrbeg & UTdechr<=dechrend)';
end

idxtim=idxtim(L_cloud(idxtim)==1);
dectimeuse = UTdechr(idxtim);
zkmg_use = GPSalt_km(idxtim);

zstore=GPSalt_km(idxtim)';
taustore=Taupart(:,idxtim);
UTstore=UTdechr(idxtim)';
zkmgps(1:size(zstore,1),jprof)=zstore;
aod(1:5,1:size(taustore,2),jprof)=Taupart(:,idxtim);
UTsav(1:size(UTstore),jprof)=UTstore;
hrbeg(jprof)=dechrbeg;
hrend(jprof)=dechrend;
date(jprof,:)=FlightDate(:);
updown(jprof,:)=direction;

end    %loop over number of profiles to process

iflag_fig1='yes';
if strcmp(iflag_fig1,'yes')
month=['June';'July'];
figure(1)
set(gcf,'Paperposition',[0.25 0.1 8 10]);
%orient portrait
set(1,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0]) %cyan,blue,green,magenta,red
for jprof=1:nprofiles_proc,
 nz=size(find(UTsav(:,jprof)>0),1);  
 col=mod(jprof-1,4);
 row=fix((jprof-1)/4);
 subplot('position',[0.13+col*0.21 0.75-row*0.21 0.18 0.19])
 if row==3 & col==1
    set(1,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 0]) %cyan,blue,green,red
    wlplt=[1 1 1 0 1]; 
    plot(aod(wlplt==1,1:nz,jprof),zkmgps(1:nz,jprof),'-','MarkerSize',3)
 else
     set(1,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0]) %cyan,blue,green,magenta,red
     plot(aod(1:5,1:nz,jprof),zkmgps(1:nz,jprof),'-','MarkerSize',3)
 end
 axis([0 0.6 0 6]);
 set(gca,'TickLength',[.03 .05]);
 set(gca,'xtick',[0 0.2 0.4 0.6]);
 set(gca,'ytick',[0 1 2 3 4 5 6]);
 if jprof==1 
     hleg1=legend(legendwvl);
     set(hleg1,'FontSize',8)
 end
 if col>=1 set(gca,'YTickLabel',[]); end
 if row<3 set(gca,'XTickLabel',[]); end
 if row==3 & col==1
     h22=text(0.2,-1.5,'AATS-6 Aerosol Optical Depth');
     set(h22,'FontSize',12)
 end
 if col==0 & row==2
     h33=text(-0.15,5,'Altitude [km]');
     set(h33,'FontSize',12,'Rotation',90)
 end
 %grid on
 titlestr=sprintf('%s %2d %5.2f-%5.2f UT\n',month(str2num(date(jprof,1))-5,1:4),...
    str2num(date(jprof,3:4)),hrbeg(jprof),hrend(jprof));
 h1=text(0.03,5.3,titlestr);
 set(h1,'FontSize',8)
 %h1=text(0.35,4.5,sprintf('%s %2d\n',month(str2num(date(jprof,1))-5,1:4),str2num(date(jprof,3:4))));
 %set(h1,'FontSize',8);
 %h2=text(0.35,4.0,sprintf('%5.2f-%5.2f UT\n',hrbeg(jprof),hrend(jprof)));
 %set(h2,'FontSize',8);
 h3=text(0.35,5.0,updown(jprof,:));
 set(h3,'FontSize',8)
end
end

flag_readproc_extprofile='yes';
if strcmp(flag_readproc_extprofile,'yes')
 filenameext=['PRIDE_extavg_ascent1_F01.txt';'PRIDE_extavg_descent_F02.txt';'PRIDE_extavg_ascent2_F02.txt';...
         'PRIDE_extavg_ascent1_F03.txt';'PRIDE_extavg_ascent1_F06.txt';'PRIDE_extavg_ascent2_F07.txt';...
         'PRIDE_extavg_ascent1_F11.txt';'PRIDE_extavg_ascent1_F12.txt';...
         'PRIDE_extavg_ascent1_F13.txt';'PRIDE_extavg_descent_F13.txt';'PRIDE_extavg_ascent1_F14.txt';...
         'PRIDE_extavg_descent_F14.txt';'PRIDE_extavg_ascent2_F14.txt';'PRIDE_extavg_ascent1_F15.txt';...
         'PRIDE_extavg_ascent1_F16.txt';'PRIDE_extavg_ascent1_F18.txt';...
         'PRIDE_extavg_descent_F18.txt';'PRIDE_extavg_ascent1_F19.txt';'PRIDE_extavg_descent_F20.txt';...
         'PRIDE_extavg_ascent2_F20.txt';'PRIDE_extavg_ascent1_F21.txt';'PRIDE_extavg_descent_F21.txt'];

 filenameSPAWAR={'Cabras Vertical Profiles\NRSVP628.xls';'Secondary Vertical Profiles\SPP630.xls';...
                 'Additional Vertical Profiles\TPP630.xls';'Cabras Vertical Profiles\NRSVP701.xls';
                 'Cabras Vertical Profiles\NRSVP705.xls';
                 'Additional Vertical Profiles\TPP706.xls';'Cabras Vertical Profiles\NRSVP712.xls';
                 'Cabras Vertical Profiles\NRSVP713.xls';'Cabras Vertical Profiles\NRSVP715.xls';
                 'Secondary Vertical Profiles\SPP715.xls';'Cabras Vertical Profiles\NRSVP716.xls';
                 'Secondary Vertical Profiles\SPP716.xls';'Additional Vertical Profiles\TPP716.xls';
                 'Cabras Vertical Profiles\NRSVP717.xls';'Cabras Vertical Profiles\NRSVP719.xls'
                 'Cabras Vertical Profiles\NRSVP721.xls';'Secondary Vertical Profiles\SPP721.xls';
                 'Cabras Vertical Profiles\NRSVP722.xls';'Secondary Vertical Profiles\SPP723.xls';
                 'Additional Vertical Profiles\TPP723.xls';'Cabras Vertical Profiles\NRSVP724.xls';
                 'Secondary Vertical Profiles\SPP724.xls'};  %'Cabras Vertical Profiles\NRSVP706.xls';
                 
 %jprofile_proc_ext=[1 2 3 5 6 7 10 11 12 13 14 15 16 17 18 19];  
 %jprofile_proc_ext=[7 14 15];  
 %jprofile_proc_ext=[10];
  %jprofile_proc_ext=[1 2 3 5 6 8 11 12 15 16 17 18 19 20 21 22];  %include 7/19
 jprofile_proc_ext=[1 2 3 5 6 8 10 11 12 16 17 18 19 20 21 22];  %include 7/15, exclude 7/19
nprofiles_proc_ext=length(jprofile_proc_ext);
   
    
 for jprof=1:nprofiles_proc_ext,
  fileread=deblank(filenameext(jprofile_proc_ext(jprof),:));
  %[UTmean,zkmmean,aodmean,aodstdev,extavg,alpha_aod,gamma_aod,alpha_ext,...
        %gamma_ext,UTextbeg,UTextend,monthext,dayext,Flightext]=read_PRIDE_AATS6_avgext(fileread);
  [UTmean,zkmmean,aodmean,aodstdev,extavg,extavg_fit,UTextbeg,UTextend,...
        monthext,dayext,Flightext]=read_PRIDE_AATS6_avgext_Mar2002(fileread);

  UTstore=UTmean';
  UTextsav(1:size(UTstore),jprof)=UTstore;
  zstore=zkmmean';
  zkmext(1:size(zstore,1),jprof)=zstore;
  ext(1:5,1:size(extavg,2),jprof)=extavg;
  tstore=UTextbeg';
  timeextbeg(1:size(tstore),jprof)=tstore;
  tstore=UTextend';
  timeextend(1:size(tstore),jprof)=tstore;
  monstore=monthext';
  mon_ext(1:size(monstore),jprof)=monstore;
  dastore=dayext';
  day_ext(1:size(dastore),jprof)=dastore;
  Fstore=Flightext';
  Flight_ext(1:size(Fstore),jprof)=Fstore;
 end
end

if strcmp(flag_process_SPAWAR,'yes')
directory='c:\johnmatlab\PRIDE SPAWAR files\';
%read/process SPAWAR excel files
 for jprof=1:nprofiles_proc_ext,
    filetitle=strcat(directory,filenameSPAWAR(jprofile_proc_ext(jprof)));
    [altkm_BG_store,FSSPSurfAreaConc_store,FSSPNumConc_store,watvap_gm3_SPAWAR_store,CWV_SPAWAR_Td_store]=read_one_SPAWAR_file(char(filetitle));
    nzFSSP(jprof)=size(altkm_BG_store,1);
    altkm_BG(1:nzFSSP(jprof),jprof)=altkm_BG_store;
    FSSPSurfAreaConc(1:nzFSSP(jprof),jprof)=FSSPSurfAreaConc_store;
    FSSPNumConc(1:nzFSSP(jprof),jprof)=FSSPNumConc_store;
 end
end

iflag_fig2='no';
if strcmp(iflag_fig2,'yes')
month=['June';'July'];
figure(2)
set(gcf,'Paperposition',[0.25 0.5 8 10]);
%orient portrait
set(2,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0]) %cyan,blue,green,magenta,red
for jprof=1:nprofiles_proc_ext,
 nz=size(find(UTextsav(:,jprof)>0),1);  
 col=mod(jprof-1,4);
 row=fix((jprof-1)/4);
 subplot('position',[0.15+col*0.21 0.75-row*0.21 0.16 0.16])
 plot(ext(1:5,1:nz,jprof),zkmext(1:nz,jprof),'-','MarkerSize',3)
 axis([0 0.3 0 6]);
 set(gca,'xtick',[0 0.1 0.2 0.3]);
 set(gca,'ytick',[0 1 2 3 4 5 6]);
 if row==3 xlabel('Extinction [km^{-1}]'); end
 if col==0 ylabel('Altitude [km]'); end
 grid on
 titlestr=sprintf('%s %2d   %5.2f-%5.2f UT\n',month(mon_ext(jprof)-5,1:4),...
    day_ext(jprof),timeextbeg(jprof),timeextend(jprof));
 h1=text(0,6,titlestr);
 set(h1,'FontSize',8)
 h3=text(0.20,5.5,filenameext(jprofile_proc_ext(jprof),14:20));
 set(h3,'FontSize',8)
end
end

iflag_fig3='yes';
if strcmp(iflag_fig3,'yes')
month=['June';'July'];
figure(3)
set(gcf,'Paperposition',[0.25 0.1 8 10]);
%orient portrait
set(3,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0]) %cyan,blue,green,magenta,red
for jprof=1:nprofiles_proc_ext,
 nz=size(find(UTextsav(:,jprof)>0),1);  
 col=mod(jprof-1,4);
 row=fix((jprof-1)/4);
 %subplot('position',[0.13+col*0.21 0.75-row*0.21 0.16 0.16])
 subplot('position',[0.13+col*0.21 0.75-row*0.21 0.18 0.19])
 h11=line(ext(1:5,1:nz,jprof),zkmext(1:nz,jprof))
 ax1=gca;

 set(ax1,'XColor','k','YColor','k','XLim',[0 0.25],'YLim',[0 6],'Box','off','TickLength',[.03 .05]);
 set(ax1,'ytick',[0 1 2 3 4 5 6]);
 set(ax1,'xtick',[0 0.05 0.10 0.15 0.20 0.25],'FontSize',9);
 if col>=1 set(ax1,'YTickLabel',[]); end
 if row<3 set(ax1,'XTickLabel',[]); end
 %set(ax1,'FontSize',14);
 if row==3 & col==1
    h33=text(0.05,-1.3,'AATS-6 Aerosol Extinction [km^{-1}]');
    set(h33,'FontSize',12)
 end
 if col==0 & row==2
     h33=text(-0.08,5,'Altitude [km]');
     set(h33,'FontSize',12,'Rotation',90)
 end
 h1=text(0.02,5.3,sprintf('%s %2d %5.2f-%5.2f UT\n',month(mon_ext(jprof)-5,1:4),day_ext(jprof),...
     timeextbeg(jprof),timeextend(jprof)));
 set(h1,'FontSize',8);
 h2=text(0.15,5.0,filenameext(jprofile_proc_ext(jprof),14:20));
 set(h2,'FontSize',8)

 ax2 = axes('Position',get(ax1,'Position'),...
   'XAxisLocation','top',...
   'YAxisLocation','right',... 
   'XLim',[0 20],'YLim',[0 6],'TickLength',[.03 .05],... %[0 600]
   'YTickLabel','',...
   'Color','none',...
   'XColor','k','YColor','k');
 %set(gca,'xtick',[0 200 400 600],'FontSize',9);
 set(gca,'xtick',[0 5 10 15 20],'FontSize',9);
 set(ax2,'ytick',[0 1 2 3 4 5 6]);
 if row>0 set(ax2,'XTickLabel',[]); end
 %h12=line(FSSPSurfAreaConc(1:nzFSSP(jprof),jprof),altkm_BG(1:nzFSSP(jprof),jprof),'Color','k','Parent',ax2);
 h12=line(FSSPNumConc(1:nzFSSP(jprof),jprof),altkm_BG(1:nzFSSP(jprof),jprof),'Color','k','Parent',ax2);
 if row==0 & col==0 
    %h22=text(150,7.2,'FSSP Surf Area Conc (\mum^{2}/cm^{3})');
    %h22=text(550,7.2,'FSSP Aerosol Surface Area Concentration [\mum^{2}/cm^{3}]';
    %h22=text(22,7.55,'FSSP Aerosol Number Concentration [cm^{-3}]');
    h22=text(2,7.55,'FSSP Aerosol Number Concentration [cm^{-3}], Surface Area Concentration [\mum^{2}/cm^{3}]');
    set(h22,'FontSize',12)    
 end    

 if flag_overplot_FSSPSA=='yes'
  ax3 = axes('Position',get(ax1,'Position'),...
   'XAxisLocation','top',...
   'YAxisLocation','right',... 
   'XLim',[-600 600],'YLim',[0 6],'TickLength',[.03 .05],... %[0 600] %'XLim',[-600 600],'YLim',[0 6],'TickLength',[.03 .05],... %[0 600]
   'YTickLabel','','XTickLabel','','XTick',[],...
   'Color','none',...
   'XColor','k','YColor','k');
 %set(gca,'xtick',[0 200 400 600],'FontSize',9);
 %if row>0 set(ax3,'XTickLabel',[]); end
 h32=line(FSSPSurfAreaConc(1:nzFSSP(jprof),jprof),altkm_BG(1:nzFSSP(jprof),jprof),'Color','k',...
     'LineStyle','-','LineWidth',1.3,'Parent',ax3);
  if row==0 
    h33=text(-15,6.9,'0')
    set(h33,'FontSize',9)
    h34=text(250,6.9,'300')
    set(h34,'FontSize',9)
    h35=text(550,6.9,'600')
    set(h35,'FontSize',9)
    if col==0
        h41=text(-500,4.1,'FSSP Number')
        set(h41,'FontSize',8)
        h42=text(350,4.1,'FSSP Area')
        set(h42,'FontSize',8)
        h43=text(-500,1.0,'AATS-6')
        set(h43,'FontSize',8,'Color',[1 0 0])
    end
  end
 end
  
end
end

%print -depsc -tiff 'c:\Powerpoint presentations\JGR PRIDE figures\AATS6_AOD_profile_multiframenew'
%print -depsc -tiff 'c:\Powerpoint presentations\JGR PRIDE figures\AATS6_ext_profile_multiframe2'
