function OQS = apply_OWCs(QIS,gv)
% OQS = apply_OWCs(QIS,gv)
% Accepts a 7D QIS matrix, a subset of gv, and resolution reso
% Returns OQS as 5D matrix with %OQS(obj,gv,obs,sfc,pltf)
% Applies Objective driven weights to the SIT-A 8a-8o case types to
% produce averaged GVs for NAD, NAN, and OND observation modes for Land and Ocean
% for four distinct Objective weights and four platforms

% NAD from average of NADLC0 and NADBC0
% NAN from NANLC0
% OND from ONDPC0
% Q-scores are averaged only for groups where GVs were provided for platforms
% Produces 16 files (4 Objectives, 4 platforms) with rows for all GV, Ocean and Land
% and columns for NAD, NAN, and OND

OCW = ACCP_Obj_Case_Weights;
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';

%QIS(gv,grp,orb/typ,pltf,obs,srfc,res)
% QIS = NaN([65,length(GRP),length(TYP),length(PFM),length(OBI),2,length(REZ)]);
%OQS(obj,gv,obs,sfc,pltf)
%% GV counter
H = length(GVnames);
%% group counter group = ["NLP", "NLB", "NLS", "NGE", "OUX"];
%% pltf counter pltf = ["SSP0", "SSP1", "SSP2", "SSG3"];
%% obs counter obs = ["NADLC0", "NADBC0", "NANLC0","ONDPC0"];

%% res counter
res = ["RES1", "RES2", "RES3", "RES4", "RES5"];
reso = 'RES1';
R = find(strcmpi(reso,res));
if ~isavar('obs')
    obs = ["NADLC0", "NADBC0", "NANLC0","ONDPC0"];
end
OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0",...
    "NADLC1","NANLC1","NADLC2","NANLC2"];

% The case have implications for land surface
% Mapping of TYP to surface type:
Ocean_cases= ["8a","8b","8c","8g","8h","8k","8l"];
Land_cases= ["8d","8e","8f","8i","8j","8m","8n","8o"];
ocen_case = [1:3 7:8 11:12];
land_case = [4:6 9:10 13:15];
case1 = 0; case2 = 15;
DRS = 0; ICA = 30;
DRS_ocen_cases = [ocen_case  case2+ocen_case];
DRS_land_cases = [land_case  case2+land_case];
ICA_ocen_cases = ICA+[ocen_case  case2+ocen_case];
ICA_land_cases = ICA+[land_case  case2+land_case];

GRP = ["NLP", "NLB", "NLS", "NGE", "OUX"];                  %5
%% They correspond to the following group/typ index combinations:
%% 1/13, 3/13, 4/13, 5/13, 2/3, 5/3, 3/1, 4/1
%%
%% NLP-DRSall is something like QIS(h, 1, 13, k, L, m, n)
%% would like to plot four pltf's as grouped bars, so
%% NLP-DRSall is QIS(h, 1, DRS_cases, :, L, m, n)
%% NLS-DRSall is QIS(h, 3, DRS_cases, :, L, m, n)
%% NGE-DRSall is QIS(h, 4, DRS_cases, :, L, m, n)
%% OUX-DRSall is QIS(h, 5, DRS_cases, :, L, m, n)
%% NLB-ICAall is QIS(h, 2, ICA_cases, :, L, m, n)

%% OUX-ICAall is QIS(h, 5,  3, :, L, m, n)
%% NLS-SPA    is QIS(h, 3,  1, :, L, m, n)
%% NGE-SPA    is QIS(h, 4,  1, :, L, m, n)
% QIS = NaN([73,length(group),length(typ),length(pltf),length(obs),length(srfc),length(res)]);
% tic
PFM = ["SSP0", "SSP1", "SSP2", "SSG3"];
%OQS(obj,gv,obs,sfc,pltf)
%OQS(obj,gv,[NAD,NAN,OND],sfc,pltf)
OQS = NaN(4,length(gv),3,2,length(PFM));
% xgv = [1:8,13:16,40:45]; % Exclude these GVs for NGE SPA and DRS
for H = gv
    m =1;
    DRS_cases = DRS_land_cases;
    ICA_cases = ICA_land_cases;
    R = find(strcmpi(reso,res));
    %RES4 for GV52-55, RES5 for GV50-51
    if H>=50&&H<=51
        % RES5
        R = 5;
    elseif H>=52 && H<= 55
        R = 4;
    end
    
    %QIS(gv,grp,orb/typ,pltf,obs,srfc,res)
    %OQS(obj,gv,obs,sfc,pltf)
