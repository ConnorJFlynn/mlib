function [ars455] = get_ars455_Nov2011(in)
% [ars455] = get_ars455_Nov2011(in)

% SWS and SAS-Ze calibrations, Nov 2011, SGP and NASA Ames
% First load the NASA GSFC calibrations of NASA Ames sources
% Load ARS455 cals from Dec 2011
% C:\case_studies\radiation_cals\GSFC_AMES\
% 201112150930ARS.txt
% 
% Source:      ARS                                                 (ARC Optronic ARS455 Sphere)           
% Date:        12/15/11                                                         
% Units:       Radiance in W/(m^2.sr.um)                                                     
% Inst:        OL 750                                                           
% Std:         20110901-h97536-lampcal.xlsx                                                               
% Tech:        Cooper                                                           
% Loc:         ARC                                                              
% Dist:        20.58                                                            
% Diam:        3.81                                                             
% Temp:        24 C                                                             
% RH:          31%                                                              
% Notes:                                                                        
% Data:        Wavelength (nm), Radiance in W/(m^2.sr.um), % (k=2) uncertainty                                                      
%                                                                               
%              Aperture A   Aperture B   Aperture C   Aperture D   Aperture O   Aperture A uncertainty
% 300          3.08         1.67         0.86         0.38         10.62        6.2%

%%
% pname = ['C:\case_studies\radiation_cals\GSFC_AMES\'];
% fname = ['201112150930ARS.txt'];
% fid = fopen([pname, fname]);
if ~exist('in','var')
    in = ['C:\case_studies\radiation_cals\GSFC_AMES\201112150930ARS.txt'];
else
    while ~exist(in,'file')
        in = getfullname_(in,'radcals','Select a calibrated radiance file');
    end
    
end
fid = fopen(in);
if fid>2
   [pname, fname, ext] = fileparts(in);
    fname = [fname, ext];
C = textscan(fid,'%f %f %f %f %f %f %f %*[^\n]','HeaderLines',15);
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