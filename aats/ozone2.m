function [tau_aero,tau_NO2,tau_O3,O3_col,p]=ozone2(site,day,month,year,lambda,O3_xsect,NO2_xsect,NO2_clima,m_aero,...
          m_ray,m_NO2,m_O3,m_H2O,wvl_chapp,wvl_aero,tau,tau_r,tau_O4,tau_H2O,O3_col_start,order);
% Estimates ozone column and computes aerosol optical depth for all wavelengths incl. H2O-absorption channels. 
% 
% Michalsky J. J., J. C. Liljegren, and L. C. Harrison, 1995: A comparison of Sun photometer derivations of total column
% water vapor and ozone to standard measures of same at the Southern Great Plains Atmospheric Radiation Measurement site.
% Journal of Geophysical Research. Vol. 100, No. D12, 25'995-26'003.
% Written 18. 7.95 by B. Schmid 
% Changes 21. 7.95 by B. Schmid: Bugs fixed in plotting final fit, dO3 gives increment in O3 Col
% Changes 24. 7.95 by B. Schmid: New Formula for Rayleigh-Scattering (preliminary)
% Changes 25. 7.95 by B. Schmid: New Ozone Absorption Cross-Sections (preliminary)
% Changes 26. 7.95 by B. Schmid: NO2 Absorption Cross-Sections included (preliminary)
% Changes 27. 7.95 by B. Schmid: Interpolates tau_aero for H2O-absorption channels.
% Changes 19.12.95 by B. Schmid: Allows to select order of polynomial fit and returns coefficients of polynom
% Changes 20. 3.96 by B. Schmid: New Ozone Absorption Cross-Sections (from MODTRAN3 )
% Changes 20. 3.96 by B. Schmid: New NO2 Absorption Cross-Sections included (from MODTRAN3) 
% Changes 11. 4.96 by B. Schmid: Uses individual airmasses
% Changes 13. 5.96 by B. Schmid: Allows input of NO2 column, all cross sections are computed externally
% Changes 10. 7.97 by B. Schmid: Plots fit at all SPM wavelengths
% Changes 23.10.98 by B. Schmid: corrects for O2-O2 absorption
% Changes  8. 2.99 by B. Schmid: corrects for H2O absorption
dO3=0.001; %Resolution of retrieval
tau_NO2=NO2_clima*NO2_xsect;
tau_O3=O3_col_start*O3_xsect;              
tau2=tau-tau_r*(m_ray/m_aero);
tau3=tau2-tau_NO2*(m_NO2/m_aero);
tau4=tau3-tau_O4*(m_ray/m_aero);
tau5=tau4-tau_H2O*(m_ray/m_H2O);
tau_aero=tau5-tau_O3*(m_O3/m_aero);
x=log(lambda(wvl_chapp==1));
y=log(tau_aero(wvl_chapp==1));
[p,S] = polyfit(x,y,order);
[y_fit,delta] = polyval(p,x,S);
a=sum(abs(delta));
% start iteration
for iter=1:600
 O3_col=O3_col_start-dO3*iter;
 tau_O3=O3_col*O3_xsect;
 tau_aero=tau5-tau_O3*(m_O3/m_aero);
 y=log(tau_aero(wvl_chapp==1));
 [p,S] = polyfit(x,y,order) ;
 [y_fit,delta] = polyval(p,x,S);
 if sum(abs(delta)) > a
  break;
end;
 a=sum(abs(delta));
end
for iter=1:600
 O3_col=O3_col+dO3*iter;
 tau_O3=O3_col*O3_xsect;
 tau_aero=tau5-tau_O3*(m_O3/m_aero);
 y=log(tau_aero(wvl_chapp==1));
 [p,S] = polyfit(x,y,order) ;
 [y_fit,delta] = polyval(p,x,S);
 if sum(abs(delta)) > a
  break;
end;
 a=sum(abs(delta));
end
O3_col=O3_col-dO3;
tau_O3=O3_col*O3_xsect;
tau_aero=tau5-tau_O3*(m_O3/m_aero);
% interpolate tau_aero for non-windows channels
y=log(tau_aero(wvl_chapp==1));
[p,S] = polyfit(x,y,order); 
[y_fit,delta] = polyval(p,log(lambda),S);
tau_aero(wvl_aero==0)=exp(y_fit(wvl_aero==0));
figure(2)
 loglog(lambda(wvl_aero==1),tau(wvl_aero==1) ,'r+',...
        lambda(wvl_aero==1),tau2(wvl_aero==1),'go',...
        lambda(wvl_aero==1),tau3(wvl_aero==1),'go',...
        lambda(wvl_aero==1),tau4(wvl_aero==1),'go',...
        lambda(wvl_aero==1),tau5(wvl_aero==1),'mo',...
        lambda(wvl_aero==1),tau_aero(wvl_aero==1),'bd',...
        lambda,exp(y_fit),'y');
 set(gca,'xlim',[.300 2.20]);
 set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2,2.2]);
 %title(sprintf('%s %2i.%2i.%2i',site,day,month,year));
 xlabel('Wavelength [microns]','FontSize',14);
 ylabel('Optical Depth','FontSize',14)
 set(gca,'FontSize',14)
 pause(0.00001)