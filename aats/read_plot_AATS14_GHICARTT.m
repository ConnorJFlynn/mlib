%read_plot_AATS14_GHICARTT.m

clear
close all

[numlines_info,info_sav,UTdechr,Latitude,Longitude,GPS_alt_km,Press_alt_km,Pressmb,...
	  Wvlnm,CWV_cm,uncCWV_cm,O3col_DU,uncO3col_DU,cloud_flag,a2_polyfit,a1_polyfit,a0_polyfit,...
	  Taupart,Unctaup,mission_name,year,month,day,filename]=read_AATS14_GH_ICARTT('c:\BEAT\DATA\ICARTT\*.ict');

date_AATS14data = datestr(datenum(year,month,day),1);
strgtitle=sprintf('File:%s   Date:%s',filename,date_AATS14data);
for i=1:length(strgtitle),
    if strcmp(strgtitle(i),'_') strgtitle(i)='-'; end
end

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

%flag_SZA='no';
flag_aodmovie='no'; %'yes';

iobsbeg=1;
iobsend=nobs;
idxuse=iobsbeg:iobsend;

aodlim=[];
ozonelim=[];
CWVlim=[];
UTlim=[];
UTlimfig6=[];
SZA_unrefrac=[];
ua_zenapp_int=[];

%cla reset
set(0,'DefaultLineMarkerSize',4)

UT_hhmmss = time_hhmmss(UTdechr);

UTCmin=min(UTdechr);
UTCmax=max(UTdechr);
numsecmin=fix(UTCmin*3600/100)*100;
numsecmax=fix((UTCmax*3600+100)/100)*100;

idxplot=iobsbeg:iobsend;
kclear=idxplot(cloud_flag==1);
UTlim=[-inf inf];

figure(1)
%set(1,'DefaultLineMarkerSize',2)
subplot(3,1,1)
plot(UTdechr(idxplot),Latitude(idxplot),'.')
set(gca,'FontSize',12)
set(gca,'xlim',UTlim)
grid on
ylabel('Latitude (deg)','FontSize',12)
title(strgtitle);
subplot(3,1,2)
plot(UTdechr(idxplot),Longitude(idxplot),'.')
set(gca,'FontSize',12)
set(gca,'xlim',UTlim)
grid on
ylabel('Longitude (deg)','FontSize',12)
subplot(3,1,3)
plot(UTdechr(idxplot),Press_alt_km(idxplot),'b.')
hold on
plot(UTdechr(idxplot),GPS_alt_km(idxplot),'r.')
set(gca,'xlim',UTlim)
set(gca,'FontSize',12)
legend('Press alt','GPS alt',4)
grid on
ylabel('Altitude (km)','FontSize',12)

if isempty(aodlim) aodlim=[0 0.8]; end
%aodlim=[0 .02];
figure(2)
subplot(3,1,1)
plot(UTdechr(idxplot),Taupart(:,idxplot),'.')
set(gca,'FontSize',12)
set(gca,'ylim',aodlim,'xlim',UTlim)
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
set(gca,'ylim',aodlim,'xlim',UTlim)
grid on
ylabel('AOD screened','FontSize',12)
subplot(3,1,3)
plot(UTdechr(idxplot),Unctaup(:,idxplot),'.')
set(gca,'FontSize',12)
set(gca,'xlim',UTlim)
grid on
ylabel('AOD Uncertainty','FontSize',12)
grid on

if isempty(ozonelim) ozonelim=[250 400]; end 
%ozonelim=[-inf inf];
CWVlim=[-inf inf];
if isempty(CWVlim) CWVlim=[0.00 0.02]; end
figure(3)
subplot(3,1,1)
%semilogy(UTdechr,CWV_cm,'g.')
%axis([-inf inf 0.0001 0.1])
plot(UTdechr,CWV_cm,'g.')
axis([UTlim CWVlim]) %9.5 12.5
set(gca,'FontSize',12)
grid on
ylabel('Columnar Water Vapor (cm)','FontSize',12)
title(strgtitle);
subplot(3,1,2)
plot(UTdechr,uncCWV_cm,'k.')
set(gca,'FontSize',12)
%set(gca,'xlim',UTlim)
axis([UTlim CWVlim])
grid on
ylabel('Unc CWV (cm)','FontSize',12)
subplot(3,1,3)
plot(UTdechr(kclear),O3col_DU(kclear),'b.')
set(gca,'FontSize',12)
grid on
ylabel('Ozone column content (DU)','FontSize',12)
xlabel('UT (hr)','FontSize',12)
axis([UTlim ozonelim])

