function [ars455] = get_ars455_20080319(in)
% [ars455] = get_ars455_20080319(in)

% % 	W/(m^2.sr.µm)			[W/(sr cm^2 nm)]	
% nm	OPEN	Uncertainty	A	B	C	D	
% 400	106	3.10%	2.96E-06	1.65E-06	8.10E-07
% 410	131.4	2.60%	3.69E-06	2.03E-06	1.04E-06
                             
% pname = ['C:\case_studies\radiation_cals\GSFC_AMES\'];
% fname = ['201112150930ARS.txt'];
% fid = fopen([pname, fname]);
if ~exist('in','var')
    in = ['C:\case_studies\radiation_cals\spheres\ARS455\20080204122100ARS455.txt'];
else
    while ~exist(in,'file')
        in = getfullname(in,'radcals','Select a calibrated radiance file');
    end
    
end
fid = fopen(in);
if fid>2
   [pname, fname, ext] = fileparts(in);
    fname = [fname, ext];
C = textscan(fid,'%f %f %f %f %f %f %f %*[^\n]','HeaderLines',19);
fclose(fid);
ars455.fname = fname;
ars455.nm = C{1};
ars455.Aper_O = C{6};
ars455.Aper_A = C{2};
ars455.Aper_B = C{3};
ars455.Aper_C = C{4};
ars455.Aper_D = C{5};
ars455.Aper_A_pct = C{7}./100;
ars455.units = 'W/(m^2.sr.um)';
figure; plot(ars455.nm, [ars455.Aper_O,ars455.Aper_A,ars455.Aper_B,ars455.Aper_C,ars455.Aper_D],'-');
legend('Aper O','Aper A','Aper B','Aper C','Aper D');
title({['NASA GSFC calibration of NASA Ames ARS455 Optronics 7" sphere'];ars455.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel(ars455.units,'interp','none');
saveas(gcf,[pname, fname, '.png']);
else
    ars455 = [];
end
return
%%