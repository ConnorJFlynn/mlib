function [pmm,tmm,qmm]=get_gfsa(lon,lat,year,mon,day,hr)

%clear all
%year=2010;mon=6;day=22;hr=14;
index6=floor(hr/6)+1;
timeweight=hr/6.0-floor(hr/6);

%lon=-76.3;lat=37;
ozmass=47.985;
airmass=28.97;
path='/Users/smith/Desktop/LaserWN4LRT/output/';
url='http://nomads.ncdc.noaa.gov/data/gfsanl/';
%year=2008;
%month=05;
timestr=['00';'06';'12';'18';'00'];
apendstr='00_000.grb';
filestr='gfsanl_3_';

if lon<0
    lon=360+lon;
end
lat=91-lat;
for i=1:9
globallon(i,1:9)=round(lon)-4:round(lon)+4;
end
for i=1:9
globallat(1:9,i)=round(lat)-4:round(lat)+4;
end


aerip=[1000.,995.,990.,985.,980.,975.,970.,965.,960.,955.,950.,...
       945.,940.,935.,930.,925.,920.,915.,910.,905.,900.,880.,860.,...
	   840.,820.,800.,780.,760.,740.,720.,700.,680.,660.,640.,620.,...
	   600.,550.,500.,450.,400.,350.,300.,250.,200.,175.,150.,125.,...
	   100.,75.,50.,30.,25.,20.,15.,10.,7.,5.,4.,3.,2.];
ozref=[0.02901,0.02913,0.02926,0.02938,...
       0.02951,0.02963,0.02976,0.02989,0.03002,0.03015,0.03027,...        
       0.03041,0.03054,0.03067,0.03080,0.03093,0.03107,0.03120,...        
       0.03134,0.03147,0.03157,0.03195,0.03233,0.03272,0.03311,...        
       0.03351,0.03385,0.03421,0.03457,0.03494,0.03514,0.03527,...        
       0.03541,0.03556,0.03595,0.03650,0.03795,0.03961,0.04150,...        
       0.04366,0.04764,0.05392,0.06529,0.08405,0.09597,0.10984,...        
       0.13151,0.20944,0.63460,1.69985,4.30000,5.57585,6.99681,...        
       8.45820,9.60463,9.76594,9.22089,8.55498,7.41904,5.48908];
pt=[ 1000,975,950,925,900,850,800,750,700,650,600,550,500,450,400,350,....
     300,250,200,150,100, 70, 50, 30, 20, 10];
o=interp1(log(aerip),ozref,log(pt));
%o=[o(1),o];
%fid1=fopen('gfsanl_200805_aerose.txt','w');


%dayinx=1:31;
%for i=1:5:31
for j=index6:index6+1
if j==5
    daten=datenum(year,mon,day)+1;
    datev=datevec(daten);
    year=datev(1);mon=datev(2);day=datev(3);
end
monstr=int2str(mon);

if (mon <10)
    monstr=['0',int2str(mon)];
end
daystr=int2str(day);

if (day<10)
    daystr=['0',int2str(day)];
end
datestr=[int2str(year),monstr,daystr];
monthdir=[datestr(1:6),'/'];
datedir=[datestr(1:8),'/'];

clear fid
urlstr=[url,monthdir,datedir,filestr,datestr,'_',timestr(j,:),apendstr];
grbfile=[path,filestr,datestr,'_',timestr(j,:),apendstr];
fid=fopen(grbfile);
if (fid<0)
    %download the ruc grbfile
%    tic
    urlwrite(urlstr,grbfile);
