function [NO2_col,tau_aero,tau_NO2,p]=nitrog(site,day,month,year,m_aero,m_ray,m_NO2,m_O3,lambda,tau,tau_aero,tau_r,tau_O3,NO2_col_start,order);

% estimates NO2 column. density

% Written 9. 4.1996 by B. Schmid 

% NO2
NO2_xsect=[13.391 15.192 12.633 5.37 0.618 0.3 0 0 0 0 0 0]; % 1/atm-cm 
dNO2=0.05e15/2.687e19; %atm-cm
tau_NO2=NO2_col_start*NO2_xsect;

tau2=tau-tau_r*(m_ray/m_aero);
tau3=tau2-tau_O3*(m_O3/m_aero);
tau_aero=tau3-tau_NO2*(m_NO2/m_aero);

x=log(lambda([1:6 8 10 12]));
y=log(tau_aero([1:6 8 10 12]));

[p,S] = POLYFIT(x,y,order);
[y_fit,delta] = POLYVAL(p,x,S);
a=sum(abs(delta));


% start iteration
for iter=1:100
 NO2_col=NO2_col_start-dNO2*iter;
 tau_NO2=NO2_col*NO2_xsect;
 tau_aero=tau3-tau_NO2*(m_NO2/m_aero);;
 y=log(tau_aero([1:6 8 10 12]));
 [p,S] = POLYFIT(x,y,order) ;
 [y_fit,delta] = POLYVAL(p,x,S);
 if sum(abs(delta)) > a
  break;
 end;
 a=sum(abs(delta));
end


for iter=1:100
 NO2_col=NO2_col+dNO2*iter;
 tau_NO2=NO2_col*NO2_xsect;
 tau_aero=tau3-tau_NO2*(m_NO2/m_aero);;
 y=log(tau_aero([1:6 8 10 12]));
 [p,S] = POLYFIT(x,y,order) ;
 [y_fit,delta] = POLYVAL(p,x,S);
 if sum(abs(delta)) > a
  break;
 end;
 a=sum(abs(delta));
end


NO2_col=NO2_col-dNO2;
tau_NO2=NO2_col*NO2_xsect;
tau_aero=tau3-tau_NO2*(m_NO2/m_aero);;
y=log(tau_aero([1:6 8 10 12]));
[p,S] = POLYFIT(x,y,order); 
[y_fit,delta] = POLYVAL(p,x,S);

figure(3)
 loglog(lambda([1:6 8 10 12]),tau([1:6 8 10 12]) ,'+',...
        lambda([1:6 8 10 12]),tau3([1:6 8 10 12]),'o',...
        lambda([1:6 8 10 12]),tau2([1:6 8 10 12]),'go',...
        lambda([1:6 8 10 12]),tau_aero([1:6 8 10 12]),'cx',...
        lambda([1:6 8 10 12]),exp(y_fit),'y');
 set(gca,'xlim',[.300 1.050]);
 title(sprintf('%s %2i.%2i.%2i',site,day,month,year));
 xlabel('Wavelength [microns]');
 ylabel('Optical Depth')

% interpolate tau_aero for water vapor channels
[y_fit,delta] = POLYVAL(p,log(lambda),S);
tau_aero([7 9 11])=exp(y_fit([7 9 11]));
end

