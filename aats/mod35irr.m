% Reads MODTRAN35 plot file
% created 19.3.1996 by Beat Schmid

clear

pathname='c:\beat\data\filter\';
filename=str2mat('300_g.prn','313_g.prn','305_1.prn','310_1.prn','320_1.prn','340_1.prn','368_2.prn','368_3.prn','368_4.prn');
filename=str2mat(filename,'412_2.prn','412_3.prn','412_4.prn','450_2.prn','450_3.prn','450_4.prn');
filename=str2mat(filename,'500_1.prn','500_2.prn','500_3.prn','500_4.prn','610_1.prn','610_2.prn','610_3.prn','610_4.prn');
filename=str2mat(filename,'675_1.prn','675_2.prn','675_3.prn','675_4.prn','719_2.prn','719_3.prn','719_4.prn');
filename=str2mat(filename,'778_2.prn','778_3.prn','778_4.prn','817_2.prn','817_3.prn','817_4.prn');
filename=str2mat(filename,'862_1.prn','862_2.prn','862_3.prn','862_4.prn','946_1.prn','946_2.prn','946_3.prn','946_4.prn');
filename=str2mat(filename,'1024_1.prn','1024_2.prn','1024_3.prn','1024_4.prn');

fid2=fopen('c:\temp\irrad.txt','a');

fid=fopen('c:\temp\tape7.dat','r');


for i_airmass=1:12
 for ii=1:8
  line=fgetl(fid);
 end

 data=fscanf(fid,'%f',[4,1]);

 wv_start=data(1)
 wv_end=data(2)
 wv_step=data(3)
 num=(-wv_start+wv_end)/wv_step + 1

 line=fgetl(fid);
 line=fgetl(fid);
 line=fgetl(fid);

 data=fscanf(fid,'%f',[5,num]);
 
 line=fgetl(fid);
 line=fgetl(fid);

 wv_num=data(1,:);
 sol_tr=data(3,:);
 sol   =data(4,:);

 clear data;

 for ifilt=1:2
 [i_airmass,ifilt]
 fid3=fopen([pathname filename(ifilt,:)]);
 data=fscanf(fid3, '%f', [2,inf]);
 fclose(fid3);

 wn_SPM=1e7*ones(1,size(data'))./data(1,:);
 response=data(2,:)/max(data(2,:));

 i=find(wv_num<=max(wn_SPM) & wv_num >= min(wn_SPM));
 response2= INTERP1(wn_SPM,response,wv_num(i));

 figure(1); 
 semilogy(wv_num,sol_tr,wv_num,sol,wv_num(i),response2);
 xlabel('Wavelength (cm-1)');
 ylabel('Irradiance');

 x =trapz(wv_num(i),response2'.*sol_tr(i))
 y =trapz(wv_num(i),response2'.*sol(i))
 x/y

 % write to file
 fprintf(fid2,'%s',filename(ifilt,:));
 fprintf(fid2,'%13.5e',x/y);
 fprintf(fid2,'%6i',i_airmass);
 fprintf(fid2,'\n');

 end

end

fclose(fid2);
fclose(fid);
fix(clock)
