%Mie_integrate_dNdr.m
%calls mie2 to calculate Mie efficiency factors, asymmetry factor, and a,b
%calls phase2 to calculate S11 
%integrates over lognormal size distribution to calculate phase function, asymmetry parameter

clear
close all

degtorad=pi/180.;

flag_read_Dubovik_phase_C4='no';
flag_read_VAXfile='no';
flag_read_JWangfiles='no';

if strcmp(flag_read_Dubovik_phase_C4,'yes')
    fid=fopen('c:\My Documents\Russell Feb02 Diffuse corrections\Dubovik phase functions for Cheju C4.txt');
    fgetl(fid);
    [wvl_dubovik,ndata] = fscanf(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f',[15,1]);
    [data,ndata] = fscanf(fid,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f',[16,inf]);
    scatang_dubovik=data(1,:);
    phasefunc_dubovik=data(2:16,:);
    wvl_dubovik=[wvl_dubovik(1:12);wvl_dubovik(14:15)];
    phasefunc_dubovik=[phasefunc_dubovik(1:12,:);phasefunc_dubovik(14:15,:)];
    fclose(fid);
    
    scatang_min=0;
    scatang_max=180;
    figure(21)
    set(21,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0]) %cyan,blue,green,magenta,red
    subplot(2,1,1)
    semilogy(scatang_dubovik,phasefunc_dubovik,'.-')
    axis([scatang_min scatang_max .05 1000])
    set(gca,'ytick',[0.05 0.1 1 2 5 10 20 50 100 500 1000])
    set(gca,'FontSize',14)
    xlabel('Scattering angle, \theta (deg)','FontSize',14)
    ylabel('Dubovik scattering phase function','FontSize',14)
    legstring='';
    for j=1:length(wvl_dubovik),
        legstr(j,:)=sprintf('%6.3f ',wvl_dubovik(j));
        legstring=[legstring;legstr(j,:)];
    end
    legh=legend(legstring);
    set(legh,'Fontsize',12)
    titlestring='Case: Cheju-11Apr01-C4';
    title(titlestring,'FontSize',12)
    subplot(2,1,2)
    semilogy(scatang_dubovik,phasefunc_dubovik,'.-')
    axis([0 5 20 1000])
    set(gca,'ytick',[20 50 100 200 500 1000])
    grid on
    set(gca,'FontSize',14)
    xlabel('Scattering angle, \theta (deg)','FontSize',14)
    ylabel('Dubovik scattering phase function','FontSize',14)
    
    figure(22)
    jwl=3;
    %set(22,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0]) %cyan,blue,green,magenta,red
    semilogy(scatang_dubovik,phasefunc_dubovik(jwl,:),'c.-')
    hold on
    semilogy(scat_angle,P_discrete(jwl,:),'b.-')
    semilogy(scat_angle,P(jwl,:),'g.-')
    axis([0 5 20 1000])
    set(gca,'ytick',[20 50 100 500 1000])
    set(gca,'FontSize',14)
    xlabel('Scattering angle, \theta (deg)','FontSize',14)
    ylabel('Scattering phase function','FontSize',14)
    legh=legend('Dubovik','Livingston discrete','Livingston lognorm');
    set(legh,'Fontsize',12)
    titledub=sprintf('Case: Cheju-11Apr01-C4   wvl: %d nm',1000*lambda(jwl))
    title(titledub,'FontSize',12)
    
    figure(23)
    jwl=3;
    %set(22,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0]) %cyan,blue,green,magenta,red
    semilogy(scatang_dubovik,phasefunc_dubovik(jwl,:),'c.-')
    hold on
    semilogy(scat_angle,P_discrete(jwl,:),'b.-')
    semilogy(scat_angle,P(jwl,:),'g.-')
    axis([0 180 0.02 1000])
    set(gca,'ytick',[0.02 0.1 1 10 20 50 100 500 1000])
    set(gca,'FontSize',14)
    xlabel('Scattering angle, \theta (deg)','FontSize',14)
    ylabel('Scattering phase function','FontSize',14)
    legh=legend('Dubovik','Livingston discrete','Livingston lognorm');
    set(legh,'Fontsize',12)
    titledub=sprintf('Case: Cheju-11Apr01-C4   wvl: %d nm',1000*lambda(jwl))
    title(titledub,'FontSize',12)

end