%    toc
end
if (fid >0)
fclose(fid);
end
  temp=nj_varget(grbfile,'Temperature',[1 1 round(lat)-4 round(lon)-4],[inf inf 9 9],[1 1 1 1]);
  %temp=reshape(temp,26,9,9);
  temp_surf=nj_varget(grbfile,'Temperature_surface',[1 round(lat)-4 round(lon)-4],[inf 9 9],[1 1 1]);
  %temp_surf=reshape(temp_surf,9,9);
  p_surf=nj_varget(grbfile,'Pressure_surface',[1 round(lat)-4 round(lon)-4],[inf 9 9],[1 1 1])/100;
  %p_surf=reshape(p_surf,9,9);
  rh=nj_varget(grbfile,'Relative_humidity',[1 1 round(lat)-4 round(lon)-4],[inf inf 9 9],[1 1 1 1]);
  %sizeofrh=size(rh);
  %rh=reshape(rh,sizeofrh(1),9,9);
  rh_surf=nj_varget(grbfile,'Relative_humidity_height_above_ground',[1 1 round(lat)-4 round(lon)-4],[inf inf 9 9],[1 1 1 1]);
  %rh_surf=reshape(rh_surf,9,9);
  ozmr=nj_varget(grbfile,'Ozone_mixing_ratio',[1 1 round(lat)-4 round(lon)-4],[inf inf 9 9],[1 1 1 1]);
  %ozmr=reshape(ozmr,6,9,9);
  p_surfloc=interp2(globallon,globallat,p_surf,lon,lat);
  temp_surfloc=interp2(globallon,globallat,temp_surf,lon,lat,'spline');
  for ii=1:26
      layer=temp(ii,:,:);
      layer=reshape(layer,9,9);
      temp_loc(ii)=interp2(globallon,globallat,layer,lon,lat,'spline');
  end
  for jj=1:9
      for kk=1:9
          es=svpwat(temp_surf(jj,kk));
          wvmr_surf(jj,kk)=622.0*es/(p_surf(jj,kk)-es)/100*rh_surf(jj,kk)+0.001;
        for ii=1:25
            es=svpwat(temp(ii,jj,kk));
            wvmr(ii,jj,kk)=622.0*es/(pt(ii)-es)/100*rh(ii,jj,kk)+0.001;
        end
      end
  end
  wvmr_surfloc=interp2(globallon,globallat,wvmr_surf,lon,lat,'spline');
  for ii=1:25
      layer=wvmr(ii,:,:);
      layer=reshape(layer,9,9);
      wvmr_loc(ii)=interp2(globallon,globallat,layer,lon,lat,'spline');
  end
  for ii=1:6
      layer=ozmr(ii,:,:);
      layer=reshape(layer,9,9);
      ozmr_loc(ii)=interp2(globallon,globallat,layer,lon,lat,'spline');
  end
  if p_surfloc>pt(1)
      prof(j).p=[p_surfloc,pt];
 %     prof(j).o=[o(1),o(1:21),ozmr_loc];
      %prof(i).o(22:27)=ozmr_loc;
      prof(j).t=[temp_surfloc,temp_loc];
      prof(j).q=[wvmr_surfloc,wvmr_loc,0.001];
      
  end
  
  if p_surfloc<pt(1)
  for ii=2:11
      if pt(ii-1)>p_surfloc;% && p(ii)<p_surfloc
          ind=ii;
      end
  end
    prof(j).p=[p_surfloc,pt(ind:26)];
%    prof(j).o=[o(ind-1:21),ozmr_loc];
    prof(j).t=[temp_surfloc,temp_loc(ind:26)];
    prof(j).q=[wvmr_surfloc,wvmr_loc(ind:25),0.001];
  end
  
  %   for ii=1:max(size(indx))
%      o(22:27)=ozmr(1:6,indx(ii))*airmass/ozmass*1e6;
%      t=[temp_surf(indx(ii)),temp(:,indx(ii))'];
%      rh1=[rh_surf(indx(ii)),rh(:,indx(ii))'];
%      p=[p_surf(indx(ii)),pt];
%      q(23:24)=0.002;q(25:27)=0.001;
%      for jj=1:22
%          es=satwvp(t(jj));
%          q(jj)=622.0*es/(p(jj)-es)/100*rh1(jj)+0.001;
%      end
%      if (p(1)<p(2))
%          aa=p(1);bb=t(1);cc=q(1);
%          p(1)=p(2);t(1)=t(2);q(1)=q(2);
%          p(2)=aa;t(2)=bb;q(2)=cc;
%      end
%         
% 
%      fprintf(fid1,'%10.3f',p);
%      fprintf(fid1,'\n');
%      fprintf(fid1,'%10.3f',t);
%      fprintf(fid1,'\n');
%      fprintf(fid1,'%10.4f',q);
%      fprintf(fid1,'\n');
%      fprintf(fid1,'%10.4f',o);
%      fprintf(fid1,'\n');
     
%  end
         
         
     
%end
%end
end

            pmm=prof(index6).p*(1-timeweight)+prof(index6+1).p*timeweight;
            tmm=prof(index6).t*(1-timeweight)+prof(index6+1).t*timeweight;
            qmm=prof(index6).q*(1-timeweight)+prof(index6+1).q*timeweight;



%fclose(fid1);