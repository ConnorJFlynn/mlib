% Reads MODTRAN35 v1.1 tape7 output file created when run in irradiance mode
% created 5.2.1997 by Beat Schmid
clear
hold off

pathname='c:\beat\data\filter\';
filename=str2mat('300_g.prn','313_g.prn','305_1.prn','310_1.prn','320_1.prn','340_1.prn','368_3.prn');
filename=str2mat(filename,'412_3.prn','450_3.prn');
filename=str2mat(filename,'500_3.prn','610_3.prn');
filename=str2mat(filename,'675_3.prn','719_3.prn');
filename=str2mat(filename,'778_3.prn','817_3.prn');
filename=str2mat(filename,'862_3.prn','946_3.prn');
filename=str2mat(filename,'1024_3.prn');

%filename=str2mat('300_g.prn','313_g.prn','305_1.prn','310_1.prn','320_1.prn','340_1.prn','368_2.prn','368_3.prn','368_4.prn');
%filename=str2mat(filename,'412_2.prn','412_3.prn','412_4.prn','450_2.prn','450_3.prn','450_4.prn');
%filename=str2mat(filename,'500_1.prn','500_2.prn','500_3.prn','500_4.prn','610_1.prn','610_2.prn','610_3.prn','610_4.prn');
%filename=str2mat(filename,'675_1.prn','675_2.prn','675_3.prn','675_4.prn','719_2.prn','719_3.prn','719_4.prn');
%filename=str2mat(filename,'778_2.prn','778_3.prn','778_4.prn','817_2.prn','817_3.prn','817_4.prn');
%filename=str2mat(filename,'862_1.prn','862_2.prn','862_3.prn','862_4.prn','946_1.prn','946_2.prn','946_3.prn','946_4.prn');
%filename=str2mat(filename,'1024_1.prn','1024_2.prn','1024_3.prn','1024_4.prn');

%nominal_cwvl=[300 313 305 310 320 340 368 412 450 500 610 675 719 778 817 862 946 1024];

fid2=fopen('c:\beat\modtran\irradiance.txt','a');
fid=fopen('c:\beat\modtran\TP7_irr.ms','r')
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
 data=fscanf(fid,'%f',[5,nwvl]);
 line=fgetl(fid);
 line=fgetl(fid); 
 
 wvl=data(1,:);
 direct_sol=data(3,:);
 extra_sol=data(4,:);

 %direct_sol = direct_sol.*wvl.^2/1e3;
 %extra_sol = extra_sol.*wvl.^2/1e3;
 %wvl=1e7./wvl;

 for ifilt=1:18
  [iangle,ifilt]
  fid3=fopen([pathname filename(ifilt,:)]);
  data=fscanf(fid3, '%f', [2,inf]);
  fclose(fid3);
  wvl_SPM=data(1,:);
  wvl_SPM=1e7./wvl_SPM;
  response=data(2,:)/max(data(2,:));

%  x0=nominal_cwvl(ifilt)
%  wvl_SPM=[x0-2:0.01:x0+2];
%  sigma=0.215;
%  response=gauss(wvl_SPM,x0,sigma);
%  response=response/max(response);
%  wvl_SPM=1e7./wvl_SPM;

  i=find(wvl<=max(wvl_SPM) & wvl >= min(wvl_SPM));
  response2= INTERP1(wvl_SPM,response,wvl(i));
  direct(ifilt,iangle)=trapz(wvl(i),response2'.*direct_sol(i));
   
%  direct(ifilt,iangle)=direct_sol(wvl==cwvl(ifilt));

  if iangle==1
  E0_true(ifilt)=trapz(wvl(i),response2'.*extra_sol(i) );  
% E0_true(ifilt)=extra_sol(wvl==cwvl(ifilt));  
  end;
end;
end;

fclose(fid);
fclose(fid2);
hold off

