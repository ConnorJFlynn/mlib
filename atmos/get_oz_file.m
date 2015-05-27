function oz = get_oz_file(time)
% Load the omi file corresponding to the month of the data.
% gecomiX1.a1.20041001.000000.cdf
% gectomsX1.a1.19960801.000000.cdf
ozone_dir = 'C:\case_studies\ozone\';
toms_dir = [ozone_dir,'toms',filesep];
omi_dir = [ozone_dir, 'omi',filesep];
V = datevec(time); V(:,4) = 0; V(:,5) = 0; V(:,6) = 0;
[V_, V_ii, V_jj] = unique(V,'rows');
time_ = datenum(V_);

for t = length(time_):-1:1
    omi = dir([omi_dir, 'gecomiX1.a1.',datestr(time_(t),'yyyymm01.000000'),'.cdf']);
    if ~isempty(omi)
        oz1 = ancload([omi_dir,omi(1).name]);
    else
        toms = dir([toms_dir, 'gectomsX1.a1.',datestr(time(1),'yyyymm01.000000'),'.cdf']);
        if ~isempty(toms)
            oz1 = ancload([toms_dir,toms(1).name]);
        else
            oz1 = [];
        end
    end
    if ~exist('oz','var')
        oz = oz1;
    else
    oz = anccat(oz,oz1);    
    end
end

return