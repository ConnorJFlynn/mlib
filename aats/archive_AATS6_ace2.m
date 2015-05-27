function [ntimwrt,filename_arc]= archive_AATS6_ace2(numlines_info,info_sav,UTdechr,Latitude,...
   Longitude,Pressmb,Airmass,Wvl_microns,Detector_volts,Watvapcolcm,Tautot,...
   Tauray,Taupart,Unctaup,mission_name,FlightNo,dateyr,datemon,dateday);

ntimwrt = length(UTdechr);	%only temporary definition; redefined below

filename_arc='arcAATS6.txt';

%Define skip records for each day 
if(datemon==6)
   
   if(dateday==22)
		filename_arc='acearc06229701.txt';
		idxskp=find(UTdechr<12.5);
      Taupart(idxskp,:)=99;
   elseif(dateday==24)
		filename_arc='acearc06249701.txt';
      idxall=find(UTdechr>0);
      idxwrt=find(idxall~=29);
      ntimwrt=length(idxwrt);
		idxskp864CWV=find(idxall>=1054 & idxall<=1128);
   		Tautot(idxskp864CWV,4)=99.999;
   		Taupart(idxskp864CWV,4)=99.999;
         Unctaup(idxskp864CWV,4)=99.999;
         Watvapcolcm(idxskp864CWV)=999.99;
	elseif(dateday==25)
		filename_arc='acearc06259701.txt';
      idxall=find(UTdechr>0);
      idxwrt=find(idxall>3 & idxall~=428 & idxall<2217);   %>UTC>17.8 for rec>=2217
      ntimwrt=length(idxwrt);
	end
   
elseif(datemon==7)
   
   if(dateday==6)
		filename_arc='acearc07069701.txt';
      idxwrt=find(UTdechr>0);
      ntimwrt=length(idxwrt);
   elseif(dateday==10)
		filename_arc='acearc07109701.txt';
      idxwrt=find((UTdechr>12.8 & UTdechr<13.3) | (UTdechr>14.2));
      ntimwrt=length(idxwrt);
      %skip 525 data for 13.3<t<14.84
      idxskp525=find(UTdechr>13.3 & UTdechr<14.84);
   		Tautot(idxskp525,3)=99.999;
   		Taupart(idxskp525,3)=99.999;
   		Unctaup(idxskp525,3)=99.999;
   	idxskpCWV=find(UTdechr>18. & Watvapcolcm>1.6);
   		Watvapcolcm(idxskpCWV)=999.99;
   elseif(dateday==11)
		filename_arc='acearc07119701.txt';
      idxskp864=find(UTdechr<16.3);
      Taupart(idxskp864,4)=99;
      Taupart(639:676,:)=99;
   elseif(dateday==18)
      filename_arc='acearc07189701.txt';
      idxall=find(UTdechr>0);
      idxwrt=find(idxall~=426 & idxall~=685);
      ntimwrt=length(idxwrt);
	elseif(dateday==19)
      filename_arc='acearc07199701.txt';
      idxwrt=find(UTdechr>0);
      ntimwrt=length(idxwrt);
	elseif(dateday==22)
      filename_arc='acearc07229701.txt';
      idxall=find(UTdechr>0);
      idxwrt=find(idxall>=2);
      ntimwrt=length(idxwrt);
		idxskp380=find(idxall>=556 & idxall<=614);
   		Tautot(idxskp380,1)=99.999;
   		Taupart(idxskp380,1)=99.999;
   		Unctaup(idxskp380,1)=99.999;
   	idxskpCWV=find(idxall>=2 & idxall<=13);
   	Watvapcolcm(idxskpCWV)=999.99;
   elseif(dateday==23)
      filename_arc='acearc07239701.txt';
      idxwrt=find(UTdechr>0);
      ntimwrt=length(idxwrt);
   end
   
end

%fid=1;  %for testing purposes
fid = fopen(filename_arc,'w');

%begin #HEADER# section
fprintf(fid,'#HEADER#\n');
fprintf(fid,'TOTAL FILES=13\n');

