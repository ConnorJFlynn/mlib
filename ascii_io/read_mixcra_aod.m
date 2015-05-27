function mixcra = read_mixcra_aod(filename);
%This reads Dave Turner's AERI MIXCRA AOD values
% Two columns, space delimited
%1st column: days since 2006_01_01 
%2nd column: AOD_11um
% Nine header lines
if ~exist('filename', 'var')||~exist(filename,'file')
   [fid,fname, pname] = getfile('*.txt','mixcra');
   fclose(fid);
   filename = [pname, fname];
end
%       txt =
%       textscan(fid,format_str,'headerlines',header_rows,'delimiter',',','treatAsEmpty','N/A');
% Nine lines of header info
fid = fopen(filename);
if fid>0
   format_str = '%f %f ';
   txt = textscan(fid,format_str, 'headerlines',9);
fclose(fid);
mixcra.time = datenum('1-1-2006','dd-mm-yyyy')+txt{1}-1;
mixcra.aod = txt{2};
else
   mixcra = [];
end


