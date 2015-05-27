%calc_transmission_AATS_Ver050912.m
%must run plot_re4_ARCTAS.m first
%in that case, comment out the "clear" "close all" statements and the "filename=filename_in" statement
clear
close all

%tau_aero= tau-tau_ray.*(ones(n(2),1)*(m_ray./m_aero))...
%    -tau_NO2.*(ones(n(2),1)*(m_NO2./m_aero))...
%    -tau_ozone.*(ones(n(2),1)*(m_O3./m_aero))...
%    -tau_O4.*(ones(n(2),1)*(m_ray./m_aero))...
%    -tau_CO2_CH4_N2O.*(ones(n(2),1)*(m_ray./m_aero));

%%%%filename=filename_in; %added 03Jan2013 to handle Dec 2012 MLO data

%load 'c:\johnmatlab\ARCTAS\AATS_plotre4_output_19Apr08.mat';
%load 'c:\johnmatlab\AATS_plotre4_matfiles\Ames2013\AATS14_08Apr13_Ames.mat';
%load 'c:\johnmatlab\AATS_plotre4_matfiles\Ames2013\AATS14_09Apr13_Ames.mat';
%load 'c:\johnmatlab\AATS_plotre4_matfiles\Ames2013\AATS14_10Apr13_Ames.mat';
%load 'c:\johnmatlab\AATS14_data_2013\Mauna Loa\20130706aats_rev07Jul.mat';
load 'c:\johnmatlab\AATS14_data_2013\Mauna Loa\20130712aats.mat';
filename=filename_in; %added 03Jan2013 to handle Dec 2012 MLO data

file_trans_wrt_base='MLO_071213_trans_ver';
%file_trans_wrt='ARCTAS_063008_trans_ver4.txt';
%file_trans_wrt='Ames_032312_trans_ver4_test.txt';
%file_trans_wrt='MLO_092911_trans_ver5.txt';
%file_trans_wrt='MLO_052812_trans_ver5.txt';
%file_trans_wrt='MLO_052912_trans_ver5.txt';
%file_trans_wrt='Ames_050512_trans_ver4_test.txt';
%file_trans_wrt_base='ARCTAS_070908_trans_ver';
%file_trans_wrt_base='MLO_092911_trans_ver';
%file_trans_wrt_base='MLO_121412_trans_ver';
%file_trans_wrt_base='MLO_121912_trans_ver';
%file_trans_wrt_base='MLO_121212_trans_ver';
%file_trans_wrt_base='MLO_121812_trans_ver';
%file_trans_wrt_base='ARCTAS_041908_trans_ver';
%file_trans_wrt_base='Ames_040813_trans_ver';
%file_trans_wrt_base='Ames_040913_trans_ver';
%file_trans_wrt_base='Ames_041013_trans_ver';


flag_output_type='TRANS'; %OD
version_wrt='01';  %for 19Apr2008
%version_wrt='10';

n=fliplr(nn); %special for 19Apr2008 Jen's run