ln10constant=log(10); %recall log(r)=log(10)*log10(r)
if strcmp(flag_read_JWangfiles,'yes')
    fid=fopen('c:\johnmatlab\JWang_ACEAsia_data\f11_dNdlog10D_JWang.txt');
    [data,ndata] = fscanf(fid,'%f%f%f%f',[4,inf]);
    fclose(fid);
    radius_JWang=0.001*data(1,:)/2;  %microns
    dNdlog10D(1,:)=data(2,:);  %boundary layer
    dNdlog10D(2,:)=data(3,:);  %pollution layer
    dNdlog10D(3,:)=data(4,:);  %free troposphere
    dNdr_JWang=dNdlog10D./(ones(3,1)*radius_JWang*ln10constant);
 
    fid=fopen('c:\johnmatlab\JWang_ACEAsia_data\f11_ref_index_JWang.txt');
    [data,ndata] = fscanf(fid,'%f%f%f%f%f%f%f',[7,inf]);
    fclose(fid);
    radius_JWang_rfr=0.001*data(1,:)/2;  %microns
    rfr_real(1,:)=data(2,:);   %boundary layer
    rfr_imag(1,:)=data(3,:);   %boundary layer
    rfr_real(2,:)=data(4,:);   %pollution layer
    rfr_imag(2,:)=data(5,:);   %pollution layer
    rfr_real(3,:)=data(6,:);   %pollution layer
    rfr_imag(3,:)=data(7,:);   %pollution layer

    idxpos=find(dNdr_JWang(1,:)>0);
    raduse_JWang_blay=radius_JWang_rfr(1,idxpos);
    dNdr_JWang_blay=dNdr_JWang(1,idxpos);
    dVdlnr_JWang_blay=(4/3)*pi*(raduse_JWang_blay.^4).*dNdr_JWang_blay;
    rfr_complex_blay=complex(rfr_real(1,idxpos),-rfr_imag(1,idxpos));

    idxpos=find(dNdr_JWang(2,:)>0);
    raduse_JWang_polllay=radius_JWang_rfr(1,idxpos);
    dNdr_JWang_polllay=dNdr_JWang(2,idxpos);
    dVdlnr_JWang_polllay=(4/3)*pi*(raduse_JWang_polllay.^4).*dNdr_JWang_polllay;
    rfr_complex_polllay=complex(rfr_real(2,idxpos),-rfr_imag(2,idxpos));

    idxpos=find(dNdr_JWang(3,:)>0);
    raduse_JWang_freetrop=radius_JWang_rfr(1,idxpos);
    dNdr_JWang_freetrop=dNdr_JWang(1,idxpos);
    dVdlnr_JWang_freetrop=(4/3)*pi*(raduse_JWang_freetrop.^4).*dNdr_JWang_freetrop;
    rfr_complex_freetrop=complex(rfr_real(3,idxpos),-rfr_imag(3,idxpos));
end

if strcmp(flag_read_VAXfile,'yes')
 %read data from vax MIEANGW2.FOR run
 fid=fopen('c:\johnmatlab\mie\beat_oct99\mie14300test.txt');
 %skip header line
 line = fgetl(fid);		%skip end-of-line character
 [data,ndata] = fscanf(fid,'%f%f%f%f%f%f%f%f%f%f',[10,inf]);
 fclose(fid);

 x_fact=data(1,:);
 Q_ext2=data(3,:);
 Q_sca2=data(4,:);
 Q_bks2=data(6,:);
 Q_4pibks2=data(7,:);
 Q_asym2=data(9,:);
 %end vax read
end

%==================================size distribution information=======================================
%lognormal size distribution
%N0=[1e4 0];        %
%r_mode=[0.1 0.3]; % Mode radius in micron
%sigma=[2.03 2];  % 
%N0=[15.87 4.2532];         %AW-N64...see MOMPHILFALL94TEST.DAT
%r_mode=[0.08 0.27]; 			%AW-N64
%sigma[1.537 1.363];  		%AW-N64 

%Cvtot=sum(N0);
%Cvfrac=[0.26 0.74];
%N0=Cvfrac*Cvtot;

flag_dVdr_params='yes';
sizedist_case='Beijing-24Mar01-C4';

%NEED TO CHECK ALL THE FOLLOWING TO MAKE SURE THAT number of wvls and number of scat param values are consistent

