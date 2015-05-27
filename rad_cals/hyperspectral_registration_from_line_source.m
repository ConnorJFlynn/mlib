function GSFC_lamp_cals_hdf_reads
%%

% line_lib = getfullname_('*.h5');
line_lib = 'D:\case_studies\radiation_cals\spectral_lines_library.h5';
%%
h5disp(line_lib,'/','min')
%%

Cd = h5read(line_lib,'/Cd');
[Cd, Cd_] = clean_lines(Cd);

Ar = h5read(line_lib,'/Ar');
[Ar, Ar_] = clean_lines(Ar);

Hg = h5read(line_lib,'/Hg');
[Hg, Hg_] = clean_lines(Hg);

Kr = h5read(line_lib,'/Kr');
[Kr, Kr_] = clean_lines(Kr);

Ne = h5read(line_lib,'/Ne');
[Ne, Ne_] = clean_lines(Ne);

Xe = h5read(line_lib,'/Xe');
[Xe, Xe_] = clean_lines(Xe);
%%
% infile = getfullname_('20130321*.mat','gsfc_lamp_cals');

infile = 'D:\data\4STAR\2013\2013_03_21_4STAR_GSFC\20130321starHgAr_25.mat';
[~,fname] = fileparts(infile);
HgAr_5 = load(infile);
star.nm = Lambda_MCS_sn081100_tec5([1:1044]);
satval = max(max(HgAr_5.nir_park.raw));
issat = max(HgAr_5.nir_park.raw,[],2)==satval;
% figure;plot(find(~issat), sum(HgAr_5.vis_park.raw(~issat,:),2),'o-')
%%
%%
HgAr_5.nir_park.nm = fliplr(lambda_swir([1:size(HgAr_5.nir_park.raw,2)]));
HgAr_5.nir_park.spectra = fliplr(HgAr_5.nir_park.raw);

%%
 maxs = max(HgAr_5.nir_park.raw,[],2);
 issat = max(HgAr_5.nir_park.raw,[],2)==satval;
light = maxs>1000 & ~issat; dark = maxs<1000 & ~issat;
trace = mean(HgAr_5.nir_park.spectra(light,:))-mean(HgAr_5.nir_park.spectra(dark,:));
ntrace = abs(trace) ./ max(trace);
figure; semilogy(HgAr_5.nir_park.nm, ntrace,'o-');
title(fname,'interp','none');
zoom('on');
ok = menu('Zoom in to the desired x-range and click OK when ready','OK')
%%
yl = ylim;
xl = xlim;

wl = Ar.Wavelength>xl(1)&Ar.Wavelength<xl(2);
XX = [Ar.Wavelength(wl),Ar.Wavelength(wl),Ar.Wavelength(wl)]';
YY = ones(size(XX));
YY(1,:) = yl(1);
YY(2,:) = Ar.Intensity(wl)./max(Ar.Intensity(wl));
YY(3,:) = NaN;
Xa = XX(:);
Ya = YY(:);
% hold('on'); 
wl = Hg.Wavelength>xl(1)&Hg.Wavelength<xl(2);
XX = [Hg.Wavelength(wl),Hg.Wavelength(wl),Hg.Wavelength(wl)]';
YY = zeros(size(XX));
YY(1,:) = yl(1);
YY(2,:) = Hg.Intensity(wl)./max(Hg.Intensity(wl));
YY(3,:) = NaN;
Xb = XX(:);
Yb = YY(:);

wl = Ar_.Wavelength>xl(1)&Ar_.Wavelength<xl(2);
XX = [Ar_.Wavelength(wl),Ar_.Wavelength(wl),Ar_.Wavelength(wl)]';
YY = zeros(size(XX));
YY(1,:) = yl(1);
if any(wl)
YY(2,:) = Ar_.Intensity(wl)./max(Ar_.Intensity(wl));
else
    YY(2,:) = NaN;
