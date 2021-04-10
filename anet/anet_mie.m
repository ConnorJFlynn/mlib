function [aod, ssa] = anet_mie(lambda,n_i, rm, M1, M2, M3)
%[aod, ssa] = anet_mie(lambda,n,rm, M1, M2, M3) with M1 = dVdlnr; 
% soon: anet_mie(lambda,n, rm, M1, M2, M3) with M2-4 as structs with .VolC .vmr and .std
% lambda (wavelength) and n_i (complex refractive indices) are of same length
% M1=rm and M2=dVdlnr are vectors of length [R] with rm (mean radius), and dVdlnr
% Coming soon, M1..M4 are alternately provided as struct with fields .vmr, (volume mean radius,.std (standard deviation from vmr)
% and .Vc volume concentration (um^3/um^2)

%Based on Mie_AERONET provided by Feng Xu, 2020-08-25 but generalized to
%accept ASD either as bin-wise size dist in dVdlnr or as a multi-mode
%log-normal with specified volume mean radius and std from vrm
% This permits demonstration of closure between AERONET optical properties (AOD and SSA) 
% and the underlying microphysics of the intensive property retrievals

%% AERONET product characteristics
% 20190815_20190820_ARM_SGP.rin
% Site,Date(dd:mm:yyyy),Time(hh:mm:ss),Day_of_Year,Day_of_Year(Fraction),Refractive_Index-Real_Part[440nm],Refractive_Index-Real_Part[675nm],Refractive_Index-Real_Part[870nm],Refractive_Index-Real_Part[1020nm],Refractive_Index-Imaginary_Part[440nm],Refractive_Index-Imaginary_Part[675nm],Refractive_Index-Imaginary_Part[870nm],Refractive_Index-Imaginary_Part[1020nm],Average_Solar_Zenith_Angles_for_Flux_Calculation(Degrees),Solar_Zenith_Angle_for_Measurement_Start(Degrees),Sky_Residual(%),Sun_Residual(%),Coincident_AOD440nm,Scattering_Angle_Bin_3.2_to_<6_degrees[440nm],Scattering_Angle_Bin_6_to_<30_degrees[440nm],Scattering_Angle_Bin_30_to_<80_degrees[440nm],Scattering_Angle_Bin_80_degrees_and_over[440nm],Scattering_Angle_Bin_3.2_to_<6_degrees[675nm],Scattering_Angle_Bin_6_to_<30_degrees[675nm],Scattering_Angle_Bin_30_to_<80_degrees[675nm],Scattering_Angle_Bin_80_degrees_and_over[675nm],Scattering_Angle_Bin_3.2_to_<6_degrees[870nm],Scattering_Angle_Bin_6_to_<30_degrees[870nm],Scattering_Angle_Bin_30_to_<80_degrees[870nm],Scattering_Angle_Bin_80_degrees_and_over[870nm],Scattering_Angle_Bin_3.2_to_<6_degrees[1020nm],Scattering_Angle_Bin_6_to_<30_degrees[1020nm],Scattering_Angle_Bin_30_to_<80_degrees[1020nm],Scattering_Angle_Bin_80_degrees_and_over[1020nm],Surface_Albedo[440m],Surface_Albedo[675m],Surface_Albedo[870m],Surface_Albedo[1020m],If_Retrieval_is_L2(without_L2_0.4_AOD_440_threshold),If_AOD_is_L2,Last_Processing_Date(dd:mm:yyyy),Last_Processing_Time(hh:mm:ss),Instrument_Number,Latitude(Degrees),Longitude(Degrees),Elevation(m),Inversion_Data_Quality_Level,Retrieval_Measurement_Scan_Type
% ARM_SGP,15:08:2019,21:46:45,227,227.907465,1.581700,1.584500,1.600000,1.600000,0.025597,0.021507,0.020917,0.020566,48.961938,48.379492,3.525587,0.360065,0.226023,3,10,8,4,3,11,7,4,3,11,7,4,4,10,7,4,0.060360,0.118960,0.292970,0.318170,0,1,26:02:2020,01:20:47,1031,36.605175,-97.485619,319.000000,lev15,Almucantar
% 20190815_20190820_ARM_SGP.siz
% Site,Date(dd:mm:yyyy),Time(hh:mm:ss),Day_of_Year,Day_of_Year(Fraction),0.050000,0.065604,0.086077,0.112939,0.148184,0.194429,0.255105,0.334716,0.439173,0.576227,0.756052,0.991996,1.301571,1.707757,2.240702,2.939966,3.857452,5.061260,6.640745,8.713145,11.432287,15.000000,Inflection_Radius_of_Size_Distribution(um),Average_Solar_Zenith_Angles_for_Flux_Calculation(Degrees),Solar_Zenith_Angle_for_Measurement_Start(Degrees),Sky_Residual(%),Sun_Residual(%),Coincident_AOD440nm,Scattering_Angle_Bin_3.2_to_<6_degrees[440nm],Scattering_Angle_Bin_6_to_<30_degrees[440nm],Scattering_Angle_Bin_30_to_<80_degrees[440nm],Scattering_Angle_Bin_80_degrees_and_over[440nm],Scattering_Angle_Bin_3.2_to_<6_degrees[675nm],Scattering_Angle_Bin_6_to_<30_degrees[675nm],Scattering_Angle_Bin_30_to_<80_degrees[675nm],Scattering_Angle_Bin_80_degrees_and_over[675nm],Scattering_Angle_Bin_3.2_to_<6_degrees[870nm],Scattering_Angle_Bin_6_to_<30_degrees[870nm],Scattering_Angle_Bin_30_to_<80_degrees[870nm],Scattering_Angle_Bin_80_degrees_and_over[870nm],Scattering_Angle_Bin_3.2_to_<6_degrees[1020nm],Scattering_Angle_Bin_6_to_<30_degrees[1020nm],Scattering_Angle_Bin_30_to_<80_degrees[1020nm],Scattering_Angle_Bin_80_degrees_and_over[1020nm],Surface_Albedo[440m],Surface_Albedo[675m],Surface_Albedo[870m],Surface_Albedo[1020m],If_Retrieval_is_L2(without_L2_0.4_AOD_440_threshold),If_AOD_is_L2,Last_Processing_Date(dd:mm:yyyy),Last_Processing_Time(hh:mm:ss),Instrument_Number,Latitude(Degrees),Longitude(Degrees),Elevation(m),Inversion_Data_Quality_Level,Retrieval_Measurement_Scan_Type
% ARM_SGP,15:08:2019,21:46:45,227,227.907465,0.000321,0.002708,0.010422,0.018989,0.018266,0.011193,0.005670,0.003155,0.002377,0.002548,0.003535,0.005525,0.008811,0.013720,0.020467,0.028187,0.032764,0.028586,0.017028,0.006553,0.001587,0.000240,0.439000,48.961938,48.379492,3.525587,0.360065,0.226023,3,10,8,4,3,11,7,4,3,11,7,4,4,10,7,4,0.060360,0.118960,0.292970,0.318170,0,1,26:02:2020,01:20:47,1031,36.605175,-97.485619,319.000000,lev15,Almucantar
% 20190815_20190820_ARM_SGP.aod tau_p_btAsl = 0.2304    0.1218    0.0843    0.0684
% Site,Date(dd:mm:yyyy),Time(hh:mm:ss),Day_of_Year,Day_of_Year(Fraction),AOD_Extinction-Total[440nm],AOD_Extinction-Total[675nm],AOD_Extinction-Total[870nm],AOD_Extinction-Total[1020nm],AOD_Extinction-Fine[440nm],AOD_Extinction-Fine[675nm],AOD_Extinction-Fine[870nm],AOD_Extinction-Fine[1020nm],AOD_Extinction-Coarse[440nm],AOD_Extinction-Coarse[675nm],AOD_Extinction-Coarse[870nm],AOD_Extinction-Coarse[1020nm],Extinction_Angstrom_Exponent_440-870nm-Total,Average_Solar_Zenith_Angles_for_Flux_Calculation(Degrees),Solar_Zenith_Angle_for_Measurement_Start(Degrees),Sky_Residual(%),Sun_Residual(%),Coincident_AOD440nm,Scattering_Angle_Bin_3.2_to_<6_degrees[440nm],Scattering_Angle_Bin_6_to_<30_degrees[440nm],Scattering_Angle_Bin_30_to_<80_degrees[440nm],Scattering_Angle_Bin_80_degrees_and_over[440nm],Scattering_Angle_Bin_3.2_to_<6_degrees[675nm],Scattering_Angle_Bin_6_to_<30_degrees[675nm],Scattering_Angle_Bin_30_to_<80_degrees[675nm],Scattering_Angle_Bin_80_degrees_and_over[675nm],Scattering_Angle_Bin_3.2_to_<6_degrees[870nm],Scattering_Angle_Bin_6_to_<30_degrees[870nm],Scattering_Angle_Bin_30_to_<80_degrees[870nm],Scattering_Angle_Bin_80_degrees_and_over[870nm],Scattering_Angle_Bin_3.2_to_<6_degrees[1020nm],Scattering_Angle_Bin_6_to_<30_degrees[1020nm],Scattering_Angle_Bin_30_to_<80_degrees[1020nm],Scattering_Angle_Bin_80_degrees_and_over[1020nm],Surface_Albedo[440m],Surface_Albedo[675m],Surface_Albedo[870m],Surface_Albedo[1020m],If_Retrieval_is_L2(without_L2_0.4_AOD_440_threshold),If_AOD_is_L2,Last_Processing_Date(dd:mm:yyyy),Last_Processing_Time(hh:mm:ss),Instrument_Number,Latitude(Degrees),Longitude(Degrees),Elevation(m),Inversion_Data_Quality_Level,Retrieval_Measurement_Scan_Type
% ARM_SGP,15:08:2019,21:46:45,227,227.907465,0.228200,0.119600,0.085100,0.070200,0.195100,0.084200,0.048300,0.032700,0.033100,0.035400,0.036800,0.037500,1.456166,48.961938,48.379492,3.525587,0.360065,0.226023,3,10,8,4,3,11,7,4,3,11,7,4,4,10,7,4,0.060360,0.118960,0.292970,0.318170,0,1,26:02:2020,01:20:47,1031,36.605175,-97.485619,319.000000,lev15,Almucantar
% 20190815_20190820_ARM_SGP.cad
% Site,Date(dd:mm:yyyy),Time(hh:mm:ss),Day_of_Year,Day_of_Year(Fraction),AOD_Coincident_Input[440nm],AOD_Coincident_Input[675nm],AOD_Coincident_Input[870nm],AOD_Coincident_Input[1020nm],Angstrom_Exponent_440-870nm_from_Coincident_Input_AOD,Average_Solar_Zenith_Angles_for_Flux_Calculation(Degrees),Solar_Zenith_Angle_for_Measurement_Start(Degrees),Sky_Residual(%),Sun_Residual(%),Coincident_AOD440nm,Scattering_Angle_Bin_3.2_to_<6_degrees[440nm],Scattering_Angle_Bin_6_to_<30_degrees[440nm],Scattering_Angle_Bin_30_to_<80_degrees[440nm],Scattering_Angle_Bin_80_degrees_and_over[440nm],Scattering_Angle_Bin_3.2_to_<6_degrees[675nm],Scattering_Angle_Bin_6_to_<30_degrees[675nm],Scattering_Angle_Bin_30_to_<80_degrees[675nm],Scattering_Angle_Bin_80_degrees_and_over[675nm],Scattering_Angle_Bin_3.2_to_<6_degrees[870nm],Scattering_Angle_Bin_6_to_<30_degrees[870nm],Scattering_Angle_Bin_30_to_<80_degrees[870nm],Scattering_Angle_Bin_80_degrees_and_over[870nm],Scattering_Angle_Bin_3.2_to_<6_degrees[1020nm],Scattering_Angle_Bin_6_to_<30_degrees[1020nm],Scattering_Angle_Bin_30_to_<80_degrees[1020nm],Scattering_Angle_Bin_80_degrees_and_over[1020nm],Surface_Albedo[440m],Surface_Albedo[675m],Surface_Albedo[870m],Surface_Albedo[1020m],If_Retrieval_is_L2(without_L2_0.4_AOD_440_threshold),If_AOD_is_L2,Last_Processing_Date(dd:mm:yyyy),Last_Processing_Time(hh:mm:ss),Instrument_Number,Latitude(Degrees),Longitude(Degrees),Elevation(m),Inversion_Data_Quality_Level,Retrieval_Measurement_Scan_Type
% ARM_SGP,15:08:2019,21:46:45,227,227.907465,0.226023,0.112446,0.086309,0.069658,1.437752,48.961938,48.379492,3.525587,0.360065,0.226023,3,10,8,4,3,11,7,4,3,11,7,4,4,10,7,4,0.060360,0.118960,0.292970,0.318170,0,1,26:02:2020,01:20:47,1031,36.605175,-97.485619,319.000000,lev15,Almucantar
if ~isavar('lambda')
lambda=[441, 673, 873, 1022];%% AERONET wavelength
end
if ~isavar('n_i')
n_i = [1.33	1.3557	1.3692	1.3702] + j.*[0.00187	0.001825	0.001824	0.001823];
end

% Default rm and M1 (dVdlr) just for testing
if ~isavar('rm')||isempty(rm)
rm=[0.05	0.065604	0.086077	0.112939	0.148184	0.194429	0.255105	0.334716	0.439173	0.576227	0.756052	0.991996	1.301571	1.707757	2.240702	2.939966	3.857452	5.06126	6.640745	8.713145	11.432287	15];
end
if ~isavar('M1')||isempty(M1)
  M1 = [0.000799	0.000783	0.001214	0.00283	0.008527	0.025265	0.052488	0.056106	0.03332	0.017428	0.011672	0.010808	0.012044	0.01447	0.017286	0.018461	0.017036	0.013154	0.008418	0.004531	0.002083	0.000823];
end
%% dVdlnr
% When actual SD is provided, it already incorporates VolC
% However, when computing from log-normal parameters we need to explicitly
% include it as below.  The effective volume concentration will depend on
% the log-spacing of dVdlr as below, below.
if ~isstruct(M1)&&(length(rm)==length(M1))
    dVdlnr = M1;
end
if isstruct(M1)&&isfield(M1,'vmr')&&isfield(M1,'std')
   dVdlnr = M1.VolC.*LnNormal(rm, M1.vmr, exp(M1.std));
end
if isavar('M2')&&isstruct(M2)&&isfield(M2,'vmr')&&isfield(M2,'std')
   dVdlnr = dVdlnr + M2.VolC.*LnNormal(rm, M2.vmr, exp(M2.std));
end
if isavar('M3')&& isstruct(M3)&&isfield(M3,'vmr')&&isfield(M3,'std')
   dVdlnr = dVdlnr + M3.VolC.*LnNormal(rm, M3.vmr, exp(M3.std));
end

bin_num=length(rm);
% del_lnr=mean(log(rm(2:end))-log(rm(1:end-1)));
del_lnr=mean(log(rm(2:end)./rm(1:end-1)));
%% get column concentration (um^3/um^2) 
Cv=dVdlnr*del_lnr; 
rm_arr=1e-6*rm;
% rBC_node_in_meter=1e-6*exp([log(rm(1))-del_lnr/2:del_lnr:log(rm(end))+del_lnr/2]);
rBC_node_in_meter=1e-6*exp([log(rm)-del_lnr/2,log(rm(end))+del_lnr/2]);
x=(pi*2*max(rBC_node_in_meter)/min(lambda*1e-9));
Na=1;
Nb=4.05;%22;
Nc=0.34;
Nd=8;%2;
N1=ceil(Na*x+Nb*x^Nc+Nd);
g_number=100;
for n_bin=1:bin_num
    [r,wtr]=lgwt(g_number,rBC_node_in_meter(n_bin),rBC_node_in_meter(n_bin+1));
    vr=log_normal_fun(rm_arr(n_bin),100,r); %% to creat a bin effect of dv/dlnr
    vr=vr/sum(wtr.*vr);    
    nv_save(:,n_bin)=vr; 
    %sum(wtr.*vr)
    %% convert to number weighted size distribution
    nr=vr./(4*pi*r.^3/3);
    n0_bin(n_bin)=sum(nr.*wtr); %% number of particles per volume particle bulk
    nr_save(:,n_bin)=nr/n0_bin(n_bin);

    r_save(n_bin,:)=r;
    wtr_save(n_bin,:)=wtr;    
end

Haerosol=2000; % aerosol layer thickness (unit: m)


Cvhere=Cv*1e-6/Haerosol;

fv=Cvhere/sum(Cvhere); 
Cn=Cvhere.*n0_bin;%number of particles per air volume
fn=Cn/sum(Cn);


for nd=1:length(lambda) 
    
%     mr=mr_arr(nd);
%     mi=mi_arr(nd);

    mr = real(n_i(nd)); 
    mi = imag(n_i(nd));
    
    for n_bin=1:bin_num
        r=r_save(n_bin,:);
        wtr=wtr_save(n_bin,:);
        nr=nr_save(:,n_bin)';
        LR=length(r);
        [SSA_p_bt(n_bin),kext_p_bt(n_bin)]=Phase_mat_common(lambda(nd)*1e-9,mr,mi,r,nr,wtr,LR,N1,Na,Nb,Nc,Nd);
    end

    %% extinction cross-section before truncation
    kext_p_bt_mixed=sum(fn.*kext_p_bt);
    ksca_p_bt_mixed=sum(fn.*kext_p_bt.*SSA_p_bt);
    SSA_p_bt_mixed(nd)=ksca_p_bt_mixed/kext_p_bt_mixed;

    Cn_allbin=sum(Cn);

    CHaerosol=Cn_allbin*Haerosol;
    kext_btAsl=kext_p_bt_mixed;
    tau_p_btAsl(nd)=CHaerosol*kext_btAsl;
end
aod = tau_p_btAsl;
ssa = SSA_p_bt_mixed;
return


function [SSA_p_bt,kext_bt]=Phase_mat_common(lamda0,m_r,m_i,r,nr,wtr,LR,N1,Na,Nb,Nc,Nd)
m_p=m_r+i*m_i;

[Qsca,Qext]=Sphere_Mie_Deri_Opt(lamda0,m_p,r,LR,N1,Na,Nb,Nc,Nd);        

pir2=pi*r.^2;
Interg_Core=pir2.*Qsca.*nr;
ksca=sum(Interg_Core.*wtr);

Interg_Core=pir2.*Qext.*nr;
kext_bt=sum(Interg_Core.*wtr);     
SSA_p_bt=ksca/kext_bt;
return


% A copy from function "Sphere_Mie_Deri", code optimized
function [Qsca,Qext]=Sphere_Mie_Deri_Opt(lamda0,m_in,R_in,LR,Nmax,Na,Nb,Nc,Nd)
m=m_in;      
anM(LR,Nmax)=0;    
bnM(LR,Nmax)=0;       
% ----------------
an(Nmax)=0;
bn(Nmax)=0;


for j=1:length(R_in)
    
    r=R_in(j);
    x=(pi*2*r/lamda0);
    y=m*x;
    % downward recursion
    N1=ceil(Na*x+Nb*x^Nc+Nd);
    % Lentz method to calculate Ln 
    Ly(N1)=fai(y,N1);
    Lx(N1)=fai(x,N1);
    n=N1;
    while n>1
        Ly(n-1)=n/y-1/[n/y+Ly(n)]; % Eq.(27) of Ref.[1]
        Lx(n-1)=n/x-1/[n/x+Lx(n)];   
        n=n-1;
    end
    % (1): n=1
    n=1;

    Fxn=2/(x^2)*(2*n+1);
    noverx=n/x;
    Lyoverm=Ly(n)/m;
    mLy=m*Ly(n);

    A(n)=1/[1-i*(cos(x)+x*sin(x))/(sin(x)-x*cos(x))];
    B0=i;
    B(n)=-noverx+1/[noverx-B0];
    Ta=[Lyoverm-Lx(n)]/[Lyoverm-B(n)];
    Tb=[mLy-Lx(n)]/[mLy-B(n)];
    an(n)=A(n)*Ta; %Eq.(28) of Ref.[1]
    bn(n)=A(n)*Tb; %Eq.(29) of Ref.[1]
    anM(j,n)=(2*n+1)/n/(n+1)*an(n);    
    bnM(j,n)=(2*n+1)/n/(n+1)*bn(n);  
    kext=Fxn*real(an(n)+bn(n));
    ksca=Fxn*(an(n)*conj(an(n))+bn(n)*conj(bn(n)));
      
    
    % (2): n>=1
    for n=2:N1
        Fxn=2/(x^2)*(2*n+1);
        nm1=n-1;
        noverx=n/x;
        Lyoverm=Ly(n)/m;
        mLy=m*Ly(n);
        B(n)=-noverx+1/[noverx-B(nm1)];
        A(n)=A(nm1)*[B(n)+noverx]/[Lx(n)+noverx];     %Eq.(34) of Ref.[1]
        Ta=[Lyoverm-Lx(n)]/[Lyoverm-B(n)];
        Tb=[mLy-Lx(n)]/[mLy-B(n)];   
        an(n)=A(n)*Ta; %Eq.(28) of Ref.[1]
        bn(n)=A(n)*Tb; %Eq.(29) of Ref.[1]
        anM(j,n)=(2*n+1)/n/(n+1)*an(n);    
        bnM(j,n)=(2*n+1)/n/(n+1)*bn(n);                  
        kext=kext+Fxn*real(an(n)+bn(n));
        ksca=ksca+Fxn*(an(n)*conj(an(n))+bn(n)*conj(bn(n)));
 
    end
    
    Qext(j)=kext;Qsca(j)=ksca;

end
return

function[flk]=fai(Z,n)
a1=(2*n+1)/Z;
a2=-(2*n+3)/Z;
flk1=a1;
df=a2+1/a1;
fll=a2;
k=2;
while k
   flk=flk1*df/fll;
   if abs(flk-flk1)<1.0e-5
      break
   end
   a3=(-1)^(k+2)*[(2*(n+k+1)-1)/Z];   
   df=a3+1/df;
   fll=a3+1/fll;
   flk1=flk;
   k=k+1;
end
flk=-n/Z+flk;
return