%read_process_SSFR_J31NavMetdata_ALIVE
clear
close all

%AMES	5257	07/12/04	18:48:06.3	+43.08863	-69.43269	+4.53	+9.47	36.01	+3836.69	+641.96	+2.7	40.0	38.7	372.5	+684.97	+671.29	+2.7	AMES
%checksum  date  time  latitude  longitude pitch  roll  heading  altitude  pressureAdj  temperatureAdj
%   relativeHumidity  track  speed  pressure2  pressure1  temperature

%pathnamedef='c:\johnmatlab\ICARTT J31 NavMet SSFR\*concat.txt';
%pathnamedef='c:\johnmatlab\INTEXB\J31_NavMet_data\20060322_2\*concat*.txt';
pathnamedef='c:\johnmatlab\ALIVE\NavMet\20050922\*concat*.txt';
[filename,pathname]=uigetfile(pathnamedef,'Choose SSFR navmet data file', 0, 0);
fid=fopen([pathname filename])

month=str2num(filename(5:6));
day=str2num(filename(7:8));
year=str2num(filename(1:4));

[datain,count]=fscanf(fid,'AMES %d %2d/%2d/%2d %2d:%2d:%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f AMES\n',[21,inf]);

iadj24=0;
UT_SSFR=datain(5,:)+datain(6,:)/60.+datain(7,:)/3600.;
for i=1:length(UT_SSFR)-1,
    if UT_SSFR(i+1)<1 & UT_SSFR(i)>23
        iadj24=1;
        isav=i+1;
        break
    end
end
if iadj24==1
    for i=isav:length(UT_SSFR),
        UT_SSFR(i)=UT_SSFR(i)+24;
    end
end
lat_SSFR=datain(8,:);
lon_SSFR=datain(9,:);
GPSkm_SSFR=datain(13,:)/1000;
Pmbadj_SSFR=datain(14,:);
tempCadj_SSFR=datain(15,:);
%RHpercent_meas_corrected=datain(16,:);
RHpercent_SSFR=datain(21,:); %uncorrected RH
heading_SSFR=datain(17,:);
speed_mpersec=datain(18,:)/3.2808;
Pmb_wing=datain(19,:); %total
Pmb_nose=datain(20,:); %measured static before Pilewskie correction
tempC_total=datain(21,:);
%RHpercent_SSFR=datain(22,:); %uncorrected RH

fclose(fid);

coeff=[-2109.13 12.1086 -0.0244111 2.74849e-05 -1.56561e-08 3.58026e-12]; %from Warren Gore 1/13/05
spec_heat_ratio=1.4;
gamma=(spec_heat_ratio-1.)/spec_heat_ratio;
tempCstat_calc_wrong=tempC_total.*(Pmbadj_SSFR./Pmb_wing).^gamma;
tempCstat_calc_correct=(tempC_total+273.16).*(Pmbadj_SSFR./Pmb_wing).^gamma - 273.16;
%calculate corrected RH
TempK=tempC_total+273.16;
TempK_corr=tempCstat_calc_correct+273.16;
satvappresmb_Ttotal=vappres(TempK);
satvappresmb_Tstat_correct=vappres(tempCstat_calc_correct+273.16);
vappresmb_meas=satvappresmb_Ttotal.*RHpercent_SSFR/100;
RH_calc_correct=100*vappresmb_meas./satvappresmb_Tstat_correct;
%RH_calc_Vaisalaformula=RHpercent_SSFR.*vappres_Vaisala(TempK)./vappres_Vaisala(tempCstat_calc_correct+273.16);
RH_calc_Vaisalaformula=RHpercent_SSFR.*vappres_Vaisala(TempK)./vappres_Vaisala(tempCadj_SSFR+273.16);
vappres_Ttotal=vappres_Vaisala(TempK);
%vappres_Tstatic=vappres_Vaisala(tempCstat_calc_correct+273.16);
vappres_Tstatic=vappres_Vaisala(tempCadj_SSFR+273.16);

