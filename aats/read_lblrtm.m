function [h2o,tran,info]=read_lblrtm(pfad,file)
% read_lblrtm   Reads slant water vapor path and water vapor transmittance data
%               from TAPE6 files.
%               First run Matlab function filter4lblrtm to set up TAPE5 files,
%               then execute LBLRTM (for use at IAP: lblrtm_v5.1_f77_sgl on UNIX system UBECX01)
%               to obtain TAPE6. 
%
%               Input:  pfad - directory name of TAPE6 file
%                       file - file name of TAPE6
%               Output: h2o  - slant water vapor path ,[molec/cm^2]
%                       tran - water vapor transmittance
%                       info - informational text
%
%               This function is called by run_lblrtm(2).
%               It can also be execute as stand-alone function.
%
%
% call: [h2o,tran,info]=readLBRTM('d:','TAPE6_946_3580_2')
%
%
% Thomas Ingold, IAP, 12/1999

info.unit={'h2o: molec/cm^2';'conversion to cm: h2o/3.345e22'};
info.channel=[];


fid=fopen([pfad,filesep,file],'r');
line=fgetl(fid);
c=0;
while isstr(line)
   if ~isempty(findstr(line,'ATMOSPHERIC PROFILE SELECTED IS:')) 
      info.atmos=fliplr(deblank(fliplr(deblank(line(47:end)))));   
   end
   if ~isempty(findstr(line,'WBROAD'))
      c=c+1;
      line=fgetl(fid);
      pos=findstr(line,'=');
      h2o(c)=str2num((line(pos+1:end)));
      line=fgetl(fid);line=fgetl(fid);
      line=fgetl(fid);line=fgetl(fid);
      pos1=findstr(line,'=');
      pos2=findstr(line,'NORM');
      tran(c)=str2num(line(pos1+1:pos2-1));
   end
	line=fgetl(fid);   
end
fclose(fid);

switch info.atmos
case 'MIDLATITUDE SUMMER'
   info.txt='mls';
case 'MIDLATITUDE WINTER'
	info.txt='mlw';   
case 'SUBARCTIC SUMMER'
   info.txt='sas';
case 'SUBARCTIC WINTER'
   txt='saw';
case 'SUBARCTIC SUMMER'
   txt='sas';
case 'TROPICAL'
   txt='tro';
case 'U. S., STANDARD,  1976'
   txt='uss76';
end
