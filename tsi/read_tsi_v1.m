function tsi = read_tsi_v1(filename);
%%
%Does not save all fields.  
if ~exist('filename', 'var')
    [fname, pname] = uigetfile('C:\case_studies\Kassianov_Berg_5yr\TSI\*.adj');
    filename = [pname, fname];
end

fid = fopen(filename);
% Fractional Sky Cover:
% BOTH the UTC and LST dates and times are included in the output files. 
% Because of the nature of the error correcting methodology, these 
% daily files based on Local day. Temporal resolution matching the 
% raw input files are named in "YYYYMMDDL.adj" format, with the "L" 
% denoting local day.  The first 3 lines in each file contain information 
% on the adjustment processing settings that were used to generate the 
% files, and are of limited interest to users. Column header abbreviations 
% for the data are as follows:
% 
% zdate - GMT date (YYYYMMDD) 
% ztim - GMT time (hhmmss)  
% ldate - LST date (YYYYMMDD)  
% ltim - LST time (hhmmss)
% CosZ - cosine of the solar zenith angle
% Azim - solar azimuth angle
% Scv - 160 degree FOV total sky cover  
% OScv - 160 degree FOV thick (opaque) sky cover
% TScv - 160 degree FOV thin sky cover  
% ZScv - zenith circle 100 degree FOV total sky cover  
% ZoScv - zenith circle 100 degree FOV thick (opaque) sky cover
% ZtScv - zenith circle 100 degree FOV thin sky cover  
% SScv - sun circle total sky cover  
% SoScv - sun circle thick (opaque) sky cover
% StScv - sun circle thin sky cover  

[pname, fname, ext] = fileparts(filename);
%%
% base_time = datenum(fname, 'yyyymmddHHMM');
txt = textscan(fid,'%d %d %*d %*d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %*[^\n]','headerlines',5);
t_str = sprintf('%08d %06d \n',([txt{1},txt{2}]'));
that = ones([17,length(txt{1})]); that(:) = t_str;
t_str = char(that)';
tsi.time = datenum(t_str,'yyyymmdd HHMMSS');
tsi.cos_sza =  txt{3};
tsi.az = txt{4};
tsi.sky_cov_160 = txt{5};
tsi.opaq_sky_cov_160 = txt{6};
tsi.thin_sky_cov_160 = txt{7};
tsi.sky_cov_100 = txt{8};
tsi.opaq_sky_cov_100 = txt{9};
tsi.thin_sky_cov_100 = txt{10};
tsi.sky_cov_sol = txt{11};
tsi.opaq_sky_cov_sol = txt{12};
tsi.thin_sky_cov_sol = txt{13};
tsi.aspect_ratio = txt{26};
%%

return;