clear

%********** Reads Output from standard detector OL 750-HSD-301C**********************
[filename,pathname]=uigetfile('g:\beat\data\op750\*.cal', 'Choose cal. file', 0, 0);
fid=fopen([pathname filename]);
date=fscanf(fid, '%d', 1);
lambda=fscanf(fid, '%g', 2);
step=fscanf(fid, '%g', 1);
amps=fscanf(fid, '%g', inf);
fclose(fid);
lambda_sens=(lambda(1):step:lambda(2))';
figure(1);
plot(lambda_sens,amps);
xlabel('Wavelength [nm]');
ylabel('Signal [A]');
title('Signal @ OL 750-HSD-301C');
grid on;

%********* Reads calibration file of standard detector OL 750-HSD-301C***************
fid=fopen('g:\beat\data\op750\hsd301c.prn');
silicon=fscanf(fid, '%d %g', [2 inf]);
fclose(fid);
lambda_Si=silicon(1,:);
silicon=silicon(2,:);
figure(2);
plot(lambda_Si,silicon);
xlabel('Wavelength [nm]');
ylabel('Reponse[A/W]');
title('Response of OL 750-HSD-301C');
grid on;

silicon= INTERP1(lambda_Si,silicon,lambda_sens);

figure(3);
lamp=amps./silicon;
semilogy(lambda_sens,lamp);
xlabel('Wavelength [nm]');
ylabel('Signal [W]');
title('Monochromator-Output');
grid on;

%********* Reads raw SPM-2000  filter scan***************

[filename,pathname]=uigetfile('g:\beat\data\op750\*.asc', 'Choose data file', 0, 0);
fid=fopen([pathname filename]);
lambda=fscanf(fid, '%d', 2);
response=fscanf(fid, '%g', inf);
fclose(fid);
lambda_SPM=LINSPACE(lambda(1),lambda(2), size(response,1))';

figure(4);
plot (lambda_SPM,response);
xlabel('Wavelength [nm]');
ylabel('SPM-Signal [V]');
title('Output of SPM');
set(gca,'ylim',[-1e-3 1e-3])
grid on;


%zero=min(response);
zero=-1.08e-4
response=response-ones(size(response))*zero;
lamp= INTERP1(lambda_sens,lamp,lambda_SPM);
response=response./lamp;


response=response/max(response);
ii=find(response<=1e-6)
response(ii)=ii.*0.0;

figure(5)
plot (lambda_SPM,response)
xlabel('Wavelength [nm]');
ylabel('Response');
title('Relative Response of SPM');
grid on

figure(6)
semilogy(lambda_SPM,response)
xlabel('Wavelength [nm]');
ylabel('Response');
set(gca,'ylim',[1e-6 1])
title('Relative Response of SPM');
grid on

%********* Writes final SPM-2000  filter scan to file ***************

fid = fopen(['g:\beat\data\filter\' filename],'w');
fprintf(fid,'%7.3f  %g\n',[lambda_SPM' ;response']);
fclose(fid)


