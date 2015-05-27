%read_plot_AATS14_GHSOLVE2.m
clear
close all

[numlines_info,info_sav,UTdechr,Latitude,Longitude,GPS_alt_km,Press_alt_km,Pressmb,...
	  Wvlnm,CWV_cm,CWVunc_cm,O3col_DU,cloud_flag,a2_polyfit,a1_polyfit,a0_polyfit,...
	  Taupart,Unctaup,mission_name,year,month,day,filename]=read_AATS14_GH_SOLVE2('c:\beat\data\solve2\*.*');

date_AATS14data = datestr(datenum(year,month,day),1);
strgtitle=sprintf('File:%s   Date:%s',filename,date_AATS14data);

nwl_aer=size(Taupart,1);

nobs = length(UTdechr);
record_number=[1:nobs];
numsecs=UTdechr*3600;

if strcmp(mission_name,'SOLVE2') 
   switch FlightNo
     case 1
       iobsbeg=1;
		 iobsend=inf;
		 recmin=0;;
       recmax=4650;
   end   
end

flag_aodmovie='yes';
iobsbeg=1;
iobsend=nobs;
idxuse=iobsbeg:iobsend;

%cla reset
set(0,'DefaultLineMarkerSize',4)

UT_hhmmss = time_hhmmss(UTdechr);

UTCmin=min(UTdechr);
UTCmax=max(UTdechr);
numsecmin=fix(UTCmin*3600/100)*100;
numsecmax=fix((UTCmax*3600+100)/100)*100;

idxplot=iobsbeg:iobsend;
kclear=idxplot(cloud_flag==1);

flag_overplot_SAGE3='yes';
wvl_SAGE3=[ 0.3843 0.4485 0.5203 0.6012 0.6756 0.7554 0.8693 1.0216 1.5452];
if (year==2003)
    if (month==1 & day==12)
        AOD_SAGE3=[ 0.0210 0.0223 0.0210 0.0198 0.0171 0.0150 0.0120 0.0089 0.0031]; %1/12/03 orbit 544020
        orbit_info_SAGE3='yyyyddd: 2003012, id: 544020, sunset , UT:11.13, lat: 67.6, lon:   0.3 (20 km)';
    end
    if (month==1 & day==14)
        orbit_info_SAGE3='yyyyddd: 2003014, id: 546720, sunset , UT:10.52, lat: 68.0, lon:  10.4 (20 km)';
        AOD_SAGE3=[ 0.0055 0.0063 0.0055 0.0044 0.0035 0.0031 0.0021 0.0015 0.0005]; %1/14/03 orbit 546720
    end
    if (month==1 & day==16)
        orbit_info_SAGE3='yyyyddd: 2003016, id: 549420, sunset , UT: 9.91, lat: 68.4, lon:  20.6 (20 km)';
        AOD_SAGE3=[ 0.0043 0.0062 0.0049 0.0037 0.0030 0.0027 0.0018 0.0012 0.0004]; 
    end
    if (month==1 & day==19)
        orbit_info_SAGE3='yyyyddd: 2003019, id: 553520, sunset , UT: 9.87, lat: 69.1,lon:  23.0 (20 km)';
        AOD_SAGE3=[ 0.0059 0.0073 0.0058 0.0049 0.0037 0.0034 0.0023 0.0016 0.0006];  
    end
    if (month==1 & day==21)
        orbit_info_SAGE3='yyyyddd: 2003019, id: 553520, sunset , UT: 9.87, lat: 69.1,lon:  23.0 (20 km)';
        AOD_SAGE3=[ 0.0059 0.0071 0.0054 0.0040 0.0033 0.0029 0.0020 0.0014 0.0005];  
    end
end

figure(1)
%set(1,'DefaultLineMarkerSize',2)
subplot(4,1,1)
plot(UTdechr(idxplot),Latitude(idxplot),'.')
set(gca,'FontSize',12)
grid on
ylabel('Latitude (deg)','FontSize',12)
title(strgtitle);
subplot(4,1,2)
plot(UTdechr(idxplot),Longitude(idxplot),'.')
set(gca,'FontSize',12)
grid on
ylabel('Longitude (deg)','FontSize',12)
subplot(4,1,3)
plot(UTdechr(idxplot),Press_alt_km(idxplot),'b.')
hold on
plot(UTdechr(idxplot),GPS_alt_km(idxplot),'r.')
set(gca,'FontSize',12)
legend('Press alt','GPS alt',4)
grid on
ylabel('Altitude (km)','FontSize',12)
subplot(4,1,4)
plot(UTdechr(idxplot),Pressmb(idxplot),'.')
set(gca,'FontSize',12)
grid on
ylabel('Pressure (mb)','FontSize',12)
xlabel('UTC (hr)','FontSize',12)

aodlim=[-0.01 .06];
figure(2)
subplot(3,1,1)
plot(UTdechr(idxplot),Taupart(:,idxplot),'.')
set(gca,'FontSize',12)
set(gca,'ylim',aodlim)
grid on
ylabel('AOD','FontSize',12)
strleg='';
for i=1:nwl_aer,
 strleg=[strleg;sprintf('%6.1f',Wvlnm(i))];
