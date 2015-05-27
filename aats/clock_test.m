clear
close all
%opens AATS-14 clock data file
[filename,pathname]=uigetfile('d:\beat\data\ACE-2\clock\','Choose AATS-14 clock File', 0, 0);
fid=fopen([pathname filename]);
hdr1=fgetl(fid)
hdr2=fgetl(fid)

data=fscanf(fid,'%g',[2,inf]);
fclose(fid);
PDMS=mod(data(1,:),86400)/60/60;
Sp1_min_PDMS=data(2,:);

%opens NOVA clock data file
[filename,pathname]=uigetfile('d:\beat\data\ACE-2\Nova\','Choose NOVA clock File', 0, 0);
fid=fopen([pathname filename]);
for i=1:2
  fgetl(fid);
end
data=fscanf(fid,'%g',[2,inf]);
fclose(fid);
Nova=mod(data(1,:),86400)/60/60;
PDMS_min_Nova=data(2,:);

%opens TransVector clock data file
[filename,pathname]=uigetfile('d:\beat\data\ACE-2\TransVector\','Choose NOVA clock File', 0, 0);
fid=fopen([pathname filename]);
for i=1:2
  fgetl(fid);
end
data=fscanf(fid,'%g',[2,inf]);
fclose(fid);

tv=mod(data(1,:),86400)/60/60;
PDMS_min_tv=data(2,:);


figure(1)
plot(tv,PDMS_min_tv,Nova,PDMS_min_Nova,PDMS,Sp1_min_PDMS)
title(hdr1)
xlabel('UT')
ylabel('Delta t (sec)')
%axis([-inf inf -20 20])
grid on
legend('PDMS-TransVector','PDMS-NOVA','AATS14-PDMS')

i=find(PDMS<=max(Nova) & PDMS>=min(Nova));
PDMS_min_Nova_interp= interp1(Nova,PDMS_min_Nova,PDMS(i));

j=find(PDMS<=max(tv) & PDMS>=min(tv));
PDMS_min_tv_interp= interp1(tv,PDMS_min_tv,PDMS(j));

figure(2)
plot(PDMS(j),PDMS_min_tv_interp+Sp1_min_PDMS(j),PDMS(i),PDMS_min_Nova_interp+Sp1_min_PDMS(i))
title(hdr1)
xlabel('UT')
ylabel('Delta t (sec)')
%axis([-inf inf -20 20])
legend('AATS14-TransVector','AATS14-NOVA')
grid on
