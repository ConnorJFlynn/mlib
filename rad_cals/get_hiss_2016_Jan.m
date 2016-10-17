function [archi] = get_hiss_Jan2016(in)

% 4STAR radiance cal before KORUS-AQ
% Source:  HISS     (ARC 30" High-output Integrating Sphere Source)                                                                                   
% Date:    1/21/2016                                                                                                   
% Units:   Radiance in W/(m^2.sr.um)                                                                                            
% Inst:    OL 750                                                                                             
% Std:     20150318-f1175-lampcal.xlsx                                                                                                   
% Tech:    Cooper                                                                                             
% Loc:     ARC                                                                                                
% Dist:    40.56                                                                                              
% Diam:    25.369                                                                                             
% Current: 6.4 A                                                                                     
% Temp:    22 C                                                                                               
% RH:      36%                                                                                                
% Notes:   Values from 300 to 380 nm not corrected for stray light.                                                                                                 
% Data:    wavelength (nm), Radiance in W/(m^2.sr.um)                                                                                             
%                                                                                                             
%          12 lamps 11 lamps 10 lamps 9 lamps  8 lamps  7 lamps  6 lamps  5 lamps  4 lamps  3 lamps  2 lamps  1 lamp
% 300      9.99     9.00     7.98     6.98     5.99     5.00     4.02     3.02     2.05     1.11     0.76     0.43

%%
if ~exist('in','var')
    in = ['D:\case_studies\radiation_cals\cal_sources_references_xsec\HISS\20160121125700HISS.txt'];
else
    while ~exist(in,'file')
        in = getfullname(in,'radcals','Select a calibrated radiance file');
    end
    
end
fid = fopen(in);
if fid>2
    
    [pname, fname, ext] = fileparts(in);
    fname = [fname, ext];
    
   C = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %*[^\n]','HeaderLines',16);
    fclose(fid);
    archi.fname = fname;
    archi.nm = C{1};
    archi.lamps_12 = C{2};
    archi.lamps_11 = C{3};
    archi.lamps_10 = C{4};
    archi.lamps_9 = C{5};
    archi.lamps_8 = C{6};
    archi.lamps_7 = C{7};
    archi.lamps_6 = C{8};
    archi.lamps_5 = C{9};
    archi.lamps_4 = C{10};
    archi.lamps_3 = C{11};
    archi.lamps_2 = C{12};
    archi.lamps_1 = C{13};
    archi.units = 'W/(m^2.sr.um)';
    figure; plot(archi.nm, [archi.lamps_12,archi.lamps_11,archi.lamps_10,...
        archi.lamps_9,archi.lamps_8,archi.lamps_7,archi.lamps_6,archi.lamps_5,...
        archi.lamps_4,archi.lamps_3,archi.lamps_2,archi.lamps_1],'-');
    legend('12 lamps','11 lamps','10 lamps','9 lamps','8 lamps','7 lamps',...
        '6 lamps','5 lamps','4 lamps','3 lamps','2 lamps','1 lamp');
    title(['Calibrated radiances from ',fname],'interp','none');
    xlabel('wavelength [nm]');
    ylabel(archi.units,'interp','none');
    if ~exist([pname, filesep,fname, '.png'],'file')
        saveas(gcf,[pname, filesep,fname, '.png']);
    end
else
    archi = [];
end
return

%%