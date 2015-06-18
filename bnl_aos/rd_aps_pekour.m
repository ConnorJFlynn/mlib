function aps = rd_aps_pekour(in_file)

% aps = rd_aps_pekour(in_file)

if ~exist('in_file','var')||~exist(in_file,'file')
    in_file = getfullname_('*.csv','aps_pvc');
end
% cols 1-7: Year,Month,Day,Hour,Min,Sec,Epoch,
% <0.523,
% 0.542,0.583,0.626,0.673,0.723,0.777,0.835,0.898,0.965,1.037,
% 1.114,1.197,1.286,1.382,1.486,1.596,1.715,1.843,1.981,2.129,
% 2.288,2.458,2.642,2.839,3.051,3.278,3.523,3.786,4.068,4.371,
% 4.698,5.048,5.425,5.829,6.264,6.732,7.234,7.774,8.354,8.977,
% 9.647,10.37,11.14,11.97,12.86,13.82,14.86,15.96,17.15,18.43,
% 19.81,Total Concentration [#/cc]

% 2012, 07, 10, 16, 40, 00, 735060.694444445,
% 8.335,
% 4.384, 6.528, 8.657, 8.015, 6.912, 5.676, 4.594, 4.119, 3.337, 3.107,
% 2.925, 2.807, 2.695, 2.737, 2.604, 2.520, 2.946, 2.793, 2.807, 2.723,
% 2.842, 2.772, 2.960, 2.667, 2.506, 2.346, 1.913, 1.815, 1.508, 1.354,
% 1.089, .8169, .7331, .5795, .4608, .3491, .2653, .1466, .1745, .1676,
% .1047, .06982, .05585, .02095, .02793, .01396, 0, 0, 0, 0, 0, 5.541

fid = fopen(in_file);
col_header = fgetl(fid);
cols = textscan(col_header, '%s','delimiter',','); cols = cols{:};


A = textscan(fid, ['%d %d %d %d %d %d %f ' repmat('%f ',[1,53]) ' %*[^\n]'],'delimiter',',');
fclose(fid);
DT = [A{1},A{2},A{3},A{4},A{5},A{6}];
A(1:7) = [];
cols(1:7) = [];
aps.time = datenum(double(DT));clear DT
if ~isempty(strfind(cols{end},'centr'))
    aps.total_conc = A{end}; A(end) = []; cols(end) = [];
    for lab = length(cols):-1:2
        aps.D(lab) = sscanf(cols{end},'%f');
        aps.sdist(:,lab) = A{end};
        A(end) = []; cols(end) = [];
    end
    aps.D(1) = 0;
    aps.sdist(:,1) = A{end};
    A(end) = []; cols(end) = [];
    bad = aps.sdist<0;
    aps.sdist(bad) = NaN;
    bad = aps.total_conc<0;
    aps.total_conc(bad) = NaN;
elseif ~isempty(strfind(cols{end},'olume'))
    aps.total_vol = A{end}; A(end) = []; cols(end) = [];
    for lab = length(cols):-1:2
        aps.D(lab) = sscanf(cols{end},'%f');
        aps.vdist(:,lab) = A{end};
        A(end) = []; cols(end) = [];
    end
    aps.D(1) = 0;
    aps.vdist(:,1) = A{end};
    A(end) = []; cols(end) = [];
    bad = aps.vdist<0;
    aps.vdist(bad) = NaN;
    bad = aps.total_vol<0;
    aps.total_vol(bad) = NaN;
    
end

%  figure; imagegap(serial2doy(aps.time), aps.D, real(log10(aps.vdist'))); colorbar; axis('xy')
[aps.pname, aps.fname, ext] = fileparts(in_file);
aps.pname = [aps.pname, filesep];aps.fname= [aps.fname, ext];
save([aps.pname, strrep(aps.fname, '.csv','.mat')],'-struct','aps');
return