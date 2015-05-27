%Plots results of King, 1978 Inversion (Aerosol Particle Size Distribution)
%and computes Reff,SURFACE AREA, VOLUME and MASS
clear 
nset=1

fid=fopen('d:\beat\mie\distplot.dat','r');
fid2=fopen('d:\beat\mie\tauplot.dat','r');

for iset=1:nset
 
 % reads DISTPLOT file
 
 line=fscanf(fid,'%f',[6,1]);
 kdate=line(1);
 year=fix(kdate/1e4)
 kdate=kdate-year*1e4;
 month=fix(kdate/1e2)
 day=kdate-month*1e2
 ri=line(2);
 rf=line(3);
 nrad=line(4);
 rfr=line(5);
 rfi=line(6);
 snu=fscanf(fid,'%f',[3,1]);
 rr=fscanf(fid,'%f',[nrad,1]);
 dnlgr1=fscanf(fid,'%f',[nrad,16]);
 dnlgr2=fscanf(fid,'%f',[nrad,16]);
 dnlgr3=fscanf(fid,'%f',[nrad,16]); 

 % reads TAUPLOT file
 
 line=fscanf(fid2,'%f',[6,1]);
 nwvl=line(4);
 wvl=fscanf(fid2,'%f',[nwvl,1]);
 tau=fscanf(fid2,'%f',[nwvl,1]);
 err=fscanf(fid2,'%f',[nwvl,1]);
 tauc1=fscanf(fid2,'%f',[nwvl,8]);
 tauc2=fscanf(fid2,'%f',[nwvl,8]);
 tauc3=fscanf(fid2,'%f',[nwvl,8]);

 % PLOTS FIGURE WITH RESULTS OF 8 ITERATIONS
 figure(1)
 orient landscape
 subplot (2,3,1), loglog (rr,dnlgr1(:,[1:2:15]));
 set (gca,'xlim',[ri rf])
 subplot (2,3,2), loglog (rr,dnlgr2(:,[1:2:15]));
 set (gca,'xlim',[ri rf])
 subplot (2,3,3), loglog (rr,dnlgr3(:,[1:2:15]));
 set (gca,'xlim',[ri rf]) 
 subplot (2,3,4), loglog (wvl,tau,'.');
 hold on
 errorbar(wvl,tau,err,err,'.')
 loglog (wvl,tauc1)
 set (gca,'xlim',[0.3 1.1])
 hold off
 subplot (2,3,5), loglog (wvl,tau,'.');
 hold on
 errorbar(wvl,tau,err,err,'.')
 loglog (wvl,tauc2)
 set (gca,'xlim',[0.3 1.1])
 hold off
 subplot (2,3,6), loglog (wvl,tau,'.');
 hold on
 errorbar(wvl,tau,err,err,'.')
 loglog (wvl,tauc3)
 set (gca,'xlim',[0.3 1.1])
 hold off

 % EXTRAPOLATES TO RI AND RF for last iteration
 rr2=[ri;rr;rf];
 x=log(rr(1:2));
 y=log(dnlgr1(1:2,15));
 [p,S] = POLYFIT (x,y,1);
 [y_fit,delta] = POLYVAL(p,log(ri),S);
 dnlgr1_ri=exp(y_fit) 

 x=log(rr(nrad-1:nrad));
 y=log(dnlgr1(nrad-1:nrad,15));
 [p,S] = POLYFIT (x,y,1);
 [y_fit,delta] = POLYVAL(p,log(rf),S);
 dnlgr1_rf=exp(y_fit)
 dnlgr(1,:)=[dnlgr1_ri;dnlgr1(:,15);dnlgr1_rf]'

 x=log(rr(1:2));
 y=log(dnlgr2(1:2,15));
 [p,S] = POLYFIT (x,y,1);
 [y_fit,delta] = POLYVAL(p,log(ri),S);
 dnlgr2_ri=exp(y_fit)

 x=log(rr(nrad-1:nrad));
 y=log(dnlgr2(nrad-1:nrad,15));
 [p,S] = POLYFIT (x,y,1);
 [y_fit,delta] = POLYVAL(p,log(rf),S);
 dnlgr2_rf=exp(y_fit)
 dnlgr(2,:)=[dnlgr2_ri;dnlgr2(:,15);dnlgr2_rf]'

 x=log(rr(1:2));
 y=log(dnlgr3(1:2,15));
 [p,S] = POLYFIT (x,y,1);
 [y_fit,delta] = POLYVAL(p,log(ri),S);
 dnlgr3_ri=exp(y_fit)

 x=log(rr(nrad-1:nrad));
 y=log(dnlgr3(nrad-1:nrad,15));
 [p,S] = POLYFIT (x,y,1);
 [y_fit,delta] = POLYVAL(p,log(rf),S);
 dnlgr3_rf=exp(y_fit)
 dnlgr(3,:)=[dnlgr3_ri;dnlgr3(:,15);dnlgr3_rf]'

 %COMPUTES Reff,SURFACE AREA, VOLUME AND MASS

 ncxr=dnlgr/log(10);
 i1=trapz(rr2,((ones(3,1)*rr2').^2.*ncxr)');
 i2=trapz(rr2,((ones(3,1)*rr2').*ncxr)');

 r_eff=i1./i2;
 area=4*pi*i2;
 volume=4/3*pi*i1;
 mass=volume*1.67 %For startospheric volcanic aerosol

 r_eff_mean=mean(r_eff)
 r_eff_std=std(r_eff)

 area_mean=mean(area)
 area_std=std(area)

 volume_mean=mean(volume)
 volume_stde=std(volume)

 mass_mean=mean(mass)
 mass_stde=std(mass)

 % PLOTS FIGURE WITH RESULTS OF LAST ITERATION
 figure(2)
 orient landscape
 subplot (1,2,1), loglog (rr,dnlgr1(:,15),'*',rr,dnlgr2(:,15),'+',rr,dnlgr3(:,15),'o',rr2,dnlgr);
 hold on
 yerrorbar('loglog',0.05,5,1e1,1e9,rr,dnlgr2(:,15),dnlgr2(:,16),dnlgr2(:,16),'+')
 hold off

 
 set (gca,'xlim',[0.07 5])
 set(gca,'xtick',[0.1,0.2 0.5,1,2,3,4]);
 set(gca,'ylim',[1e1 1e9]);
 xlabel('Radius [µm]');
 ylabel('dN/dlogr');
 text(0.2,6e8,sprintf('R_e_f_f= %5.2f µm',r_eff_mean))
 text(0.2,3.5e8,sprintf('S= %4.2f 10^6 µm²/cm²',area_mean/1e6))
 text(0.2,1.75e8,sprintf('V= %4.2f 10^6 µm³/cm²',volume_mean/1e6))
 text(0.2,0.9e8,sprintf('M= %4.2f µg/cm²',mass_mean/1e6))
 
 
 subplot (1,2,2), loglog (wvl,tau,'*',wvl,tauc1(:,8),wvl,tauc2(:,8),wvl,tauc3(:,8));
 text(0.4,0.03,sprintf('m= %5.2f - %7.4f',rfr,rfi))

 set(gca,'xlim',[.35 1.6]);
 set(gca,'xtick',[0.35,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
 set(gca,'ylim',[0.02 0.3]);
 set(gca,'ytick',[0.02 0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.2,0.3]);

 hold on
 yerrorbar('loglog',0.35, 1.6, 0.02,0.3, wvl,tau,err,err,'.')
 hold off
 xlabel('Wavelength [µm]');
 ylabel('Aerosol Optical Depth');
 title(sprintf('%s %i %s %i %s %i',' ',day,'.',month,'.',year));
 %print -dwin

 %Averages
 figure(3)
 
 orient landscape
 subplot (1,2,1), loglog (rr2,mean(dnlgr),rr,mean([dnlgr1(:,15),dnlgr2(:,15),dnlgr3(:,15)]'),'*')
 set (gca,'xlim',[0.07 5])
 set(gca,'xtick',[0.1,0.2 0.5,1,2,3,4]);
 set(gca,'ylim',[1e3 1e9]);
 hold on  
 xlabel('Radius [µm]');
 ylabel('dN/dlogr');
 
 subplot (1,2,2), loglog (wvl,tau,'*',wvl,mean([tauc1(:,8),tauc2(:,8),tauc3(:,8)]'));
    
 set(gca,'xlim',[.35 1.6]);
 set(gca,'xtick',[0.35,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
 set(gca,'ylim',[0.01 0.4]);
 
 hold on
 errorbar(wvl,tau,err,err,'.')
 hold off
 xlabel('Wavelength [µm]');
 ylabel('Aerosol Optical Depth');
 title(sprintf('%s %i %s %i %s %i',' ',day,'.',month,'.',year));
 hold on
 pause
end

 % PLOTS FIGURE WITH RESULTS OF LAST ITERATION AND BEST NU*
 figure(4)
 hold on
 orient landscape
 
 subplot (1,2,1), loglog (rr,dnlgr2(:,15),'ko',rr2,dnlgr(2,:),'k');
 hold on
 yerrorbar('loglog',0.1,5,1e3,1e9,rr,dnlgr2(:,15),dnlgr2(:,16),-dnlgr2(:,16),'k');
 hold off
 set (gca,'xlim',[0.09 5])
 set(gca,'xtick',[0.1,0.2,0.3, 0.5,1,2,3,4,5]);
 set(gca,'ylim',[1e3 1e9]);
% set(gca,'ytick',[1e3 1e4 1e5 1e6 1e7 1e8 1e9]);
 xlabel('Radius [µm]','FontSize',13);
 ylabel('dN/dlogr [1/cm²]','FontSize',13);
 text(1,4e8,sprintf('R_e_f_f= %5.2f µm',r_eff(2)))
 text(1,2e8,sprintf('S= %4.2f 10^6 µm²/cm²',area(2)/1e6))
 text(1,.8e8,sprintf('V= %4.2f 10^6 µm³/cm²',volume(2)/1e6))
 %text(0.2,0.9e8,sprintf('M= %4.2f µg/cm²',mass(2)/1e6))
 set(gca,'FontSize',13)

 subplot (1,2,2), loglog (wvl,tau,'k*',wvl,tauc2(:,8),'k');
 text(0.35,0.025,sprintf('m= %5.2f - %7.4f',rfr,rfi))
% text(0.35,0.7,sprintf('m= %5.2f - %7.4f',rfr,rfi))
 set(gca,'xlim',[.3 1.6]);
 set(gca,'xtick',[0.3,0.4,0.5,0.6,0.8,1.0,1.3,1.6]);
 set(gca,'ylim',[0.02 0.3]);
% set(gca,'ylim',[0.2 0.8]);

% set(gca,'ytick',[0.2 0.3 0.4 0.5 0.6 0.7 0.8]);
 
% set(gca,'ytick',[0.02 0.03,0.04,0.05,0.06,0.07,0.08]);
 hold on
 yerrorbar('loglog',0.35,1.6,0.02,0.3,wvl,tau,err,err,'k.');
 hold off
 xlabel('Wavelength [µm]','FontSize',14);
 ylabel('Aerosol Optical Depth','FontSize',14);
 title(sprintf('%s %i %s %i %s %i',' ',day,'.',month,'.',year));
 set(gca,'FontSize',14)

 
 fclose(fid);
 fclose(fid2);