gascons_watvap=8.314441/18.015; %[J/(g K)]
watvap_density_gm3_meas_Ttot=100*vappresmb_meas./(gascons_watvap.*TempK); %1 mb = 100 N/m^2 = 100 J/m^3
watvap_density_gm3_meas_Tstat=100*vappresmb_meas./(gascons_watvap.*TempK_corr); %1 mb = 100 N/m^2 = 100 J/m^3
%wcalc=100*vappresmb_meas./(gascons_watvap.*(TempK-3.0)); %1 mb = 100 N/m^2 = 100 J/m^3

%This computes water vapor density according to Boegel, 1977, p.108
b=(8.082-tempCstat_calc_correct/556).*tempCstat_calc_correct./(256.1+tempCstat_calc_correct);
a=13.233*(1+1e-8.*Pmbadj_SSFR.*(570-tempCstat_calc_correct))./(tempCstat_calc_correct+273.15);
watvap_density_gm3_calc=RH_calc_correct.*a.*10.^b;

%now use Ttotal and uncorrected RH.
b=(8.082-tempC_total/556).*tempC_total./(256.1+tempC_total);
a=13.233*(1+1e-8.*Pmbadj_SSFR.*(570-tempC_total))./(tempC_total+273.15);
watvap_density_gm3_calc2=RHpercent_SSFR.*a.*10.^b;

watvap_density_gm3_meas=watvap_density_gm3_meas_Tstat;
figure
subplot(4,1,1)
plot(UT_SSFR,watvap_density_gm3_meas,'b-')
hold on
%plot(UT_SSFR,wcalc,'g--')
plot(UT_SSFR,watvap_density_gm3_calc,'r-')
plot(UT_SSFR,watvap_density_gm3_calc2,'g-')
grid on
set(gca,'fontsize',12)
ylabel('Wat vap density [gm^{-3}]','fontsize',12)
hleg1=legend('ideal gas (T_{stat})','Boegel(adj T_{stat},RH)','Boegel(unadj T_{tot},RH)');
set(hleg1,'fontsize',10)
filenamestr=filename;
for i=1:length(filename),
 if strcmp(filenamestr(i),'_') filenamestr(i)='-'; end
end
title(filenamestr,'fontsize',12)
subplot(4,1,2)
plot(UT_SSFR,watvap_density_gm3_calc-watvap_density_gm3_meas,'b-')
%hold on
%plot(UT_SSFR,watvap_density_gm3_calc-wcalc,'r-.')
grid on
set(gca,'fontsize',12)
%ylabel('Difference (Boegel(calc Tstat,RH)-idealgas) [gm^{-3}]','fontsize',12)
ylabel('Diff(calc-meas) [gm^{-3}]','fontsize',12)
hleg2=legend('Boegel(adjusted T_{stat} & RH)');
set(hleg2,'fontsize',10)
subplot(4,1,3)
plot(UT_SSFR,watvap_density_gm3_calc2-watvap_density_gm3_meas,'m-')
grid on
set(gca,'fontsize',12)
%ylabel('Difference (Boegel(Ttot,RHunadj)-idealgas) [gm^{-3}]','fontsize',12)
ylabel('Diff(calc2-meas) [gm^{-3}]','fontsize',12)
hleg3=legend('Boegel(unadjusted T_{tot} & RH)');
set(hleg3,'fontsize',10)
subplot(4,1,4)
plot(UT_SSFR,100*(watvap_density_gm3_calc-watvap_density_gm3_meas)./watvap_density_gm3_meas,'b-')
hold on
plot(UT_SSFR,100*(watvap_density_gm3_calc2-watvap_density_gm3_meas)./watvap_density_gm3_meas,'m-')
grid on
set(gca,'fontsize',12)
%ylabel('Difference (Boegel(Ttot,RHunadj)-idealgas) [gm^{-3}]','fontsize',12)
ylabel('Relative Diff [%]','fontsize',12)
xlabel('UT [hr]','fontsize',14)
hleg4=legend('Boegel(adjusted T_{stat} & RH)','Boegel(unadj T_{tot},RH)');
set(hleg4,'fontsize',10)