switch sizedist_case
    case 'Cheju-11Apr01-C1'
        N0=[0.1246 0.3543]; %Cheju 4/11/01 C1  Dubovik JAS2002
        r_mode=[0.0808 2.4843]; %Cheju 4/11/01 C1
        sigma=exp([0.3214 0.5776]); %Cheju 4/11/01 C1
        dVdlogr_discrete=[2.16E-02	1.79E-01	1.99E-01	4.31E-02	5.18E-03	1.12E-03	8.04E-04	1.80E-03	7.52E-03	2.72E-02	4.32E-02	5.21E-02	1.22E-01	1.92E-01	1.78E-01	2.40E-01	2.69E-01	1.32E-01	3.34E-02	8.55E-03	3.83E-03	3.70E-03]; %case C1 see spreadsheet EastAsiaDiffuse.xls 
        lambda_in=[0.354 0.380 0.440 0.451 0.499 0.525 0.606 0.675 0.778 0.865 0.942 1.020 1.059 1.24 1.56];
        lambda=[0.354 0.380 0.440 0.451 0.499 0.525 0.606 0.675 0.778 0.865 0.942 1.020 1.059 1.24 1.56];
        refrac_real=[1.33E+00	1.33E+00	1.33E+00	1.33E+00	1.35E+00	1.36E+00	1.40E+00	1.42E+00	1.46E+00	1.49E+00	1.49E+00	1.50E+00	1.50E+00	1.51E+00	1.54E+00]; %Cheju C1
        refrac_imag=-[2.28E-03	2.25E-03	2.20E-03	2.19E-03	2.15E-03	2.13E-03	2.06E-03	2.01E-03	2.11E-03	2.20E-03	2.20E-03	2.20E-03	2.20E-03	2.20E-03	2.20E-03]; %Cheju C1
        ssa=[9.27E-01	9.25E-01	9.24E-01	9.25E-01	9.28E-01	9.29E-01	9.35E-01	9.39E-01	9.41E-01	9.42E-01	9.45E-01	9.48E-01	9.49E-01	9.55E-01	9.63E-01]; %Cheju C1
        aod_Dubovik=[6.24E-01	5.68E-01	4.85E-01	4.77E-01	4.51E-01	4.39E-01	4.12E-01	3.97E-01	3.83E-01	3.76E-01	3.71E-01	3.66E-01	3.65E-01	3.60E-01	3.60E-01];  %Cheju C1
    case 'Cheju-11Apr01-C3'
        N0=[0.1246 0.3543]; %Cheju 4/11/01 C3=C1  Dubovik JAS2002
        r_mode=[0.0808 2.4843]; %Cheju 4/11/01 C3=C1
        sigma=exp([0.3214 0.5776]); %Cheju 4/11/01 C3=C1
        dVdlogr_discrete=[2.16E-02	1.79E-01	1.99E-01	4.31E-02	5.18E-03	1.12E-03	8.04E-04	1.80E-03	7.52E-03	2.72E-02	4.32E-02	5.21E-02	1.22E-01	1.92E-01	1.78E-01	2.40E-01	2.69E-01	1.32E-01	3.34E-02	8.55E-03	3.83E-03	3.70E-03]; %case C1 see spreadsheet EastAsiaDiffuse.xls 
        lambda_in=[0.354 0.380 0.440 0.451 0.499 0.525 0.606 0.675 0.778 0.865 0.942 1.020 1.059 1.24 1.56];
        lambda=[0.354 0.380 0.440 0.451 0.499 0.525 0.606 0.675 0.778 0.865 0.942 1.020 1.059 1.24 1.56];
        dVdlogr_discrete=[2.16E-02	1.79E-01	1.99E-01	4.31E-02	5.18E-03	1.12E-03	8.04E-04	1.80E-03	7.52E-03	2.72E-02	4.32E-02	5.21E-02	1.22E-01	1.92E-01	1.78E-01	2.40E-01	2.69E-01	1.32E-01	3.34E-02	8.55E-03	3.83E-03	3.70E-03]; %case C3
        refrac_real=[1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00]; %C3
        refrac_imag=-[2.90E-03	2.72E-03	2.30E-03	2.22E-03	1.89E-03	1.70E-03	1.15E-03	6.98E-04	6.46E-04	6.03E-04	6.00E-04	6.00E-04	6.00E-04	6.00E-04	6.00E-04]; %C3
        ssa=[9.41E-01	9.40E-01	9.40E-01	9.41E-01	9.45E-01	9.49E-01	9.63E-01	9.77E-01	9.80E-01	9.83E-01	9.84E-01	9.85E-01	9.85E-01	9.87E-01	9.89E-01]; %C3
        aod_Dubovik=[9.94E-01	8.68E-01	6.69E-01	6.42E-01	5.51E-01	5.13E-01	4.41E-01	4.08E-01	3.83E-01	3.73E-01	3.67E-01	3.62E-01	3.61E-01	3.56E-01	3.58E-01];    
    case 'Cheju-11Apr01-C4'
        N0=[0.043837 0.4382353]; %Cheju 4/11/01 C4  Dubovik JAS2002
        r_mode=[0.09178916 3.065843]; %Cheju 4/11/01 C4
        sigma=exp([0.564998 0.705641]); %Cheju 4/11/01 C4
        dVdlogr_discrete=[3.44E-02	3.42E-02	3.40E-02	3.14E-02	6.73E-03	4.79E-03	4.43E-03	4.39E-03	7.04E-03	1.74E-02	3.49E-02	7.29E-02	2.06E-01	1.84E-01	1.28E-01	1.46E-01	2.18E-01	2.68E-01	2.11E-01	9.80E-02	2.58E-02	3.97E-03]; %case C4
        lambda_in=[0.354 0.380 0.440 0.451 0.499 0.525 0.606 0.675 0.778 0.865 0.942 1.020 1.059 1.24 1.56];
        lambda=[0.354 0.380 0.440 0.451 0.499 0.525 0.606 0.675 0.778 0.865 0.942 1.020 1.059 1.24 1.56];
        refrac_real=[1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00]; %Cheju C4
        refrac_imag=-[2.90E-03	2.72E-03	2.30E-03	2.22E-03	1.89E-03	1.70E-03	1.15E-03	6.98E-04	6.46E-04	6.03E-04	6.00E-04	6.00E-04	6.00E-04	6.00E-04	6.00E-04]; %Cheju C4
        ssa=[8.65E-01	8.73E-01	8.93E-01	8.96E-01	9.12E-01	9.20E-01	9.46E-01	9.67E-01	9.72E-01	9.75E-01	9.77E-01	9.78E-01	9.78E-01	9.80E-01	9.83E-01]; %Cheju C4
        aod_Dubovik=[5.73E-01	5.37E-01	4.76E-01	4.68E-01	4.38E-01	4.25E-01	4.01E-01	3.92E-01	3.81E-01	3.75E-01	3.71E-01	3.70E-01	3.70E-01	3.80E-01	4.03E-01];
    case 'Cheju-11Apr01 spheroid'
        N0=[0.029841	0.293469]; %Cheju 4/11/01 C4  Dubovik e-mail excel sheet 8/28/02
        r_mode=[0.147604	2.461077]; %Cheju 4/11/01 C4 Dubovik e-mail excel sheet 8/28/02
        sigma=exp([0.698626	0.591604]); %Cheju 4/11/01 C4 Dubovik e-mail excel sheet 8/28/02
        dVdlogr_discrete=[0.01038	0.013265	0.014109    0.01313   0.011849	0.011273	0.01117 	0.011307	0.013386	0.022032	0.042785	0.067956	0.086462	0.111141	0.167445	0.239066	0.205987	0.091112	0.027933	0.009401	0.004835	0.004328]; %Cheju 4/11/01 C4 Dubovik e-mail excel sheet 8/28/02
        ssa_in=[0.909324	0.923026	0.919632	0.924386];%Cheju 4/11/01 C4 Dubovik e-mail excel sheet 8/28/02
        lambda=[0.354 0.380 0.440 0.451 0.499 0.525 0.606 0.675 0.778 0.865 0.942 1.020 1.059 1.24 1.56];
        lambda_in=[0.440    0.670   0.860   1.020];  %Dubovik e-mail excel sheet 8/28/02
        refrac_real_in=[1.59996     1.599993	1.554921	1.531169];   %Dubovik e-mail excel sheet 8/28/02     
        refrac_imag_in=-[0.003613	0.003362	0.004121	0.00434];   %Dubovik e-mail excel sheet 8/28/02     
        aod_Dubovik_in=[0.482648	0.400071	0.376931	0.359659]; %%Dubovik e-mail excel sheet 8/28/02
        refrac_real=interp1(lambda_in,refrac_real_in,lambda,'linear','extrap');
        refrac_imag=interp1(lambda_in,refrac_imag_in,lambda,'linear','extrap');
        ssa=interp1(lambda_in,ssa_in,lambda,'linear','extrap');
        aod_Dubovik=exp(interp1(log(lambda_in),log(aod_Dubovik_in),log(lambda),'linear','extrap'));
    case 'Beijing-24Mar01-C4'
        N0=[0.094186 3.386443]; %Beijing 3/24/01 C4  
        r_mode=[0.109932 4.62816]; %Beijing 3/24/01 C4
        sigma=exp([0.67893 0.719479]); %Beijing 3/24/01 C4
        dVdlogr_discrete=[0.06029 0.06189	0.06244	0.05906	0.02115	0.01668	0.01593	0.01633	0.03300	0.07965	0.11687	0.27751	1.48245	0.46037	0.23038	0.33175	0.80685	1.96454	3.68595	2.44229	0.49937	0.09012]; %case C4 Beijing
        lambda=[0.354 0.380 0.440 0.451 0.499 0.525 0.606 0.675 0.778 0.865 0.942 1.020 1.059 1.24 1.56];
        refrac_real=[1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00	1.48E+00]; %Beijing C4
        refrac_imag=-[2.90E-03	2.72E-03	2.30E-03	2.22E-03	1.89E-03	1.70E-03	1.15E-03	6.98E-04	6.46E-04	6.03E-04	6.00E-04	6.00E-04	6.00E-04	6.00E-04	6.00E-04]; %Beijing C4
        ssa=[8.55E-01	8.63E-01	8.82E-01	8.86E-01	9.02E-01	9.12E-01	9.42E-01	9.66E-01	9.72E-01	9.75E-01	9.77E-01	9.78E-01	9.79E-01	9.82E-01	9.87E-01]; %Beijing C4
        aod_Dubovik=[2.25E+00	2.18E+00	2.08E+00	2.06E+00	2.00E+00	1.97E+00	1.95E+00	1.97E+00	1.94E+00	1.89E+00	1.86E+00	1.85E+00	1.86E+00    1.96E+00	2.17E+00]; %Russell excel spreadsheet    
    end

