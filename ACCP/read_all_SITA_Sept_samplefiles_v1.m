function [QIS, MER, RMS, VERS, files] = read_all_SITA_Sept_samplefiles_v2(dpath)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Code to read sample files for ACCP SIT-A Sept study            %%
%% assessment work and create plots for Study Team                %%
%%                                                                %%
%% By: Connor Flynn, Sept 1, 2020                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Based directly on read_all_ACCP_Arch11_samplefiles_v1
% If dpath is passed in, then read from that path
% Else, read from ACCP/submitted/_highest
% v1: original version
% v2: 2020-09-01, propagate SSP0 value for ONDPC0 to SSP1 and SSP2 for NLB and OUX
if ~isavar('dpath')
    dpath = setnamedpath('ACCP_set','','Select directory of data to read (and subdirs)');
end

GRP = ["NLP", "NLB", "NLS", "NGE", "OUX"];                  %5
TYP = ["DRS8a1", "DRS8b1", "DRS8c1", "DRS8d1", "DRS8e1",... % typ_ind  1-5
    "DRS8f1", "DRS8g1", "DRS8h1", "DRS8i1", "DRS8j1",...    % typ_ind  6-10
    "DRS8k1", "DRS8l1", "DRS8m1", "DRS8n1", "DRS8o1",...    % typ_ind 11-15
    "DRS8a2", "DRS8b2", "DRS8c2", "DRS8d2", "DRS8e2",...    % typ_ind 16-20
    "DRS8f2", "DRS8g2", "DRS8h2", "DRS8i2", "DRS8j2",...    % typ_ind 21-25
    "DRS8k2", "DRS8l2", "DRS8m2", "DRS8n2", "DRS8o2",...    % typ_ind 26-30
    "ICA8a1", "ICA8b1", "ICA8c1", "ICA8d1", "ICA8e1",...    % typ_ind 31:35
    "ICA8f1", "ICA8g1", "ICA8h1", "ICA8i1", "ICA8j1",...    % typ_ind 36:40
    "ICA8k1", "ICA8l1", "ICA8m1", "ICA8n1", "ICA8o1",...    % typ_ind 41:45    
    "ICA8a2", "ICA8b2", "ICA8c2", "ICA8d2", "ICA8e2",...    % typ_ind 46:50
    "ICA8f2", "ICA8g2", "ICA8h2", "ICA8i2", "ICA8j2",...    % typ_ind 51:55
    "ICA8k2", "ICA8l2", "ICA8m2", "ICA8n2", "ICA8o2",...    % typ_ind 56:60    
    "SPA", "RDA"];                                          %62
% Mapping of TYP to surface type:
Ocean_cases= ["8a","8b","8c","8g","8h","8k","8l"]; 
Land_cases= ["8d","8e","8f","8i","8j","8m","8n","8o"];
ocen_case = [1:3 7:8 11:12]; 
land_case = [4:6 9:10 13:15];
case1 = 0; case2 = 15;
DRS = 0; ICA = 30;
for typ = length(TYP):-1:1
    O_case(typ) = contains(TYP(typ),Ocean_cases);
    L_case(typ) = contains(TYP(typ),Land_cases);
end

PFM = ["SSP0", "SSP1", "SSP2", "SSG3"];                     %4  
OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0",...
    "NADLC1","NANLC1","NADLC2","NANLC2"];    
%8
SFC_ = ["LNDD", "LNDV", "OCEN","LAND","NONE"]; %labels parsed but not in QIS, RMS, MER
SFC = ["LAND","OCEN"];
REZ = ["RES1", "RES2", "RES3", "RES4", "RES5"];             %5
comments = 'A sample ACCP A11 assessment output file';
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
% QIS = NaN([65,length(GRP),length(TYP),length(PFM),length(OBI),length(SFC),length(REZ)]);
QIS = NaN([65,length(GRP),length(TYP),length(PFM),length(OBI),2,length(REZ)]); %Only two actual surfaces?
MER = QIS; RMS = QIS;
% 031,AOD_l_UV_column               ,   0.853,   0.000,     0.032
% tic

% Leave only highest version of each input file
% [~,flist] = dirlist_to_filelist(direc);
% for ff = length(flist):-1:1
%     blip = textscan(flist(ff),'%*s %*s %*s %*s %*s %*s V%f', 'delimiter','_'); blip = blip{1};
%     vers(ff) = blip;
% end

f = 1;
while f<length(direc)
    lr = fliplr(direc(f).name); [~,lr] = strtok(lr,'.');
    [rev,lr] = strtok(lr(2:end),'_'); stem = fliplr(lr);
    %     vs = find(startsWith(flist,stem)); % identify same stem with different versions, keep last one
    vs = find(startsWith({direc(:).name},stem));
    if length(vs)>1
        [blip,ij]= sort({direc(vs).name}); %highest version is last
        direc(end+1) = direc(vs(ij(end)));
        direc(vs) = [];
        %         [vv,vi] = max(vs);
        %         direc(f).name = direc(vi).name;
        %         vers(f) = vers(vi);
        %         vs(vs==f)=[]; % remove current indice from list
        %         direc(vs) = []; vers(vs) = [];
    else
        f = f+1;
    end
end

for f = length(direc):-1:1
    %     try
    infile = direc(f).name;
    [grp,rst] = strtok(infile,'_'); rst(1) = [];
    grp_ind = find(strcmpi(grp,GRP));
    
    [tip,rst] = strtok(rst,'_'); rst(1) = [];% Caution, see 2:end
    typ_ind = find(strcmpi(tip,TYP));
    if isempty(typ_ind)&&strcmpi(tip,'ICA')||strcmpi(tip,'DRS')
        tip = [tip,'all'];
        typ_ind = find(strcmpi(tip,TYP));
    end
