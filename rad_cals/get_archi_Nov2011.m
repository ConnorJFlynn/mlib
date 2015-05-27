function [archi] = get_archi_Nov2011(in)

% SWS and SAS-Ze calibrations, Nov 2011, SGP and NASA Ames
% First load the NASA GSFC calibrations of NASA Ames sources
% Load ARCHI cals from Dec 2011
% C:\case_studies\radiation_cals\GSFC_AMES\
% 201112090906Archi.txt
%
% % Source:   Archi                                   (ARC 30" Sphere)
% Date:     12/9/11
% Units:    Radiance in W/(m^2.sr.um)
% Inst:     OL 750
% Std:      20110901-h97536-lampcal.xlsx
% Tech:     Cooper
% Loc:      ARC
% Dist:     63.24
% Diam:     29.85
% Temp:     24 C
% RH:       31%
% Notes:
% Data:     Wavelength (nm), Radiance in W/(m^2.sr.um), % uncertainty (k=2)
%
%           12 lamps  9 lamps   6 lamps   3 lamps   2 lamps   1 lamp    12 lamps uncertainty
% 300       1.91      1.42      0.95      0.48      0.32      0.15      6.72
%%
if ~exist('in','var')
    in = ['C:\case_studies\radiation_cals\spheres\ARCHI\201112090906Archi.txt'];
else
    while ~exist(in,'file')
        in = getfullname_(in,'radcals','Select a calibrated radiance file');
    end
    
end
fid = fopen(in);
if fid>2
    
    [pname, fname, ext] = fileparts(in);
    fname = [fname, ext];
    
    C = textscan(fid,'%f %f %f %f %f %f %f %f %*[^\n]','HeaderLines',15);
    fclose(fid);
    archi.fname = fname;
    archi.nm = C{1};
    archi.lamps_12 = C{2};
    archi.lamps_9 = C{3};
    archi.lamps_6 = C{4};
    archi.lamps_3 = C{5};
    archi.lamps_2 = C{6};
    archi.lamps_1 = C{7};
    archi.units = 'W/(m^2.sr.um)';
    archi.lamps_12_pct = C{8}./100;
    figure; plot(archi.nm, [archi.lamps_12,archi.lamps_9,archi.lamps_6, archi.lamps_3,archi.lamps_2,archi.lamps_1],'-');
    legend('12 lamps','9 lamps','6 lamps','3 lamps','2 lamps','1 lamp');
    title(['Calibrated radiances from ',fname],'interp','none');
    xlabel('wavelength [nm]');
    ylabel(archi.units,'interp','none');
    saveas(gcf,[pname, fname, '.png']);
    
else
    archi = [];
end
return

%%