end
YY(3,:) = NaN;
xa = XX(:);
ya = YY(:);
% hold('on'); 
wl = Hg_.Wavelength>xl(1)&Hg_.Wavelength<xl(2);
XX = [Hg_.Wavelength(wl),Hg_.Wavelength(wl),Hg_.Wavelength(wl)]';
YY = zeros(size(XX));
YY(1,:) = yl(1);
if any(wl)
YY(2,:) = Hg_.Intensity(wl)./max(Hg_.Intensity(wl));
else
    YY(2,:) = NaN;
end
YY(3,:) = NaN;
xb = XX(:);
yb = YY(:);
%%
semilogy(HgAr_5.nir_park.nm,ntrace ,'o-',...
    [Xa],[Ya], 'r-',...
    [Xb],[Yb], 'g-',...
    [xb],[yb], 'g--');
legend('4STAR','Ar','Hg','_Hg_')
title('4STAR Spectra with HgAr lamp and reference lines');
xlim(xl);
ylim(yl);

%%
infile = strrep(infile,'20130321starHgAr_25','20130321starCd_15')
[~,fname] = fileparts(infile);
Cd_15 = load(infile);
star.nm = Lambda_MCS_sn081100_tec5([1:1044]);
satval = max(max(Cd_15.nir_park.raw));
issat = max(Cd_15.nir_park.raw,[],2)==satval;
% figure;plot(find(~issat), sum(Cd_15.vis_park.raw(~issat,:),2),'o-')
%%
%%
Cd_15.nir_park.nm = fliplr(lambda_swir([1:size(Cd_15.nir_park.raw,2)]));
Cd_15.nir_park.spectra = fliplr(Cd_15.nir_park.raw);

%%
 maxs = max(Cd_15.nir_park.raw,[],2);
 issat = max(Cd_15.nir_park.raw,[],2)==satval;
light = maxs>1000 & ~issat; dark = maxs<1000;
trace = mean(Cd_15.nir_park.spectra(light,:))-mean(Cd_15.nir_park.spectra(dark,:));
ntrace = trace ./ max(trace);
ntrace = abs(trace) ./ max(trace);
figure; semilogy(Cd_15.nir_park.nm, ntrace,'o-');
title(fname,'interp','none');
zoom('on');
ok = menu('Zoom in to the desired x-range and click OK when ready','OK')
%%
yl = ylim;
xl = xlim;

wl = Cd.Wavelength>xl(1)&Cd.Wavelength<xl(2);
XX = [Cd.Wavelength(wl),Cd.Wavelength(wl),Cd.Wavelength(wl)]';
YY = ones(size(XX));
YY(1,:) = yl(1);
YY(2,:) = Cd.Intensity(wl)./max(Cd.Intensity(wl));
YY(3,:) = NaN;
Xa = XX(:);
Ya = YY(:);
% hold('on'); 
wl = Cd_.Wavelength>xl(1)&Cd_.Wavelength<xl(2);
XX = [Cd_.Wavelength(wl),Cd_.Wavelength(wl),Cd_.Wavelength(wl)]';
YY = zeros(size(XX));
YY(1,:) = yl(1);
if any(wl)
YY(2,:) = Cd_.Intensity(wl)./max(Cd_.Intensity(wl));
else
    YY(2,:) = NaN;
end
YY(3,:) = NaN;
Xb = XX(:);
Yb = YY(:);

semilogy(Cd_15.nir_park.nm,ntrace ,'-o',...
    [Xa],[Ya], 'r-',...
    [Xb],[Yb], 'r--');
legend('4STAR','Cd','_Cd_')
title('4STAR Spectra with Cd lamp and reference lines');
xlim(xl);
ylim(yl);

%%
infile = strrep(infile,'20130321starCd_15','20130321starKr_15')

% infile = 'C:\case_studies\4STAR\data\2013\2013_03_21_4STAR_GSFC\.mat';
[~,fname] = fileparts(infile);
Kr_15 = load(infile);
star.nm = Lambda_MCS_sn081100_tec5([1:1044]);
satval = max(max(Kr_15.nir_park.raw));
issat = max(Kr_15.nir_park.raw,[],2)==satval;
% figure;plot(find(~issat), sum(Kr_15.vis_park.raw(~issat,:),2),'o-')
%%
%%
Kr_15.nir_park.nm = fliplr(lambda_swir([1:size(Kr_15.nir_park.raw,2)]));
Kr_15.nir_park.spectra = fliplr(Kr_15.nir_park.raw);