figure(51)
subplot(3,1,1)
plot(UT_SSFR,watvap_density_gm3_meas_Ttot,'b-')
hold on
plot(UT_SSFR,watvap_density_gm3_meas_Tstat,'r-')
grid on
set(gca,'fontsize',12)
ylabel('Wat vap density [gm^{-3}]','fontsize',12)
hleg1=legend('ideal gas: Ttot','ideal gas: Tstat');
set(hleg1,'fontsize',10)
filenamestr=filename;
for i=1:length(filename),
 if strcmp(filenamestr(i),'_') filenamestr(i)='-'; end
end
title(filenamestr,'fontsize',12)
subplot(3,1,2)
plot(UT_SSFR,watvap_density_gm3_meas_Tstat-watvap_density_gm3_meas_Ttot,'b-')
grid on
set(gca,'fontsize',12)
ylabel('Diff (calcTstat-calcTtot) [gm^{-3}]','fontsize',12)
subplot(3,1,3)
plot(UT_SSFR,100*(watvap_density_gm3_meas_Tstat-watvap_density_gm3_meas_Ttot)./watvap_density_gm3_meas_Ttot,'b-')
grid on
set(gca,'fontsize',12)
ylabel('Rel Diff [%]','fontsize',12)

%month=2;
%day=20;
%year=2006;
UTlim=[16 20];
%UTlim=[-inf inf];
figure(52)
subplot(4,1,1)
plot(UT_SSFR,lat_SSFR,'b-')
set(gca,'fontsize',14)
set(gca,'xlim',UTlim)
grid on
ylabel('Latitude (deg)','fontsize',14)
title(sprintf('J31 flight date: %2d/%2d/%4d',month,day,year),'fontsize',14)
subplot(4,1,2)
plot(UT_SSFR,lon_SSFR,'r-')
set(gca,'fontsize',14)
set(gca,'xlim',UTlim)
grid on
ylabel('Longitude (deg)','fontsize',14)
subplot(4,1,3)
plot(UT_SSFR,GPSkm_SSFR,'k-')
set(gca,'fontsize',14)
set(gca,'xlim',UTlim)
grid on
ylabel('GPS altitude (km)','fontsize',14)
subplot(4,1,4)
plot(UT_SSFR,RHpercent_SSFR,'b-')
grid on
hold on
set(gca,'fontsize',14)
set(gca,'xlim',UTlim)
%plot(UT_SSFR,RHpercent_meas_corrected,'r-')
plot(UT_SSFR,RH_calc_Vaisalaformula,'r-')
ylabel('RH (%)','fontsize',14)
hleg1=legend('RH meas','RH corrected');
set(hleg1,'fontsize',12)
xlabel('UT (hr)','fontsize',14)

