% Sequence of components:
% Vis  36u1
% NIR  47u1
% Splitter F9823
% Shutter
% 10m SAS fiber
%% Transmission of 10 m fiber, 600 micron solid core (10m / Shutter)

Mixer.vis = SAS_read_ava;
NoMixer.vis = SAS_read_ava;

%%
Radin.vis = SAS_read_ava;
Radin.nir = SAS_read_ava;
Spectralon.vis = SAS_read_ava;
Spectralon.nir = SAS_read_ava;

%%
Radin.vis.dark = max(Radin.vis.spec,[],2)<10000;
Spectralon.vis.dark = max(Spectralon.vis.spec,[],2)<10000;
nm_ii = max(find(Radin.nir.nm>1275 & Radin.nir.nm<1280));
Radin.nir.dark = Radin.nir.spec(:,nm_ii)<5000;
Spectralon.nir.dark = Spectralon.nir.spec(:,nm_ii)<5000;
Radin.vis.light = mean(Radin.vis.spec(~Radin.vis.dark,:))-...
   mean(Radin.vis.spec(Radin.vis.dark,:));
Spectralon.vis.light = mean(Spectralon.vis.spec(~Spectralon.vis.dark,:))-...
   mean(Spectralon.vis.spec(Spectralon.vis.dark,:));
Radin.nir.light = mean(Radin.nir.spec(~Radin.nir.dark,:))-...
   mean(Radin.nir.spec(Radin.nir.dark,:));
Spectralon.nir.light = mean(Spectralon.nir.spec(~Spectralon.nir.dark,:))-...
   mean(Spectralon.nir.spec(Spectralon.nir.dark,:));
figure; plot(Radin.vis.nm, Radin.vis.light./Spectralon.vis.light, 'b-',Radin.nir.nm, Radin.nir.light./Spectralon.nir.light,'r-')

% Radin seems to have higher throughput.  There is a pronounced difference
% in the wavelength dependence of these two at short wavelengths with ratio 
% Radin/Spectralon showing a noted peak ~ 400 nm.  
% In the NIR the difference is less striking with nearly linear dependence
% on wavelength plus possibly reduced water absorption lines in radin.  

% difference 
%% 

Mixer.vis = SAS_read_ava;
Mixer.nir = SAS_read_ava;
FiberA.vis = SAS_read_ava;
FiberA.nir = SAS_read_ava;

%%
Mixer.vis.dark = max(Mixer.vis.spec,[],2)<1000;
FiberA.vis.dark = max(FiberA.vis.spec,[],2)<1000;
nm_ii = max(find(Mixer.nir.nm>1275 & Mixer.nir.nm<1280));
Mixer.nir.dark = Mixer.nir.spec(:,nm_ii)<2500;
FiberA.nir.dark = FiberA.nir.spec(:,nm_ii)<6000;

Mixer.vis.light = mean(Mixer.vis.spec(~Mixer.vis.dark,:))-...
   mean(Mixer.vis.spec(Mixer.vis.dark,:));
FiberA.vis.light = mean(FiberA.vis.spec(~FiberA.vis.dark,:))-...
   mean(FiberA.vis.spec(FiberA.vis.dark,:));
Mixer.nir.light = mean(Mixer.nir.spec(~Mixer.nir.dark,:))-...
   mean(Mixer.nir.spec(Mixer.nir.dark,:));
FiberA.nir.light = mean(FiberA.nir.spec(~FiberA.nir.dark,:))-...
   mean(FiberA.nir.spec(FiberA.nir.dark,:));
%%
% figure; plot(FiberA.vis.nm, FiberA.vis.light,'k-',Mixer.vis.nm, Mixer.vis.light, 'm');
figure; plot(FiberA.nir.nm, FiberA.nir.light,'k-',Mixer.nir.nm, Mixer.nir.light, 'm');

%%
figure; plot(FiberA.vis.nm, Mixer.vis.light./FiberA.vis.light,'b-',FiberA.nir.nm, Mixer.nir.light./FiberA.nir.light,'r-');


