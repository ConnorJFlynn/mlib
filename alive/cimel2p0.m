function cimel = cimel2p0(infile)
% Does not eat raw files
% Files require pre-editing via Excel to remove the top 3 rows and strip
% out NaNs
if ~exist('infile','var')
   [fname, pname]= uigetfile('*.csv');
   infile = [pname, fname];
end
if ~exist(infile,'file')
   [fname, pname]= uigetfile('*.csv');
   infile = [pname, fname];
end
raw = loadit(infile);
cimel.time = (raw(:,1)-1+datenum('2005-01-01','yyyy-mm-dd'));
cimel.aot_1020 = raw(:,2);
cimel.aot_870 = raw(:,3);
cimel.aot_670 = raw(:,4);
cimel.aot_500 = raw(:,5);
cimel.aot_440 = raw(:,6);
cimel.aot_380 = raw(:,7);
cimel.aot_340 = raw(:,8);
cimel.h20 = raw(:,9);
cimel.ang_440_870 = raw(:,10);
cimel.ang_380_500 = raw(:,11);
cimel.ang_440_675 = raw(:,12);
cimel.ang_500_870 = raw(:,13);
cimel.ang_340_440 = raw(:,14);
cimel.zen = raw(:,15);
cimel.CW1020 = raw(1,16);
cimel.CW870 = raw(1,17);
cimel.CW670 = raw(1,18);
cimel.CW500 = raw(1,19);
cimel.CW440 = raw(1,20);
cimel.CW380 = raw(1,21);
cimel.CW340 = raw(1,22);
cimel.CW_H2O = raw(1,23);