%     DRS_cases = DRS_land_cases;
%     ICA_cases = ICA_land_cases;
    
    for OO = 1:4
        OC = OCW(:,OO);
        L = 1; % for NADLC0
        OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_1)) &&R~=1
            OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, 1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        % We want to take the mean and be left with a length of 4 (pltf)
        OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_2)) &&R~=1
            OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, 1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_3)) && (R~=1)
            OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_4 = nanmean(squeeze(QIS(H, 5,DRS_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_4)) &&R~=1
            OQ_4 = nanmean(squeeze(QIS(H,5,DRS_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_5 = nanmean(squeeze(QIS(H,2, ICA_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_5)) &&R~=1
            OQ_5 = nanmean(squeeze(QIS(H,2,ICA_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        new_OQ = [OQ_1; OQ_2; OQ_3; OQ_4; OQ_5]; % old, newQIS 8x4, so now 5x4?
        % Only use cases where all 4 platforms are reported
        ONAN = double(~isNaN(new_OQ));
        ONAN(isNaN(new_OQ)) = NaN; anyNaN = any(isNaN(ONAN)')'; ONAN(anyNaN,:) = NaN;
        meanOQ_NADLC0 = meannonan(new_OQ.*ONAN); % These are mean Qs for this GV and O5.
        %OQS(obj,gv,obs,sfc,pltf)
        
        L = 2; % for NADBC0
        OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_1)) &&R~=1
            OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, 1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        % We want to take the mean and be left with a length of 4 (pltf)
        OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_2)) &&R~=1
            OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, 1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_3)) && (R~=1)
            OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_4 = nanmean(squeeze(QIS(H, 5,DRS_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_4)) &&R~=1
            OQ_4 = nanmean(squeeze(QIS(H,5,DRS_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_5 = nanmean(squeeze(QIS(H,2, ICA_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_5)) &&R~=1
            OQ_5 = nanmean(squeeze(QIS(H,2,ICA_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        new_OQ = [OQ_1; OQ_2; OQ_3; OQ_4; OQ_5]; % old, newQIS 8x4, so now 5x4?
        % Only use cases where all 4 platforms are reported
        ONAN = double(~isNaN(new_OQ));
        ONAN(isNaN(new_OQ)) = NaN; anyNaN = any(isNaN(ONAN)')'; ONAN(anyNaN,:) = NaN;
        meanOQ_NADBC0 = meannonan(new_OQ.*ONAN); % These are mean Qs for this GV and O5.
        temp = nanmean([meanOQ_NADLC0; meanOQ_NADBC0]);
        %             temp(temp>1)=1;temp(temp<0)=0;
        OQS(OO,H,1,1,:) = temp;
        %OQS(obj,gv,obs,sfc,pltf
        
        L = 3; % for NANLC0
        OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        
        if all(isNaN(OQ_1)) &&R~=1
            OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, 1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        % We want to take the mean and be left with a length of 4 (pltf)
        OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_2)) &&R~=1
            OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, 1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_3)) && (R~=1)
            OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_4 = nanmean(squeeze(QIS(H, 5,DRS_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_4)) &&R~=1
            OQ_4 = nanmean(squeeze(QIS(H,5,DRS_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_5 = nanmean(squeeze(QIS(H,2, ICA_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_5)) &&R~=1
            OQ_5 = nanmean(squeeze(QIS(H,2,ICA_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        new_OQ = [OQ_1; OQ_2; OQ_3; OQ_4; OQ_5]; % old, newQIS 8x4, so now 5x4?
        % Only use cases where all 4 platforms are reported
        ONAN = double(~isNaN(new_OQ));
        ONAN(isNaN(new_OQ)) = NaN; anyNaN = any(isNaN(ONAN)')'; ONAN(anyNaN,:) = NaN;
        meanOQ = meannonan(new_OQ.*ONAN); % These are mean Qs for this GV and O5.
        %OQS(obj,gv,obs,sfc,pltf)
        %             meanOQ(meanOQ<0)=0; meanOQ(meanOQ>1)=1;
        OQS(OO,H,2,1,:) = meanOQ;
        
        L = 4; % for ONDPC0
        OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_1)) &&R~=1
            OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, 1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        % We want to take the mean and be left with a length of 4 (pltf)
        OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_2)) &&R~=1
            OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, 1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_3)) && (R~=1)
            OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_4 = nanmean(squeeze(QIS(H, 5,DRS_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_4)) &&R~=1
            OQ_4 = nanmean(squeeze(QIS(H,5,DRS_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        OQ_5 = nanmean(squeeze(QIS(H,2, ICA_cases,:,L,m,R)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        if all(isNaN(OQ_5)) &&R~=1
            OQ_5 = nanmean(squeeze(QIS(H,2,ICA_cases,:,L,m,1)).*([OC(land_case);OC(land_case)]*ones([1,4])))./mean([OC(land_case);OC(land_case)]);
        end
        new_OQ = [OQ_1; OQ_2; OQ_3; OQ_4; OQ_5]; % old, newQIS 8x4, so now 5x4?
        % Only use cases where all 4 platforms are reported
        ONAN = double(~isNaN(new_OQ));
        ONAN(isNaN(new_OQ)) = NaN; anyNaN = any(isNaN(ONAN)')'; ONAN(anyNaN,:) = NaN;
        meanOQ = meannonan(new_OQ.*ONAN); % These are mean Qs for this GV and O5.
        %             meanOQ(meanOQ<0)=0; meanOQ(meanOQ>1)=1;
        OQS(OO,H,3,1,:) = meanOQ;
        %OQS(obj,gv,obs,sfc,pltf
        
    end %of OWC loop
    
    %ocen cases
    m = 2;
    DRS_cases = DRS_ocen_cases;
    ICA_cases = ICA_ocen_cases;
    %QIS(gv,grp,orb/typ,pltf,obs,srfc,res)
    for OO = 1:4
        OC = OCW(:,OO);
        L = 1; % for NADLC0
        OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_1)) &&R~=1
            OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, 1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        % We want to take the mean and be left with a length of 4 (pltf)
        OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_2)) &&R~=1
            OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, 1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_3)) && (R~=1)
            OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_4 = nanmean(squeeze(QIS(H, 5,DRS_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_4)) &&R~=1
            OQ_4 = nanmean(squeeze(QIS(H,5,DRS_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_5 = nanmean(squeeze(QIS(H,2, ICA_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_5)) &&R~=1
            OQ_5 = nanmean(squeeze(QIS(H,2,ICA_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        new_OQ = [OQ_1; OQ_2; OQ_3; OQ_4; OQ_5]; % old, newQIS 8x4, so now 5x4?
        % Only use cases where all 4 platforms are reported
        ONAN = double(~isNaN(new_OQ));
        ONAN(isNaN(new_OQ)) = NaN; anyNaN = any(isNaN(ONAN)')'; ONAN(anyNaN,:) = NaN;
        meanOQ_NADLC0 = meannonan(new_OQ.*ONAN); % These are mean Qs for this GV and O5.
        %OQS(obj,gv,obs,sfc,pltf)
        
        L = 2; % for NADBC0
        OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_1)) &&R~=1
            OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, 1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        % We want to take the mean and be left with a length of 4 (pltf)
        OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_2)) &&R~=1
            OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, 1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_3)) && (R~=1)
            OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_4 = nanmean(squeeze(QIS(H, 5,DRS_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_4)) &&R~=1
            OQ_4 = nanmean(squeeze(QIS(H,5,DRS_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_5 = nanmean(squeeze(QIS(H,2, ICA_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_5)) &&R~=1
            OQ_5 = nanmean(squeeze(QIS(H,2,ICA_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        new_OQ = [OQ_1; OQ_2; OQ_3; OQ_4; OQ_5]; % old, newQIS 8x4, so now 5x4?
        % Only use cases where all 4 platforms are reported
        ONAN = double(~isNaN(new_OQ));
        ONAN(isNaN(new_OQ)) = NaN; anyNaN = any(isNaN(ONAN)')'; ONAN(anyNaN,:) = NaN;
        meanOQ_NADBC0 = meannonan(new_OQ.*ONAN); % These are mean Qs for this GV and O5.
        temp = nanmean([meanOQ_NADLC0; meanOQ_NADBC0]);
        %             temp(temp>1) = 1; temp(temp<0)=0;
        OQS(OO,H,1,2,:) = temp;
        %OQS(obj,gv,obs,sfc,pltf
        
        L = 3; % for NANLC0
        OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_1)) &&R~=1
            OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, 1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        % We want to take the mean and be left with a length of 4 (pltf)
        OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_2)) &&R~=1
            OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, 1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_3)) && (R~=1)
            OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_4 = nanmean(squeeze(QIS(H, 5,DRS_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_4)) &&R~=1
            OQ_4 = nanmean(squeeze(QIS(H,5,DRS_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_5 = nanmean(squeeze(QIS(H,2, ICA_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_5)) &&R~=1
            OQ_5 = nanmean(squeeze(QIS(H,2,ICA_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        new_OQ = [OQ_1; OQ_2; OQ_3; OQ_4; OQ_5]; % old, newQIS 8x4, so now 5x4?
        % Only use cases where all 4 platforms are reported
        ONAN = double(~isNaN(new_OQ));
        ONAN(isNaN(new_OQ)) = NaN; anyNaN = any(isNaN(ONAN)')'; ONAN(anyNaN,:) = NaN;
        meanOQ = meannonan(new_OQ.*ONAN); % These are mean Qs for this GV and O5.
        %OQS(obj,gv,obs,sfc,pltf)
        %             meanOQ(meanOQ<0)=0; meanOQ(meanOQ>1)=1;
        OQS(OO,H,2,2,:) = meanOQ;
        
        L = 4; % for ONDPC0
        OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_1)) &&R~=1
            OQ_1 = nanmean(squeeze(QIS(H, 1, DRS_cases,  :,L, m, 1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        % We want to take the mean and be left with a length of 4 (pltf)
        OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_2)) &&R~=1
            OQ_2 = nanmean(squeeze(QIS(H, 3,DRS_cases,  : ,L, m, 1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_3)) && (R~=1)
            OQ_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_4 = nanmean(squeeze(QIS(H, 5,DRS_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_4)) &&R~=1
            OQ_4 = nanmean(squeeze(QIS(H,5,DRS_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        OQ_5 = nanmean(squeeze(QIS(H,2, ICA_cases,:,L,m,R)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        if all(isNaN(OQ_5)) &&R~=1
            OQ_5 = nanmean(squeeze(QIS(H,2,ICA_cases,:,L,m,1)).*([OC(ocen_case);OC(ocen_case)]*ones([1,4])))./mean([OC(ocen_case);OC(ocen_case)]);
        end
        new_OQ = [OQ_1; OQ_2; OQ_3; OQ_4; OQ_5]; % old, newQIS 8x4, so now 5x4?
        % Only use cases where all 4 platforms are reported
        ONAN = double(~isNaN(new_OQ));
        ONAN(isNaN(new_OQ)) = NaN; anyNaN = any(isNaN(ONAN)')'; ONAN(anyNaN,:) = NaN;
        meanOQ = meannonan(new_OQ.*ONAN); % These are mean Qs for this GV and O5.
        %OQS(obj,gv,obs,sfc,pltf)
        %             meanOQ(meanOQ<0)=0; meanO(meanOQ>1)=1;
        OQS(OO,H,3,2,:) = meanOQ;
        
    end %of OWC loop
    
end
OQS(OQS<0)=0; OQS(OQS>1)=1;

% apply zero min, unity max to OQS


%OQS(obj,gv,obs,sfc,pltf)
srfc = [" Land", " Ocean"];
%OQS(obj,gv,obs,sfc,pltf)
for OO = 1:4
    for pp = 1:length(PFM)
        NN_ = ''; NN = 1;
        OQS_file = [getnamedpath('ACCP_set'),'..',filesep,'OQS_weighted_for_O',num2str(OO+4),'_',PFM{pp},NN_,'.csv'];
        while isafile(OQS_file)
            NN = NN + 1; NN_ = sprintf('.v%d',NN);
            OQS_file = [getnamedpath('ACCP_set'),'..',filesep,'OQS_weighted_for_O',num2str(OO+4),'_',PFM{pp},NN_,'.csv'];
        end
        fid = fopen(OQS_file,'w+');
        pause(0.5);
        fprintf(fid,'%s,\t%s,\t%s,\t%s \n','GV_name', 'Nadir Daytime', 'Nadir Nighttime', 'Off nadir Daytime');
        for H = 1:length(gv)
            for ss = length(srfc):-1:1
                fprintf(fid,'%s, %2.3f, %2.3f, %2.3f \n', string([GVnames{H},srfc{ss}]), OQS(OO,H,1,ss,pp), OQS(OO,H,2,ss,pp), OQS(OO,H,3,ss,pp));
            end
        end
        fclose(fid);
        pause(0.5);
    end
end

% toc

out.OQS_struct = '%OQS(obj,gv,obs,sfc,pltf)';
out.obj = [5:8]; out.gv = [1:65]; out.obs = ["NAD=mean(NADL,NADB)","NAN","OND"]; out.sfc = ["Land","Ocean"]; out.plfm = ["SSP0","SSP1","SSP2","SSG3"];
out.OQS = OQS;
save([getnamedpath('ACCP_set'),'SITA_OQS_',datestr(now,'yyyymmdd_HHMM'),'.mat'],'-struct','out');


return