slant_transmission_total=(data'./(ones(n(1),1)*V0)/f)'; %added 3/28/2012
slant_transmission_Rayleigh=exp(-(ones(14,1)*m_ray).*tau_ray);
slant_transmission_O3=exp(-(ones(14,1)*m_O3).*tau_ozone);
slant_transmission_NO2=exp(-(ones(14,1)*m_NO2).*tau_NO2);
slant_transmission_O4=exp(-(ones(14,1)*m_ray).*tau_O4);
slant_transmission_H2O=exp(-(ones(14,1)*m_aero).*tau_H2O);
slant_transmission_CO2_CH4_N2O=exp(-(ones(14,1)*m_ray).*tau_CO2_CH4_N2O);


%calculate slant Transmission uncertainty
trans_slant_err1=(ones(n(1),1)*V0err)';
trans_slant_err2=(ones(n(1),1)*dV)'./data;
track_err=(Elev_err.^2+Az_err.^2).^0.5;
trans_slant_err3=(ones(n(1),1)*slope)'.*(ones(n(2),1)*track_err);
slant_trans_err = (trans_slant_err1.^2 + trans_slant_err2.^2 + trans_slant_err3.^2).^0.5;

%tau_CO2_CH4_N2O
%tau_H2O
%tau_NO2
%tau_O4
%tau_ozone


for i=1:14,
    jf=floor(i/6)+1
    figure(300+jf)
    isub=mod(i,6)+1;
    subplot(2,3,isub)
    semilogy(UT,slant_trans_err,'ko')
    hold on
    semilogy(UT,trans_slant_err1,'c.')
    semilogy(UT,trans_slant_err2,'g.')
    semilogy(UT,trans_slant_err3,'r.')
    %if isub==3
    %    legstr=['tot';'V0 ',;'V  ';'trk'];
    %    %hleg=legend('tot','V0','V','trk');
    %    hleg=legend(legstr);
    %    set(hleg,'fontsize',14)
    %end
    grid on
    set(gca,'fontsize',14)
    set(gca,'ylim',[0.01 100])
    xlabel('UT (hr)','fontsize',14)
    ylabel('Rel error: tot(k),V0(c),V(g),track(r)','fontsize',14)
    title(sprintf('%s  %6.1f nm',filename,1000*lambda(i)),'fontsize',14) %filename_in
end

%calculate datenum   datenum(Y, M, D, H, MN, S)
hrminsec=degrees2dms(UT');
for j=1:length(UT),
    serialdatenum(j)=datenum(year,month,day,hrminsec(j,1),hrminsec(j,2),hrminsec(j,3));
end
datestrout=datestr(serialdatenum,0);

CWV=U/H2O_conv; %added Feb 2011

%   UT
%   GPS_Alt
%   SZA_unrefrac
%   lambda(14)
%   day,month,year
%   tau_aero(14,:)
%   CWV
%   slant_transmission_total(14,:)
%   m_aero
%   m_ray

if julian(day,month,year,0)==julian(26,6,2008,0)
    ireset=find(UT>=16.2895 & UT<=16.2905); %remove bad pressure data point
    L_H2O(ireset)=0;
    L_cloud(ireset)=0;
elseif julian(day,month,year,0)==julian(30,6,2008,0)
    ireset=find((UT>=20.993&UT<=20.994) | (UT>=21.379&UT<=21.38) | (UT>=21.381&UT<=21.382) | (UT>=21.656&UT<=21.6575)); %remove bad pressure data point
    L_H2O(ireset)=0;
    L_cloud(ireset)=0;
end

d=datevec(now);

file_trans_wrt=sprintf('%s%s.txt',file_trans_wrt_base,version_wrt);

UTwrtbeg=0; %16
UTwrtend=30;
wvl_aero_wrt=wvl_aero;
wvl_aero_wrt=[     1     1     1     1     1     1     1     1     1     0     1     1     1     1];

%fidwr=fopen(['c:\johnmatlab\ARCTAS_AATS_transmission_files\' file_trans_wrt],'w');
fidwr=fopen(['c:\johnmatlab\AATS_transmission_files_2013\' file_trans_wrt],'w');
fprintf(fidwr,'%4d %2d %2d %4d %2d %2d\n',year,month,day,d(1,1),d(1,2),d(1,3));
fprintf(fidwr,'%6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f\n',lambda(wvl_aero_wrt==1),lambda(wvl_water==1));
if strcmp(flag_output_type,'OD')
    fprintf(fidwr,['......datestr.......   lat(deg)  long(deg)  Press(mb)  GPS(km) SZA(deg)     mRay    maero  CWV(cm) L_cld  ...................................total slant path transmission (all wvls, 940 last).......................................  '...
        '...............relative error in total slant path transmission (all wvls, 940 last).........................................  ................................Rayleigh slant path transmission (all wvls, 940 last).......................................   '...
        '.......................................aerosol optical depth (13 wvls)............................................  ........................................optical depth ozone(13 wvls)...............................................  '...
        '.....................................optical depth NO2(13 wvls)....................................................  ........................................optical depth O4(13 wvls)..................................................  '...
        '.....................................optical depth CO2-CH4-N2O(13 wvls)............................................  ...................................optical depth H2O(13 wvls)......................................................\n'])
    
    %jobsw=find(L_H2O==1);
    jobsw=find(L_H2O==1 & UT>=UTwrtbeg & UT<=UTwrtend); %use for Ames 2012 data
    ntimwrt=length(jobsw);
    for jw = 1:ntimwrt,
        i=jobsw(jw);
        format_str = (['%s %10.5f %10.5f %10.5f %8.5f %8.4f %8.5f %8.5f %8.5f %8.4f %5i %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f '...
            '%8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f\n']);
        fprintf(fidwr,format_str,datestrout(i,:),geog_lat(i),geog_long(i),press(i),GPS_Alt(i),SZA_unrefrac(i),m_ray(i),m_aero(i),m_O3(i),CWV(i),L_cloud(i),slant_transmission_total(wvl_aero_wrt==1,i),slant_transmission_total(wvl_water==1,i),...
            slant_trans_err(wvl_aero_wrt==1,i),slant_trans_err(wvl_water==1,i),slant_transmission_Rayleigh(wvl_aero_wrt==1,i),slant_transmission_Rayleigh(wvl_water==1,i),tau_aero(wvl_aero_wrt==1,i),tau_ozone(wvl_aero_wrt==1,i),...
            tau_NO2(wvl_aero_wrt==1,i),tau_O4(wvl_aero_wrt==1,i),tau_CO2_CH4_N2O(wvl_aero_wrt==1,i),tau_H2O(wvl_aero_wrt==1,i))
    end
elseif strcmp(flag_output_type,'TRANS')
    fprintf(fidwr,['......datestr.......   lat(deg)  long(deg)  Press(mb)  GPS(km) SZA(deg)     mRay    maero      mO3  CWV(cm) L_cld  ...................................total slant path transmission (all wvls, 940 last).......................................  '...
        '...............relative error in total slant path transmission (all wvls, 940 last).........................................  ................................Rayleigh slant path transmission (all wvls, 940 last).......................................   '...
        '.......................................aerosol optical depth (13 wvls)............................................  ........................................O3 slant transmiss (13 wvls)...............................................  '...
        '.....................................NO2 slant transmn(13 wvls)....................................................  ........................................O4 slant transmn(13 wvls)..................................................  '...
        '.....................................CO2-CH4-N2O slant transmn(13 wvls)............................................  ...................................H2O slant transmn(13 wvls)......................................................  '...
        '...................................aerosol optical depth error(13 wvls)............................................\n'])
    
    %jobsw=find(L_H2O==1);
    jobsw=find(L_H2O==1 & UT>=UTwrtbeg & UT<=UTwrtend); %use for Ames 2012 data
    ntimwrt=length(jobsw);
    for jw = 1:ntimwrt,
        i=jobsw(jw);
        format_str = (['%s %10.5f %10.5f %10.5f %8.5f %8.4f %8.5f %8.5f %8.5f %8.4f %5i %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f '...
            '%8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f '...
            '%8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f %8.4f\n']);
        fprintf(fidwr,format_str,datestrout(i,:),geog_lat(i),geog_long(i),press(i),GPS_Alt(i),SZA_unrefrac(i),m_ray(i),m_aero(i),m_O3(i),CWV(i),L_cloud(i),slant_transmission_total(wvl_aero_wrt==1,i),slant_transmission_total(wvl_water==1,i),...
            slant_trans_err(wvl_aero_wrt==1,i),slant_trans_err(wvl_water==1,i),slant_transmission_Rayleigh(wvl_aero_wrt==1,i),slant_transmission_Rayleigh(wvl_water==1,i),tau_aero(wvl_aero_wrt==1,i),slant_transmission_O3(wvl_aero_wrt==1,i),...
            slant_transmission_NO2(wvl_aero_wrt==1,i),slant_transmission_O4(wvl_aero_wrt==1,i),slant_transmission_CO2_CH4_N2O(wvl_aero_wrt==1,i),slant_transmission_H2O(wvl_aero_wrt==1,i),tau_aero_err(wvl_aero_wrt==1,i))
    end
    
end
fclose(fidwr)

legstr100=[];
for i=1:14,
    if wvl_aero(i)==1       
        legstr100=[legstr100;sprintf('%6.1f',1000*lambda(i))];
    end
end
figure(100)
ax1=subplot(3,1,1);
plot(UT,CWV,'bo')
set(gca,'fontsize',16)
grid on
ylabel('CWV (cm)','fontsize',20)
title(titlestr,'fontsize',14)
ax2=subplot(3,1,2);
plot(UT,tau_H2O(wvl_aero==1,:),'.')
set(gca,'fontsize',16)
grid on
hleg100=legend(legstr100);
set(hleg100,'fontsize',10)
ylabel('Effective OD (H2O)','fontsize',20)
ax3=subplot(3,1,3);
plot(UT,slant_transmission_H2O(wvl_aero==1,:),'.')
set(gca,'fontsize',16)
grid on
ylabel('Effective Trans.(H2O)','fontsize',20)
xlabel('UT (hr)','fontsize',20)
linkaxes([ax1 ax2 ax3],'x')

figure(200)
ax1=subplot(3,1,1);
plot(UT(L_cloud==1),CWV(L_cloud==1),'bo')
set(gca,'fontsize',16)
grid on
ylabel('CWV (cm)','fontsize',20)
title(titlestr,'fontsize',14)
ax2=subplot(3,1,2);
plot(UT(L_cloud==1),tau_H2O(wvl_aero==1,L_cloud==1),'.')
set(gca,'fontsize',16)
grid on
hleg100=legend(legstr100);
set(hleg100,'fontsize',10)
ylabel('Effective OD (H2O)','fontsize',20)
ax3=subplot(3,1,3);
plot(UT(L_cloud==1),slant_transmission_H2O(wvl_aero==1,L_cloud==1),'.')
set(gca,'fontsize',16)
grid on
ylabel('Effective Trans.(H2O)','fontsize',20)
xlabel('UT (hr)','fontsize',20)
linkaxes([ax1 ax2 ax3],'x')

stopherenow

%special for Connor
%file_trans_wrt_special='Ames_050512_special.txt';
file_trans_wrt_special='Ames_050812_special.txt';
wvl_aero_wrt=[0 1 1 1 1 1 1 1 1 0 1 1 0 1];
fidwr=fopen(['c:\johnmatlab\ARCTAS_AATS_transmission_files\' file_trans_wrt_special],'w');
fprintf(fidwr,'%4d %2d %2d %4d %2d %2d\n',year,month,day,d(1,1),d(1,2),d(1,3));
fprintf(fidwr,'%6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f\n',lambda(wvl_aero_wrt==1),lambda(wvl_water==1));
fprintf(fidwr,'......datestr.......   lat(deg)  long(deg)  SZA(deg) .......................dark-corrected raw voltages (for wvls listed above, 940 last)......................  ......................total slant path transmission (for wvls listed above, 940 last).....................\n');

%jobsw=find(L_H2O==1 & UT>=UTwrtbeg & UT<=UTwrtend); %use for Ames 2012 data
jobsw=find(UT>=UTwrtbeg & UT<=UTwrtend); %use for Ames 2012 data
ntimwrt=length(jobsw);
for jw = 1:ntimwrt,
   i=jobsw(jw);
   format_str = '%s %10.5f %10.5f %8.4f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f %8.5f\n';
   fprintf(fidwr,format_str,datestrout(i,:),geog_lat(i),geog_long(i),SZA_unrefrac(i),data(wvl_aero_wrt==1,i),data(wvl_water==1,i),slant_transmission_total(wvl_aero_wrt==1,i),slant_transmission_total(wvl_water==1,i))
end
fclose(fidwr)




