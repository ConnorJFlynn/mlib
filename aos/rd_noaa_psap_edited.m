function [psap] = rd_noaa_psap_edited(infile);
% This function is intended to read a mentor-edited NOAA CLAP or PSAP file
% It could be made much more general to parse NOAA's format
if ~exist('infile','var')
   infile = getfullname('*psap3wM1*','NOAA_edited_psap','Select an NOAA edited PSAP file.');
end
if exist(infile,'file')
   %   Detailed explanation goes here
   fid = fopen(infile);
else
   disp('No valid file selected.')
   return
end

% 9999-99-99T99:99:99Z;FFFF;FFFF;0;9999.99;9999.99;9999.99;9.9999999;9.9999999;9.9999999;99999.999;9999.99
fmt_str = '%s %s %f %s %s %s %s %f %f %f %f %f %f %f %f '; % Date/time, "I"

this = [];
while ~feof(fid) &&  (isempty(this)||strcmp(this(1),'!'))
   mark = ftell(fid);
   this = fgetl(fid);
end

if ~feof(fid)
   fseek(fid,mark,-1);
   A = textscan(fid,fmt_str, 'delimiter',',');
end
fclose(fid);

A(1) = []; A(1) = [];
epoch = A{1};A(1)= [];
psap.time = epoch2serial(epoch);
time_str = A{1};A(1)= [];
% F1_A11;F2_A11;Ff_A11; BaB_A11;BaG_A11;BaR_A11; IrB_A11;IrG_A11;IrR_A11; L_A11;BaO_A11
psap.F1 = A{1}; psap.F2 = A{2}; psap.Ff = A{3};
psap.Ba_B = A{4}; psap.Ba_G = A{5}; psap.Ba_R = A{6};
miss = psap.Ba_B>9000 |psap.Ba_G>9000 | psap.Ba_R>9000;
psap.Ba_B(miss) = NaN;psap.Ba_G(miss) = NaN; psap.Ba_R(miss) = NaN;
psap.Tr_B = A{7}; psap.Tr_G = A{8}; psap.Tr_R = A{9};
miss = psap.Tr_B>9 | psap.Tr_G>9 | psap.Tr_R>9 ;
psap.Tr_B(miss) = NaN;  psap.Tr_G(miss) = NaN;  psap.Tr_R(miss) = NaN; 
psap.Length = A{10};psap.Ba_O = A{11};

return