end
h1=legend(strleg);
set(h1,'FontSize',10)
grid on
title(strgtitle);
subplot(3,1,2)
plot(UTdechr(kclear),Taupart(:,kclear),'.')
set(gca,'FontSize',12)
set(gca,'ylim',aodlim)
grid on
ylabel('AOD screened','FontSize',12)
subplot(3,1,3)
plot(UTdechr(idxplot),Unctaup(:,idxplot),'.')
set(gca,'FontSize',12)
grid on
ylabel('AOD Uncertainty','FontSize',12)
grid on
xlabel('UT (hr)','FontSize',12)

figure(3)
subplot(3,1,1)
semilogy(UTdechr,CWV_cm,'g.')
axis([-inf inf 0.0001 0.1])
%plot(UTdechr,CWV_cm,'g.')
%set(gca,'FontSize',12)
grid on
ylabel('Columnar Water Vapor (cm)','FontSize',12)
title(strgtitle);
subplot(3,1,2)
plot(UTdechr,CWVunc_cm,'k.')
set(gca,'FontSize',12)
grid on
ylabel('Unc CWV (cm)','FontSize',12)
subplot(3,1,3)
plot(UTdechr(kclear),O3col_DU(kclear),'b.')
set(gca,'FontSize',12)
grid on
ylabel('Ozone column content (DU)','FontSize',12)
xlabel('UT (hr)','FontSize',12)

figure(4)
subplot(2,1,1)
plot(UTdechr(idxplot),-a1_polyfit(idxplot),'b.')
set(gca,'FontSize',12)
grid on
hold on
plot(UTdechr(idxplot),-a2_polyfit(idxplot),'g.')
title(strgtitle);
legend('alphastar','gamma')
ylabel('polynomial fit parameters','FontSize',12)
subplot(2,1,2)
plot(UTdechr(kclear),-a1_polyfit(kclear),'b.')
set(gca,'FontSize',12)
grid on
hold on
plot(UTdechr(kclear),-a2_polyfit(kclear),'g.')
ylabel('screened polynomial fit parameters','FontSize',12)
xlabel('UT (hr)','FontSize',12)

wvl_chapp_aeronly=[1 1 1 1 0 1 1 1 1 1 1 0 0]; %note that there are only 13 values since this applies to aer wvls only
order=2;
xf=log(Wvlnm/1000);
if strcmp(flag_aodmovie,'yes')
 ibeg=1;
 ivl=1;
 iend=length(UTdechr);
 UTmovie_beg=[];
 UTmovie_end=[];
 if (year==2003 & month==1 & day==14)
    %UTmovie_beg=10.05;
    %UTmovie_end=10.35;
    %UTmovie_beg=10.3225;
    %UTmovie_end=10.3325;
    %use following after plotting
    %hhh=text(0.85,.032,'10.3325-10.3335 UT, 68.683N/12.167E to 68.703N/12.167E')
    %set(hhh,'FontSize',12,'Color','b')
 end
  if (year==2003 & month==1 & day==19)
     UTmovie_beg=0;
     UTmovie_end=9.87;
    %use following after plotting
    hhh=text(0.85,.032,'10.5- 10.6 UT ')
    set(hhh,'FontSize',12,'Color','b')
end
 
 if ~isempty(UTmovie_beg)
    idxplot=find(UTdechr>=UTmovie_beg & UTdechr<=UTmovie_end)
 else
    idxplot=[ibeg:ivl:iend];
 end
 figure(5)
 for i=idxplot,
  if(cloud_flag(i)==1)

  klam(1:13)=1;
  kk=[];
  kk=find(Taupart(:,i)>=99.9999);
  if ~isempty(kk) klam(kk)=0; end
  idx=find(wvl_chapp_aeronly==1 & klam==1);
    x=log(Wvlnm(idx)/1000);
    y=log(Taupart(idx,i));
    [p1,S1] = polyfit(x,y,order);
    switch order
    case 1
        a0(i)=p1(2); 
        alpha(i)=-p1(1);
        gamma(i)=0;
    case 2  
        a0(i)=p1(3); 
        alpha(i)=-p1(2);
        gamma(i)=-p1(1); 
    end   
    [y_fit2,delta] = polyval(p1,xf,S1);
          
   hold off
   y=log(Taupart(wvl_chapp_aeronly==1,i));
   %[p,S] = polyfit(x,y,order); 
   [y_fit] = polyval([-a2_polyfit(i) -a1_polyfit(i) a0_polyfit(i)],log(Wvlnm/1000));
   loglog(Wvlnm/1000,Taupart(:,i),'o','MarkerSize',5)
   hold on
   loglog(Wvlnm/1000,exp(y_fit),'b');
   loglog(Wvlnm/1000,exp(y_fit2),'b--');
   set(gca,'xlim',[.300 2.20]);
   set(gca,'ylim',[.0001 0.1])
   grid on
   set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2,2.2]);
   xlabel('Wavelength [microns]','FontSize',14);
   ylabel('Optical Depth','FontSize',14)
   set(gca,'FontSize',14)
   ht=title(sprintf(' rec:%d zGPS:%6.3f UT:%6.3f  Lat:%6.2f  Lon:%6.2f',i,GPS_alt_km(i),UTdechr(i),Latitude(i),Longitude(i)));
   set(ht,'FontSize',14) 
   if strcmp(flag_overplot_SAGE3,'yes')
       loglog(wvl_SAGE3,AOD_SAGE3,'r^','MarkerSize',7)  %'MarkerFaceColor','k',
       hs=text(0.27,0.00023,orbit_info_SAGE3);
       set(hs,'FontSize',11,'Color','r')
   end
   pause(0.00001)
  end 
 end
end