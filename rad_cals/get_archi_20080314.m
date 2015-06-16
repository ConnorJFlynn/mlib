function [archi] = get_archi_20080314(in)

% C:\case_studies\radiation_cals\GSFC_AMES\
% File = /rarray/calibrat/source/30inch/2008/20080314_v1.src
% Source = Ames 30 inch standard sphere
% Lamps = 1,2,3,4,5,6,7,8,9,10,11,12 (12-9-6-3)
% Power supply voltage = 6.4
% Date of calibration measurement = March 14, 2008
% Place of measurement = Ames Research Center
% Method of measurement = Monochrometer (747) 
% Measurement performed by =  J. Cooper (GSCF)
% Units = W(m^2.sr.um)
% Version = 1.0
% COMMENTS = Periodic calibration measurement  
% Derived from file = /rarray/calibrat/source/30inch/2008/20080314105200Archi.txt
% ******************************************************************************
% 0.37	6.71	5.09	3.63	1.78
%%
if ~exist('in','var')
    in = ['C:\case_studies\radiation_cals\spheres\ARCHI\20080314_v1.Archi.txt'];
else
    while ~exist(in,'file')
        in = getfullname(in,'radcals','Select a calibrated radiance file');
    end
    
end
fid = fopen(in);
if fid>2
    
    [pname, fname, ext] = fileparts(in);
    fname = [fname, ext];
    
    C = textscan(fid,'%f %f %f %f %f %f %f %f %*[^\n]','HeaderLines',15);
    fclose(fid);
    archi.fname = fname;
    archi.nm = C{1}.*1000;
    archi.lamps_12 = C{2};
    archi.lamps_9 = C{3};
    archi.lamps_6 = C{4};
    archi.lamps_3 = C{5};
%     archi.lamps_2 = C{6};
%     archi.lamps_1 = C{7};
    archi.units = 'W/(m^2.sr.um)';
%     archi.lamps_12_pct = C{8}./100;
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