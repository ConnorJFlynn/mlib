function [archi] = get_hiss_June2013_(in)

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
% %                                                                                                                                     
%            12 lamps   8.5 lamps  8 lamps    5.5 lamps  2.5 lamps  1.5 lamps  0.5  lamps 12 lamps uncertainty
% 300        11.42      7.75       6.82       4.35       1.03       0.64       0.27       5.86%
%%
disp('Recommend using get_hiss_June2013 from June 5 rather than this one from June 6.')
if ~exist('in','var')
    in = ['D:\case_studies\radiation_cals\spheres\HISS\20130606105500HISS.txt'];
else
    while ~exist(in,'file')
        in = getfullname(in,'radcals','Select a calibrated radiance file');
    end
    
end
fid = fopen(in);
if fid>2
    
    [pname, fname, ext] = fileparts(in);
    fname = [fname, ext];
    
    C = textscan(fid,'%f %f %f %f %f %f %f %f %f %*[^\n]','HeaderLines',15);
    fclose(fid);
    archi.fname = fname;
    archi.nm = C{1};
    archi.lamps_12 = C{2};
    archi.lamps_8p5 = C{3};
    archi.lamps_8 = C{4};
    archi.lamps_5p5 = C{5};
    archi.lamps_2p5 = C{6};
    archi.lamps_1p5 = C{7};
    archi.lamps_p5 = C{8};
    archi.units = 'W/(m^2.sr.um)';
    archi.lamps_12_pct = C{9}./100;
    figure; plot(archi.nm, [archi.lamps_12,archi.lamps_8p5,archi.lamps_8, archi.lamps_5p5,archi.lamps_2p5,archi.lamps_1p5,archi.lamps_p5],'-');
    legend('12 lamps','8.5 lamps','8 lamps','5p5 lamps','2p5 lamps','1p5 lamp','0.5 lamp');
    title(['Calibrated radiances from ',fname],'interp','none');
    xlabel('wavelength [nm]');
    ylabel(archi.units,'interp','none');
    saveas(gcf,[pname, fname, '.png']);
    
else
    archi = [];
end
return

%%