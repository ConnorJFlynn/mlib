%%
assist_dir = getdir('*.*','ASSIST');
temp_dir = [assist_dir,'temp'];
if ~exist([assist_dir,'temp'],'dir')
    mkdir(temp_dir);
end
temp_dir = [temp_dir,filesep];

sky_dir = [assist_dir,'sky'];
if ~exist([assist_dir,'sky'],'dir')
    mkdir(sky_dir);
end
sky_dir = [sky_dir,filesep];

%%
piz = dir([assist_dir,'*.piz']);
for p = length(piz):-1:1
    disp(p)
    piz_file = strrep([assist_dir,piz(p).name],'piz','zip');
    if ~exist(piz_file,'file')
        system(['move ',assist_dir,piz(p).name, '  ',piz_file])
            end
end
%%
piz = dir([assist_dir,'*.zip']);
for p = length(piz):-1:1
    disp(p)
    piz_file = strrep([assist_dir,piz(p).name],'piz','zip');
    if ~exist(piz_file,'file')
        unzip(piz_file, temp_dir)
        system(['move ',temp_dir,'*_ann_SKY.csv ',sky_dir]);
        system(['del ',temp_dir,'*.* /q' ]);
    end
end