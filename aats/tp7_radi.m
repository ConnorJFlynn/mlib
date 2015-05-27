% Reads MODTRAN35 v1.1 tape7 output file created when run in radiance mode
% created 5.2.1997 by Beat Schmid
clear
hold off

pathname='c:\beat\data\filter\';
filename=str2mat('300_g.prn','313_g.prn','305_1.prn','310_1.prn','320_1.prn','340_1.prn','368_2.prn','368_3.prn','368_4.prn');
filename=str2mat(filename,'412_2.prn','412_3.prn','412_4.prn','450_2.prn','450_3.prn','450_4.prn');
filename=str2mat(filename,'500_1.prn','500_2.prn','500_3.prn','500_4.prn','610_1.prn','610_2.prn','610_3.prn','610_4.prn');
filename=str2mat(filename,'675_1.prn','675_2.prn','675_3.prn','675_4.prn','719_2.prn','719_3.prn','719_4.prn');
filename=str2mat(filename,'778_2.prn','778_3.prn','778_4.prn','817_2.prn','817_3.prn','817_4.prn');
filename=str2mat(filename,'862_1.prn','862_2.prn','862_3.prn','862_4.prn','946_1.prn','946_2.prn','946_3.prn','946_4.prn');
filename=str2mat(filename,'1024_1.prn','1024_2.prn','1024_3.prn','1024_4.prn');

%********* Reads Kuruz-Spectrum***********************************
fid=fopen('c:\beat\data\sun\sun_kur.dat');
line=fgetl(fid);
line=fgetl(fid);
data=fscanf(fid, '%g %g', [2,inf]);
lambda_sun2=data(1,:);
sun2       =data(2,:);
fclose(fid);
sun2=sun2.*lambda_sun2.^2/1e3;
lambda_sun2=1e7./lambda_sun2;


FOV=0.002 %in sterad
fid2=fopen('c:\beat\modtran\radiance.txt','a');
fid=fopen('c:\beat\modtran\TP7_rad.DAT','r')
for iangle=1:14
 model=fscanf(fid,'%s',[1,1]);
 if (model=='t' | model=='T') model='MODTRAN3' ,end
 if (model=='f' | model=='F') model='LOWTRAN7' ,end
 line=fgetl(fid);
 line=fgetl(fid);
 line=fgetl(fid);
 line=fgetl(fid);
 dummy=fscanf(fid,'%2d',[1,1]);
 atmosphere=fgetl(fid);
 geom=fscanf(fid,'%f',[7 1]);
 angle(iangle)=geom(3);
 line=fgetl(fid);
 line=fgetl(fid);
 line=fgetl(fid);
 range=fscanf(fid,'%i',[4 1]);
 line=fgetl(fid);
 line=fgetl(fid);
 line=fgetl(fid);
 nwvl=(range(2)-range(1))/range(3)+1 
 data=fscanf(fid,'%f',[13,nwvl]);
 line=fgetl(fid);
 line=fgetl(fid); 
 
 wvl=data(1,:);
 diffuse_rad=data(10,:);
 direct_rad =data(12,:);

 diffuse_rad=diffuse_rad.*wvl.^2/1e3*FOV;
 direct_rad = direct_rad.*wvl.^2/1e3;
 wvl=1e7./wvl;


 figure(1)
 semilogy(wvl, diffuse_rad./direct_rad);
 xlabel=('Wavelength (nm)');
 ylabel=('Diffuse/Direct');
 hold on
 for ifilt=1:48
  [iangle,ifilt]
  fid3=fopen([pathname filename(ifilt,:)]);
  data=fscanf(fid3, '%f', [2,inf]);
  fclose(fid3);
  wvl_SPM=data(1,:);
  response=data(2,:)/max(data(2,:));

  i=find(wvl<=max(wvl_SPM) & wvl >= min(wvl_SPM));
  response2= INTERP1(wvl_SPM,response,wvl(i));
  diffuse(ifilt,iangle)=-trapz(wvl(i),response2'.*diffuse_rad(i));
  direct(ifilt,iangle)=-trapz(wvl(i),response2'.*direct_rad(i) );
  ratio(ifilt,iangle)=diffuse(ifilt,iangle)/direct(ifilt,iangle)

  if iangle==1
   i=find(lambda_sun2<=max(wvl_SPM) & lambda_sun2 >= min(wvl_SPM));
   response2= INTERP1(wvl_SPM,response,lambda_sun2(i));
   E0_true(ifilt) = -trapz(lambda_sun2(i),response2'.*sun2(i))
  end

 % write to file
  fprintf(fid2,'%s',filename(ifilt,:));
  fprintf(fid2,'%13.5e',angle(iangle),diffuse(ifilt,iangle),direct(ifilt,iangle),ratio(ifilt,iangle));
  fprintf(fid2,'\n');
 end;
end;
fclose(fid);
fclose(fid2);
hold off