%%
 maxs = max(Kr_15.nir_park.raw,[],2);
 issat = max(Kr_15.nir_park.raw,[],2)==satval;
light = maxs>1000 & ~issat; dark = maxs<1000;
trace = mean(Kr_15.nir_park.spectra(light,:))-mean(Kr_15.nir_park.spectra(dark,:));
ntrace = abs(trace) ./ max(trace);
figure; semilogy(Kr_15.nir_park.nm, ntrace,'o-');
title(fname,'interp','none');zoom('on');
ok = menu('Zoom in to the desired x-range and click OK when ready','OK');

%%
yl = ylim;
xl = xlim;

wl = Kr.Wavelength>xl(1)&Kr.Wavelength<xl(2);
XX = [Kr.Wavelength(wl),Kr.Wavelength(wl),Kr.Wavelength(wl)]';
YY = ones(size(XX));
YY(1,:) = yl(1);
YY(2,:) = Kr.Intensity(wl)./max(Kr.Intensity(wl));
YY(3,:) = NaN;
Xa = XX(:);
Ya = YY(:);
% hold('on'); 
wl = Kr_.Wavelength>xl(1)&Kr_.Wavelength<xl(2);
XX = [Kr_.Wavelength(wl),Kr_.Wavelength(wl),Kr_.Wavelength(wl)]';
YY = zeros(size(XX));
YY(1,:) = yl(1);
if any(wl)
YY(2,:) = Kr_.Intensity(wl)./max(Kr_.Intensity(wl));
else
    YY(2,:) = NaN;
end
YY(3,:) = NaN;
Xb = XX(:);
Yb = YY(:);

semilogy(Kr_15.nir_park.nm,ntrace ,'-o',...
    [Xa],[Ya], 'r-',...
    [Xb],[Yb], 'r--');
legend('4STAR','Kr','_Kr_')
title('4STAR Spectra with Kr lamp and reference lines');
xlim(xl);
ylim(yl);
%%
% infile = 'C:\case_studies\4STAR\data\2013\2013_03_21_4STAR_GSFC\20130321starNe_15.mat';
infile = strrep(infile,'20130321starKr_15','20130321starNe_15')

[~,fname] = fileparts(infile);
Ne_15 = load(infile);
star.nm = Lambda_MCS_sn081100_tec5([1:1044]);
satval = max(max(Ne_15.nir_park.raw));
issat = max(Ne_15.nir_park.raw,[],2)==satval;
% figure;plot(find(~issat), sum(Ne_15.vis_park.raw(~issat,:),2),'o-')
%%
%%
Ne_15.nir_park.nm = fliplr(lambda_swir([1:size(Ne_15.nir_park.raw,2)]));
Ne_15.nir_park.spectra = fliplr(Ne_15.nir_park.raw);

%%
 maxs = max(Ne_15.nir_park.raw,[],2);
 issat = max(Ne_15.nir_park.raw,[],2)==satval;
light = maxs>1000 & ~issat; dark = maxs<1000;
trace = mean(Ne_15.nir_park.spectra(light,:))-mean(Ne_15.nir_park.spectra(dark,:));
ntrace = abs(trace) ./ max(trace);
figure; semilogy(Ne_15.nir_park.nm, ntrace,'o-');
title(fname,'interp','none');zoom('on');
ok = menu('Zoom in to the desired x-range and click OK when ready','OK')
%%
yl = ylim;
xl = xlim;

wl = Ne.Wavelength>xl(1)&Ne.Wavelength<xl(2);
XX = [Ne.Wavelength(wl),Ne.Wavelength(wl),Ne.Wavelength(wl)]';
YY = ones(size(XX));
YY(1,:) = yl(1);
YY(2,:) = Ne.Intensity(wl)./max(Ne.Intensity(wl));
YY(3,:) = NaN;
Xa = XX(:);
Ya = YY(:);
% hold('on'); 
wl = Ne_.Wavelength>xl(1)&Ne_.Wavelength<xl(2);
XX = [Ne_.Wavelength(wl),Ne_.Wavelength(wl),Ne_.Wavelength(wl)]';
YY = zeros(size(XX));
YY(1,:) = yl(1);
if any(wl)
YY(2,:) = Ne_.Intensity(wl)./max(Ne_.Intensity(wl));
else
    YY(2,:) = NaN;
