function [tau_aero,tau_NO2,tau_O3,O3_col,p]=ozone_box(site,day,month,year,lambda,O3_xsect,NO2_xsect,NO2_clima,...
          m_aero,m_ray,m_NO2,m_O3,m_H2O,wvl_chapp,wvl_aero,tau,tau_r,tau_O4,tau_H2O,O3_col_start,order);
       
% Function ozone_box       
%      
% Estimates ozone column and computes aerosol optical depth for all wavelengths incl. H2O-absorption channels. 
% Unlike in ozone2.m the Gail Box algo is used here
% Written 12.2.98 by B. Schmid

%               380.3  448.25 452.97  499.4  524.7  605.4  666.8   711.8 778.5   864.4   939.5 1018.7 1059   1557.5	
alpha=        [-0.051        0.484  -1.785  1.790         0.846        -0.489   0.207                             ]; %smallest eigenvalue
%alpha=         [0.061        -0.486   1.074 -0.465         1.480        -1.250   0.596                             ]; %second smallest eigenvalue
wvl_chapp_weak=[1      0      1       1      1      0      1       0     1       1       0     0      0      0     ]; 
wvl_chapp_peak=[0      0      0       0      0      1      0       0     0       0       0     0      0      0     ]; 

tau_NO2=NO2_clima*NO2_xsect;

tau2=tau-tau_r*(m_ray/m_aero);
tau3=tau2-tau_NO2*(m_NO2/m_aero);
tau4=tau3-tau_O4*(m_ray/m_aero);
tau5=tau4-tau_H2O*(m_ray/m_H2O);

O3_col_init=0;
O3_col=(tau5(wvl_chapp_peak==1)-alpha*tau5(wvl_chapp_weak==1))/(O3_xsect(wvl_chapp_peak==1));

while abs(O3_col-O3_col_init) > 0.001 
   O3_col_init=O3_col ;
   tau_O3=O3_col*O3_xsect;
   tau_aero=tau5-tau_O3*(m_O3/m_aero);
   O3_col=(tau5(wvl_chapp_peak==1)-alpha*tau_aero(wvl_chapp_weak==1))/(O3_xsect(wvl_chapp_peak==1));
end


% interpolate tau_aero for non-windows channels
x=log(lambda(wvl_chapp==1));
y=log(tau_aero(wvl_chapp==1));
[p,S] = polyfit(x,y,order);
[y_fit,delta] = polyval(p,log(lambda),S);
tau_aero(wvl_aero==0)=exp(y_fit(wvl_aero==0));

figure(2)
 loglog(lambda(wvl_aero==1),tau(wvl_aero==1) ,'r+',...
        lambda(wvl_aero==1),tau2(wvl_aero==1),'ko',...
        lambda(wvl_aero==1),tau3(wvl_aero==1),'bo',...
        lambda(wvl_aero==1),tau4(wvl_aero==1),'go',...
        lambda(wvl_aero==1),tau5(wvl_aero==1),'co',...
        lambda(wvl_aero==1),tau_aero(wvl_aero==1),'rx',...
        lambda,exp(y_fit),'y');
 set(gca,'xlim',[.300 1.60]);
 set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
 %title(sprintf('%s %2i.%2i.%2i',site,day,month,year));
 xlabel('Wavelength [microns]');
 ylabel('Optical Depth')
 pause(0.01)
