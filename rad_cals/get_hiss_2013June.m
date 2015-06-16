function [archi] = get_hiss_June2013(in)

% 4STAR radiance cal after TCAP2 and before SEAC4RS
% Source:    Hiss                                        (ARC High Output Sphere)                                                                           
% Date:      6/5/13                                                                                                                   
% Units:     Radiance in W/(m^2.sr.um)                                                  
% Inst:      OL 750                                                                                                                   
% Std:       20121203-h99056-lampcal.xlsx                                                                                                                   
% Tech:      Cooper                                                                                                                   
% Loc:       ARC                                                                                                                      
% Dist:      40.61                                                                                                                    
% Diam:      25.37                                                                                                                    
% Temp:                                                                                                                               
% RH:                                                                                                                                 
% Notes:                                                                                                                              
% Data:      Wavelength (nm), Radiance in W/(m^2.sr.um), % (k=2) uncertainty                                                                                                                 
%                                                                                                                                     
%            12 lamps   9 lamps    8 lamps    7 lamps    6 lamps    5 lamps    4  lamps   3 lamps    2 lamps    1 lamps    0.5 lamps  12 lamps uncertainty
% 300        11.46      7.95       6.84       5.70       4.57       3.43       2.33       1.24       0.84       0.48       0.27       6.04%

%%
if ~exist('in','var')
    in = ['D:\case_studies\radiation_cals\spheres\HISS\20130605124300HISS.txt'];
else
    while ~exist(in,'file')
        in = getfullname(in,'radcals','Select a calibrated radiance file');
    end
    
end
fid = fopen(in);
if fid>2
    
    [pname, fname, ext] = fileparts(in);
    fname = [fname, ext];
    
   C = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %*[^\n]','HeaderLines',15);
    fclose(fid);
    archi.fname = fname;
    archi.nm = C{1};
    archi.lamps_12 = C{2};
    archi.lamps_9 = C{3};
    archi.lamps_8 = C{4};
    archi.lamps_7 = C{5};
    archi.lamps_6 = C{6};
    archi.lamps_5 = C{7};
    archi.lamps_4 = C{8};
    archi.lamps_3 = C{9};
    archi.lamps_2 = C{10};
    archi.lamps_1 = C{11};
    archi.lamps_p5 = C{12};
    archi.units = 'W/(m^2.sr.um)';
    archi.lamps_12_pct = C{9}./100;
    figure; plot(archi.nm, [archi.lamps_12,archi.lamps_9,archi.lamps_8,archi.lamps_7,archi.lamps_6,archi.lamps_5,...
        archi.lamps_4,archi.lamps_3,archi.lamps_2,archi.lamps_1,archi.lamps_p5],'-');
    legend('12 lamps','9 lamps','8 lamps','7 lamps','6 lamps','5 lamps','4 lamps','3 lamps','2 lamps','1 lamp','0.5 lamp');
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