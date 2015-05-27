function filter4lblrtm

% filter4lblrtm   creates LBLRTM input file (TAPE5).
%                 - allows to select some LBLRTM input parameters
%                 - reads filter data
%
%                 For other TAPE5 parameter, see lblrtm_instructions delivered with LBLRTM package 
%
%                 Additional Information: Set the correct defintions inside this function.
%
%
% Call: filter4lblrtm
%
%
% Thomas Ingold, IAP, 12/1999
% Changed Beat Schmid, NASA Ames 2001, 2002

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN defintions
%%%%%%%%%%%%%%
% defintions %
%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%
% general defintions %
%%%%%%%%%%%%%%%%%%%%%%
%
atmos=0;        % built-in LBLRTM atmosphere
sza=[0];          % solar zenith angle (SZA), deg
altitude=[0:0.2:12];   % station altitude, km
%
%%%%%%%%%%
% filter %
%%%%%%%%%%
c=1000;          % inverse filter transmittance resolution; set c to 10^n, with n=2,3,4, ...
                 % This parameter will determine minimum and maximum wavelength (frequency) of the
                 % filter function set up in TAPE5
step=2.8;        % resolution, cm-1

T_lab=25;        % Temperature at which filter was scanned
T_instr=40;      % Temperature at which filter is operated

%%%%%%%%
% path %
%%%%%%%%
%
file_load='c:\beat\data\filter';
file_save='c:\beat\lblrtm\tape5';
%%%%%%%%%%%%%%%%%%%%%%
% program defintions %
%%%%%%%%%%%%%%%%%%%%%%
%
graph=0;     % 0 - no graphical output
			 % 1 - plots transmittance function
normalize=1; % 0 - no filter transmittance adjustment
             % 1 - filter transmittance normalized to maximum value
offset=1;    % 0 - no offset in filter wavelength
             % 1 - offset based on Delta_T
             % 2 - constant offset

interactive=0;   % 1 - lets you choose filters and atmospheres from menu
			     % 0 - runs all filters in directory

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END defintions 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% defintions from interactive input %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
atmos=menu('Atmosphere','User','Tropical','MLS','MLW','SAS','SAW','USS 1976')-1;

if atmos==0
   [file,pfad] = uigetfile([file_load,filesep,'*.*'], 'Atmosphere File Selection');
   [info.pfad,info.name,info.ext,info.ver]=fileparts(fullfile(pfad,file));
   fid=fopen([pfad,filesep,file],'r');
   for i=1:6
    fgetl(fid);
   end
   data=fscanf(fid,'%g',[4,inf]);
   fclose(fid);
   z=data(1,:); %altitude in km
   T=data(2,:); %temperature in K
   p=data(3,:); %pressure in mbar or hPa
   RH=data(4,:); % in percent
   JCHARP='A';
   JCHART='A';
   JCHAR='H555555';
   IMMAX=length(data);
   HMOD='NSA 2mm';
 end

prompt={'SZA:','Altitude [km]','Inverse Filter Transmittance Resolution','Resolution [cm-1]','Path for Filter Data Files','Save Path for LBLRTM Input File','Filter Normalization (0 - no; 1 - yes))','Filter Wavelength Offset (0 - no; 1 - yes; 2 - constant)'};

%This varies SZA and keeps altitude
%def={'0 5 10 15 20 25 30 35 40 45 50 52.5 55 57.5 60 62.5 65 67.5 70 72.5 75 77.5 80 82.5 85',num2str(altitude),num2str(c),num2str(step),file_load,file_save,num2str(normalize),num2str(offset)};

%This varies altitude and keeps SZA
def={num2str(sza),num2str(altitude),num2str(c),num2str(step),file_load,file_save,num2str(normalize),num2str(offset)};

AddOpts.Resize='on';
AddOpts.WindowStyle='normal';
AddOpts.Interpreter='tex';
dlgTitle='LBLRTM Simulation';
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
sza=str2num(answer{1});
altitude=str2num(answer{2});
c=str2num(answer{3});
step=str2num(answer{4});
file_load=answer{5};
file_save=answer{6};
normalize=str2num(answer{7});
if normalize~=1
   normalize=0;
end
offset=str2num(answer{8});
if isempty(offset)
   offset=0;
end
if offset~=0
   disp(sprintf('Wavelength Offset due to Temperature'))
end

% filter data reading and change data to TAPE5 format

