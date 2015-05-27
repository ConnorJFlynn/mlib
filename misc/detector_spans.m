clear
mct.wn = [450:2000];
insb.wn = [1800:3000];
Si.nm = [300:1050];
InGaAs.nm = [950:2200];


mct.nm = (1000*10000)./mct.wn;
insb.nm = (1000*10000)./insb.wn;
Si.wn = (1000*10000)./Si.nm;
InGaAs.wn = (1000*10000)./InGaAs.nm;

mct.x = ones(size(mct.nm));
insb.x = ones(size(insb.nm));
Si.x = ones(size(Si.nm));
InGaAs.x = ones(size(InGaAs.nm));

figure; 
subplot(2,1,1);
plot(mct.nm, mct.x,'+',insb.nm,insb.x,'x',InGaAs.nm,InGaAs.x,'o',Si.nm,Si.x,'.');
legend('mct','insb','InGaAs','Si');
xlabel('wavelength [nm]');
subplot(2,1,2);
plot(mct.wn, mct.x,'+',insb.wn,insb.x,'x',InGaAs.wn,InGaAs.x,'o',Si.wn,Si.x,'.');
xlabel('wavenumber [1/cm]')
%%