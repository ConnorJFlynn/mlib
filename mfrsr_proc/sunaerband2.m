function [ra,dec,lmst,ha,az,el,refrac,al,aha,azk,ahk]=sunae(year,jday,hour,lat,long) 
%function [ra,dec,lmst,ha,az,el,refrac,aha,w2,chk]=sunae(year,jday,hour,lat,long) 
%20060712pra debug refraction-corrected band position (apparent hour angle)
%function [az,el]=sunae(year,jday,hour,lat,long) 
%returns azimuth and elevation in radains [JJ Michalsky,SEJ 40(3)227-235] 20021105pra
r90=pi/2; delta=year-1949; leap=fix(delta/4); ahk=0;
jd=32916.5+delta*365+leap+jday+hour/24;
if (mod(year,100)==0) & (mod(year,400)~=0); jd=jd-1;end
time=jd-51545.0;
mnlong=280.460+.9856474*time; mnlong=mod(mnlong,360);if mnlong<0;mnlong=mnlong+360;end
mnanom=357.528+.9856003*time; mnanom=mod(mnanom,360);if mnanom<0;mnanom=mnanom+360;end
%fprintf(' jd,t,t,ml,ma=%14.7f%14.7f%14.7f%14.7f%14.7f\n',jd,time,time,mnlong,mnanom);
chk=[delta,leap,jd,time,mnlong,mnanom];
mnanom=mnanom*pi/180;
eclong=mnlong+1.915*sin(mnanom)+.020*sin(2*mnanom); eclong=mod(eclong,360);if eclong<0;eclong=eclong+360;end
eclong=eclong*pi/180; 
oblqec=(23.439-.0000004*time)*pi/180;

num=sin(oblqec+r90)*sin(eclong);den=sin(eclong+r90);
%ra=atan2(num,den);if ra<0;ra=ra+2*pi;end
ra=atan(num/den);
if den<0;
   ra=ra+pi;
elseif num<0;
   ra=ra+pi+pi;
end
dec=asin(sin(oblqec)*sin(eclong));
chk=[hour,jd,time,mnlong,mnanom,eclong,oblqec,ra,dec];
gmst=6.697375+.0657098242*time+hour; gmst=mod(gmst,24);if gmst<0;gmst=gmst+24;end
lmst=gmst+long/15;lmst=mod(lmst,24);if lmst<0;lmst=lmst+24;end;lmst=lmst*pi/12;

ha=lmst-ra;if ha<-pi;ha=ha+pi+pi;end
if ha>pi;ha=ha-pi-pi;end

lat=lat*pi/180;
%---------------at this point all angles in radians--------------------------
%el=asin(sin(dec)*sin(lat)+cos(dec)*cos(lat)*cos(ha));
cosz=sin(dec)*sin(lat)+cos(dec)*cos(lat)*cos(ha);
%%cosz=sin(dec)*sin(lat)+sin(dec+r90)*sin(lat+r90)*sin(ha+r90);
el=asin(cosz); %Note cosz=sin(el)
%az=asin(-cos(dec)*sin(ha)/cos(el));
sinaz=-cos(dec)*sin(ha)/cos(el);%RETAINING SINAZ MAY BE KEY TO EVALUATING aha==w ! ! ! ! 
%az=-sin(dec+r90)*sin(ha)/sin(el+r90);
az=asin(sinaz);
%Walraven version
if dec~=0
  if cosz*sin(lat)<sin(dec)
    if az<0; az=az+pi+pi; end
    az=pi-az;
  end
end
chk=[gmst,lmst,ha,lat,el,az];
  
%JJM version
if 0
if sin(dec)-sin(el)*sin(lat)>=0
  if sin(az)<0; az=az+pi+pi;
  az=pi-az;
  end   
end
end
%if az>pi; az=az-pi-pi; end
%put az between -pi and +pi radians
%az=mod(az+pi,pi+pi)-pi;
%---below looks like aborted attempt...s/b elc=asin(sin(dec)*sin(lat))?
%elc=asin(sin(dec)/sin(lat));
%if el>=elc;az=pi-az;end
%if el<=elc & ha>0;az=pi+pi+az;end
%-----------------------------------test quadrant selection----------------
%%w=asin(-cos(el)*sin(az)/cos(dec));
ahk=asin(-cos(el)*sinaz/cos(dec));
if el<asin(sin(dec)*sin(lat)); 
    if ahk>0; ahk=pi-ahk; 
    else; ahk=-pi-ahk; end
end
%cosw=acos(cosz-sin(dec)*sin(lat))/(cos(dec)*cos(lat));

el=el*180/pi;
%if el> -0.56; refrac=3.51561*(.1594+.0196*el+.00002*el*el)/(1+.505*el+.0845*el*el);
%else; refrac=.56; end
if el>=19.225; 
  refrac=.00452*3.51823/tan(el*pi/180); 
  al=(el+refrac)*pi/180;
  aha=asin(-cos(al)*sinaz/cos(dec));
  %%aha=acos(sin((el+refrac)*pi/180)-sin(dec)*sin(lat))/(cos(dec)*cos(lat));
  %%aha=asin(-cos((el+refrac)*pi/180)*sin(az)/sin(dec+r90));
elseif (el>-.766)&(el<19.225);
  refrac=3.51823*(.1594+.0196*el+.00002*el*el)/(1+.505*el+.0845*el*el); 
  al=(el+refrac)*pi/180;
  aha=asin(-cos(al)*sinaz/cos(dec));
  %%aha=acos(sin((el+refrac)*pi/180)-sin(dec)*sin(lat))/(cos(dec)*cos(lat));
  %%aha=asin(-cos((el+refrac)*pi/180)*sin(az)/sin(dec+r90));
  %%if az<pi/2; aha=pi-aha; end
  %%if az>pi/2; aha=aha-pi; end
elseif el<=-.766; 
  refrac=0; 
  al=(el+refrac)*pi/180; 
  aha=nan;
end
%el=pi*(el+refrac)/180;
if al<asin(sin(dec)*sin(lat)); 
    if aha>0; aha=pi-aha; 
    else; aha=-pi-aha; end
end
azk=asin(-cos(dec)*sin(aha)/cos(al));
if dec~=0
  if cos(r90-al)*sin(lat)<sin(dec)
    if azk<0; azk=azk+pi+pi; end; azk=pi-azk;
  end
end
%%w2=acos(sin((el)*pi/180)-sin(dec)*sin(lat))/(cos(dec)*cos(lat));
%el=el+refrac;
%aha=asin(-cos((el+refrac)*pi/180)*sin(az)/sin(dec+r90));
%if el+refrac<0; aha=nan; end; %may need to set a flag on the ShBand CR10X
%interesting to plot aha|el as well as aha(t),el(t) together
az=az*180/pi;
azk=azk*180/pi;
%el=el*180/pi;
al=al*180/pi;
%RETURN az,el in degrees; all else in radians