if interactive ==1
 [file,pfad] = uigetfile([file_load,filesep,'ff*'], 'Filter File Selection');
 files.name=fullfile(pfad,file); 
end   

if interactive ==0
	eval(['cd ',file_load])
	files=dir(fullfile(file_load,'ff*'));
end   

for i=1:length(files)

 %[info.pfad,info.name,info.ext,info.ver]=fileparts(fullfile(pfad,file));
 [info.pfad,info.name,info.ext,info.ver]=fileparts(files(i).name);
 eval(['filter.data=load([file_load,filesep,info.name,info.ext]);']) 
 % 1st row: wavelength, nm
 % 2nd row: transmittance 
 
  switch offset
     case 0 
         delta_lambda=0;    %for Omega filters measured at 40C
     case 1   
         %compute cwvl shift, determine nominal cwvl first
         pos=findstr(info.name,'-');
         nom_cwvl=str2num(info.name(3:pos-1));
         if nom_cwvl <440   %for Barr filters from 1995 and 1998  
             T_coeff=5e-6;   
         else
             T_coeff=4e-5;
         end
         delta_T=T_instr-T_lab;
         delta_lambda=T_coeff*delta_T*nom_cwvl;
     case 2
         delta_lambda=0.06; %for Barr filters from 2002 
 end
 
filter.data=sortrows(filter.data);
filter.data(:,1)=filter.data(:,1)+delta_lambda;

if normalize==1
   filter.data(:,2)=filter.data(:,2)./max(filter.data(:,2));
   disp('filter normalization on')
else
   disp('filter normalization off')
end

% conversion to cm-1
filter.freq=10000./(filter.data(:,1)./1000);
filter.round=round(filter.data(:,2)*c)/c;
nr=find(max(filter.data(:,2))==filter.data(:,2));
channel=num2str(round(filter.data(round(mean(nr)),1)));
if strcmp(info.ext,'.prn') % SPM IAP format
	channel=info.name(1:end-2);   
	add_txt='';   
else
   add_txt=info.name;
end
kk1=find(filter.round<1/c & filter.freq>10000./(str2num(channel)./1000)  );
kk2=find(filter.round<1/c & filter.freq<10000./(str2num(channel)./1000)  );
if ~isempty(kk1)
   f1=filter.freq(kk1(end));
else
   f1=filter.freq(1);
end
if ~isempty(kk2)
   f2=filter.freq(kk2(1));
else
   f2=filter.freq(end);
end

filter.freq_new=[f2:step:f1]'

filter.t_new=interp1(filter.freq,filter.data(:,2),filter.freq_new);
filter.t_new_round=round(filter.t_new*c)/c;

% graphical representation of filter data selection
if graph==1
%   figure
%   subplot(2,1,1)
%   plot(filter.freq,filter.data(:,2),'b-')
%   hold on
%   plot(filter.freq_new,filter.t_new,'bx')
%   plot(filter.freq_new,filter.t_new_round,'rx')
%   ll=legend('Raw Data','Interp.','Interp. & Rounded',0);
%   set(ll,'Visible','off','Box','off');
%   grid on
%   hold off
%   title(info.name)
%   xlabel('Frequency [cm^{-1}]')
%   ylabel('Filter Transmittance')
%   subplot(2,1,2)
%   plot(10000./filter.freq*1000,filter.data(:,2),'b-')
%   hold on
%   plot(10000./filter.freq_new*1000,filter.t_new,'bx')
%   plot(10000./filter.freq_new*1000,filter.t_new_round,'rx')
%   ll=legend('Raw Data','Interp.','Interp. & Rounded',0);
%   set(ll,'Visible','off','Box','off');
%   grid on
%   hold off
%   xlabel('Wavelength [nm]')
%   ylabel('Filter Transmittance')
   
   figure
   subplot(2,1,1)
   semilogy(filter.freq,filter.data(:,2),'b-')
   hold on
   semilogy(filter.freq_new,filter.t_new,'bx')
   semilogy(filter.freq_new,filter.t_new_round,'rx')
   ll=legend('Raw Data','Interp.','Interp. & Rounded',0);
   set(ll,'Visible','off','Box','off');
   grid on
   hold off
   title(info.name)
   xlabel('Frequency [cm^{-1}]')
   ylabel('Filter Transmittance')
   subplot(2,1,2)
   semilogy(10000./filter.freq*1000,filter.data(:,2),'b-')
   hold on
   semilogy(10000./filter.freq_new*1000,filter.t_new,'bx')
   semilogy(10000./filter.freq_new*1000,filter.t_new_round,'rx')
   ll=legend('Raw Data','Interp.','Interp. & Rounded',0);
   set(ll,'Visible','off','Box','off');
   grid on
   hold off
   xlabel('Wavelength [nm]')
   ylabel('Filter Transmittance')
 end


