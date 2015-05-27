% ASSIST_ALL-SKY Retrieval Program 
 clear all;
 %close all;
global COEF
global pvecbar
global PCPvec
global meanLBL
global meanradfasti
Date1='20120223';
% Input Parameters
%Wavenumber to test
Wvn_start=15795;  %Test wavenumber 15795:15804 with interval of 0.1
Wvn_end=15804;
Wvn_sep=0.1;
total_pts=32768;
avg_int=10;  %Averages soundings +/-10 mins for RUC sounding (clearest)

% % End input parameters
p_normal=[ 1000.,995.,990.,985.,980.,975.,970.,965.,960.,955.,950.,945.,...
            940.,935.,930.,925.,920.,915.,910.,905.,900.,880.,860.,840.,...
            820.,800.,780.,760.,740.,720.,700.,680.,660.,640.,620.,600.,...
            550.,500.,450.,400.,350.,300.,250.,200.,175.,150.,125.,100.,...
             75.,50.,  30., 25., 20., 15., 10.,  7.,  5.,  4.,  3.,  2.];

%Add path to data
ret_prog='/Users/smith/Desktop/LaserWN4LRT/';
addpath(genpath(ret_prog))
addpath('/Users/smith/Desktop/LaserWN4LRT/InputData')
addpath('/Users/smith/Desktop/LaserWN4LRT/InputData/QuebecData_1/')
addpath('/Users/smith/Desktop/LaserWN4LRT/output')
%Retrieval Programs  directory
savefile=[ret_prog,'output/'];
lat=47;
lon=-71.0;
sfcP=1000;
alt=4;
nsamples=0; kmct=-1;
radianceList = getRadianceFileList('//Users/smith/Desktop/LaserWN4LRT/InputData/QuebecData_1/');
for ksamples=1:65
%%%%%%%Compute Laser Wavenumber from Clear Sky Input Data
% Load ASSIST
kmct=kmct+2; kinsb=kmct+1;
inputFileMCT= radianceList{kmct};
inputFileINSB=radianceList{kinsb};
wnCut=1800;
test=getRadiancesFromFiles(inputFileMCT, inputFileINSB, wnCut);
for k=1:6
kk=nsamples+k;
Date(kk)=test.date(k,1);
year(kk)=Date{kk}.year; 
month(kk)=Date{kk}.month;  
day(kk)=Date{kk}.day; 
hour(kk)=Date{kk}.hour;
minute(kk)=Date{kk}.minute; 
second(kk)=Date{kk}.second;
ASSIST_Time0(kk,1)=year(kk); ASSIST_Time0(kk,2)=month(kk);ASSIST_Time0(kk,3)=day(kk);ASSIST_Time0(kk,4)=hour(kk);ASSIST_Time0(kk,5)=minute(kk);ASSIST_Time0(kk,6)=second(kk);
end;
wvnassist=test.wn;
ASSIST=test.radiance;
N=size(ASSIST,2);
for k=1:6
kk=nsamples+k;
rin(1:N,1)=ASSIST(k,1:N);
apodASSIST_clr1(kk,:)=real(apodizer(rin,'apply',1));
tassist(kk,1)=ASSIST_Time0(kk,4)+(ASSIST_Time0(kk,5)/60)+(ASSIST_Time0(kk,6)/3600);
end
nsndo=nsamples;
nsnde=nsamples+6;
nsamples=nsnde;
end;  %% End of Input File

%Data from ASSIST File
Time=ASSIST_Time0;
Rad=apodASSIST_clr1;
sndgs=size(Rad,1); spectra=size(Rad,2);
for i=1:sndgs; BT(:,i)=rad2bt(wvnassist(1,:)',Rad(i,:)'); end;
TP=BT';
assist_wn=wvnassist;

%Site Information
lon=-71.25;
lat=46.8;
sufP=1000;

%Wavenumber to test
Wvn_start=15795;  %Test wavenumber 15795:15804 with interval of 0.1
Wvn_end=15804;
Wvn_sep=0.1;
total_pts=32768;
avg_int=30;  %Averages soundings +/-10 mins for RUC sounding (clearest)
Time=ASSIST_Time0;
nl=60;
%%%%%%%%%%%%%%%%%%%%% End Inputs  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Does data cross UTC?
if Time(1,3)<Time(end,3)
    idx=find(Time(:,4)==0);
    Time(idx(1,1):end,4)=Time(idx(1,1):end,4)+24;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Download GSFA or RUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Time_dec=Time(:,4)+(Time(:,5)/60)+(Time(:,6)/(60*60));
hour1=Time(1,4);
m=0;
for n=1:size(Time,1)
    if Time(n,4)==hour1+1
        m=m+1;
        new_hour(m,1)=n;
        year=Time(n,1);
        month=Time(n,2);
        day=Time(n,3);
        hour=Time(n,4);
        if hour>=24
            hour=hour-24;
        end    
        %%%% Use GFSA
        [pmm_ruc,tmm_ruc,qmm_ruc]=get_gfsa(lon,lat,year,month,day,hour);
        %%%% OR USE RUC        
