% Check SWS aux files
%%
sws_aux = ancload(getfullname('*.cdf','swsaux'));
%
% plot_qcs(sws_aux)
[pname, fname, ext] = fileparts(sws_aux.fname);

files = dir([pname,filesep, 'sgpswsauxC1.b1.*.cdf']);
for f = 1:length(files)
   sws_aux = ancload([pname,filesep, files(f).name]);
   plot(serial2doy(sws_aux.time), sws_aux.vars.InGaAs_spect_temp.data,'o');
   title(files(f).name,'interp','none');
   ylim([-11,-9]);
   xlim([serial2doy(floor(sws_aux.time(1))),serial2doy(ceil(sws_aux.time(end)))]);
   zoom('on')
   k = menu('Continue','Continue');
end
