function Mie_AERONET
% Deprecated by anet_mie
% This code originally provided by Feng Xu on Aug 25, 2020
% It was an .m script and was converted into a function by Connor Flynn
% It uses proscribed refractive indices (mr_arr, mi_arr) and bin-wise SD (rm)[dVdlnr]
% to reproduce Aeronet AOD and SSA values
% Internal functions:
%   Phase_mat_common
%   Sphere_Mie_Deri_Opt and
%   fai

%% AERONET product characteristics
lambda=[441, 673, 873, 1022];%% AERONET wavelength
mr_arr(1:length(lambda))= [1.33	1.3557	1.3692	1.3702];%real refractive index 
mi_arr(1:length(lambda))= [0.00187	0.001825	0.001824	0.001823];% imaginary refractive index 

%% size distribution (AERONET)
rm=[0.05	0.065604	0.086077	0.112939	0.148184	0.194429	0.255105	0.334716	0.439173	0.576227	0.756052	0.991996	1.301571	1.707757	2.240702	2.939966	3.857452	5.06126	6.640745	8.713145	11.432287	15];
%% dVdlnr
dVdlnr(1:length(rm))= [0.000799	0.000783	0.001214	0.00283	0.008527	0.025265	0.052488	0.056106	0.03332	0.017428	0.011672	0.010808	0.012044	0.01447	0.017286	0.018461	0.017036	0.013154	0.008418	0.004531	0.002083	0.000823];

bin_num=length(rm);
del_lnr=mean(log(rm(2:end))-log(rm(1:end-1)));
%% get column concentration (um^3/um^2) 
Cv=dVdlnr*del_lnr; 
rm_arr=1e-6*rm;
rBC_node_in_meter=1e-6*exp([log(rm(1))-del_lnr/2:del_lnr:log(rm(end))+del_lnr/2]);

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
    
    mr=mr_arr(nd);
    mi=mi_arr(nd);
    
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
tau_p_btAsl
SSA_p_bt_mixed
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