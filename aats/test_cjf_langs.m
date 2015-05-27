% % % clear; 
% % % %%
% % % 
% % % prepare;
% % % %%
% % % 
% % % %Keep lambda, wvl_aero, data, UT
% % % aats.fname = filename;
% % % aats.pname = data_dir;
% % % aats.lat = geog_lat(1);
% % % aats.lon = geog_long(1);
% % % aats.time = (datenum([year,month,day])+UT/24);
% % % aats.lambda = lambda;
% % % aats.wvl_aero = wvl_aero;
% % % aats.data = data;
% % % aats.good = true(size(aats.data));
% % % [Zen_Sun,Az_Sun, soldst, HA_Sun, Decl_Sun, Elev_Sun, aats.airmass] = sunae(aats.lat, aats.lon,aats.time);
% % % aats.Vo = NaN(size(lambda));
% % % aats.Vo_ = NaN(size(lambda));
% % % %%
% % % 
% % % for ii = find(wvl_aero)
% % %    %
% % % %    disp(num2str(lambda(ii)))
% % %    [aats.Vo(ii),tau,aats.Vo_(ii), tau_, aats.good(ii,:)] = dbl_lang(aats.airmass,aats.data(ii,:),3,5,0);
% % %    %
% % %    [lambda(ii), aats.Vo(ii), aats.Vo_(ii), min(aats.airmass(aats.good(ii,:))), max(aats.airmass(aats.good(ii,:)))]
% % % end
% % % [pth fname]  = fileparts(aats.fname);
% % % out_name = [aats.pname, fname,'.',datestr(aats.time(1),'yyyy_mm_dd.HH'), 'UTC.Vo.mat'];
% % % save(out_name, 'aats');
   %%
Vo_dir = 'C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\MLO_Aug_2008\AATS\mauna loa\';
files = dir([Vo_dir, '*.Vo.mat']);
for f = length(files):-1:1
   aats_day(f).aats = loadinto([Vo_dir, files(f).name]);
end

all_Vo = [aats_day(1).aats.Vo];
for a = 2:length(aats_day)
all_Vo = [all_Vo aats_day(a).aats.Vo];
end
mean_Vo = mean(all_Vo,2);
std_Vo = std(all_Vo')';
pct_Vo = 100*std_Vo./mean_Vo;