tempClim=[-10 30];
zkmlim=[0 5];
RHlim=[0 120];
pmblim=[500 1100];
UTlim=[-inf inf];
figure(53)
subplot(4,1,1)
plot(UT_SSFR,GPSkm_SSFR,'k-','linewidth',2)
grid on
set(gca,'fontsize',14)
set(gca,'xlim',UTlim,'ylim',zkmlim)
ylabel('GPS altitude (km)','fontsize',14)
title(sprintf('J31 flight date: %2d/%2d/%4d',month,day,year),'fontsize',14)
subplot(4,1,2)
plot(UT_SSFR,RHpercent_SSFR,'r-','linewidth',2)
grid on
hold on
set(gca,'fontsize',14)
set(gca,'xlim',UTlim,'ylim',RHlim,'ytick',[RHlim(1):20:RHlim(2)])
%plot(UT_SSFR,RHpercent_meas_corrected,'b-','linewidth',2)
plot(UT_SSFR,RH_calc_Vaisalaformula,'b-','linewidth',2)
ylabel('RH (%)','fontsize',14)
hleg1=legend('RH meas','RH corrected');
set(hleg1,'fontsize',12)
xlabel('UT (hr)','fontsize',14)
subplot(4,1,3)
plot(UT_SSFR,Pmb_wing,'r','linewidth',2)
hold on
plot(UT_SSFR,Pmb_nose,'g','linewidth',2)
plot(UT_SSFR,Pmbadj_SSFR,'b-','linewidth',2)
grid on
set(gca,'fontsize',14)
set(gca,'xlim',UTlim,'ylim',pmblim,'ytick',[pmblim(1):200:pmblim(2)])
ylabel('Pressure (mb)','fontsize',14)
hleg2=legend('Ptotal (=Pwing)','Pnose (meas)','Pstatic (calc)');
set(hleg2,'fontsize',12)
subplot(4,1,4)
plot(UT_SSFR,tempC_total,'r-','linewidth',2)
hold on
plot(UT_SSFR,tempCadj_SSFR,'b-','linewidth',2)
grid on
set(gca,'fontsize',14)
set(gca,'xlim',UTlim,'ylim',tempClim)
hleg3=legend('Total Temp','Static Temp');
set(hleg3,'fontsize',12)
ylabel('Temp (deg C)','fontsize',14)
%subplot(5,1,5)
%plot(UT_SSFR,speed_mpersec,'m','linewidth',2)
%grid on
%set(gca,'fontsize',14)
%set(gca,'xlim',UTlim,'ylim',[0 150])
%ylabel('GPS speed (m/s)','fontsize',14)
%xlabel('UT (hr)','fontsize',14)
%stopherenow

fidout=fopen('c:\johnmatlab\INTEXB\J31_NavMet_data\J31navmet.txt','w')
fprintf(fidout,' UTSSFR    GPSkm   Pmbtot   Pmbadj   Pmbadjcalc      tCtot     tCadj      tCstat1     tCstat2      RHmeasVais   RHcalcJ  RHcalc_Vaisalaformula\n');
for i=1:length(tempCadj_SSFR),
    Pmbadj_calc(i) = coeff(1) + coeff(2)*Pmb_nose(i) + coeff(3)*Pmb_nose(i).^2 + coeff(4)*Pmb_nose(i).^3 + coeff(5)*Pmb_nose(i).^4 + coeff(6)*Pmb_nose(i).^5;
    %fprintf(fidout,'%8.5f  %6.3f  %7.1f  %7.1f  %10.1f  %10.1f  %10.2f  %10.2f  %10.2f  %10.1f  %10.1f  %10.1f   %10.3f\n',UT_SSFR(i),GPSkm_SSFR(i),Pmb_wing(i),Pmbadj_SSFR(i),Pmbadj_calc(i),tempC_total(i),tempCadj_SSFR(i),tempCstat_calc_wrong(i),tempCstat_calc_correct(i),RHpercent_SSFR(i),RHpercent_meas_corrected(i),RH_calc_correct(i),RH_calc_Vaisalaformula(i));
    fprintf(fidout,'%8.5f  %6.3f  %7.1f  %7.1f  %10.1f  %10.1f  %10.2f  %10.2f  %10.2f  %10.1f  %10.3f   %10.3f\n',UT_SSFR(i),GPSkm_SSFR(i),Pmb_wing(i),Pmbadj_SSFR(i),Pmbadj_calc(i),tempC_total(i),tempCadj_SSFR(i),tempCstat_calc_wrong(i),tempCstat_calc_correct(i),RHpercent_SSFR(i),RH_calc_correct(i),RH_calc_Vaisalaformula(i));
end
fclose(fidout);