figure(4)
subplot(2,1,1)
plot(UTdechr(idxplot),-a1_polyfit(idxplot),'b.')
set(gca,'FontSize',12)
grid on
hold on
plot(UTdechr(idxplot),-a2_polyfit(idxplot),'g.')
set(gca,'xlim',UTlim)
title(strgtitle);
legend('alphastar','gamma')
ylabel('polynomial fit parameters','FontSize',12)
subplot(2,1,2)
plot(UTdechr(kclear),-a1_polyfit(kclear),'b.')
set(gca,'FontSize',12)
grid on
hold on
plot(UTdechr(kclear),-a2_polyfit(kclear),'g.')
set(gca,'xlim',UTlim)
ylabel('screened polynomial fit parameters','FontSize',12)
xlabel('UT (hr)','FontSize',12)

aodlim=[0 0.8]; %1/24
%ozonelim=[240 280];
figure(5)
subplot(2,1,1)
plot(UTdechr(kclear),Taupart(:,kclear),'.')
set(gca,'FontSize',12)
set(gca,'ylim',aodlim,'xlim',UTlim)
grid on
ylabel('AOD screened','FontSize',12)
set(gca,'xlim',UTlim,'ylim',aodlim)
title(strgtitle);
subplot(2,1,2)
plot(UTdechr(kclear),O3col_DU(kclear),'b.')
set(gca,'FontSize',14)
grid on
ylabel('Ozone column content (DU)','FontSize',14)
xlabel('UT (hr)','FontSize',14)
set(gca,'xlim',UTlim,'ylim',ozonelim)

if isempty(UTlimfig6) UTlimfig6=UTlim; end
idxwvlbeg=1;
figure(6)
subplot(2,1,1)
plot(UTdechr(kclear),Taupart(idxwvlbeg:end,kclear),'.')
set(gca,'FontSize',14)
set(gca,'ylim',aodlim,'xlim',UTlim)
grid on
ylabel('AOD screened','FontSize',14)
set(gca,'xlim',UTlimfig6,'ylim',aodlim)
title(strgtitle); 
strleg='';
for jj=idxwvlbeg:13,
    strleg=[strleg;sprintf('%6.1f',Wvlnm(jj))];
end
leghh=legend(strleg);
set(leghh,'FontSize',10)
subplot(2,1,2)
hl1 = line(UTdechr(kclear),O3col_DU(kclear),'Marker','.','Color','k','LineStyle','None');
ax1=gca;
set(ax1,'XColor','k','YColor','k','XLim',UTlim,'YLim',ozonelim,'Box','off');
%set(ax1,'YTick',odtickmarks);
set(ax1,'FontSize',14);
ylabel('Ozone column content (DU)','FontSize',14)
xlabel('UT (hr)','FontSize',14)
set(gca,'xlim',UTlimfig6)
grid on

