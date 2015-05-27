clear; 
%%

prepare;
%%

%Keep lambda, wvl_aero, data, UT
aats.fname = filename;
aats.pname = data_dir;
aats.lat = geog_lat(1);
aats.lon = geog_long(1);
aats.time = (datenum([year,month,day])+UT/24);
aats.lambda = lambda;
aats.wvl_aero = wvl_aero;
aats.data = data;
aats.good = true(size(aats.data));
[Zen_Sun,Az_Sun, soldst, HA_Sun, Decl_Sun, Elev_Sun, aats.airmass] = sunae(aats.lat, aats.lon,aats.time);
aats.Vo = NaN(size(lambda));
aats.Vo_ = NaN(size(lambda));
%%

for ii = find(wvl_aero)
   [aats.Vo(ii),tau,aats.Vo_(ii), tau_, aats.good(ii,:)] = dbl_lang(aats.airmass,aats.data(ii,:),2.5,5,0);
end
aats.min_am = min(aats.airmass(aats.good(ii,:)));
aats.max_am = max(aats.airmass(aats.good(ii,:)));

[pth fname]  = fileparts(aats.fname);

out_name = [aats.pname, fname,'.',datestr(aats.time(1),'yyyy_mm_dd.HH'), 'UTC.Vo.mat'];
disp(['Saving ',out_name]);
save(out_name, 'aats');
   %%
