% defines wavelengths to be shown on plot
% ACE-2         380.3  448.25 452.97 499.4  524.7  605.4  666.8  711.8  778.5  864.4  939.5  1018.7 1059   1557.5	

% SAFARI        354    380    448    453    499    525    605    675    779    864    940    1019   1240   1558	
      wvl_plot= [1      1      1      0      1     1      1      1       1      1      0      1      1      1     ];

channels=1:size(V0');

figure(29)
subplot(1,2,1)
plot(tau_aero(wvl_plot==1,L_cloud==1 & L_dist==1),r(L_cloud==1 & L_dist==1),'.')
set(gca,'FontSize',14)
set(gca,'xlim',[0 0.8])
xlabel('Aerosol Optical Depth','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
title(sprintf('%s %s','NASA Ames Sunphotometer',site),'FontSize',14);
hold on
clear layer

%layer(1,:)=[0.32 1.40];
%layer(2,:)=[1.4  1.6];
%layer(3,:)=[1.6  1.90];
%layer(4,:)=[1.90  2.02];
%layer(5,:)=[2.02 3.0];
%layer(6,:)=[3.0 3.27];
%layer(7,:)=[3.27 3.863];

layer(1,:)=[0.32 1.50];
layer(2,:)=[1.5 2.95];
layer(3,:)=[2.95 3.24];
layer(4,:)=[3.24 3.863];

for ichan=channels(wvl_plot==1);
    [n_lay,m]=size(layer);
    for n=1:n_lay,
        L=(r>=layer(n,1) & r<=layer(n,2));,
        
        [p,S] = polyfit (r(L.*L_cloud.*L_dist==1),tau_aero(ichan,L.*L_cloud.*L_dist==1),1)
        ext_coeff(n)=-p(1);
        
        [y_fit,delta] = polyval(p,r(L),S);
        
        subplot(1,2,1)
        plot(y_fit,r(L),'k--')
    end
    for n=1:n_lay,
        for i=1:2,
            if i==1
                r_layer(n*(i+1)-1)=layer(n,i);
                ext_layer(ichan,n*(i+1)-1)=ext_coeff(n);
            elseif i==2
                r_layer(n*i)=layer(n,i);
                ext_layer(ichan,n*i)=ext_coeff(n);
            end      
        end
    end   
end
grid on 

hold off

figure(29)
subplot(1,2,2)
plot(ext_layer(wvl_plot==1,:),r_layer)
ylabel('Altitude [km]','FontSize',14)
xlabel('Aerosol Extinction [1/km]','FontSize',14)
set(gca,'FontSize',14)
title(sprintf('%2i/%2i/%2i %g-%g %s',month,day,year,UT_start,UT_end,' UT'),'FontSize',14);
%if strcmp(instrument,'AMES14#1') |  strcmp(instrument,'AMES14#1_2000') 
%   legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(4)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
%          num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(10)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
%end
if strcmp(instrument,'AMES14#1') |  strcmp(instrument,'AMES14#1_2000') 
   legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
          num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'),num2str(lambda(14),'%4.3f')  );
end
if strcmp(instrument,'AMES14#1_2001') 
   legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
          num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'),num2str(lambda(14),'%4.3f'));
end
if strcmp(instrument,'AMES6')
 legend('380.1','450.7','525.3','863.9','1020.7'	)
end
%legend('354 nm','380 nm','448 nm', '499 nm','525 nm','605 nm','675 nm','779 nm','864 nm','1019 nm','1240 nm', '1558 nm')
grid on