fidout2=fopen('c:\johnmatlab\INTEXB\J31_NavMet_data\J31navmet3.txt','w')
fprintf(fidout2,'  UT          RHmeasVais   RHcorrKarl  RHcalcJohn vappTtot    vappTstat\n');
for i=1:length(tempCadj_SSFR),
    fprintf(fidout2,'%2d:%2d:%4.1f  %10.1f  %10.3f  %10.3f  %10.5f  %10.5f\n',datain(5,i),datain(6,i),datain(7,i),RHpercent_SSFR(i),RHpercent_meas_corrected(i),RH_calc_Vaisalaformula(i),vappres_Ttotal(i),vappres_Tstatic(i));
end

filewrite='Navmet_rewrite.txt';  %note that format revised 3/8/05 to add measured Ttotal and calculated values of H2O density
fidwrite=fopen([pathname filewrite],'w');
numsecs_SSFR=3600*UT_SSFR;
for i=1:length(UT_SSFR),
    fprintf(fidwrite,'%6.1f  %8.5f %9.5f  %9.5f %9.5f %8.2f %6.1f %7.2f %7.1f %7.1f %7.1f %12.4e %12.4e\n',numsecs_SSFR(i),UT_SSFR(i),lat_SSFR(i),lon_SSFR(i),GPSkm_SSFR(i),Pmbadj_SSFR(i),RHpercent_SSFR(i),tempCstat_calc_correct(i),tempCadj_SSFR(i),...
        RH_calc_correct(i),tempC_total(i),watvap_density_gm3_meas_Tstat(i),watvap_density_gm3_calc(i));
end
fclose(fidwrite)

stop275

%plot color map
msize=4;
    colorlevels=[0 1 1; 0 0 1; 0 1 0; 1 1 0; 1 .65 .4; 1 0 1;1 0 0;0.8 0.2 0.2;0.5 0.5 0.5;0 0 0]; % cyan,blue,green,yellow,orange,magenta,red,brown,gray
    if ((max(GPSkm_SSFR)-round(max(GPSkm_SSFR)))>0)
       zcrit=[0.25 0.5:0.5:(round(max(GPSkm_SSFR))+0.5)];
    else
       zcrit=[0.25 0.5:0.5:round(max(GPSkm_SSFR))];
    end
    zcrit=[0.25 0.5 0.75 1 2 3 4 5 6 7];
    zcrit=[0.25 0.5 0.75 1 1.5 2 3 4 5 6];
    figure(41)
    %worldmap([min(Latitude)-.1,max(Latitude)+.1],[min(Longitude)-.1 max(Longitude)+.1],'patch')
    %worldmap([41.5,44.5],[-72,-64],'patch')  %full map
    %worldmap([41.5,44.5],[-72,-68],'patch')  %for 8/2 F19
    %worldmap([42.5,44.5],[-72,-67.5],'patch')  %for 8/2 F20
    %worldmap([42,44],[-72,-69],'patch')  %for 8/2 F20
    %worldmap([41,44],[-72,-67],'patch')  %for 8/7 F22 
    %worldmap([42,44],[-72,-66.5],'patch')  %for 8/8 F23 
    %worldmap([42.6,43.6],[-71,-69.0],'patch')  %for 7/12 
    %worldmap([42.2,43.6],[-71,-67.5],'patch')  %for 7/16 
    %worldmap([42.7,43.5],[-71,-69],'patch')  %for 7/17 
    %worldmap([42.8,43.6],[-71,-69],'patch')  %for 7/20 
    %%worldmap([42.7,43.7],[-71,-69.4])  %for 7/21 
    %worldmap([42.65,43.7],[-71,-69.8],'patch')  %for 7/21   %AATS SSFR special
    %worldmap([42.4,43.6],[-71,-69.2],'patch')  %for 7/22 Flight 13
    %worldmap([42.4,43.4],[-71,-69.8],'patch')  %for 7/23 
    %worldmap([42.5,43.3],[-71,-69.5])%,'patch')  %for 7/29   
    %worldmap([42.4,43.4],[-71,-69.4],'patch')  %for 8/7 
    %worldmap([42.2,43.4],[-71,-69.2],'patch')  %for 8/2 
    %worldmap([41.6,43.2],[-71,-67.5],'patch')  %for 8/7 
    %worldmap([42.6,43.3],[-71,-67.5],'patch')  %for 8/8 
    %worldmap([41.6,43.6],[-71,-67.5],'patch')  %for all 
    %worldmap([35.6 38],[-123 -121]) %for Monterey areaa 2/24/06 flight
    worldmap([min(lat_SSFR)-.4,max(lat_SSFR)+.4],[min(lon_SSFR)-.1 max(lon_SSFR)+.2],'patch')
    %worldmap([19 26],[-98 -94]) %for 3/21/06 transit to Brownsville 