aod_Dubovik_in=aod_Dubovik;  %DON'T USE FOR 11APR01-SPHEROID
titlestring=sprintf('Case: %s\n',sizedist_case);

%================================ interpolation =====================================
%if length(lambda)~=length(lambda_in)
 %refrac_real_in=refrac_real;
 %refrac_imag_in=refrac_imag;
 %ssa_in=ssa;
 %aod_Dubovik_in=aod_Dubovik;
 %clear refrac_real refrac_imag ssa aod_Dubovik;
 %refrac_real=interp1(lambda_in,refrac_real_in,lambda,'linear','extrap')
 %refrac_imag=interp1(lambda_in,refrac_imag_in,lambda,'linear','extrap')
 %ssa=interp1(lambda_in,ssa_in,lambda,'linear','extrap')
 %aod_Dubovik=exp(interp1(log(lambda_in),log(aod_Dubovik_in),log(lambda),'linear','extrap'));
 %else
 %aod_Dubovik_in=aod_Dubovik;
 %end
%================================end other wavelength and refractive index info=================================

%following few lines restrict calculations to lambdause wavelengths
flag_onewvlonly='no';
if strcmp(flag_onewvlonly,'yes')
    lambdause=[0.440];  %one wavelength only
    jlambdause=find(lambdause==lambda);
    if isempty(jlambdause) stophere_nowvl; end
    lambda=lambda(jlambdause);
    refrac_real=refrac_real(jlambdause);
    refrac_imag=refrac_imag(jlambdause);
    ssa=ssa(jlambdause);
