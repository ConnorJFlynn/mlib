%plot_AOD_movie.m
flag_aodmovie='yes';
order=2;
Taupart=tau_aero(wvl_aero==1,:);
lambda_aer=lambda(wvl_aero==1);
if strcmp(flag_aodmovie,'yes')
 ibeg=1;
 ivl=1; %10;
 iend=length(UT);
 UTmovie_beg=[];
 UTmovie_end=[];
 if (year==2006 & month==2 & day==24)
    UTmovie_beg=18.5;
    UTmovie_end=18.9;
 end
 if ~isempty(UTmovie_beg)
    idxplot=find(UT>=UTmovie_beg & UT<=UTmovie_end);
    idxplot=[idxplot(1):ivl:idxplot(end)];
 else
    idxplot=[ibeg:ivl:iend];
 end

 wvl_fit=[1 1 1 1 1 1 1 1 1 1 1 1 0];
 figure(8)
 for i=idxplot,
  if(L_cloud(i)==1)

  kk=[];
  xf=log(lambda_aer(wvl_fit==1));
  yf=log(Taupart(wvl_fit==1,i));
  [p1,S1] = polyfit(xf,yf,order);
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
    [y_fit2,delta] = polyval(p1,log(lambda_aer),S1);
          
   hold off
   y=log(Taupart(:,i));
   loglog(lambda_aer,Taupart(:,i),'o','MarkerSize',8,'MarkerFaceColor','b')
   hold on
   loglog(lambda_aer,exp(y_fit2),'b--','Linewidth',1.5);
   set(gca,'xlim',[.300 2.20]);
   set(gca,'ylim',[.0001 1])
   grid on
   set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2,2.2]);
   xlabel('Wavelength [microns]','FontSize',14);
   ylabel('Aerosol Optical Depth','FontSize',14)
   set(gca,'FontSize',14)
   ht=title(sprintf(' rec:%d zGPS:%6.3f UT:%6.3f  Lat:%6.2f  Lon:%6.2f',i,GPS_Alt(i),UT(i),geog_lat(i),geog_long(i)));
   set(ht,'FontSize',14) 
   pause(0.1)
  end 
 end
end
