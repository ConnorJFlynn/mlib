%reads MISU PSAP profile
lambda_PSAP=565/1e3;
[filename,pathname]=uigetfile('d:\beat\data\ACE-2\Misu\*.asc','Choose PSAP data file', 0, 0);
fid=fopen([pathname filename]);
fgetl(fid);
data=fscanf(fid,'%g',[2,inf]);
fclose(fid);
Altitude_PSAP=data(1,:);
Abs_PSAP=data(2,:);

Abs_PSAP_inst_err=0.25*Abs_PSAP;
Abs_PSAP_interp_err=0.30*Abs_PSAP;

[filename,pathname]=uigetfile('d:\beat\data\ACE-2\Caltech\*abs.txt','Choose PSAP correction file', 0, 0);
fid=fopen([pathname filename]);
data=fscanf(fid,'%g',[2,inf]);
fclose(fid);
Altitude_PSAP_corr=data(1,:)/1e3;
PSAP_corr=data(2,:);
PSAP_corr=interp1(Altitude_PSAP_corr,PSAP_corr,Altitude_PSAP);

Abs_PSAP_corr_err=0.20*(Abs_PSAP.*PSAP_corr-Abs_PSAP);

Abs_PSAP_corr=Abs_PSAP.*PSAP_corr;

PSAP_err=sqrt(Abs_PSAP_inst_err.^2+Abs_PSAP_interp_err.^2+Abs_PSAP_corr_err.^2);

figure(12)
subplot(1,3,1)
plot(Abs_PSAP,Altitude_PSAP,'-*',Abs_PSAP_corr,Altitude_PSAP,'-*')
ylabel('Altitude [km]');
xlabel('Absorption [1/km]');
grid on
legend('uncorrected','corrected for cut-off')
subplot(1,3,2)
plot(PSAP_corr,Altitude_PSAP,'-*')
ylabel('Altitude [km]');
xlabel('Ratio');
grid on
subplot(1,3,3)
plot(PSAP_err./Abs_PSAP_corr,Altitude_PSAP,'-*')
legend('Error')
ylabel('Altitude [km]');
xlabel('Ratio');
grid on