end

%calculate complex refractive index,k,radius values for Mie scatt calcs
refrac_idx_wvl=complex(refrac_real,refrac_imag);
k=2*pi./lambda;
r_min=0.01; % minimum radius
r_max=20;  %5;   % maximum radius
n_rad=800; %200; % number of radii
radius=logspace(log10(r_min), log10(r_max), n_rad);% radius vector equally spaced in log r

rad_sizedist_discrete=[0.05	0.066	0.086	0.113	0.148	0.194	0.255	0.335	0.439	0.576	0.756	0.992	1.302	1.708	2.241	2.94	3.857	5.061	6.641	8.713	11.432	15];
%convert dVdlogr_discrete to dNdr_discrete
dNdr_discrete=3*dVdlogr_discrete./(4*pi*rad_sizedist_discrete.^4);
%interpolate in log-log dNdr vs r space to calculate dNdr at Mie radius values
dNdr_discrete_interp = exp(interp1(log(rad_sizedist_discrete),log(dNdr_discrete),log(radius),'linear'));
%calculate dVdlogr from interpolated dNdr_discrete_interp values
dVdlogr_discrete_interp=4*pi*radius.^4.*dNdr_discrete_interp/3;
%for subsequent extinction calculations, find only those indices for which dNdr_discrete_interp is finite (i.e., not=NaN)
idx_discrete=find(isfinite(dNdr_discrete_interp));

%parameterized size distribution 
[dNdr]=lognorm(radius,N0,r_mode,sigma);
if strcmp(flag_dVdr_params,'yes')
 dVdr=dNdr;
 dVdlogr=radius.*dVdr;
 dNdr=3*dNdr./(4*pi*radius.^3);  %use where N0,r_mode,sigma are for dV/dr
end
%================================end size distribution information=====================================

%define scat_angle for Mie scatt scattering intensity calculations
%scat_angle=[0:180]; 
%use following for plotting
%scat_angle=[[0:0.05:2.0] [2.25:0.25:3.0] [4:1:5]]; 
%use following in order to get diffuse light correction factor
scat_angle=[[0:0.05:2.0] [2.25:0.25:3.0] [4:1:99] [101:179] [180]]; 
%scat_angle=[[0:0.05:2.0] [2.25:0.25:3.0] [4:1:5]]; %reduced set to 5 deg only
fov_angle=1.85;  %for AATS
idx_fovang=find(scat_angle<=fov_angle);

%..........Mie scattering calculations............
   %x1=[0.01:.01:2];
   %x2=[2.02:.02:10];
   %x3=[10.05:.05:50];
   %x4=[50.1:.1:150];
   %x5=[151:1:300];
   %x=[x1 x2 x3 x4 x5];
   %n_rad=length(x);
   %x=x';
   %radius=x.*lambda(1)/(2*pi);

   x=mie_par(radius,lambda);
   for irad=1:n_rad,
     for ilambda=1:length(lambda),
        refrac_idx=refrac_idx_wvl(ilambda);
        N=mie_test(x(irad,ilambda));
          if isnan(N)
             N=40;
          end
        N=N+10;
        [Q_ext(irad,ilambda),Q_scat(irad,ilambda),Q_bks(irad,ilambda),...
              gasym(irad,ilambda),a,b]=mie2(x(irad,ilambda),refrac_idx,N);
        
        %scattering intensity calculation for subsequent phase function calculation
		  %[S11(irad,:)]=phase2(a,b,x(irad,ilambda),N,scat_angle);
		  [S11(:,irad,ilambda),S12]=phase2(a,b,x(irad,ilambda),N,scat_angle);
     end
   end
%..................................................

