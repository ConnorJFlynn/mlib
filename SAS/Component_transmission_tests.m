% Sequence of components:
% Vis  36u1
% NIR  47u1
% Splitter F9823
% Shutter
% 10m SAS fiber
%% Transmission of 10 m fiber, 600 micron solid core (10m / Shutter)

TenM.vis = SAS_read_ava;
TenM.nir = SAS_read_ava;
TenM.vis.bkgnd = SAS_read_ava;
TenM.nir.bkgnd = SAS_read_ava;

%%
Shutter.vis = SAS_read_ava;
Shutter.nir = SAS_read_ava;
Shutter.vis.bkgnd = SAS_read_ava;
Shutter.nir.bkgnd = SAS_read_ava;


%% Transmission of Shutter (Shutter / Splitter)
Splitter.vis = SAS_read_ava;
Splitter.nir = SAS_read_ava;
Splitter.vis.bkgnd = SAS_read_ava;
Splitter.nir.bkgnd = SAS_read_ava;


%% 
Spectro.vis = SAS_read_ava;
Spectro.nir = SAS_read_ava;
Spectro.vis.bkgnd = SAS_read_ava;
Spectro.nir.bkgnd = SAS_read_ava;

%%
TenM.vis.avg = (mean(TenM.vis.spec) - mean(TenM.vis.bkgnd.spec))./unique(TenM.vis.Integration);
TenM.nir.avg = (mean(TenM.nir.spec) - mean(TenM.nir.bkgnd.spec))./unique(TenM.nir.Integration);
Shutter.vis.avg = (mean(Shutter.vis.spec) - mean(Shutter.vis.bkgnd.spec))./unique(Shutter.vis.Integration);
Shutter.nir.avg = (mean(Shutter.nir.spec) - mean(Shutter.nir.bkgnd.spec))./unique(Shutter.nir.Integration);
Splitter.vis.avg = (mean(Splitter.vis.spec) - mean(Splitter.vis.bkgnd.spec))./unique(Splitter.vis.Integration);
Splitter.nir.avg = (mean(Splitter.nir.spec) - mean(Splitter.nir.bkgnd.spec))./unique(Splitter.nir.Integration);
Spectro.vis.avg = (mean(Spectro.vis.spec) - mean(Spectro.vis.bkgnd.spec))./unique(Spectro.vis.Integration);
Spectro.nir.avg = (mean(Spectro.nir.spec) - mean(Spectro.nir.bkgnd.spec))./unique(Spectro.nir.Integration);
%%
visgood = TenM.vis.nm>=375&TenM.vis.nm<=1150;
nirgood = TenM.nir.nm>=950&TenM.nir.nm<=1700;
TenM.vis.T = TenM.vis.avg./Shutter.vis.avg;
TenM.nir.T = TenM.nir.avg./Shutter.nir.avg;
Shutter.vis.T = Shutter.vis.avg./Splitter.vis.avg;
Shutter.nir.T = Shutter.nir.avg./Splitter.nir.avg;
Splitter.vis.T = Splitter.vis.avg./Spectro.vis.avg;
Splitter.nir.T = Splitter.nir.avg./Spectro.nir.avg;
%%

figure; plot(TenM.vis.nm(visgood), 100.*TenM.vis.T(visgood),'b-',TenM.nir.nm(nirgood), 100.*TenM.nir.T(nirgood),'k-')
title('Transmission of 10 m fiber');
ylabel('%')
xlabel('wavelength [nm]');
legend('vis','nir');
%%
pname = TenM.vis.pname;
[A,B] = strtok(fliplr(pname),filesep); 
pname = fliplr(B);
saveas(gcf,[pname, 'T_10m_fiber.fig']);
saveas(gcf,[pname, 'T_10m_fiber.png']);

%%
figure; plot(Shutter.vis.nm(visgood), 100.*Shutter.vis.T(visgood),'b-',Shutter.nir.nm(nirgood), 100.*Shutter.nir.T(nirgood),'k-')
title('Transmission of shutter');
ylabel('%')
xlabel('wavelength [nm]');
legend('vis','nir');
%%
pname = Shutter.vis.pname;
[A,B] = strtok(fliplr(pname),filesep); 
pname = fliplr(B);
saveas(gcf,[pname, 'T_FOS1_shutter.fig']);
saveas(gcf,[pname, 'T_FOS1_shutter.png']);
%%
a = .3;
figure; s(1)=subplot(2,1,1); 
semilogy([Splitter.vis.nm(visgood),Splitter.nir.nm(nirgood)],[...
[mean(TenM.vis.spec(:,visgood))./unique(TenM.vis.Integration),mean(TenM.nir.spec(:,nirgood))./unique(TenM.nir.Integration)];...
[mean(Shutter.vis.spec(:,visgood))./unique(Shutter.vis.Integration),mean(Shutter.nir.spec(:,nirgood))./unique(Shutter.nir.Integration)];...
[mean(Splitter.vis.spec(:,visgood))./unique(Splitter.vis.Integration),mean(Splitter.nir.spec(:,nirgood))./unique(Splitter.nir.Integration)];...
[mean(Spectro.vis.spec(:,visgood))./unique(Spectro.vis.Integration),mean(Spectro.nir.spec(:,nirgood))./unique(Spectro.nir.Integration)]],'-');
legend('10 meter fiber','Shutter','Y-fiber','Spectro')
s(2)=subplot(2,1,2); 
plot([Splitter.vis.nm(visgood),Splitter.nir.nm(nirgood)],[...
[TenM.vis.T(visgood),TenM.nir.T(nirgood)];...
[Shutter.vis.T(visgood),Shutter.nir.T(nirgood)];...
[4.*a.*Splitter.vis.T(visgood),4.*(1-a).*Splitter.nir.T(nirgood)]...
],'-');
legend('10 meter fiber','Shutter','Y-fiber (adjusted A/B)')
linkaxes(s,'x')
%%
figure; semilogy(Splitter.nir.nm(nirgood), [mean(Splitter.nir.spec(:,nirgood)); mean(Splitter.nir.bkgnd.spec(:,nirgood)); ...
   mean(Spectro.nir.spec(:,nirgood)); mean(Spectro.nir.bkgnd.spec(:,nirgood))])
%%
figure; plot(Splitter.vis.nm(visgood), 100.*Splitter.vis.T(visgood),'b-',Splitter.nir.nm(nirgood), 100.*Splitter.nir.T(nirgood),'k-')
title('Transmission of 600/300/300 splitter');
ylabel('%')
xlabel('wavelength [nm]');
legend('vis','nir');
%%
pname = Splitter.vis.pname;
[A,B] = strtok(fliplr(pname),filesep); 
pname = fliplr(B);
saveas(gcf,[pname, 'T_splitter.fig']);
saveas(gcf,[pname, 'T_splitter.png']);



