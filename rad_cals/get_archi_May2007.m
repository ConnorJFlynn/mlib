function [archi] = get_archi_May2007(in)

% SWS and SAS-Ze calibrations, Nov 2011, SGP and NASA Ames
% First load the NASA GSFC calibrations of NASA Ames sources
% Load ARCHI cals from Dec 2011
% C:\case_studies\4STAR\Calibration\new_bigsphere_cal_20070809\
% 20070518083800Archi.txt
%
% Source:   Archi     (ARC 30" Sphere)    
% Date:     05-18-07            
% Units:    Radiance in W/(m^2.sr.µm)               
% Inst:     OL 746              
% Std:      HEC2023-200702-WLC.CAL                  
% Tech:     Cooper              
% Loc:      ARC, Bldg. 256N               
% Dist:     75.30 cm            
% Diam:     29.85 cm            
% Temp:     24 c                
% RH:       38%                 
% Ver:      0                   
% Files:    (std lamp)          L070518[CO].ALL     
%           (blocked) A070518[AH].ALL     
%           (source)  A070518[DIK].ALL    
%           (levels)  A070518[DEFGKLMN].ALL         
% Notes:    This calibration prior to changing lamps (lamps changed on 5/17/2007). Values < 600nm corrected for stray light.                                      
% Data:                                             
% nm        12        9         6         3         Uncertainty [12 lamps, K=1]
% 370       7.06      5.20      3.58      1.82      2.9%

%%
if ~exist('in','var')
    in = ['C:\case_studies\4STAR\Calibration\new_bigsphere_cal_20070809\20070518083800Archi.txt'];
else
    while ~exist(in,'file')
        in = getfullname(in,'radcals','Select a calibrated radiance file');
    end
    
end
fid = fopen(in);
if fid>2
    
    [pname, fname, ext] = fileparts(in);
    pname = [pname, filesep];
    fname = [fname, ext];
    
    C = textscan(fid,'%f %f %f %f %f %f  %*[^\n]','HeaderLines',19);
    fclose(fid);
    archi.fname = fname;
    archi.nm = C{1};
    archi.lamps_12 = C{2};
    archi.lamps_9 = C{3};
    archi.lamps_6 = C{4};
    archi.lamps_3 = C{5};
    archi.units = 'W/(m^2.sr.um)';
    archi.lamps_12_pct = C{6}./100;
    figure; plot(archi.nm, [archi.lamps_12,archi.lamps_9,archi.lamps_6, archi.lamps_3],'-');
    legend('12 lamps','9 lamps','6 lamps','3 lamps');
    title(['Calibrated radiances from ',fname],'interp','none');
    xlabel('wavelength [nm]');
    ylabel(archi.units,'interp','none');
    saveas(gcf,[pname, fname, '.png']);
    
else
    archi = [];
end
return

%%