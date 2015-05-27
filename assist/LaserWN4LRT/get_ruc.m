function prof=get_ruc(lon,lat,year,mon,day,hr)
load ruc_grids.txt;
%load wn_assist.mat
lower_p=[1010.,1005.,1000.,995.,990.,985.,980.,975.,970.,965.,960.,955.,950.,945.,...
          940.,935.,930.,925.,920.,915.,910.,905.,900.,880.,860.,840.,...
          820.,800.,780.,760.,740.,720.,700.,680.,660.,640.,620.,600.];
     iasi_p=[   0.00500000,    0.0161000,    0.0384000,    0.0769000,     0.137000,     0.224400...
,     0.345400,     0.506400,     0.714000,     0.975300,      1.29720,      1.68720...
,      2.15260,      2.70090,      3.33980,      4.07700,      4.92040,      5.87760...
,      6.95670,      8.16550,      9.51190,      11.0038,      12.6492,      14.4559...
,      16.4318,      18.5847,      20.9224,      23.4526,      26.1829,      29.1210...
,      32.2744,      35.6504,      39.2566,      43.1001,      47.1882,      51.5278...
,      56.1259,      60.9895,      66.1252,      71.5398,      77.2395,      83.2310...
,      89.5203,      96.1138,      103.017,      110.237,      117.777,      125.646...
,      133.846,      142.385,      151.266,      160.496,      170.078,      180.018...
,      190.320,      200.989,      212.028,      223.441,      235.234,      247.408...
,      259.969,      272.919,      286.262,      300.000,      314.137,      328.675...
,      343.618,      358.966,      374.724,      390.892,      407.474,      424.470...
,      441.882,      459.712,      477.961,      496.630,      515.720,      535.232...
,      555.167,      575.525,      596.306,      617.511,      639.140,      661.192...
,      683.667,      706.565,      729.886,      753.627,      777.789,      802.371...
,      827.371,      852.788,      878.620,      904.866,      931.523,      958.591...
,      986.066,      1013.95,      1042.23,      1070.92,      1100.00];


[p2,IX]=sort(iasi_p,'descend');
p=cat(2,lower_p,iasi_p(IX(22:101)));
ruc_lat=reshape(ruc_grids(:,3),225,301);
ruc_lon=reshape(ruc_grids(:,4),225,301);
% lat=37.10;lon=-76.39;
% year=2010;mon=7;day=7;hr=03;
%lat=36.32;lon=-115.62;
% for i=1:224
%     for j=1:300
%         if ((ruc_lon(i,j)<lon) && (ruc_lon(i+1,j+1)>lon) && (ruc_lat(i,j)<lat) && (ruc_lat(i+1,j+1)>lat) )
%             ix=i;iy=j;
%             break
%         end
%     end
% end
d=acos(sind(ruc_lat).*sind(lat)+cosd(ruc_lat).*cosd(lat).*cosd(lon-ruc_lon))*6371;
[mina,I]=min(d(:));
ix=mod(I,225);iy=floor(I/225)+1;
% ruc_lat=ruc_lat(ix-20:ix+20,iy-20:iy+20);
% ruc_lon=ruc_lon(ix-20:ix+20,iy-20:iy+20);
ruc_lat=ruc_lat(ix-30:ix+30,iy-30:iy+30);
ruc_lon=ruc_lon(ix-30:ix+30,iy-30:iy+30);
path='/Users/smith/Desktop/LaserWN4LRT/output/';
url='http://nomads.ncdc.noaa.gov/data/ruc/';
apendstr='00_000.grb';
filestr='ruc2_252_';
monstr=int2str(mon);
if (mon <10)
    monstr=['0',int2str(mon)];
end
daystr=int2str(day);

if (day<10)
    daystr=['0',int2str(day)];
end
timestr=int2str(hr);
if (hr<10)
    timestr=['0',int2str(hr)];
end
datestr=[int2str(year),monstr,daystr];
monthdir=[datestr(1:6),'/'];
datedir=[datestr(1:8),'/'];

