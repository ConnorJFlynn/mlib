function TWST_HgAr_h5
%%

    line_lib = getfullname('*.h5','spectral_line_library','Select spectra lines library.');

    
%%
h5disp(line_lib,'/','min')
%%

% Cd = h5read(line_lib,'/Cd');
% [Cd, Cd_] = clean_lines(Cd);

Ar = h5read(line_lib,'/Ar');
[Ar, Ar_] = clean_lines(Ar);

Hg = h5read(line_lib,'/Hg');
[Hg, Hg_] = clean_lines(Hg);
% 
% Kr = h5read(line_lib,'/Kr');
% [Kr, Kr_] = clean_lines(Kr);
% 
% Ne = h5read(line_lib,'/Ne');
% [Ne, Ne_] = clean_lines(Ne);
% 
% Xe = h5read(line_lib,'/Xe');
% [Xe, Xe_] = clean_lines(Xe);
%%
 infile = getfullname('*TWST*.nc','twst_nc4','Select instrument-level TWST pol test file');
[pname, fname, ext] = fileparts(infile);
twst = twst4_to_struct(infile); 

satval = max(max(twst.raw_A));
issat = max(twst.raw_A,[],2)==satval;
sig_A = twst.raw_A - interp1( twst.dark_time,twst.dark_A', twst.time,'linear')';
msig_A = nanmean(sig_A,2);
sig_B = twst.raw_B - interp1( twst.dark_time,twst.dark_B', twst.time,'linear')';
msig_B = nanmean(sig_B,2);

atrace = abs(msig_A) ./ max(msig_A);
btrace = abs(msig_B) ./ max(msig_B);
figure; semilogy(twst.wl_A, atrace,'-', twst.wl_B, btrace,'-');
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
semilogy(twst.wl_B,btrace ,'o-',...
    [Xa],[Ya], 'r-',...
    [Xb],[Yb], 'g-',...
    [xb],[yb], 'g--');
legend('TWST Ch B','Ar','Hg','_Hg_')
title('TWST Ch B with HgAr lamp and reference lines');
xlim(xl);
ylim(yl);


%%

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