%Integration over size distribution to calculate phase function,extinction,backscatter,asym
sinscatang_rad=sin(deg2rad(scat_angle));  %sin(theta) in radians
scatang_rad=deg2rad(scat_angle);    %scattering angles in radians
for iwl=1:length(lambda),
    
 %calculate phase function...note normalization by 4*pi   
  %P=trapz(radius,S11.*(ones(size(scat_angle))'*dNdr')')./...
  %trapz(radius,(ones(size(scat_angle))'*(k.^2*pi*radius.^2.*Q_scat.*dNdr)')');
  scatint=S11(:,:,iwl)';
  P(iwl,:)=4*pi*trapz(radius,scatint.*(dNdr'*ones(size(scat_angle))))./...
   trapz(radius,(k(iwl).^2*pi*radius'.^2.*Q_scat(:,iwl).*dNdr')*ones(size(scat_angle)));  %note factor of 4*pi added 8/02 to agree with Russell diffuse stuff
 
  P_discrete(iwl,:)=4*pi*trapz(radius(idx_discrete),scatint(idx_discrete,:).*(dNdr_discrete_interp(idx_discrete)'*ones(size(scat_angle))))./...
   trapz(radius(idx_discrete),(k(iwl).^2*pi*radius(idx_discrete)'.^2.*Q_scat(idx_discrete,iwl).*dNdr_discrete_interp(idx_discrete)')*ones(size(scat_angle)));  %note factor of 4*pi added 8/02 to agree with Russell diffuse stuff

 %calculate diffuse light correction factor
  P_deltaomega_numerator=trapz(scatang_rad(idx_fovang),sinscatang_rad(idx_fovang).*P(iwl,idx_fovang));
  P_deltaomega_denominator=trapz(scatang_rad,sinscatang_rad.*P(iwl,:));
  extinct_frac=ssa(iwl)*(P_deltaomega_numerator./P_deltaomega_denominator);
  corr_factor_diffuse(iwl)=1./(1.-extinct_frac);

 %calculate diffuse light correction factor for discrete phase function
  P_deltaomega_numerator=trapz(scatang_rad(idx_fovang),sinscatang_rad(idx_fovang).*P_discrete(iwl,idx_fovang));
  P_deltaomega_denominator=trapz(scatang_rad,sinscatang_rad.*P_discrete(iwl,:));
  extinct_frac=ssa(iwl)*(P_deltaomega_numerator./P_deltaomega_denominator);
  corr_factor_diffuse_discrete(iwl)=1./(1.-extinct_frac);

 %calculate extinction and backscatter
  extinction(iwl)=trapz(radius,pi*radius'.^2.*Q_ext(:,iwl).*dNdr');  %[km^-1] 1.e-03*
  extinction_discrete(iwl)=trapz(radius(idx_discrete),pi*radius(idx_discrete)'.^2.*Q_ext(idx_discrete,iwl).*dNdr_discrete_interp(idx_discrete)');  %[km^-1] 1.e-03*
  backscatter(iwl)=trapz(radius,pi*radius'.^2.*Q_bks(:,iwl).*dNdr');  %[km^-1 sr^-1] 1.e-03*

 %calculate ssa
  ssacalc(iwl)=trapz(radius,pi*radius'.^2.*Q_scat(:,iwl).*dNdr')/trapz(radius,pi*radius'.^2.*Q_ext(:,iwl).*dNdr');

 %integrate P*sin(theta) over all scat angles from 0 to pi; result should = 2
  Pint_check(iwl)=trapz(scatang_rad,sinscatang_rad.*P(iwl,:));
  Pint_discrete_check(iwl)=trapz(scatang_rad,sinscatang_rad.*P_discrete(iwl,:));
end

%Integration over size distribution to calculate asymmetry parameter
%asym_sizedis=trapz(radius,radius.^2.*Q_scat.*gasym.*dNdr)/...
   %trapz(radius,radius.^2.*Q_scat.*dNdr);

figure(1)
subplot(1,2,1)
loglog(radius,dNdr,'g.-')
hold on
loglog(rad_sizedist_discrete,dNdr_discrete,'ro-')
loglog(radius,dNdr_discrete_interp,'b.')
axis([0.01 20 1e-08 1e4])
xlabel('Radius (\mum)','FontSize',14)
%ylabel('dNdr (cm^{-3} \mum^{-1})','FontSize',14)
ylabel('dNc/dr (\mum^{-3})','FontSize',14)
set(gca,'Xtick',[.01 .1 1.0 10 20])
set(gca,'FontSize',14)
grid on
subplot(1,2,2)
semilogx(radius,dVdlogr,'g.-')
hold on
semilogx(rad_sizedist_discrete,dVdlogr_discrete,'ro-')
semilogx(radius,dVdlogr_discrete_interp,'b.')
axis([0.01 20 -inf inf])
xlabel('Radius (\mum)','FontSize',14)
%ylabel('dVdlogr (\mum^{3} cm^{-3})','FontSize',14)
ylabel('dVc/dlogr (\mum^{3} \mum^{-2})','FontSize',14)
set(gca,'Xtick',[.01 .1 1.0 10 20])
set(gca,'FontSize',14)
grid on
title(titlestring,'FontSize',12)

plot_asym='no';
if strcmp(plot_asym,'yes')
figure(2)
plot(x,gasym,'b.-');
%hold on
%plot(x_fact,Q_asym2,'g.-')
axis([0 30 0 1])
xlabel('Mie size parameter')
ylabel('Mie asymmetry factor')
end
end

plot_Qext='no';
if strcmp(plot_Qext,'yes')
figure(3)
set(3,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 0;0 0 0]) %cyan,blue,green,red,black
%semilogy(x,Q_scat,'m.');
%semilogy(x,Q_ext,'b.');
semilogx(radius,Q_ext,'.');
hold on
%semilogy(x_fact,Q_ext2,'g.');
%semilogy(x,Q_bks/(4*pi),'r.');
%semilogy(x_fact,Q_bks2,'k.');
axis([.01 20 1e-6 5])
%xlabel('Mie size parameter')
set(gca,'FontSize',14)
xlabel('Radius (\mum)','FontSize',14)
ylabel('Mie extinction efficiency factors','FontSize',14)
legstring='';
for j=1:length(lambda),
 legstr(j,:)=sprintf('%6.3f ',lambda(j));
 legstring=[legstring;legstr(j,:)];
end
legh=legend(legstring);
set(legh,'Fontsize',12)
title(titlestring)

figure(13)
set(13,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 0;0 0 0]) %cyan,blue,green,red,black
%semilogy(x,Q_scat,'m.');
%semilogy(x,Q_ext,'b.');
semilogx(radius(idx_discrete),Q_ext(idx_discrete,:),'.');
hold on
%semilogy(x_fact,Q_ext2,'g.');
%semilogy(x,Q_bks/(4*pi),'r.');
%semilogy(x_fact,Q_bks2,'k.');
axis([.01 20 1e-6 5])
%xlabel('Mie size parameter')
set(gca,'FontSize',14)
xlabel('Radius (\mum)','FontSize',14)
ylabel('Mie extinction efficiency factors (idx discrete)','FontSize',14)
legstring='';
for j=1:length(lambda),
 legstr(j,:)=sprintf('%6.3f ',lambda(j));
 legstring=[legstring;legstr(j,:)];
end
legh=legend(legstring);
set(legh,'Fontsize',12)
title(titlestring)
end

scatang_min=0;
scatang_max=5;
figure(4)
set(4,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0]) %cyan,blue,green,magenta,red
subplot(2,1,1)
semilogy(scat_angle,P,'.-')
axis([scatang_min scatang_max 20 3000])
grid on
set(gca,'ytick',[20 50 100 200 300 400 500 1000 2000 3000])
%axis([scatang_min scatang_max 1 7])
%set(gca,'ytick',[1 2 3 4 5 6 7])
set(gca,'FontSize',14)
xlabel('Scattering angle, \theta (deg)','FontSize',14)
ylabel('Scattering phase function, P(\theta)','FontSize',14)
legstring='';
for j=1:length(lambda),
 legstr(j,:)=sprintf('%6.3f ',lambda(j));
 legstring=[legstring;legstr(j,:)];
end
legh=legend(legstring);
set(legh,'Fontsize',12)
title(titlestring,'FontSize',12)
subplot(2,1,2)
plot(scat_angle,ones(length(lambda),1)*sin(deg2rad(scat_angle)).*P,'.-')
grid on
axis([scatang_min scatang_max 0 15])
set(gca,'FontSize',14)
xlabel('Scattering angle, \theta (deg)','FontSize',14)
ylabel('sin(\theta)*P(\theta)','FontSize',14)

scatang_min=0;
scatang_max=5;
jwluse=[1:length(lambda)];
figure(5)
set(5,'DefaultAxesColorOrder',[0 0 1;0 1 0]) %blue,green
%set(5,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0]) %cyan,blue,green,magenta,red
%subplot(2,1,1)
for kwl=1:length(jwluse),
 jwl=jwluse(kwl);
 semilogy(scat_angle,P_discrete(jwl,:),'b.-')
 hold on
 semilogy(scat_angle,P(jwl,:),'g.-')
end
axis([scatang_min scatang_max 20 1000])
grid on
set(gca,'ytick',[20 50 100 200 300 400 500 1000])
%axis([scatang_min scatang_max 1 7])
%set(gca,'ytick',[1 2 3 4 5 6 7])
set(gca,'FontSize',14)
xlabel('Scattering angle, \theta (deg)','FontSize',14)
ylabel('Scattering phase function, P(\theta)','FontSize',14)
%title(sprintf('wvl: %6.3f microns',lambda(jwluse)));
legstring='';
legstring=[sprintf('%s','discrete');sprintf('%s','lognorm ')];
legh=legend(legstring);
set(legh,'Fontsize',12)
title(titlestring,'FontSize',12)

figure(6)
loglog(lambda,extinction_discrete,'bo-')
hold on
loglog(lambda,extinction,'gd-')
loglog(lambda,aod_Dubovik_in,'rx-')
axis([0.3 1.6 0.1 1])
axis([0.3 1.6 1.5 2.5])
set(gca,'xtick',[0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6])
%set(gca,'ytick',[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0])
%set(gca,'ytick',[0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2])
set(gca,'ytick',[1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5])
grid on
set(gca,'FontSize',14)
ylabel('Aerosol Optical Depth','FontSize',14)
xlabel('Wavelength (\mum)','FontSize',14)
title(titlestring,'FontSize',12)
legstring='';
legstring=[sprintf('%s','discLiv ');sprintf('%s','lognorm ');;sprintf('%s','discDubo')];
legh=legend(legstring);
set(legh,'Fontsize',12)

figure(7)
semilogx(lambda,corr_factor_diffuse_discrete,'bo-')
hold on
semilogx(lambda,corr_factor_diffuse,'gd-')
%axis([0.3 1.6 1.0 1.1])
axis([0.3 1.6 1.0 1.2])
set(gca,'xtick',[0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6])
xlabel('Wavelength (\mum)','FontSize',14)
ylabel('Diffuse light correction factor for AATS','FontSize',14)
set(gca,'FontSize',14)
grid on
title(titlestring,'FontSize',12)
legstring='';
legstring=[sprintf('%s','discrete');sprintf('%s','lognorm ')];
legh=legend(legstring);
set(legh,'Fontsize',12)

figure(8)
set(8,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 0;0 0 0]) %cyan,blue,green,red,black
semilogx(lambda,ssa,'ro-')
%semilogx(lambda_in,ssa_in,'ro-')
hold on
semilogx(lambda,ssacalc,'bo-')
axis([0.3 1.6 0.84 1])
set(gca,'xtick',[0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6])
set(gca,'ytick',[0.84 0.86 0.88 0.90 0.92 0.94 0.96 0.98 1.00])
grid on
set(gca,'FontSize',14)
ylabel('Single Scattering Albedo','FontSize',14)
xlabel('Wavelength (\mum)','FontSize',14)
legh=legend('Dubovik','Livingston');
set(legh,'FontSize',12)
title(titlestring,'FontSize',12)

figure(9)
set(9,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 0;0 0 0]) %cyan,blue,green,red,black
subplot(2,1,1)
%semilogx(lambda_in,refrac_real_in,'rx-')
%set(gca,'MarkerSize',6)
%hold on
semilogx(lambda,refrac_real,'bo-')
%semilogx(lambda_in,refrac_real_in,'xo-')
axis([0.3 1.6 1.3 1.65])
set(gca,'xtick',[0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6])
set(gca,'ytick',[1.3 1.35 1.4 1.45 1.5 1.55 1.6 1.65])
grid on
set(gca,'FontSize',14)
xlabel('Wavelength (\mum)','FontSize',14)
ylabel('Real Refractive Index','FontSize',14)
%legh=legend('input','interpolated');
%set(legh,'FontSize',12)
title(titlestring,'FontSize',12)
subplot(2,1,2)
%semilogx(lambda_in,refrac_imag_in,'rx-')
%hold on
semilogx(lambda,refrac_imag,'bo-')
%axis([0.3 1.6 -.006 -.003])
axis([0.3 1.6 -.004 0])
grid on
%set(gca,'xtick',[0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6])
%set(gca,'ytick',[-.006 -.005 -.004 -.003])
set(gca,'ytick',[-.004 -.003 -.002 -.001 0])
grid on
set(gca,'FontSize',14)
ylabel('Imaginary Refractive Index','FontSize',14)
xlabel('Wavelength (\mum)','FontSize',14)