states = shaperead('usastatehi', 'UseGeoCoords', true);
 %symbols = makesymbolspec('Polygon', ...
   %{'Name', 'California', 'FaceColor', [0.7 0.7 0.4]}, ...
   %{'Name', 'Nevada', 'FaceColor', [0.7 0.7 0.4]});
    symbols = makesymbolspec('Polygon',{'Name','Texas','FaceColor',[0.7 0.7 0.4]},...
                                       {'Name','New Mexico','FaceColor',[0.6 0.7 0.4]},...
                                       {'Name', 'Arizona', 'FaceColor', [0.5 0.7 0.4]},...
                                       {'Name', 'Mexico', 'FaceColor', [0.4 0.7 0.4]},...
                                       {'Name', 'California', 'FaceColor', [0.3 0.7 0.4]});
    %states = shaperead('landareas', 'UseGeoCoords', true);
    %symbols = makesymbolspec('Polygon',{'Name', 'Mexico', 'FaceColor', [0.7 0.7 0.4]},...
    %                                     {'Name', 'Guatemala', 'FaceColor', [0.7 0.6 0.4]},...
    %                                     {'Name', 'Belize', 'FaceColor', [0.7 0.5 0.4]},...
    %                                     {'Name', 'Honduras', 'FaceColor', [0.7 0.4 0.4]},...
    %                                     {'Name', 'Nicaragua', 'FaceColor', [0.6 0.7 0.4]},...
    %                                     {'Name', 'Costa Rica', 'FaceColor', [0.5 0.7 0.4]},...
    %                                     {'Name', 'Cuba', 'FaceColor', [0.5 0.7 0.4]},...
    %                                     {'Name', 'El Salvador', 'FaceColor', [0.4 0.7 0.4]});
