%This program has the options to compute
% 1) CWVL, BW (FWHM) and peak Transmission
% 2) weighted O2-O2 optical depths
% 3) Weighted NO2 cross-sections
% 4) Weighted MODTRAN37 x-sections 

%%%%%%%%
% path %
%%%%%%%%

%file_load='c:\beat\data\filter\AATS-6';
%file_save='c:\beat\data\filter\AATS-6\';

%file_load='c:\beat\data\filter\AATS-14\Barr_98';
%file_save='c:\beat\data\filter\AATS-14\Barr_98\';

%file_load='c:\beat\data\filter\AATS-14\Barr_2002';
%file_save='c:\beat\data\filter\AATS-14\Barr_2002\';

%file_load='c:\beat\data\filter\AATS-14\Omega_2002';
%file_save='c:\beat\data\filter\AATS-14\Omega_2002\';

file_load='c:\beat\data\filter\AATS-14\Omega_2005';
file_save='c:\beat\data\filter\AATS-14\Omega_2005\';


%%%%%%%%%%%%%%%%%%%%%%
% program defintions %
%%%%%%%%%%%%%%%%%%%%%%

c=1e3;           % inverse filter transmittance resolution; set c to 10^n, with n=2,3,4, ...
                 % This parameter will determine minimum and maximum wavelength (frequency) of the
                 % filter function
                 
step=2.8;        % resolution, cm-1

graph=1;         % 0 - no graphical output
			     % 1 - plots transmittance function

normalize=0;     % 0 - no filter transmittance adjustment
                 % 1 - filter transmittance normalized to maximum value
                 
interactive=0;   % 0 - runs all filters in directory
                 % 1 - lets you choose filters and atmospheres from menu
			     
offset=0;        % 0 - no offset in filter wavelength
                 % 1 - offset based on Delta_T

T_lab=25;        % Temperature at which filter was scanned
T_instr=40;      % Temperature at which filter is operated

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END defintions 


% filter data reading

if interactive ==1
 [file,pfad] = uigetfile([file_load,filesep,'ff*'], 'Filter File Selection');
 files.name=fullfile(pfad,file); 
end   

if interactive ==0
  eval(['cd ',file_load])
  files=dir(fullfile(file_load,'ff*'));
end   

for i=1:length(files)
 [info.pfad,info.name,info.ext,info.ver]=fileparts(files(i).name);
 eval(['filter.data=load([file_load,filesep,info.name,info.ext]);']) 
 % 1st row: wavelength, nm
 % 2nd row: transmittance


 if offset==1
  %compute cwvl shift, determine nominal cwvl first
  pos=findstr(info.name,'-');
  nom_cwvl=str2num(info.name(3:pos-1));
  if nom_cwvl <440
    T_coeff=5e-6;
  else
    T_coeff=4e-5;
  end
  delta_T=T_instr-T_lab;
  delta_lambda=T_coeff*delta_T*nom_cwvl;
 else
  delta_lambda=0;  
 end
 filter.data=sortrows(filter.data);
 filter.data(:,1)=filter.data(:,1)+delta_lambda;

 T_max=max(filter.data(:,2));

 if normalize==1
   filter.data(:,2)=filter.data(:,2)./max(filter.data(:,2));
   disp('filter normalization on')
 else
   disp('filter normalization off')
 end

 [cwvl,FWHM]=cwl(filter.data(:,1),filter.data(:,2),0.005);


