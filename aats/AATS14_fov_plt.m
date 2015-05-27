%AATS14_fov_plt.m
%reads 7730-byte/record FOV data file written by VB AATS-14 data acquistion program

clear
close all

% lambda_AATS14=[380.3 448.25 452.97 499.4 524.7 605.4 666.8 711.8 778.5 864.4 939.5 1018.7 1059.0 1557.5]; %For ACE-2
%lambda_AATS14=[380.3 448.25 452.97 499.4 524.7 605.4 675 354 778.5 864.4 939.5 1018.7 1240 1557.5]; % For SAFARI-2000
%lambda_AATS14=[380 448 1060 500 525 605 675 354 779 865 940 1020 1240 1558]; % For ACE-Asia and CLAMS
lambda_AATS14=[380 453 1240 500 520 605 675 354 779 865 940  1020 2138 1558]; % since SOLVE-2


[filename,pathname]=uigetfile('c:\beat\data\ames\f????05.*','Choose a File');
%[filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\f????03.*','Choose a File');
%[filename,pathname]=uigetfile('c:\beat\data\Mauna Loa\f????05.*','Choose a File');
%[filename,pathname]=uigetfile('c:\beat\data\Dryden\f????02.*','Choose a File');
%[filename,pathname]=uigetfile('c:\beat\data\solve2\f??????.*','Choose a File');
fid=fopen(deblank([pathname filename]));

start_rec=1
nrec=inf;

%direction='elev'; 
direction='azim'; 

cumulative_bytes=0
Header=fread(fid,[3 inf],'3*uchar',7727);
cumulative_bytes=cumulative_bytes+3
status=fseek(fid,(start_rec-1)*7730+3,'bof');
[Detector_volts,count1]=fread(fid,[1442 nrec],'1442*float',7730-4*1442);
cumulative_bytes=cumulative_bytes+4*1442
status=fseek(fid,(start_rec-1)*7730+cumulative_bytes,'bof');
[hhmmss,count2]=fread(fid,[309 nrec],'309*uchar',7730-309);
cumulative_bytes=cumulative_bytes+309
status=fseek(fid,(start_rec-1)*7730+cumulative_bytes,'bof');
[Position,count3]=fread(fid,[412 nrec],'412*float',7730-4*412);
cumulative_bytes=cumulative_bytes+4*412
fclose(fid);

nrec=size(Detector_volts,2);
%if nrec>3 nrec=3; end

for irec=1:nrec,
   for iang=1:103,
      for jwl=1:14,
         Voltsig(iang,jwl,irec)=Detector_volts(14*(iang-1)+jwl,irec);
      end
   end
end

for irec=1:nrec,
   for iang=1:103,
      idx=3*(iang-1);
      UT_fov(iang,irec)=hhmmss(idx+1,irec)+hhmmss(idx+2,irec)/60+hhmmss(idx+3,irec)/3600;
   end
end

for irec=1:nrec,
   for iang=1:103,
      idx=4*(iang-1);
      Elev_pos(iang,irec)=Position(idx+1,irec);
      Azim_pos(iang,irec)=Position(idx+2,irec);
      Elev_err(iang,irec)=Position(idx+3,irec);
      Azim_err(iang,irec)=Position(idx+4,irec);
   end
end


figure(1)
set(1,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
orient landscape
symb1 = '-'
symb2 = '--'
for irec = 1:nrec,
   
 if strcmp(direction,'elev')   
   abscissa = Elev_pos;
   error = Elev_err;
   xtext='Elevation position (deg)';
   xmin = floor(Elev_pos(50,irec)-5);
   xmax = ceil(Elev_pos(50,irec)+5);
 elseif strcmp(direction,'azim') 
   abscissa = Azim_pos;
   error = Azim_err;
   xtext='AATS-14 Azimuth position (deg)';
   xmin = floor(Azim_pos(50,irec)-10);
   xmax = ceil(Azim_pos(50,irec)+10);
 end

 subplot(nrec,1,irec)
 hold off
 plot(abscissa(:,irec),Voltsig(:,1:7,irec),symb1(1,:))
 hold on
 plot(abscissa(:,irec),Voltsig(:,8:14,irec),symb2(1,:))
 axis([-inf inf -inf 10])
 grid on
 ylabel('Signals(V)')
 title(strcat('AATS-14 FOV:     ',filename,'  Rec:',num2str(irec)))
 legend(num2str(lambda_AATS14(1)),num2str(lambda_AATS14(2)),num2str(lambda_AATS14(3)),num2str(lambda_AATS14(4)),num2str(lambda_AATS14(5)),num2str(lambda_AATS14(6)),num2str(lambda_AATS14(7)),...
        num2str(lambda_AATS14(8)),num2str(lambda_AATS14(9)),num2str(lambda_AATS14(10)),num2str(lambda_AATS14(11)),num2str(lambda_AATS14(12)),num2str(lambda_AATS14(13)),num2str(lambda_AATS14(14)));

 if irec==nrec
    xlabel(xtext)
 end
end

elev_delta=2;
azim_delta=2;

%plot normalized scans
%normalize each to its first point
symb1 = '.-'
symb2 = '--'   
for irec = 1:nrec,
figure(irec+1)
orient portrait
set(irec+1,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown,black
   
   for jwl=1:14,
      Voltnorm(:,jwl)=Voltsig(:,jwl,irec)./Voltsig(52,jwl,irec);
   end
   
   if strcmp(direction,'elev')   
   	abscissa = Elev_pos;
   	error = Elev_err;
   	xtext='Elevation position (deg)';
   	xmin = floor(Elev_pos(52,irec)-elev_delta);
   	xmax = ceil(Elev_pos(52,irec)+elev_delta);
 	elseif strcmp(direction,'azim') 
   	abscissa = Azim_pos;
   	error = Azim_err;
   	xtext='AATS-14 Azimuth position (deg)';
   	xmin = floor(Azim_pos(52,irec)-azim_delta);
   	xmax = ceil(Azim_pos(52,irec)+azim_delta);
 	end

 subplot(2,1,1)
 plot(abscissa(:,irec),Voltnorm(:,1:7),symb1(1,:))
 axis([xmin xmax 0.9 inf])
 grid on
 ylabel('Normalized Signal(V)')
  title(strcat('AATS-14 FOV:     ',filename,'  Rec:',num2str(irec)))
 legend(num2str(lambda_AATS14(1)),num2str(lambda_AATS14(2)),num2str(lambda_AATS14(3)),num2str(lambda_AATS14(4)),num2str(lambda_AATS14(5)),num2str(lambda_AATS14(6)),num2str(lambda_AATS14(7)));
 
 subplot(2,1,2)
 plot(abscissa(:,irec),Voltnorm(:,8:14),symb1(1,:))
 axis([xmin xmax 0.9 inf])
 grid on
 ylabel('Normalized Signal(V)')
 legend(num2str(lambda_AATS14(8)),num2str(lambda_AATS14(9)),num2str(lambda_AATS14(10)),num2str(lambda_AATS14(11)),num2str(lambda_AATS14(12)),num2str(lambda_AATS14(13)),num2str(lambda_AATS14(14)));
 %title(strcat('AATS-14 FOV:     ',filename,'  Rec:',num2str(irec)))
 %if irec==nrec
    xlabel(xtext)
 %end
end


%plot normalized scans vs true angle
%normalize each to its first point
symb1 = '.-'
symb2 = '--'   
for irec = 1:nrec,
figure(irec+10)
orient portrait
set(irec+10,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown,black
   
   for jwl=1:14,
      Voltnorm(:,jwl)=Voltsig(:,jwl,irec)./Voltsig(52,jwl,irec);
   end
   
   if strcmp(direction,'elev')   
   	abscissa = Elev_pos;
   	error = Elev_err;
   	xtext='AATS-14 True Elevation Position (deg)';
   	xmin = floor(Elev_pos(52,irec)-elev_delta);
      xmax = ceil(Elev_pos(52,irec)+elev_delta);
      for k=2:102,
         angle_calc(k,1)=Elev_pos(1,irec)-0.1*(52-k);
      end
      angle_true=[Elev_pos(1,irec);angle_calc(2:102,1);Elev_pos(103,irec)];
 	elseif strcmp(direction,'azim') 
   	abscissa = Azim_pos;
   	error = Azim_err;
   	xtext='AATS-14 True Azimuth Position (deg)';
   	xmin = floor(Azim_pos(52,irec)-azim_delta);
   	xmax = ceil(Azim_pos(52,irec)+azim_delta);
      for k=2:102,
         angle_calc(k,1)=Azim_pos(1,irec)-0.1*(52-k);
      end
      angle_true=[Azim_pos(1,irec);angle_calc(2:102,1);Azim_pos(103,irec)];
 	end

 subplot(2,1,1)
 plot(angle_true,Voltnorm(:,1:7),symb1(1,:))
 axis([xmin xmax 0.9 inf])
 grid on
 ylabel('Normalized Signal(V)')
  title(strcat('AATS-14 FOV:     ',filename,'  Rec:',num2str(irec)))
 legend(num2str(lambda_AATS14(1)),num2str(lambda_AATS14(2)),num2str(lambda_AATS14(3)),num2str(lambda_AATS14(4)),num2str(lambda_AATS14(5)),num2str(lambda_AATS14(6)),num2str(lambda_AATS14(7)));
 
 subplot(2,1,2)
 plot(angle_true,Voltnorm(:,8:14),symb1(1,:))
 axis([xmin xmax 0.9 inf])
 grid on
 ylabel('Normalized Signal(V)')
 legend(num2str(lambda_AATS14(8)),num2str(lambda_AATS14(9)),num2str(lambda_AATS14(10)),num2str(lambda_AATS14(11)),num2str(lambda_AATS14(12)),num2str(lambda_AATS14(13)),num2str(lambda_AATS14(14)));
 %title(strcat('AATS-14 FOV:     ',filename,'  Rec:',num2str(irec)))
 %if irec==nrec
    xlabel(xtext)
 %end
end


%plots of Elev, Azim vs record number: figures 31,32,33,...
angles=[1:103];
for irec = 1:nrec,
 figure(irec+30)
 orient landscape
 subplot(2,1,1)
 plot(angles,Elev_pos(:,irec),'-o')
 axis([0 110 -inf inf])
 xlabel('Rec #')
 ylabel('Elevation (deg)')
 grid on
 title(strcat('AATS-14 FOV:     ',filename,'  Rec:',num2str(irec)))
 subplot(2,1,2)
 plot(angles,Azim_pos(:,irec),'-o')
 axis([0 110 -inf inf])
 xlabel('Rec #')
 ylabel('Azimuth (deg)')
 grid on
end