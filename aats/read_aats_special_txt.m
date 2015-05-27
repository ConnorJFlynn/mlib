function aats = read_aats_special_txt(infile);
if ~exist('infile','var')
inpath = ['C:\case_studies\4STAR\data\2012\2012_05_08_AATS_4STAR_Prede_Avantes\'];
fname = ['AATS_Ames_050812_special.txt'];
infile = [inpath, fname];
end
fid = fopen([infile]);
date_row = fgetl(fid);
filter_row = fgetl(fid);
label_row = fgetl(fid);
txt = textscan(fid,'%s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %*[^\n]','delimiter',' :', 'MultipleDelimsAsOne',true);
fclose(fid);

first = txt{1};
firsts = char(first{1});
indate = datenum(firsts,'dd-mmm-yyyy');
HHMMSS = txt{2};
dv = datevec(indate);
dv = ones([length(txt{2}),1])*dv;
HH = txt{2}; MM = txt{3}; SS = txt{4};
aats.time = datenum([dv(:,1:3),HH,MM,SS])
aats.nm =  [0.3800 0.4520 0.5005 0.5204 0.6052 0.6751 0.7805 0.8645 1.0191 1.2356 2.1391 0.9410]';
aats.lat = [txt{5}];
aats.lon = [txt{6}];
aats.sza = [txt{7}];
aats.V = [txt{8},txt{9},txt{10},txt{11},txt{12},txt{13},txt{14},txt{15},txt{16},txt{17},txt{18},txt{19}];
aats.T = [txt{20},txt{21},txt{22},txt{23},txt{24},txt{25},txt{26},txt{27},txt{28},txt{29},txt{30},txt{31}];
%%

return

%%