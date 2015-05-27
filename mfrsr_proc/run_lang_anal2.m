
%%
pname = [];
while ~exist(pname,'dir')
   pname = getdir;
end
% arg.pname = 'C:\case_studies\dust\nimmfrsrM1.b1\solarday\';
arg.pname = pname;

% arg.mfr.fname =[arg.pname,'nimmfrsrM1.b1.20051205.000000.cdf'];
%This initial Vo for filter 5 was determined from a manually identified
%clear sky day.  It is used only for the initial cloud screen.
arg.Vo = 1.0

file_list = dir([arg.pname, '*.cdf']);

for f = 1:length(file_list)
   disp(['Processing: ',file_list(f).name])
   disp(['#', num2str(f), ' of ', num2str(length(file_list))])
   arg.mfr.fname = [arg.pname, file_list(f).name];
   tic;
   [lang] = lang_nim(arg);
   toc
end
   