function aats = prepare_aats(filename);
if ~exist('filename','var')||(~exist(filename,'file'))
   filename = getfullname('R*.*','aats','read aats file')
end
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