end
YY(3,:) = NaN;
Xb = XX(:);
Yb = YY(:);

semilogy(Ne_15.nir_park.nm,ntrace ,'o-',...
    [Xa],[Ya], 'r-',...
    [Xb],[Yb], 'r--');
legend('4STAR','Ne','_Ne_')
title('4STAR Spectra with Ne lamp and reference lines');
xlim(xl);
ylim(yl);
%%
% infile = 'C:\case_studies\4STAR\data\2013\2013_03_21_4STAR_GSFC\20130321starXe_15.mat';
infile = strrep(infile,'20130321starNe_15','20130321starXe_15')

[~,fname] = fileparts(infile);
Xe_15 = load(infile);
star.nm = Lambda_MCS_sn081100_tec5([1:1044]);
satval = max(max(Xe_15.nir_park.raw));
issat = max(Xe_15.nir_park.raw,[],2)==satval;
% figure;plot(find(~issat), sum(Xe_15.vis_park.raw(~issat,:),2),'o-')
%%
%%
Xe_15.nir_park.nm = fliplr(lambda_swir([1:size(Xe_15.nir_park.raw,2)]));
Xe_15.nir_park.spectra = fliplr(Xe_15.nir_park.raw);

%%
 maxs = max(Xe_15.nir_park.raw,[],2);
 issat = max(Xe_15.nir_park.raw,[],2)==satval;
light = maxs>1000 & ~issat; dark = maxs<1000;
trace = mean(Xe_15.nir_park.spectra(light,:))-mean(Xe_15.nir_park.spectra(dark,:));
ntrace = abs(trace) ./ max(trace);
figure; semilogy(Xe_15.nir_park.nm, ntrace,'o-');
title(fname,'interp','none');
zoom('on');
ok = menu('Zoom in to the desired x-range and click OK when ready','OK')
%%
yl = ylim;
xl = xlim;

wl = Xe.Wavelength>xl(1)&Xe.Wavelength<xl(2);
XX = [Xe.Wavelength(wl),Xe.Wavelength(wl),Xe.Wavelength(wl)]';
YY = zeros(size(XX));
YY(1,:) = yl(1);
YY(2,:) = Xe.Intensity(wl)./max(Xe.Intensity(wl));
YY(3,:) = NaN;
Xa = XX(:);
Ya = YY(:);
% hold('on'); 
wl = Xe_.Wavelength>xl(1)&Xe_.Wavelength<xl(2);
XX = [Xe_.Wavelength(wl),Xe_.Wavelength(wl),Xe_.Wavelength(wl)]';
YY = zeros(size(XX));
YY(1,:) = yl(1);
if any(wl)
YY(2,:) = Xe_.Intensity(wl)./max(Xe_.Intensity(wl));
else
    YY(2,:) = NaN;
end
YY(3,:) = NaN;
Xb = XX(:);
Yb = YY(:);

semilogy(Xe_15.nir_park.nm,ntrace ,'o-',...
    [Xa],[Ya], 'r-',...
    [Xb],[Yb], 'r--');
legend('4STAR','Xe','_Xe_')
title('4STAR Spectra with Xe lamp and reference lines');
xlim(xl);
ylim(yl);

%%
return

function [cwl, fwhm, ref] = fit_the_peaks(nm, ntrace,x,y);
%accepts a spectral trace (nm, ntrace) and a list of reference lines
% Allows user to repeatedly identify specific peaks by zooming. 
% Then identifies a linear baseline to subtract based on lowest 5% of selected
% points, renormalizes the remaining peak, fits a gaussian to yield cwl and
% FWHM, and identifies the reference wavelength.  If more than one
% reference wavelength is within the selected range, user selects line.




return