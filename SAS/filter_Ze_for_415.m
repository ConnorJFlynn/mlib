files = getfullname('sgpsas*.*','filterbands');

Ze = anc_load(files{1});
vars = fieldnames(Ze.vdata);
remv = foundstr(vars,'zenith_transmittance')|foundstr(vars,'vis')|foundstr(vars,'nir');
remv = remv | (foundstr(vars,'zenith_radiance')&~foundstr(vars,'_4'));
remv = remv | foundstr(vars,'collector') | foundstr(vars,'chiller') | foundstr(vars,'temp');
Ze.vdata = rmfield(Ze.vdata, vars(remv)); Ze.vatts = rmfield(Ze.vatts,vars(remv));

for f = 2:length(files)
   Ze2 = anc_load(files{f});
   Ze2.vdata = rmfield(Ze2.vdata, vars(remv)); Ze2.vatts = rmfield(Ze2.vatts,vars(remv));
   Ze = anc_cat(Ze, Ze2);
   disp(num2str(length(files)-f))
end

save('D:\AGU_prep\Ze_filtered.mat','-struct','Ze')