wvl_chapp_aeronly=[1 1 1 1 1 1 1 1 1 1 1 1 1]; %note that there are only 13 values since this applies to aer wvls only
order=2;
Wvlnm_aer=Wvlnm(1:13);
xf=log(Wvlnm_aer/1000);
if strcmp(flag_aodmovie,'yes')
 ibeg=1;
 ivl=10;
 iend=length(UTdechr);
 UTmovie_beg=[];
 UTmovie_end=[];
 if (year==2004 & month==7 & day==12)
    %UTmovie_beg=18.15;
    %UTmovie_end=20.04;
 end
 if ~isempty(UTmovie_beg)
    idxplot=find(UTdechr>=UTmovie_beg & UTdechr<=UTmovie_end)
 else
    idxplot=[ibeg:ivl:iend];
 end
 figure(7)
 for i=idxplot,
  if(cloud_flag(i)==1)

  klam(1:13)=1;
  kk=[];
  kk=find(Taupart(:,i)<=-9999);
  if ~isempty(kk) klam(kk)=0; end
  idx=find(wvl_chapp_aeronly==1 & klam==1);
    x=log(Wvlnm_aer(idx)/1000);
    y=log(Taupart(idx,i));
    [p1,S1] = polyfit(x,y,order);
    switch order
    case 1
        a0(i)=p1(2); 
        alpha(i)=p1(1);
        gamma(i)=0;
    case 2  
        a0(i)=p1(3); 
        alpha(i)=p1(2);
        gamma(i)=p1(1); 
    end   
    [y_fit2,delta] = polyval(p1,xf,S1);
          
   hold off
   y=log(Taupart(wvl_chapp_aeronly==1,i));
   [y_fit] = polyval([a2_polyfit(i) a1_polyfit(i) a0_polyfit(i)],log(Wvlnm_aer/1000));
   loglog(Wvlnm_aer/1000,Taupart(:,i),'o','MarkerSize',8,'MarkerFaceColor','b')
   hold on
   loglog(Wvlnm_aer/1000,exp(y_fit),'b--','Linewidth',1.5);
   %loglog(Wvlnm/1000,exp(y_fit2),'b--');
   set(gca,'xlim',[.300 2.20]);
   set(gca,'ylim',[.001 1])
   grid on
   set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2,2.2]);
   xlabel('Wavelength [microns]','FontSize',14);
   ylabel('Optical Depth','FontSize',14)
   set(gca,'FontSize',14)
   ht=title(sprintf(' rec:%d zGPS:%6.3f UT:%6.3f  Lat:%6.2f  Lon:%6.2f',i,GPS_alt_km(i),UTdechr(i),Latitude(i),Longitude(i)));
   set(ht,'FontSize',14) 
   pause(0.00001)
  end 
 end
end

msize=4;
colorlevels=[0 1 1; 0 0 1; 0 1 0; 1 1 0; 1 .65 .4; 1 0 1;1 0 0;0.8 0.2 0.2;0.5 0.5 0.5;0 0 0]; % cyan,blue,green,yellow,orange,magenta,red,brown,gray
zcrit=[0.25 0.5:0.5:4];
figure
cm=colormap(colorlevels);
%plot(Longitude,Latitude,'linewidth',2)
jp=find(GPS_alt_km<=zcrit(1));
plot(Longitude(jp),Latitude(jp),'o','color',cm(1,:),'markersize',msize,'markerfacecolor',cm(1,:))
hold on
for i=2:length(zcrit),
 jp=find(GPS_alt_km>zcrit(i-1) & GPS_alt_km<=zcrit(i));
 plot(Longitude(jp),Latitude(jp),'o','color',cm(i,:),'markersize',msize,'markerfacecolor',cm(i,:))
end
jp=find(GPS_alt_km>zcrit(end));
plot(Longitude(jp),Latitude(jp),'o','color',cm(length(zcrit)+1,:),'markersize',msize,'markerfacecolor',cm(length(zcrit)+1,:))
hold on
grid on
set(gca,'fontsize',14)
xlabel('Longitude [deg]','fontsize',14)
ylabel('Latitude [deg]','fontsize',14)
title(sprintf('J31 Flight Track: %s  %6.3f-%6.3f UT',date_AATS14data,UTdechr(1),UTdechr(end)),'fontsize',14)
ylims=get(gca,'ylim');
ntim=length(Latitude);
dely=0.02*(ylims(2)-ylims(1));
for i=1:floor(ntim/10):ntim,
    plot(Longitude(i),Latitude(i),'o','markersize',10,'MarkerFacecolor','b')
    ht=text(Longitude(i),Latitude(i)-dely,sprintf('%5.2f',UTdechr(i)));
    set(ht,'fontsize',12)
end
xlimits=get(gca,'xlim');
ylimits=get(gca,'ylim');
cb=colorbar;
set(cb,'yticklabel',[0 zcrit inf],'fontsize',14)
cbpos=get(cb,'Position');
ht2=text(xlimits(2)+0.05*(xlimits(2)-xlimits(1)),ylimits(1)-0.04*(ylimits(2)-ylimits(1)),'Altitude [km]');
set(ht2,'fontsize',13)