geoshow(states, 'SymbolSpec', symbols,'DefaultFaceColor', 'blue','DefaultEdgeColor', 'black');
    %%plotm(Latitude,Longitude)    
    cm=colormap(colorlevels);
    jp=find(GPSkm_SSFR<=zcrit(1));
    %UTAATS_beg=18.245;
    %UTAATS_end=18.385;
    %jp=find(UT>=UTAATS_beg & UT<=UTAATS_end  & GPS_Alt<=0.1);
    if ~isempty(jp)
        plotm(lat_SSFR(jp),lon_SSFR(jp),'o','color',cm(1,:),'markersize',msize,'markerfacecolor',cm(1,:))
    end
    hold on
    msizeuse=msize;
    for i=2:length(zcrit),
      jp=find(GPSkm_SSFR>zcrit(i-1) & GPSkm_SSFR<=zcrit(i));
      if ~isempty(jp)
        %plotm(Latitude(jp),Longitude(jp),'o','color',cm(i,:),'markersize',msize,'markerfacecolor',cm(i,:))
       if(i<=10)
         plotm(lat_SSFR(jp),lon_SSFR(jp),'o','color',cm(i,:),'markersize',msize,'markerfacecolor',cm(i,:))
       else
         plotm(lat_SSFR(jp),lon_SSFR(jp),'o','color',cm(10,:),'markersize',msize,'markerfacecolor',cm(10,:))
       end
      end
    end
    jp=find(GPSkm_SSFR>zcrit(end));
    if ~isempty(jp)
        plotm(lat_SSFR(jp),lon_SSFR(jp),'o','color',cm(length(zcrit)+1,:),'markersize',4,'markerfacecolor',cm(length(zcrit)+1,:))
    end
    set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
    setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
    setm(gca,'fontsize',12,'fontweight','bold')
    setm(gca,'glinestyle','--','glinewidth',1)
    %setm(gca,'plabellocation',0.5,'plinelocation',0.5)
    %setm(gca,'plabellocation',0.2,'plinelocation',0.2,'plabelround',-1)
    setm(gca,'plabellocation',0.5,'plinelocation',0.5,'plabelround',-1)
    %setm(gca,'plabellocation',0.1,'plinelocation',0.1)
    %setm(gca,'mlabellocation',0.2,'mlinelocation',0.2,'mlabelround',-1)
    setm(gca,'mlabellocation',1,'mlinelocation',0.5,'mlabelround',-1)
    %setm(gca,'mlabellocation',0.5,'mlinelocation',0.5,'mlabelround',-1)
    %%%%set(gca,'PlotBoxAspectRatioMode','Manual','PlotBoxAspectRatio',[1 1 1])
    %%%set(gca,'DataAspectRatioMode','Manual','DataAspectRatio',[2 1 133])
    %hidem(gca)
    hold on
    xlabel('Longitude (deg W)','fontsize',14)
    %scaleruler on
    %hsc=handlem('scaleruler');
    %setm(hsc,'Xloc',0.0035,'Yloc',0.7459,'linewidth',2,'fontweight','bold','fontsize',11)
    %setm(hsc,'linewidth',2,'fontweight','bold','fontsize',11)

    ylims=get(gca,'ylim');
    ntim=length(lat_SSFR);
    %ntim=length(jp);
    dely=0.02*(ylims(2)-ylims(1));
    increment_times=20; %10;
    for i=1:floor(ntim/increment_times):ntim-ntim/increment_times,
    %%for ip=1:floor(ntim/increment_times):ntim-ntim/increment_times, %special
        %%i=jp(ip);  %special
        plotm(lat_SSFR(i),lon_SSFR(i),'+','color','k','markersize',8,'MarkerFacecolor','k')
        ht=textm(lat_SSFR(i)-.02,lon_SSFR(i),sprintf('%5.2f',UT_SSFR(i)));
        set(ht,'fontsize',12)
    end
    %plotm(Latitude(1226),Longitude(1226),'+','color','k','markersize',8,'MarkerFacecolor','k')  %MISR 7/29  1534 UT
    %plotm(Latitude(1028),Longitude(1028),'+','color','k','markersize',8,'MarkerFacecolor','k')  %MODIS 7/21  1805 UT
    i=floor(i+(ntim-i)/2);    
    plotm(lat_SSFR(i),lon_SSFR(i),'+','color','k','markersize',8,'MarkerFacecolor','k')
    ht=textm(lat_SSFR(i)-.02,lon_SSFR(i),sprintf('%5.2f',UT_SSFR(i)));
    set(ht,'fontsize',12)
    title(filenamestr,'fontsize',14,'fontweight','bold')
    
    cb=colorbar;
    cbpossav=get(cb,'Position');
    cbpos=cbpossav;
    cbpos(1)=0.81;
    cbpos(2)=0.23;
    cbpos(3)=0.03;
    cbpos(4)=0.6;
    %cbpos = [0.81    0.160    0.0300    0.75]; %7/17
    %cbpos = [0.81    0.30    0.0300    0.46]; %7/20
    set(cb,'Position',cbpos)
    set(cb,'yticklabel',[0 zcrit inf],'fontsize',12,'fontweight','bold')
    set(cb,'ylim',[0 1])
    xlimits=get(gca,'xlim');
    ylimits=get(gca,'ylim');
    ht2=text(xlimits(2)+0.05*(xlimits(2)-xlimits(1)),ylimits(1)+0.01*(ylimits(2)-ylimits(1)),'Altitude [km]');
    set(ht2,'fontsize',13,'fontweight','bold')
