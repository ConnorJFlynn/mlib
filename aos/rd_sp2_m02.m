function sp2 = rd_sp2_m02(in_file);

if ~exist('in_file','var') || ~exist(in_file,'file')
   in_file = getfullname('*.sp2.*.m02*','sp2','select mentor-edited SP2 file');
end
% tic
fid = fopen(in_file);

in = fgetl(fid);
cols = textscan(in,'%s','delimiter','\t'); cols = cols{:};
data = textscan(fid,['%*s %*d %s %s %f %f %f %f ',repmat('%f ',[1,400])],'delimiter','\t');
fclose(fid);
date = data{1}; UTC = data{2}; 
data(1) = []; data(1) = [];
for r = length(date):-1:1
   dates(r) = {[date{r}, ' ',UTC{r}]};
end
sp2.time = datenum(dates,'yyyy/mm/dd HH:MM:SS');
cols(1) = []; cols(1) = []; % Remove filenotes and (Igor?) time in seconds
cols(1) = []; cols(1) = []; % Remove date and time columns

sp2.(cols{1}) = data{1}; 
data(1) = []; cols(1) = [];
sp2.(cols{1}) = data{1}; 
data(1) = []; cols(1) = [];
sp2.(cols{1}) = data{1}; 
data(1) = []; cols(1) = [];
sp2.(cols{1}) = data{1}; 
data(1) = []; cols(1) = [];
sp2.cnts = [data{1:200}]; 
data(1:200) = []; cols(1:200) = [];
sp2.scat_cnts = [data{1:200}]; 
data(1:200) = []; cols(1:200) = [];

sp2.Dmin = sp2.SP2_Dmin(isfinite(sp2.SP2_Dmin))'; sp2 = rmfield(sp2,'SP2_Dmin');
sp2.Dmax = sp2.SP2_Dmax(isfinite(sp2.SP2_Dmax))'; sp2 = rmfield(sp2,'SP2_Dmax');
sp2.Dgeo = sp2.SP2_Dgeo(isfinite(sp2.SP2_Dgeo))'; sp2 = rmfield(sp2,'SP2_Dgeo');

return