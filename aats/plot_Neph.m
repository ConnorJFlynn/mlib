%compares Mie wit Neph
close all
clear all


% %read in smps data
% [r_raw,dNdr,r_low,r_high,filename]=read_SMPS;
% 
% %interpolate on fine grid
% N_points=200;
% %%r_low=0.007; %lower radius limit in microns
% r_low=0.150; %lower radius limit in microns
% % r_high=r_high;
% r=linspace(r_low, r_high, N_points);
% dNdr_fine = INTERP1(r_raw,dNdr,r,'nearest','extrap');
% %get rid of raw values
% dNdr=dNdr_fine;
% run='D=500 nm NIST PSS measured'
% N_part=trapz(r,dNdr) %Total Number
% dNdr=dNdr/N_part;


 run='lognorm D=300 nm NIST PSS'
 r=linspace(0.1, 0.2, 200);
 [dNdr]=lognorm(r,1,0.1495,0.00205,1);

% run='lognorm D=500 nm NIST PSS'
% r=linspace(0.2, 0.3, 200);
% [dNdr]=lognorm(r,1,0.2495,0.00325,1);

% run='lognorm D=700 nm NIST'
% r=linspace(0.3, 0.4, 200);
% [dNdr]=lognorm(r,1,0.3505,0.0045,1);

% run='lognorm D=900 nm NIST'
% r=linspace(0.4, 0.5, 200);
% [dNdr]=lognorm(r,1,0.4515,0.00465,1);

%ideal scattering spectrum
lambda_p=[0.3:0.005:1.6];
for i_channel=1:length(lambda_p);
    lambda=lambda_p(i_channel);
    m=polystyrene(lambda); % PSL spheres
    %m=1.0003; % AIR
    x=mie_par(r,lambda);
    N=mie_test(x);
    [Q_ext_p,Q_scat_p,a,b]=mie(x,m,N);
    
    % scattering coefficient for ideal instrument with many wavelengths
    y=pi.*r.^2.*Q_scat_p'.*dNdr;
    scat_p(i_channel)=trapz(r',y');
end

lambda_use=lambda_p([31,51,76,79,81,251]);
lambda_TSI=lambda_use([1,2,5])
scat_use=scat_p([31,51,76,79,81,251]);
scat_per_part=scat_use([1,2,5])
lambda_cadenza=lambda_use([3,4,6])
scat_per_part_cadenza=scat_use([3 4 6])

stop

%                450     550     700
scat_corr=     [1.1078	1.0621	1.0590] % D=500 nm NIST
%scat_corr=     [1.1110	1.0802	1.0785] % D=500 nm NIST smps measured size distribution


[dec_h,scat,bscat]=read_TSI_Neph; %read TSI Neph Data
scat_TSI_Neph=1e6*scat'.*repmat(scat_corr,[length(scat),1]); %convert to Mm-1 and correct for angular non-dealities

[Time,N]=read_cpc('c:\beat\data\strawa\','aux030219_00.csv'); %read CPC data
scat_Mie=repmat(N,[1,length(scat_per_part)]).*repmat(scat_per_part,[length(N),1]); %compute Mie scattering
scat_Mie_int=interp1(Time,scat_Mie,dec_h); %interpolate to TSI times
       N_int=interp1(Time,N       ,dec_h); %interpolate to TSI times

       
[time_690,VS_690,N_690,time_1550,N_1550,SigE_690,SigE_1550]=read_cadenza;
ext_Mie_690=N_690*scat_per_part_cadenza;

       
       
figure(1)    %plot scattering
plot(Time,scat_Mie,'.-')
hold on
plot(dec_h,scat_TSI_Neph)
plot(time_690,ext_Mie_690,'k.-',time_690,SigE_690,'k',time_690,(VS_690-0.018)*400,'m')
plot(time_1550,SigE_1550)
hold off
axis([-inf inf 0 60])
grid on
xlabel('Time(h)','Fontsize',14)
ylabel('\sigma_s (Mm^-^1)','Fontsize',14)
legend('Mie 450 nm','Mie 550 nm','Mie 700 nm','Neph 450 nm','Neph 550 nm','Neph 700 nm','Mie 690','CRD ext 690 nm','CRD scat 690 nm')
set(gca,'Fontsize',14)

%average over time period
[x,y] = GINPUT; %select period
 
ii=find(dec_h>=x(1) & dec_h<=x(2));
mean_N            =mean(N_int(ii))
mean_scat_TSI_Neph=mean(scat_TSI_Neph(ii,:))
mean_scat_Mie=mean(scat_Mie_int(ii,:))
ratio=mean_scat_TSI_Neph./mean_scat_Mie

figure(2)   %plot ratios
plot(dec_h,scat_TSI_Neph./scat_Mie_int)
axis([-inf inf 0.8 1])
grid on
xlabel('Time(h)','Fontsize',14)
ylabel('Ratio','Fontsize',14)
legend('450 nm','550 nm','700 nm')
set(gca,'Fontsize',14)

figure(3)
% plot scattering spectrum
loglog(lambda_p,scat_p,'.-',lambda_TSI,mean_scat_TSI_Neph/mean_N,'*')
title(run)
set(gca,'ylim',[0.1 1]);
set(gca,'xlim',[.30 1.6]);
set(gca,'xtick',[0.3 0.4,0.5,0.6,0.7,0.8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6]);
xlabel('Wavelength [\mum]','Fontsize',14)
ylabel('\sigma_s [Mm^-^1]','Fontsize',14)
grid on
set(gca,'Fontsize',14)

ratio_check=mean_scat_TSI_Neph./scat_per_part/mean_N

