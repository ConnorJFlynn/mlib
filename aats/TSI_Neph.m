close all
clear all
% %read in smps data
[r_raw,dNdr,r_low,r_high,filename]=read_SMPS;

%interpolate on fine grid
N_points=200;
%%r_low=0.007; %lower radius limit in microns
r_low=0.150; %lower radius limit in microns
% r_high=r_high;
r=linspace(r_low, r_high, N_points);
dNdr_fine = INTERP1(r_raw,dNdr,r,'nearest','extrap');
figure(1)
plot(r,dNdr_fine,'-',r_raw,dNdr,'.-');
text(100,10,filename)

%get rid of raw values
dNdr=dNdr_fine;


% r=linspace(0.3, 0.4, 200);
% [dNdr]=lognorm(r,1,0.3505,0.0045,1);
% filename='lognorm D=700 nm NIST'
% 
% r=linspace(0.2, 0.3, 200);
% [dNdr]=lognorm(r,1,0.2495,0.00325,1);
% filename='lognorm D=500 nm NIST'
% 
% r=linspace(0.15, 0.35, 300);
% [dNdr]=lognorm(r,1,0.2575,0.05,1);
% filename='lognorm D=500 nm broad'


N_part=trapz(r,dNdr) %Total Number


dNdr=dNdr/N_part; %normalize to one particle/cm3
dSdr=4*pi*r.^2.*dNdr; %Area


%ideal scattering spectrum
lambda_p=[0.3:0.010:1.6];

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

lambda_use=lambda_p([16,26,40,41,126])
scat_use=scat_p([16,26,40,41,126])

figure(3)
% plot scattering spectrum
loglog(lambda_p,scat_p,'.-')
title(filename)
set(gca,'ylim',[1 10]);
set(gca,'xlim',[.30 1.6]);
set(gca,'xtick',[0.3 0.4,0.5,0.6,0.7,0.8 .9 1 1.1 1.2 1.3 1.4 1.5 1.6]);
xlabel('Wavelength [\mum]')
ylabel('\sigma_s [Mm^-^1]')
grid on

%define scattering angles
scat_angle=[0:0.25:180]; 
sinscatang_rad=sin(deg2rad(scat_angle));  %sin(theta) in radians
scatang_rad=deg2rad(scat_angle);    %scattering angles in radians

%read in Nephelometer filter functions 
[wvl450,wvl550,wvl700,response450,response550,response700]=read_TSI_filter;
lambda_TSI=[.450,.550,.700];

for i_channel=1:3
    switch i_channel
        case 1
            wvl=wvl450;
            response=response450;
        case 2
            wvl=wvl550;
            response=response550;
        case 3
            wvl=wvl700;
            response=response700;
    end

   
%ideal nephelometer
lambda=lambda_TSI(i_channel);
m=polystyrene(lambda); % PSL spheres
%m=1.0003; % AIR
x=mie_par(r,lambda);
N=mie_test(x);
[Q_ext_ideal,Q_scat_ideal,a,b]=mie(x,m,N);
  
%loop over filter-wavelengths
S11=[];S12=[];x=[];
for  i_wvl=1:length(wvl)
    lambda=wvl(i_wvl) %microns
    m=polystyrene(lambda); % PSL spheres
    %m=1.0003; % aIR
    x(:,i_wvl)=mie_par(r,lambda);
    N=mie_test(x(:,i_wvl));
  
    [Q_ext,Q_scat,a,b]=mie(x(:,i_wvl),m,N);
      
    [S11(:,:,i_wvl),S12(:,:,i_wvl)]=phase2(a,b,x(:,i_wvl),N,scat_angle);
    
end
    
    % no truncation or illumination correction
    integ_ang=trapz(scatang_rad,repmat(sinscatang_rad, [length(x),1,length(wvl)]).*S11,2);
    integ_ang=squeeze(integ_ang);
    Q_scat_test=2.*integ_ang./x.^2;
    
    % integrate over filter 
    Q_scat_test2=2./(4*pi^2*r'.^2).*trapz(wvl,repmat(response,[length(x),1]).*integ_ang.*(repmat(wvl,[length(x),1]).^2),2); %don't know why I need a factor of 2
        
    % truncation and illumination correction
    [angle,f_ang_scat,f_ang_scat_sin,f_ang_bscat,f_ang_bscat_sin]=read_TSI_fangle; %read in angular sensitivity function of TSI neph
    
    f_ang_scat= INTERP1(angle,f_ang_scat,scat_angle,'linear');
    
    integ_ang=trapz(scatang_rad,repmat(f_ang_scat,[length(x),1,length(wvl)]).*S11,2);
    integ_ang=squeeze(integ_ang);
    Q_scat_test3=2.*integ_ang./x.^2;
    
    % integrate over filter 
    Q_scat_test4=2./(4*pi^2*r'.^2).*trapz(wvl,repmat(response,[length(x),1]).*integ_ang.*(repmat(wvl,[length(x),1]).^2),2); %don't know why I need a factor of 2
 
    figure(4)
    subplot(2,1,1)
    plot(r,Q_scat_test,r,Q_scat_test2,'k.')     
    subplot(2,1,2)
    plot(r,Q_scat_test3,r,Q_scat_test4,'k.')     
   
    figure(5)
    subplot(2,1,1)
    plot(r,Q_scat_ideal,r,Q_scat_test4)
    subplot(2,1,2)
    plot(r,Q_scat_ideal./Q_scat_test4)
    
  
    % scattering coefficient (with angular non-idealities)
    y=pi.*r.^2.*Q_scat_test4'.*dNdr;
    scat_trunc(i_channel)=trapz(r',y');

    % scattering coefficient for ideal nephelometer
    y=pi.*r.^2.*Q_scat_ideal'.*dNdr;
    scat_ideal(i_channel)=trapz(r',y');
    scat_ideal_cum=cumtrapz(r',y');
    
   
    figure(2)
    subplot(3,1,1)
    plot(r,dNdr,'-');
    title(filename)
    subplot(3,1,2)
    plot(r,dSdr,'-');
    subplot(3,1,3)
    plot(r,scat_ideal_cum./scat_ideal(i_channel));
end    

    %Correction factor
    Kr=[1.0985;1.1042;1.064]';
    scat_trunc=scat_trunc.*Kr
    corr=scat_ideal./scat_trunc
    alpha_450_550=-log(scat_trunc(1)/scat_trunc(2))/log(lambda_TSI(1)/lambda_TSI(2))
    alpha_450_700=-log(scat_trunc(1)/scat_trunc(3))/log(lambda_TSI(1)/lambda_TSI(3))
    alpha_550_700=-log(scat_trunc(2)/scat_trunc(3))/log(lambda_TSI(2)/lambda_TSI(3))

     figure(6)
    % plot scattering spectrum
    loglog(lambda_TSI,scat_ideal,'.-',lambda_TSI,scat_trunc,'.-')
    title(filename)
    set(gca,'ylim',[100 1000]);
    set(gca,'xlim',[.40 .8]);
    set(gca,'xtick',[0.4,0.5,0.6,0.7,0.8]);
    xlabel('Wavelength [\mum]')
    ylabel('\sigma_s [Mm^-^1]')
    grid on