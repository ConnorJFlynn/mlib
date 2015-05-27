lambda=[0.3:0.001: 1.6];
pressure=980;
tau_r1=rayleigh(lambda,pressure);
tau_r2=rayleigh_ht(lambda,pressure);
%
figure(1);
loglog(lambda,tau_r1,lambda,tau_r2)
set(gca,'xlim',[.300 1.60]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
xlabel('Wavelength [microns]','FontSize',14);
ylabel('Optical Depth','FontSize',14)
set(gca,'FontSize',14)

figure(2);
plot(lambda,tau_r2-tau_r1,'.')
set(gca,'xlim',[.300 1.60]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
xlabel('Wavelength [microns]','FontSize',14);
ylabel('Optical Depth','FontSize',14)
text(1.2,-0.001,'Bucholtz-Hansen&Travis')
set(gca,'FontSize',14)
grid on

figure(3);
plot(lambda,tau_r2-tau_r1,'.')
set(gca,'xlim',[.300 0.500]);
%set(gca,'xtick',[0.3,0.4,0.5]);
xlabel('Wavelength [microns]','FontSize',14);
ylabel('Hansen&Travis-Bucholtz','FontSize',14)
text(1.2,-0.001,'')
set(gca,'FontSize',14)
grid on

figure(4)
plot(lambda,100*(tau_r2-tau_r1)./tau_r1,'.')
set(gca,'xlim',[.300 1.60]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
xlabel('Wavelength [microns]','FontSize',14);
ylabel('Difference in %','FontSize',14)
text(1.2,-0.65,'Bucholtz-Hansen&Travis')
set(gca,'FontSize',14)
grid on