% data saving TAPE5
s=min(filter.freq_new);
txt=sprintf(' (f%i.%i)',length(num2str(c))+1,length(num2str(c))-1);

ll=length(filter.freq_new);

%if length(sza)==1
%   name=sprintf('_%s%s_%i_%i_%i',channel,add_txt,altitude*1000,sza,atmos);
%else
%   name=sprintf('_%s%s_%i_%i',channel,add_txt,altitude*1000,atmos);
%end

if length(altitude)==1
  name=sprintf('_%s%s_%i_%i_%i',channel,add_txt,altitude*1000,sza,atmos);
else
  name=sprintf('_%s%s_%i_%i',channel,add_txt,sza,atmos);
end


if exist(file_save,'dir')
   fid=fopen([file_save,filesep,'TAPE5',name],'w');
else
   [newmathfile, newpath] = uiputfile([path,filesep,'TAPE5',name], '(error: wrong save path), Save As');
   fid=fopen(fullfile(newpath,newmathfile),'w');
end

%for ii=1:length(sza)
for ii=1:length(altitude)
   if strcmp(info.ext,'.prn')% SPM IAP format
      fprintf(fid,'$ SPM%s simulation with filter No. %s\r\n',channel,info.name(end));
   else
      fprintf(fid,'$ Simulation for %s\r\n',add_txt);  
   end
   fprintf(fid,' HI=1 F4=1 CN=6 AE=0 EM=0 SC=0 FI=1 PL=0 TS=0 AM=1 MG=0 LA=0 OD=0 XS=0   00   00\r\n');
   fprintf(fid,'0.000 0.000 0.000 0.000 1.000 0.000 0.000\r\n');
%     RECORD 1.2a   (required if ICNTNM = 6)
%              XSELF, XFRGN, XCO2C, XO3CN, XO2CN, XN2CN, XRAYL
%              free format
%              XSELF  H2O self broadened continuum absorption multiplicative factor
%              XFRGN  H2O foreign broadened continuum absorption multiplicative factor
%              XCO2C  CO2 continuum absorption multiplicative factor
%              XO3CN  O3 continuum absorption multiplicative factor
%              XO2CN  O2 continuum absorption multiplicative factor
%              XN2CN  N2 continuum absorption multiplicative factor
%              XRAYL  Rayleigh extinction multiplicative factor

   fprintf(fid,'%10.3f%10.3f\r\n',floor((f2-step)/10)*10,ceil((f1+step)/10)*10);
   fprintf(fid,'%5i    3    0    0    0    7    0                                   360.000   \r\n',atmos);
%   fprintf(fid,'%10.3f%10.3f%10.3f\r\n',altitude,0,sza(ii));
   fprintf(fid,'%10.3f%10.3f%10.3f\r\n',altitude(ii),0,sza);
   fprintf(fid,'   \r\n');
   if atmos==0
      fprintf(fid,'%5i,%s\r\n',IMMAX,HMOD);   
      for ii=1:IMMAX
         count=fprintf(fid,'%10.3f%10.3f%10.3f%s%s%s%s%s\r\n',z(ii),p(ii),T(ii),'     ',JCHARP,JCHART,'   ',JCHAR);
         fprintf(fid,'%8.3f\r\n',RH(ii));
      end   
   end 
   if strcmp(info.ext,'.prn')% SPM IAP format
      fprintf(fid,'%10.3f%10.4f%5i%5i%5i%5i%5i%%5isSPM%s No. %s\r\n',s,step,ll,0,0,0,0,33,'     ',channel,info.name(end));
   else
      fprintf(fid,'%10.3f%10.4f%5i%5i%5i%5i%5i%5i%sFilter file: %s\r\n',s,step,ll,0,0,0,0,33,'     ',add_txt);
   end
   fprintf(fid,'%s\r\n',txt);
   dummy=['fprintf(fid,''%',txt(4:6),'f\r\n'',filter.t_new_round);'];
   eval([dummy])
   fprintf(fid,'-1\r\n');
end
fprintf(fid,'%%%%%%%%\r\n');
fclose(fid);
end