%             prof=get_ruc(lon,lat,year,month,day,hour);
%             pmm_ruc=prof.p;
%             tmm_ruc=prof.t;
%             qmm_ruc=prof.q;
        %%%%   
                   
        [pi,ti,qi,zi]=interpolate_sounding_ozonef(pmm_ruc,tmm_ruc,qmm_ruc,qmm_ruc);
        clear pmm_ruc tmm_ruc qmm_ruc
        for j=1:nl
            tr(j,1)=ti(1,j);
            qr(j,1)=qi(1,j);
            pr(j,1)=pi(1,j);
            zr(j,1)=zi(1,j);
            [wvi,rhi]=RH(qr(j,1),tr(j,1),pr(j,1));
            rhr(j,1)=rhi;
        end;
        pmm(m,:)=pi;
        tmm(m,:)=ti;
        qmm(m,:)=qi;
        hour1=hour1+1;       
                
        %Find soundings btw +/- avg_int mins
        start_time(m,1)=hour1-(avg_int/60);
        end_time(m,1)=hour1+(avg_int/60);
        clear idx
        idx=find(Time_dec>=start_time(m,1) & Time_dec<=end_time(m,1));
        avg_pts(m,1)=idx(1,1);
        avg_pts(m,2)=idx(end,1);
        opaque_region=find(wvnassist>=670 & wvnassist<=690);
       tbbar(:,1)=mean(TP(:,opaque_region),2);
        TSFC(m,1)=mean(tbbar(avg_pts(m,1):avg_pts(m,2),1),1);
        clear p t q
    end
end

%%%% Parts of the following code were provided By Melissa Yesalusky  (3/3/2012)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Run RUC data in Fast Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[~,ipsfc]=min(abs(sufP-pmm(1,:)));
for i=1:size(tmm,1);
    tmm(i,1:2)=TSFC(i,1);
    [wn1,radcal(i,:)]= radcalccldf(pmm(i,:),tmm(i,:),qmm(i,:),0,ipsfc);
    radfasti(i,:)=radcal(i,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Expand ASSIST Wavenumber
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w=assist_wn(1,1):assist_wn(1,1)-assist_wn(1,2):-1;
[~,b]=min(abs(w));
full_wavenumber_scale=[fliplr(w(1,2:b)),wvnassist];
assist_zeros=zeros(size(Rad,1),b-1); %b-1 b/c first point is assist wvn(1,1)
Rad_full=[assist_zeros,Rad];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Average Clearest Soundings +/- 10 mins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
atm_window=find(full_wavenumber_scale>=850 & full_wavenumber_scale<=1000);
for n=1:size(avg_pts,1)
    R=Rad_full(avg_pts(n,1):avg_pts(n,2),:);
    R_wind=R(:,atm_window);
    R_wind_mean=mean(R_wind,2);
    R_min=min(R_wind_mean);
    clear idx
    idx=find(R_wind_mean<=R_min+5);
    
    Rad_avg(n,:)=mean(R(idx,:));
  
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Standard Deviation Between Observation and Fast Model Vs Laser Wavenumber
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idx_stdd=find(wn1>=650 & wn1<=2400); %Standard Deviation between 650-2400
Poss_wvn=Wvn_start:Wvn_sep:Wvn_end;
idx_stdd=idx_stdd';
for n=1:size(avg_pts,1)
    for m=1:size(Poss_wvn,2);        
        %Find wavenumber scale given the laser frequency
        spc=Poss_wvn(1,m)/total_pts;
        W(1,1)=spc/2;
        for w=2:total_pts/2
            W(1,w)=W(1,w-1)+spc;
        end
        wnscale = W';
        
        %Interpolate ASSIST to FM scale and find radiance derivative
        Rad_interp(n,:)=interp1(wnscale(1:size(Rad_avg,2),1)',Rad_avg(n,:),wn1);
        Rad_interpo(m,:)=Rad_interp(n,:);
        if Poss_wvn(1,m)==15799.7; no=m; Rad_interp(no,:)=Rad_interp(n,:); end;
        for d=2:size(idx_stdd,1)
            d2=idx_stdd(d,1);
            DIFrad(1,d2)=abs(Rad_interp(n,d2)-radfasti(n,d2));
        end       
       
        %Find Minimum STD between Observation and Fast Model
        STDF=std(DIFrad,1,2);
        Fast_std(n,m)=STDF;
        
        clear STDF
    end
    figure
    plot(Poss_wvn,Fast_std(n,:),'b') 
    [~,a2]=min(Fast_std(n,:),[],2);  
    Results(1,n)=Poss_wvn(1,a2);     
        figure
    plot(wn1,radfasti(n,:),'k')
        hold on
    plot(wn1,Rad_interpo(a2,:),'r')
    plot(wn1,Rad_interp(no,:),'g')
    legend('Fast Model','ASSIST New LWN','ASSIST Original LWN')
    axis([500 2500 0 150])
    BTfasti=rad2bt(wn1(1,:)',radfasti(n,:)');
    BTobs=rad2bt(wn1(1,:)',Rad_interpo(a2,:)');
    BTobsno=rad2bt(wn1',Rad_interp(no,:)');
    BTfast=BTfasti';
    BTavg=BTobs';
    BTavgno=BTobsno';
    figure
    plot(wn1,BTfast,'k')
        hold on
    plot(wn1,BTavg,'r')
    plot(wn1,BTavgno,'g')
    legend('Fast Model','ASSIST New LWN','ASSIST Original LWN')
    axis([500 2500 150 300])

    clear a2 
end
format long
display('Laser Wavenumer Results');
display(Results)
return

