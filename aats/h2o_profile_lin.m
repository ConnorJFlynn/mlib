figure(10)
subplot(1,2,1)
plot(U(L_H2O==1 & L_dist==1)/H2O_conv,r(L_H2O==1 & L_dist==1),'.')
set(gca,'FontSize',14)
xlabel('Columnar Water Vapor [g/cm^2]','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
title(sprintf('%s %2i.%2i.%2i %g-%g',site,day,month,year,UT_start,UT_end,' UT'),'FontSize',14);
hold on
clear layer

layer(1,:)=[0.32 1.40];
layer(2,:)=[1.4 2.9];
layer(3,:)=[2.90 3.29];
layer(4,:)=[3.29 3.863];
 [n_lay,m]=size(layer);
 for n=1:n_lay,
  L=(r>=layer(n,1) & r<=layer(n,2));,
  [p,S] = polyfit (r(L),U(L)/H2O_conv,1)
  H2O_dens(n)=-p(1)*10;
  [y_fit,delta] = polyval(p,r(L),S);
  subplot(1,2,1)
  plot(y_fit,r(L),'k--')
 end
 for n=1:n_lay,
    for i=1:2,
       if i==1
        r_layer(n*(i+1)-1)=layer(n,i);
        H2O_layer(n*(i+1)-1)=H2O_dens(n);
       elseif i==2
        r_layer(n*i)=layer(n,i);
        H2O_layer(n*i)=H2O_dens(n);
       end      
    end
  end   
 grid on 

hold off
figure(10)
subplot(1,2,2)
plot(H2O_layer,r_layer)
ylabel('Altitude [km]','FontSize',14)
xlabel('Water Vapor Density [g/m^3]','FontSize',14)
set(gca,'FontSize',14)
grid on