function popsext = rd_popsext_raw(in_file)
% aims = rd_aims_raw(in_file)
% Reads aims raw csv file and returns time-dimensioned struct
% V 0.1, 2022-07-25, Connor Flynn (in preparation for UAS3 STAP processing

% UTC,Altitude_m,Extinction_um-1
% 09-Jul-2022 13:59:49.034,914,31.22

if ~isavar('in_file')||~isafile(in_file)
    in_file = getfullname('*uav.ext*.txt','aaf_popsext');
end
fid = fopen(in_file);

header_line = fgetl(fid); 
header = textscan(header_line,'%s','delimiter',',');header = header{:};
fmt = ['%s %f %f %*[^\n]'];
AA = textscan(fid,fmt,'delimiter',','); AA;
fclose(fid);
DS = AA{1}; 
popsext.time = datenum(DS,'dd-mmm-yyyy HH:MM:SS.fff');
popsext.alt_mAGL = AA{2};
popsext.ext_um = AA{3};

end