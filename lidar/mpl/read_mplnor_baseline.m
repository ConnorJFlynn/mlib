function mplbase = read_mplnor_baseline(filename);
%This reads MPLnor baseline files...
if ~exist('filename', 'var')||~exist(filename,'file')
   [filename] = getfullname_('*.dat','mplbase');
end
% Header is 3 lines, one text, one with update time in yyyymmdd.hhmmss,
% third with number of lines of data
% data is three columns of doubles, range(km), avgprof, std(signal to
% noise?)

fid = fopen(filename);
if fid>0
   time_str = textscan(fid,'%s',1,'HeaderLines',1);
   dmp = textscan(fid,'%s',1);
      format_str = '%f %f %f ';
 txt =  textscan(fid,format_str);
end
fclose(fid);
mplbase.time = datenum(time_str{1},'yyyymmdd.HHMMSS');
mplbase.range = txt{1};
mplbase.avgprof = txt{2};
mplbase.std = txt{3};
