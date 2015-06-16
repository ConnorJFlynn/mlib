%% Checking ASSIST data from Gan, trying to find source of crash in ingest
% causes core dump on two piz packets.
clear
matfile = getfullname('*chA_BTemp_SKY.coad.mrad.coad.merged.degraded.truncated.mat','edgar_mat','Select and edgar mat file')

[pname, fname] = fileparts(matfile);

%%
files = dir([pname, filesep,'*chB*.mat']);
%%
for f = length(files):-1:1
tic
infile = files(f).name
mat = repack_edgar([pname, filesep,files(f).name]);
if length(mat.time)>1&&any(diff(mat.time)<0)
    menu('Bad times','OK')
end
figure(1);
plot([1:length(mat.time)], serial2doy(mat.time),'*');
tl = title({'Times for :';infile}); set(tl,'interp','none');

figure(2);
lines = plot(mat.x(3:end-2), mat.y(:,3:end-2),'-');
title(infile,'interp','none')
if length(lines)>1&~all(mat.time==mat.time(1))
    recolor(lines,mat.time); 
else
    tl =title({datestr(mat.time(1),'yyyy-mm-dd HH:MM:SS');infile});
    set(tl,'interp','none')
end
toc
end

%%
matfile = getfullname('*chA_BTemp_SKY.coad.mrad.coad.merged.degraded.truncated.mat','edgar_mat','Select and edgar mat file');

[pname, fname] = fileparts(matfile);
infile = '20111011_000426_chA_RESP_IMA_SKY.coad.mrad.pro.merged.degraded.truncated.mat';
mat = repack_edgar([pname, filesep,infile])
figure(1);
plot([1:length(mat.time)], serial2doy(mat.time),'*');
tl = title({'Times for :';infile}); set(tl,'interp','none');

figure(2);
lines = plot(mat.x(3:end-2), mat.y(:,3:end-2),'-');
title(infile,'interp','none')
if length(lines)>1&~all(mat.time==mat.time(1))
    recolor(lines,mat.time); 
else
    tl =title({datestr(mat.time(1),'yyyy-mm-dd HH:MM:SS');infile});
    set(tl,'interp','none')
end

