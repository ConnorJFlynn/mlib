function [QIS, MER, RMS, VERS, files] = read_all_ACCP_8K_samplefiles_v7(dpath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code to read sample files for ACCP SIT-A Architecture 8K       %%
%% assessment work and create plots for Study Team                %%
%%                                                                %%
%% By: Jens Redemann, June 1, 2020                                %%
%%     Connor Flynn, June 4, 2020                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified to mask MER and RMS if corresponding QI is invalid.
% If dpath is passed in, then read from that path
% Else, read from ACCP/submitted/_highest
% v4, fixed mislabel of DSR6g as DRSg, and catch SSG3 as GPM
% v4, catch SSG3 as GPM, catch DRSall as DRS6all
% v5, Return VERS and list of files in agggregate
% v6, changed conditions for bad MERS and RMS to tighten on 999.00
% v7, Identify and use only highest version of each input file, and catch SSG3 as SSG4
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
    "DRS6f","DRS6g", "DRS6h", "DRS6i"];
pltf = ["SSP0", "SSP1", "SSP2", "SSG3"];
obs = ["NAD", "NAN", "OND"];
srfc = ["LNDD", "LNDV", "OCEN"];
res = ["RES1", "RES2", "RES3", "RES4", "RES5"];
comments = 'A sample ACCP 8K assessment output file';
row2_text = 'GV#, GVname, QIscore, mean error, RMSE';

% Get listing of files within dpath or subdirectories for *.csv
dirs = dir([dpath,'*']);
direc = dir(fullfile(dpath,'*.csv'));
for d = 1:length(dirs)
    if ~strcmpi(dirs(d).name,'.') && ~strcmpi(dirs(d).name,'..') && isadir([dirs(d).folder,filesep,dirs(d).name])
        direc = [direc; dir([dirs(d).folder,filesep,dirs(d).name,filesep,'*.csv'])];
    end
end
files = {direc(:).name}';
QIS = NaN([73,length(group),length(typ),length(pltf),length(obs),length(srfc),length(res)]);
MER = QIS; RMS = QIS;
% 031,AOD_l_UV_column               ,   0.853,   0.000,     0.032
% tic

% Leave only highest version of each input file
[~,flist] = dirlist_to_filelist(direc);
for ff = length(flist):-1:1
    blip = textscan(flist(ff),'%*s %*s %*s %*s %*s %*s V%f', 'delimiter','_'); blip = blip{1};
    vers(ff) = blip;
end

f = 1; 
while f<length(direc)
    lr = fliplr(direc(f).name); [~,lr] = strtok(lr,'.'); 
    [rev,lr] = strtok(lr(2:end),'_'); stem = fliplr(lr);
    vs = find(startsWith(flist,stem));
    if length(vs)>1
        [vv,vi] = max(vs);
        direc(f).name = direc(vi).name;
        vers(f) = vers(vi);
        vs(vs==f)=[]; % remove current indice from list
        direc(vs) = []; vers(vs) = [];
    end
    f = f+1;
end
     
for f = length(direc):-1:1
%     try
    infile = direc(f).name;
    [grp,rst] = strtok(infile,'_'); rst(1) = [];
    grp_ind = find(strcmpi(grp,group));
    
    [tip,rst] = strtok(rst,'_'); rst(1) = [];% Caution, see 2:end
    typ_ind = find(strcmpi(tip,typ));
    if isempty(typ_ind)&&strcmpi(tip,'ICA')||strcmpi(tip,'DRS')
        tip = [tip,'all'];
        typ_ind = find(strcmpi(tip,typ));
    end
    if isempty(typ_ind)&&strcmpi(tip,'DRS6all')
        typ_ind = 13;
    end
    [plt,rst] = strtok(rst,'_');rst(1) = [];
    plt_ind = find(strcmpi(plt,pltf)); 
    if isempty(plt_ind)&&(strcmpi(plt,'SSP3')||strcmpi(plt,'GPM')||strcmpi(plt,'SSG4')) % Catch SSG3 mislabeled as SSP3
        plt_ind = 4;
    end
    [ob,rst] = strtok(rst,'_');rst(1) = [];
    obs_ind = find(strcmpi(ob,obs));
    [sfc,rst] = strtok(rst,'_');rst(1) = [];
    srfc_ind = find(strcmpi(sfc,srfc));
    [rs,rst] = strtok(rst,'_'); if ~isempty(rst) rst(1) = []; end
    res_ind = find(strcmpi(rs,res)); if isempty(res_ind) res_ind = 1; end;% Assume RES1
    [vs,rst] = strtok(rst,'.'); 
    VERS(f,:) = [string(grp),string(tip), string(plt), string(ob), string(sfc), string(rs), string(vs)];
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
      
            bla1 = blah{1}; badQ = bla1>990; bla1(badQ) = NaN; 
            if length(bla1)==75; bla1(46:47) = [];end  %Catch and correct malformed data files
            % Catch cases
            bla2 = blah{2}; bad = bla2>998.999&bla2<999.0001; 
            if any(badQ&~bad)
                g_str = sprintf('%d ',find(badQ&~bad));
                disp(['Valid MeanErr for invalid QI? GV:',g_str,'in ',direc(f).name]);
            end
            bla2(bad|badQ) = NaN; 
            if length(bla2)==75; bla2(46:47) = [];end %Catch and correct malformed data files
            
            bla3 = blah{3}; bad = bla3>998.999&bla3<999.0001; 
            if any(badQ&~bad)
                g_str = sprintf('%d ',find(badQ&~bad));
                disp(['Valid RMSE for invalid QI? GV:',g_str,'in ',direc(f).name]);
            end
            bla3(bad|badQ) = NaN; 
            if length(bla3)==75; bla3(46:47) = [];end %Catch and correct malformed data files
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
    else
        disp([infile, ' not matched?']);
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