hhmmss=100.*hr2hms(UTdechr);
hms_str=num2str(hhmmss');
for i = 1:length(UTdechr)
   if(hms_str(i,1)==' ')
      hms_str(i,1)='0';
   end
end

ymd_str=num2str(10000*dateyr+100*datemon+dateday);

starthms_str=hms_str(idxwrt(1),:);   %num2str(hhmmss(idxwrt(1)));
fprintf(fid,'FILE START TIME=');
fprintf(fid,'%s\n',strcat(ymd_str,starthms_str,'.0'));

stophms_str=hms_str(idxwrt(ntimwrt),:);    %num2str(hhmmss(idxwrt(ntimwrt)));
fprintf(fid,'FILE STOP TIME=');
fprintf(fid,'%s\n',strcat(ymd_str,stophms_str,'.0'));

fprintf(fid,'VERSION=1\n');

d=datevec(now);
submit_date_str=num2str(10000*(d(1,1)-1900)+100*d(1,2)+d(1,3));
fprintf(fid,'SUBMIT_DATE=');
fprintf(fid,'%s\n',submit_date_str);

%begin #REMARK# section
fprintf(fid,'#REMARKS#\n');
strings=char(info_sav);
for j=1:numlines_info
   fprintf(fid,'%s\n',strings(j,:));
end

%begin #PARAMETER# section
fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'START TIME\nUTC\n*\n*\n*\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Ship Latitude\ndeg\n-90.0\n90.0\n99.999\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Ship Longitude\ndeg\n-180.0\n180.0\n99.999\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Atmospheric Pressure\nmb\n500.\n1050.\n9999.9\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Airmass\n*\n1.\n20.\n99.999\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Detector Output in 941.4-nm Channel\nVolts\n0.0\n10.0\n99.999\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Water Vapor Column Content Derived from 941.4-nm Measurement\ncm\n0.\n10.\n999.99\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Detector Output\nVolts\n0.0\n10.0\n99.999\nwavelength\nnm\n');
fprintf(fid,'%6.1f ',1000.*Wvl_microns);
fprintf(fid,'\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Total Optical Depth\n*\n0.0\n50.0\n99.999\nwavelength\nnm\n');
fprintf(fid,'%6.1f ',1000.*Wvl_microns);
fprintf(fid,'\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Rayleigh Optical Depth\n*\n0.0\n50.0\n99.999\nwavelength\nnm\n');
fprintf(fid,'%6.1f ',1000.*Wvl_microns);
fprintf(fid,'\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Particulate Optical Depth\n*\n0.0\n50.0\n99.999\nwavelength\nnm\n');
fprintf(fid,'%6.1f ',1000.*Wvl_microns);
fprintf(fid,'\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Absolute Uncertainty in Particulate Optical Depth\n*\n0.0\n50.0\n99.999\nwavelength\nnm\n');
fprintf(fid,'%6.1f ',1000.*Wvl_microns);
fprintf(fid,'\n');

%begin #DATA# section
fprintf(fid,'#DATA#\n');
for j = 1:ntimwrt        
   %for j = 1:5 for testing purposes
   i=idxwrt(j);
   fprintf(fid,'%s ',strcat(ymd_str,hms_str(i,:),'.0'));
   fprintf(fid,'%7.3f %8.3f %7.1f %6.3f %6.3f %6.2f ',Latitude(i),Longitude(i),Pressmb(i),...
      Airmass(i),Detector_volts(i,6),Watvapcolcm(i));
   fprintf(fid,'%6.3f %6.3f %6.3f %6.3f %6.3f ',Detector_volts(i,1:5));
   fprintf(fid,'%6.3f %6.3f %6.3f %6.3f %6.3f ',Tautot(i,1:5));
   fprintf(fid,'%6.3f %6.3f %6.3f %6.3f %6.3f ',Tauray(i,1:5));
   fprintf(fid,'%6.3f %6.3f %6.3f %6.3f %6.3f ',Taupart(i,1:5));
   fprintf(fid,'%6.3f %6.3f %6.3f %6.3f %6.3f\n',Unctaup(i,1:5));
end

fclose(fid);

fprintf(1,'%d records successfully written to file %s\n',ntimwrt,filename_arc);

return