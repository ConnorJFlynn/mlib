%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code to write out sample files for ACCP SIT-A Architecture 8K  %%
%% assessment work                                                %%
%%                                                                %%
%% By: Jens Redemann, June 1, 2020                                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all

group = ["NLP", "NLB", "NLS", "NGE", "OUX", "CND"];
typ = ["SPA", "RDA",...
       "ICAall", "ICA6a", "ICA6b", "ICA6c", "ICA6d", "ICA6e",...
       "ICA6f","ICA6g", "ICA6h", "ICA6i",...
       "DRSall", "DRS6a", "DRS6b", "DRS6c", "DRS6d", "DRS6e",...
       "DRS6f","DRS6g", "DRS6h", "DRS6i"];
pltf = ["SSP0", "SSP1", "SSP2", "SSG3"];
obs = ["NAD", "NAN", "OND"];
srfc = ["LNDD", "LNDV", "OCEN"];
res = ["RES1", "RES2", "RES3", "RES4", "RES5"];
comments = 'A sample ACCP 8K assessment output file';
row2_text = 'GV#, GVname, QIscore, mean error, RMSE';  


%% Import the GVnames as array of strings from xlsx file
[~, ~, GVnames] = xlsread('C:\jens\Documents\Missions\ACCP\SITA_8K_assessments\GVnames.xlsx','Sheet1');

GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';

QIscore = ones(1,length(GVnames));
mean_unc = ones(1,length(GVnames));
RMS = ones(1,length(GVnames));

%% Dimensioning the results array
results = ones(length(group),length(typ),length(pltf),length(obs),length(srfc),length(res));

%% Populating files
for i=1:length(group)
    for j=1:length(typ)
        for k=1:length(pltf)
            for l=1:length(obs)
                for m=1:length(srfc)
                    for n=1:length(res)

%% Defining filename
resultfile=join([group(i),'_',typ(j),'_',pltf(k),'_',obs(l),'_',srfc(m),'_',res(n),'_V04', '.csv'],'')
path = ['c:\jens\Documents\Missions\ACCP\SITA_8K_assessments\Test\']

%%writing to file
fid=fopen(join([path resultfile],''),'w');

fprintf(fid,'%s%s%s\r\n',resultfile, ', Comments: ',comments);
fprintf(fid,'%s\r\n',row2_text);

for o=1:length(GVnames) %#ok<*NOPTS>
    r1=rand(3,1)
    fprintf(fid,'%2d, %s, %8.3f, %8.3f, %8.3f\r\n',o, GVnames(o), r1(1)*QIscore(o), r1(2)*mean_unc(o), r1(3)*RMS(o));
end
fclose(fid);
                    end
                end
            end
        end
    end
end


close all


