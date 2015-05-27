%plot_TOMSozone_vs_lat.m
datestr='17 Dec 2002';
lonTOMS=[-128.125 -126.875 -125.625 -124.375 -123.125 -121.875 -120.625 -119.375 -118.125 ]; 
latTOMS=[33.5 34.5 35.5 36.5 37.5 38.5 39.5 40.5 41.5];
OzoneTOMS=[...
 265     264     265     261     259     261     265     267       0; 
 270     273     276     272     270     273     274     272     270; 
 283     284     287     286     282     282     280     279     283; 
 295     294     297     294     290     291     294     295     284; 
 311     307     310     304     298     306     311     301     295; 
 339     325     326     325     325     321     331     320     311; 
 351     344     348     339     342     338     341     337     334; 
 362     362     354     351     349     351     346     347     351; 
 363     371     363     358     358     358     356     353     351]; 

idxlatuse=[3:9];
idxlonuse=[3:8];

datestr='19 Dec 2002';
lonTOMS=[-120.625 -119.375 -118.125 -116.875 -115.625];
latTOMS=[21.5:1:35.5];
%following for 12/19/02
OzoneTOMS19=[...
  247     248     247       0       0; 
  245     246     248       0       0; 
  248     247     251       0       0; 
  249     250     251       0       0; 
  247     250     254       0       0; 
  255     252     252       0       0; 
  255     257     257       0     258; 
  252     254     258       0     256; 
  259     258       0       0     258; 
  268     271       0       0     261; 
  277     278       0     267     267; 
  284     279       0     272     272; 
  286     280     279     278     277; 
  289     289     286     285     284; 
  288     287     298     294     292;] 

idxlatuse=[1:15];
idxlonuse=[1:5];

%following for 12/20/02
OzoneTOMS20=[...                            
  248     248     245     246     247;
  251     249     249     249     249; 
  249     249     248     251     250; 
  251     248     248     248     248; 
  258     256     257     255     253; 
  263     260     258     258     260; 
  269     266     267     261     258; 
  277     278     274     274     269; 
  283     285     285     287     276; 
  288     292     293     299     283; 
  292     292     293     301     289; 
  294     296     299     298     293; 
  301     306     304     297     297; 
  311     315     308     304     300; 
  319     326     327     336     315;]
  
idxlatuse=[1:15];
idxlonuse=[1:5];

OzoneTOMS=OzoneTOMS19;

figure  
plot(latTOMS(idxlatuse),OzoneTOMS(idxlatuse,idxlonuse),'o-')
xlabel('Latitude (deg)','FontSize',14)
ylabel('TOMS Ozone (DU)','FontSize',14)
title(datestr,'FontSize',14)
set(gca,'FontSize',14)
grid on

legstr='';
for i=1:length(lonTOMS(idxlonuse)),
    legstr=[legstr;sprintf('%6.2f ',lonTOMS(idxlonuse(i)))];
end
lleg=legend(legstr);
set(lleg,'FontSize',12)
ht=text(35,370,'Longitude:');
set(ht,'FontSize',12)

%now read GH archive file and overplot
[numlines_info,info_sav,UTdechr,Latitude,Longitude,GPS_alt_km,Press_alt_km,Pressmb,...
	  Wvlnm,CWV_cm,CWVunc_cm,O3col_DU,cloud_flag,a2_polyfit,a1_polyfit,a0_polyfit,...
	  Taupart,Unctaup,mission_name,year,month,day,filename]=read_AATS14_GH_SOLVE2('c:\johnmatlab\AATS14_2002_archive\*.*');

hold on
plot(Latitude,O3col_DU,'co')