%  % conversion to cm-1
%  filter.freq=10000./(filter.data(:,1)./1000);
%  filter.round=round(filter.data(:,2)*c)/c;
%  nr=find(max(filter.data(:,2))==filter.data(:,2));
%  channel=num2str(round(filter.data(round(mean(nr)),1)));
%  if strcmp(info.ext,'.prn') % SPM IAP format
% 	channel=info.name(1:end-2);   
% 	add_txt='';   
%  else
%    add_txt=info.name;
%  end
%  kk1=find(filter.round<1/c & filter.freq>10000./(str2num(channel)./1000)  );
%  kk2=find(filter.round<1/c & filter.freq<10000./(str2num(channel)./1000)  );
%  if ~isempty(kk1)
%    f1=filter.freq(kk1(end));
%  else
%    f1=filter.freq(1);
%  end
%  if ~isempty(kk2)
%    f2=filter.freq(kk2(1));
%  else
%    f2=filter.freq(end);
%  end
% 
%  filter.freq_new=[f2:step:f1]'
%  filter.t_new=interp1(filter.freq,filter.data(:,2),filter.freq_new);
%  filter.t_new_round=round(filter.t_new*c)/c;
% 
%  % graphical representation of filter data selection
%  if graph==1
%    figure(1)
%    subplot(2,1,1)
%    plot (filter.data(:,1),filter.data(:,2),'r',[cwvl cwvl],[0,1],'r',[cwvl-FWHM/2 cwvl-FWHM/2],[0,1],':r',[cwvl+FWHM/2 cwvl+FWHM/2],[0,1],':r')
%    xlabel('Wavelength [nm]');
%    ylabel('Response');
%    title(info.name);
%    subplot(2,1,2)
%    semilogy(filter.data(:,1),filter.data(:,2))
%    xlabel('Wavelength (nm)');
%    ylabel('Relative Response');
%  
%    figure(2)
%    subplot(2,1,1)
%    plot(filter.freq,filter.data(:,2),'b-')
%    hold on
%    plot(filter.freq_new,filter.t_new,'bx')
%    plot(filter.freq_new,filter.t_new_round,'rx')
%    ll=legend('Raw Data','Interp.','Interp. & Rounded',0);
%    set(ll,'Visible','off','Box','off');
%    grid on
%    hold off
%    title(info.name)
%    xlabel('Frequency [cm^{-1}]')
%    ylabel('Filter Transmittance')
%    subplot(2,1,2)
%    plot(10000./filter.freq*1000,filter.data(:,2),'b-')
%    hold on
%    plot(10000./filter.freq_new*1000,filter.t_new,'bx')
%    plot(10000./filter.freq_new*1000,filter.t_new_round,'rx')
%    ll=legend('Raw Data','Interp.','Interp. & Rounded',0);
%    set(ll,'Visible','off','Box','off');
%    grid on
%    hold off
%    xlabel('Wavelength [nm]')
%    ylabel('Filter Transmittance')
%    
%    figure(3)
%    subplot(2,1,1)
%    semilogy(filter.freq,filter.data(:,2),'b-')
%    hold on
%    semilogy(filter.freq_new,filter.t_new,'bx')
%    semilogy(filter.freq_new,filter.t_new_round,'rx')
%    ll=legend('Raw Data','Interp.','Interp. & Rounded',0);
%    set(ll,'Visible','off','Box','off');
%    grid on
%    hold off
%    title(info.name)
%    xlabel('Frequency [cm^{-1}]')
%    ylabel('Filter Transmittance')
%    subplot(2,1,2)
%    semilogy(10000./filter.freq*1000,filter.data(:,2),'b-')
%    hold on
%    semilogy(10000./filter.freq_new*1000,filter.t_new,'bx')
%    semilogy(10000./filter.freq_new*1000,filter.t_new_round,'rx')
%    ll=legend('Raw Data','Interp.','Interp. & Rounded',0);
%    set(ll,'Visible','off','Box','off');
%    grid on
%    hold off
%    xlabel('Wavelength [nm]')
%    ylabel('Filter Transmittance')
% end
% 
% 
% 
%  [tau_O4,p]=O4(10000./filter.freq_new*1000,filter.t_new_round,cwvl) 
 %NO2_xsect=NO2(10000./filter.freq_new*1000,filter.t_new_round)

 %write CWVL to file
 fid=fopen([file_save 'cwvl.txt'],'a');
 fprintf(fid,'%c',' ',[file_load,filesep,info.name,info.ext]);
 fprintf(fid,'%9.2f',cwvl,FWHM,T_max);
 fprintf(fid,'\r\n');
 fclose(fid);

%  %write NO2_xsect to file
%  fid=fopen([file_save 'NO2_xsect.txt'],'a');
%  fprintf(fid,'%c',' ',[file_load,filesep,info.name,info.ext]);
%  fprintf(fid,'%9.4f',NO2_xsect);
%  fprintf(fid,'\r\n');
%  fclose(fid); 
% 
 %write to tau_O4 file
%  fid=fopen([file_save 'tau_O4.txt'],'a');
%  fprintf(fid,'%c',' ',[file_load,filesep,info.name,info.ext]);
%  fprintf(fid,'%14.5e',tau_O4,exp(p(3)),p(2),p(1));
%  fprintf(fid,'\r\n');
%  fclose(fid); 

 %mod37(lambda,response,file)
 
end