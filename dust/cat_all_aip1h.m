function aip_1h = cat_all_aip1h;
% aos_1min_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aos_1min\'];
% aos_um_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aos_um\'];
% aip_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aip\'];
aip_1h_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aip_1h\'];

clear aip_1h
mats = dir([aip_1h_dir, 'aip_1h.*.mat']);
%
%%
for m = 1:length(mats)
   disp(['Loading ',mats(m).name]);
   if ~exist('aip_1h','var')
      aip_1h = loadinto([aip_1h_dir,mats(m).name]);
      aip_1h = fix_dim(aip_1h);
   else
      A = loadinto([aip_1h_dir,mats(m).name]);
      A = fix_dim(A);
      aip_1h = cat_1h(aip_1h,A);
      %  aip_1h = cat_1h(aip_1h,loadinto([aip_1h_dir,mats(m).name]));
   end
end

function A = fix_dim(A);
fields = fieldnames(A);
for f = 2:length(fields)
   if all(size(A.(fields{1}))==size(A.(fields{f})'))
      A.(fields{f}) = A.(fields{f})';
   end
end

function aip_1h = cat_1h(aip_1h,B);

[aip_1h.time, inds] = unique([aip_1h.time; B.time]);
fields = fieldnames(B);
for f = 2:length(fields)
   if length(B.(fields{f}))==length(B.time)
%    disp(fields{f});
   tmp = [aip_1h.(fields{f});B.(fields{f})];
   aip_1h.(fields{f}) = tmp(inds);
   end
end