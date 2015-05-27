function mpl = mplnor_passthru(mpl);
% Read mplnor file.
% Read relevant baseline files to populate baseline array
if ~exist('mpl', 'var')
   mpl = ancload(getfullname_('*.cdf*','mplnor','Select MPLnor netcdf file.'));
end
%%
%get baseline
disp(datestr(mpl.time([1 end])))
dstr = datestr(mpl.time(1),'yyyymmdd');
%%
baseline_path = 'C:\case_studies\mplnor\twp_C3\';
basefile = dir([baseline_path,'*baseline.*.dat']);
b = length(basefile)
bases = read_mplnor_baseline([baseline_path,basefile(b).name]);
for b = (length(basefile)-1):-1:1
   tmp_base = read_mplnor_baseline([baseline_path,basefile(b).name]);
[bases.time,ind] = unique([bases.time,tmp_base.time]);
bases.avgprof(:,ind) = [bases.avgprof,tmp_base.avgprof];
bases.std(:,ind) = [bases.std,tmp_base.std];

end

return
