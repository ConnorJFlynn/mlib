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

star.aats_wl =  [0.4526   0.4994   0.5194  0.6044 0.6751  0.7784 0.8645    1.0121]*1e3;
aats_pct = [0.24 0.26 0.22 0.45 0.09 0.09 0.05 0.08];

[aats_day(f).aats.lambda([3:9 11]), pct_Vo([3:9 11]),aats_pct' ]