%     if isempty(typ_ind)&&strcmpi(tip,'DRS6all')
%         typ_ind = 13;
%     end
    [plt,rst] = strtok(rst,'_');rst(1) = [];
    plt_ind = find(strcmpi(plt,PFM));
    if isempty(plt_ind)&&(strcmpi(plt,'SSP3')||strcmpi(plt,'GPM')||strcmpi(plt,'SSG4')||strcmpi(plt,'SSPG3')) % Catch SSG3 mislabeled as SSP3
        plt_ind = 4;
    end
    [ob,rst] = strtok(rst,'_');rst(1) = [];
    obs_ind = find(strcmpi(ob,OBI));
    [sfc,rst] = strtok(rst,'_');rst(1) = [];
    srfc_ind = find(strcmpi(sfc,SFC_));
    if isempty(srfc_ind)&&contains(sfc,'RES') %This "if" to catch missing surface tag where supplied RES shows up here instead.
        srfc_ind = 5;
        rs = sfc;
    else
        [rs,rst] = strtok(rst,'_'); if ~isempty(rst) rst(1) = []; end
    end
    %     SFC = ["LNDD", "LNDV", "OCEN","LAND","NONE"];
    if contains(sfc,SFC_([1,2,4]))||L_case(typ_ind)
        sfc = "LAND";
    elseif contains(sfc,SFC_(3))||O_case(typ_ind)
        sfc = "OCEN";
    end
    srfc_ind = find(strcmpi(sfc,SFC));
    % Re-assign srfc_ind based on typ_ind
    res_ind = find(strcmpi(rs,REZ)); if isempty(res_ind) res_ind = 1; end;% Assume RES1
    [vs,rst] = strtok(rst,'.');
    test_NLS = (grp_ind==3 )&& (typ_ind==12) && (obs_ind==1) && (srfc_ind==2) & (res_ind==1);
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
            
            bla1 = blah{1}; badQ = bla1>998.9 & bla1<999.1; bla1(badQ) = NaN;
%             if length(bla1)==75; bla1(46:47) = [];end  %Catch and correct malformed data files
            % Catch cases
            bla2 = blah{2};
            bad = bla2>998.999&bla2<999.0001;
            if any(badQ&~bad)
                bla2(bla2==0)=999;  bad = bla2>998.999&bla2<999.0001; % Set MER==0 to 999
                if any(badQ&~bad)
                    g_str = sprintf('%d ',find(badQ&~bad));
                    disp(['Valid MeanErr for invalid QI? GV:',g_str,'in ',direc(f).name]);
                end
            end
            bla2(bad|badQ) = NaN;
%             if length(bla2)==75; bla2(46:47) = [];end %Catch and correct malformed data files
            
            bla3 = blah{3};
            bad = bla3>998.999&bla3<999.0001;
            if any(badQ&~bad)
                bla3(bla3==0)=999;  bad = bla3>998.999&bla3<999.0001; %Set RMS==0 to 999
                if any(badQ&~bad)
                    g_str = sprintf('%d ',find(badQ&~bad));
                    disp(['Valid RMSE for invalid QI? GV:',g_str,'in ',direc(f).name]);
                end
            end
            bla3(bad|badQ) = NaN;
%             if length(bla3)==75; bla3(46:47) = [];end %Catch and correct malformed data files
% test_NLS = (grp_ind==3 )&& (typ_ind==12) && (obs_ind==1) && (srfc_ind==2) & (res_ind==1);
            if all(isNaN(bla1))&&all(isNaN(bla2))&&all(isNaN(bla3))
                disp([direc(f).name, ' is all NaN']);
            else % QI_5 = QIS(H,2,3,:,L,m,1);
                QIS(:,grp_ind,typ_ind,plt_ind,obs_ind,srfc_ind,res_ind) = bla1;
                test_NLS = (grp_ind==3 )&& (typ_ind==12) && (obs_ind==1) && (srfc_ind==1) & (res_ind==1);
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

% QIS = NaN([65,length(GRP),length(TYP),length(PFM),length(OBI),length(SFC),length(REZ)]);
% GRP = ["NLP", "NLB", "NLS", "NGE", "OUX"]; 
% PFM = ["SSP0", "SSP1", "SSP2", "SSG3"];                     %4  
% OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0","NADLC1","NANLC1","NADLC2","NANLC2"]; 
%Propagate SSP0 results into SSP1 and SSP2 for obs=ONDPC0

QIS(:,2,:,2,4,:,:) = QIS(:,2,:,1,4,:,:); QIS(:,2,:,3,4,:,:) = QIS(:,2,:,1,4,:,:); % NLB
QIS(:,5,:,2,4,:,:) = QIS(:,5,:,1,4,:,:); QIS(:,5,:,3,4,:,:) = QIS(:,5,:,1,4,:,:); % OUX
MER(:,2,:,2,4,:,:) = MER(:,2,:,1,4,:,:); MER(:,2,:,3,4,:,:) = MER(:,2,:,1,4,:,:); % NLB
MER(:,5,:,2,4,:,:) = MER(:,5,:,1,4,:,:); MER(:,5,:,3,4,:,:) = MER(:,5,:,1,4,:,:); % OUX
RMS(:,2,:,2,4,:,:) = RMS(:,2,:,1,4,:,:); RMS(:,2,:,3,4,:,:) = RMS(:,2,:,1,4,:,:); % NLB
RMS(:,5,:,2,4,:,:) = RMS(:,5,:,1,4,:,:); RMS(:,5,:,3,4,:,:) = RMS(:,5,:,1,4,:,:); % OUX


end