alpha_3801020=-log(extinction_discrete(12)/extinction_discrete(2))/log(lambda(12)/lambda(2));
alpha_5001020=-log(extinction_discrete(12)/extinction_discrete(5))/log(lambda(12)/lambda(5));
alpha_8651020=-log(extinction_discrete(12)/extinction_discrete(10))/log(lambda(12)/lambda(10));
alpha_10201558=-log(extinction_discrete(15)/extinction_discrete(12))/log(lambda(15)/lambda(12));
lambda550=0.550;
corrfact_550=interp1(lambda,corr_factor_diffuse_discrete,lambda550,'linear','extrap');

filewrpath='c:\My Documents\Russell Feb02 Diffuse Corrections\';
filewrite=strcat(filewrpath,'Mieintg-',sizedist_case,'.txt');
fidw=fopen(filewrite,'w')
fprintf(fidw,'%s\n',sizedist_case);
fprintf(fidw,'wvl refrac_real refrac_imag C_minus_one AOD_Livingston AOD_Dubovik ssa_Livingston ssa_Dubovik\n');
for i=1:length(lambda),
 fprintf(fidw,'%6.4f %6.3f %6.4f %6.3f %6.3f %6.3f %6.3f %6.3f\n',lambda(i),real(refrac_idx_wvl(i)),imag(refrac_idx_wvl(i)),corr_factor_diffuse_discrete(i)-1,...
     extinction_discrete(i),aod_Dubovik(i),ssa(i),ssacalc(i));
end
fprintf(fidw,'alpha3801020 alpha5001020 alpha8651020 alpha10201558\n');
fprintf(fidw,'%6.3f %6.3f %6.3f %6.3f\n',alpha_3801020,alpha_5001020,alpha_8651020,alpha_10201558);
fclose(fidw)