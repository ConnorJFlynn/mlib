%get_aos_flags
clear
pname = 'C:\case_studies\dust\nimaosM1.a1\';
files = dir([pname,'nimaosM1.*.cdf']);
for f = 1:length(files);
   disp(['File ',num2str(f),' of ',num2str(length(files))])
   aos = ancload([pname,files(f).name]);
   if ~exist('aos_flags','var')
      aos_flags.time = aos.time;
      aos_flags.hex = aos.vars.flags_NOAA.data;
   else
      aos_flags.time = [aos_flags.time, aos.time];
      aos_flags.hex = [aos_flags.hex, aos.vars.flags_NOAA.data];
   end
end
[aos_flags.time, inds] = unique(aos_flags.time);
aos_flags.hex = aos_flags.hex(:,inds);
aos_flags.flags = uint32(hex2dec(aos_flags.hex')');

save aos_flags.mat aos_flags
%%
