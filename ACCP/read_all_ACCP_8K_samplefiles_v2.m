function [QIS, MER, RMS] = read_all_ACCP_8K_samplefiles_v2(dpath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code to read sample files for ACCP SIT-A Architecture 8K       %%
%% assessment work and create plots for Study Team                %%
%%                                                                %%
%% By: Jens Redemann, June 1, 2020                                %%
%%     Connor Flynn, June 4, 2020                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If dpath is passed in, then read from that path
% Else, read from ACCP/submitted/_highest

% clear all
% close all
if ~isavar('dpath')
    dpath = setnamedpath('ACCP_set','','Select directory of data to read (and subdirs)');
end

group = ["NLP", "NLB", "NLS", "NGE", "OUX", "CND"];
typ = ["SPA", "RDA",...
    "ICAall", "ICA6a", "ICA6b", "ICA6c", "ICA6d", "ICA6e",...
    "ICA6f","ICA6g", "ICA6h", "ICA6i",...
    "DRSall", "DRS6a", "DRS6b", "DRS6c", "DRS6d", "DRS6e",...
    "DRS6f","DRSg", "DRS6h", "DRS6i"];
pltf = ["SSP0", "SSP1", "SSP2", "SSG3"];
obs = ["NAD", "NAN", "OND"];
srfc = ["LNDD", "LNDV", "OCEN"];
res = ["RES1", "RES2", "RES3", "RES4", "RES5"];
comments = 'A sample ACCP 8K assessment output file';
row2_text = 'GV#, GVname, QIscore, mean error, RMSE';

% Get listing of files within dpath or subdirectories for *.csv
dirs = dir([dpath,'*.']);
direc = dir(fullfile(dpath,'*.csv'));
for d = 1:length(dirs)
    if ~strcmp(dirs(d).name,'.') && ~strcmp(dirs(d).name,'..') && isadir([dirs(d).folder,filesep,dirs(d).name])
        direc = [direc; dir([dirs(d).folder,filesep,dirs(d).name,filesep,'*.csv'])];
    end
end

QIS = NaN([73,length(group),length(typ),length(pltf),length(obs),length(srfc),length(res)]);
MER = QIS; RMS = QIS;
% 031,AOD_l_UV_column               ,   0.853,   0.000,     0.032
% tic
for f = length(direc):-1:1
%     try
    infile = direc(f).name;
    [grp,rst] = strtok(infile,'_'); rst(1) = [];
    grp_ind = find(strcmp(grp,group));
    [tip,rst] = strtok(rst,'_'); rst(1) = [];% Caution, see 2:end
    typ_ind = find(strcmp(tip,typ));
    if isempty(typ_ind)&&strcmp(tip,'ICA')||strcmp(tip,'DRS')
        tip = [tip,'all'];
        typ_ind = find(strcmp(tip,typ));
    end
    [plt,rst] = strtok(rst,'_');rst(1) = [];
    plt_ind = find(strcmp(plt,pltf)); 
    if isempty(plt_ind)&&strcmp(plt,'SSP3')
        plt_ind = 4;
    end
    [ob,rst] = strtok(rst,'_');rst(1) = [];
    obs_ind = find(strcmp(ob,obs));
    [sfc,rst] = strtok(rst,'_');rst(1) = [];
    srfc_ind = find(strcmp(sfc,srfc));
    [rs,rst] = strtok(rst,'_'); if ~isempty(rst) rst(1) = []; end
    res_ind = find(strcmp(rs,res)); if isempty(res_ind) res_ind = 1; end;% Assume RES1
    if ~isempty(grp_ind)&&~isempty(typ_ind)&&~isempty(plt_ind)&&~isempty(obs_ind)&&~isempty(srfc_ind)&&~isempty(res_ind)
        
        %       blah = importdata([direc(f).folder, filesep, direc(f).name]);
        %       fopen, textscan, fclose runs in 1/10th the time as importdata
        fid = fopen([direc(f).folder, filesep, direc(f).name],'r');
        if fid>0
            [blah, endpos] = textscan(fid,'%*d %*s %f %f %f','delimiter',',', 'headerlines',2);
            if isempty(blah{1})
                % x_GV_,GVName,unc,UnitsForUnc,QIScore,MeanError,RMSE
                [blah, endpos] = textscan(fid,'%*d %*s %*s %*s %f %f %f','delimiter',',', 'headerlines',1);
            end            
            bla1 = blah{1}; bad = bla1>990; bla1(bad) = NaN; if length(bla1)==75; bla1(46:47) = [];end
            bla2 = blah{2}; bad = bla2>990; bla2(bad) = NaN; if length(bla2)==75; bla2(46:47) = [];end
            bla3 = blah{3}; bad = bla3>990; bla3(bad) = NaN; if length(bla3)==75; bla3(46:47) = [];end
            if all(isNaN(bla1))&&all(isNaN(bla2))&&all(isNaN(bla3))
                disp([direc(f).name, ' is all NaN']);
            else % QI_5 = QIS(H,2,3,:,L,m,1);
                QIS(:,grp_ind,typ_ind,plt_ind,obs_ind,srfc_ind,res_ind) = bla1;
                MER(:,grp_ind,typ_ind,plt_ind,obs_ind,srfc_ind,res_ind) = bla2;
                RMS(:,grp_ind,typ_ind,plt_ind,obs_ind,srfc_ind,res_ind) = bla3;
                %                 disp([num2str(sum(isNaN(bla1))+sum(isNaN(bla2))+sum(isNaN(bla3))), ' nonNaNs'])
            end
            fclose(fid);
        end
        %     sprintf('%s : %d ',direc(f).name, endpos)
%         disp(['Good']);
    end
%     catch
%         disp(['Bad:',infile]);
%     end
    
end
% toc
% gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73];
% plot_ACCP_fig_V3(QIS,MER,RMS,gv,'LNDD','RES1');
% plot_ACCP_fig_V3(QIS,MER,RMS,gv,'OCEN','RES1');
end