clear fid
urlstr=[url,monthdir,datedir,filestr,datestr,'_',timestr,apendstr];
grbfile1=[path,filestr,datestr,'_',timestr,apendstr];
fid=fopen(grbfile1);
if (fid<0)
    %download the ruc grbfile
    tic
    urlwrite(urlstr,grbfile1);
    toc
end
if (fid >0)
fclose(fid);
end
%for itime=1:14
temp=double(nj_varget(grbfile1,'Temperature',[1,1,ix-30,iy-30],[inf,inf,61,61],[1,1,1,1]));
rh=double(nj_varget(grbfile1,'Relative_humidity',[1,1,ix-30,iy-30],[inf,inf,61,61],[1,1,1,1]));
gh=double(nj_varget(grbfile1,'Geopotential_height',[1,1,ix-30,iy-30],[inf,inf,61,61],[1,1,1,1]));
pp=double(nj_varget(grbfile1,'Pressure',[1,1,ix-30,iy-30],[inf,inf,61,61],[1,1,1,1]));
surft=double(nj_varget(grbfile1,'Temperature_surface',[1,ix-30,iy-30],[inf,61,61],[1,1,1]));
surfp=double(nj_varget(grbfile1,'Pressure_surface',[1,ix-30,iy-30],[inf,61,61],[1,1,1]))/100.;
surfgh=double(nj_varget(grbfile1,'Geopotential_height_surface',[1,ix-30,iy-30],[inf,61,61],[1,1,1]));
surfrh=double(nj_varget(grbfile1,'Relative_humidity_height_above_ground',[1,1,ix-30,iy-30],[inf,inf,61,61],[1,1,1,1]));

a=size(surft);
for i=1:a(1)
    for j=1:a(2)
        surfq(i,j)=mrcal(surft(i,j),surfrh(i,j),surfp(i,j));
    end
end
p1=1000:-25:100;
% rucsurfq4iasi=griddata(ruc_lon,ruc_lat,surfq,IASI_lon,IASI_lat);
% rucsurft4iasi=griddata(ruc_lon,ruc_lat,surft,IASI_lon,IASI_lat);
% rucsurfp4iasi=griddata(ruc_lon,ruc_lat,surfp,IASI_lon,IASI_lat);
 rucsurfq4sonde=griddata(ruc_lon,ruc_lat,surfq,-76.39,37.10);
 rucsurft4sonde=griddata(ruc_lon,ruc_lat,surft,-76.39,37.10);
 rucsurfp4sonde=griddata(ruc_lon,ruc_lat,surfp,-76.39,37.10);
 rucsurfgh4sonde=griddata(ruc_lon,ruc_lat,surfgh,-76.39,37.10);

for k=1:37
    rh1=reshape(rh(k,:,:),a(1),a(2));
    t1=reshape(temp(k,:,:),a(1),a(2));
    gh1=reshape(gh(k,:,:),a(1),a(2));
    for i=1:a(1)
        for j=1:a(2)
            q(i,j)=mrcal(t1(i,j),rh1(i,j),p1(k));
        end
    end
%     rucq4iasi(:,k)=griddata(ruc_lon,ruc_lat,q,IASI_lon,IASI_lat);
%     ruct4iasi(:,k)=griddata(ruc_lon,ruc_lat,t1,IASI_lon,IASI_lat);
    rucq4sonde(:,k)=griddata(ruc_lon,ruc_lat,q,-76.39,37.10);
    ruct4sonde(:,k)=griddata(ruc_lon,ruc_lat,t1,-76.39,37.10);
    rucgh4sonde(:,k)=griddata(ruc_lon,ruc_lat,gh1,-76.39,37.10);

end
indx=find(p1<rucsurfp4sonde);
% rucq4iasi=[rucsurfq4iasi,rucq4iasi];
% ruct4iasi=[rucsurft4iasi,ruct4iasi];
prof.t=[rucsurft4sonde,ruct4sonde(indx)];
prof.q=[rucsurfq4sonde,rucq4sonde(indx)];
prof.p=[rucsurfp4sonde,p1];
%rucgh(itime,:)=[rucsurfgh4sonde,rucgh4sonde];
%end