function [Qall,Qgrp_all] = compute_Qall(QIS)
% [Qall,Qgrp_all] = compute_Qall(QIS)
% Qall collapses grp, case, and res so become 4-D
% Qgrp_all retains the grp dimension so becomes 5-D
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';
H = length(GVnames);
Qall = NaN(H,4,8,2); % Qall(gv,plt,obi,sfc)

%% group counter group = ["NLP", "NLB", "NLS", "NGE", "OUX"];
% i=grp;
%% typ counter
% j=typ;
%% pltf counter pltf = ["SSP0", "SSP1", "SSP2", "SSG3"];
% k=pltf;
%% obs counter obs = ["NADLC0", "NADBC0", "NANLC0","ONDPC0"];
% L=obs;
% %% srfc counter
for m = 2:-1:1
    srfc = ["LAND", "OCEN"];
    sfc = srfc(m);
    %% res counter
    res = ["RES1", "RES2", "RES3", "RES4", "RES5"];
    if ~isavar('reso') reso = 'RES1'; end
    n = find(strcmpi(reso,res));
        OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0",...
        "NADLC1","NANLC1","NADLC2","NANLC2"];
    if ~isavar('obs')
        obs = OBI;
    end

    
    % The case have implications for land surface
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
        "SPA", "RDA"];
    %62
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
    if contains(sfc,'LAND') %
        m = 1;
        DRS_cases = DRS_land_cases;
        ICA_cases = ICA_land_cases;
    elseif contains(sfc,'OCEN') %
        m = 2;
        DRS_cases = DRS_ocen_cases;
        ICA_cases = ICA_ocen_cases;
    end
    
    
    % Not including SPA or RDA in averaged, only in case.
    % So QMR includes DRS and ICA "all" which we compute ourselves from the
    % cases, but instead of "all" do we do "Land" and "Ocen"?  Yes, I think so.
    
    %% there are eight combinations of group and typ that have priority - they
    %% can be labeled:
    %% NLP-DRS,NLS-DRS,NGE-DRS,OUX-DRS,NLB-ICA,OUX-DRS
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
    
%     xgv = [1:8,13:16,40:45]; % Exclude these GVs for NGE SPA and DRS
%     xgv = [];
    for H = length(GVnames):-1:1
        
        %     disp(['GV: ',num2str(gv)])
        %     cf =figure(H); sb = 1;
        % %             set(cf,'Position',[67 50 1443 741],'Visible',true);
        %     set(cf,'Position',[67 50 1443 741],'Visible',false); % Comment out to see plots, but slower
        %     clear lg tla tlb tlc
        
        n = find(strcmpi(reso,res));
        %RES4 for GV52-55, RES5 for GV50-51
        if H>=50&&H<=51
            % RES5
            n = 5;
        elseif H>=52 && H<= 55
            n = 4;
        end
        % typ = ["SPA", "RDA",...
        %     "ICAall", "ICA6a", "ICA6b", "ICA6c", "ICA6d", "ICA6e",...
        %     "ICA6f","ICA6g", "ICA6h", "ICA6i",...
        %     "DRSall", "DRS6a", "DRS6b", "DRS6c", "DRS6d", "DRS6e",...
        %     "DRS6f","DRS6g", "DRS6h", "DRS6i"];
        % group counter group = ["NLP", "NLB", "NLS", "NGE", "OUX"];
        
        %     QIS = NaN([65,length(GRP),length(TYP),length(PFM),length(OBI),2,length(REZ)]); %Only two actual surfaces?
        %     adjs = mean_adj(H,:);
        %     NADadj = (adjs(1:4)+adjs(5:8))./2;  NANadj = adjs(9:12); ONDadj= adjs(13:16);
        %     adj = [NADadj(pp),NANadj(pp), ONDadj(pp)];
        
        clear max_yl max_yl2

        for L=length(OBI):-1:1 % find OBI indices of supplied obs
%             L = find(contains(OBI,obs(LO)));
            %         [num2str(H),GRP(1),TYP(DRS_cases),"PFM",OBI(L),sfc,n]
            QI_1 = nanmean(squeeze(QIS(H, 1, DRS_cases, :, L, m, n))); %% NLP-DRSall is QIS(h, 1, 13, :, L, m, n)
            if all(isNaN(QI_1)) &&n~=1
                QI_1 = nanmean(squeeze(QIS(H,1,DRS_cases,:,L,m,1)));
            end
            % This out-of-sequence ordering was inherited from plotting
            % code that pushed NLB grp 2 toward the end as the only ICA analysis
            QI_5 = nanmean(squeeze(QIS(H, 2, ICA_cases, :, L, m, n))); %% NLB-ICAall is QIS(h, 2,  3, :, L, m, n)
            if all(isNaN(QI_5)) &&n~=1
                QI_5 = nanmean(squeeze(QIS(H,2,ICA_cases,:,L,m,1))); % GV51,2,3
                % QIS = NaN([73,length(group),length(typ),length(pltf),length(obs),length(srfc),length(res)]);
            end
            % We want to take the mean and be left with a length of 4 (pltf)
            QI_2 = nanmean(squeeze(QIS(H, 3, DRS_cases, :, L, m, n))); %% NLS-DRSall is QIS(h, 3, 13, :, L, m, n)
            if all(isNaN(QI_2)) &&n~=1
                QI_2 = nanmean(squeeze(QIS(H,3,DRS_cases,:,L,m,1)));
            end
            QI_3 = nanmean(squeeze(QIS(H, 4, DRS_cases, :, L, m, n))); %% NGE-DRSall is QIS(h, 4, 13, :, L, m, n)
            if all(isNaN(QI_3)) && (n~=1)
                QI_3 = nanmean(squeeze(QIS(H,4,DRS_cases,:,L,m,1)));
            end
%             if ~isempty(intersect(H,xgv))&&L==2
%                 QI_3= QI_3.*NaN;
%             end
            QI_4 = nanmean(squeeze(QIS(H, 5, DRS_cases, :, L, m, n))); %% OUX-DRSall is QIS(h, 5, 13, :, L, m, n)
            if all(isNaN(QI_4)) &&n~=1
                QI_4 = nanmean(squeeze(QIS(H,5,DRS_cases,:,L,m,1)));
            end

            %         newQIS = squeeze([QIS(H, 1, 13, :, L, m, n) QIS(H, 3, 13, :, L, m, n) ...
            %             QIS(H, 4, 13, :, L, m, n) QIS(H, 5, 13, :, L, m, n) ...
            %             QIS(H, 2,  3, :, L, m, n) QIS(H, 5,  3, :, L, m, n) ...
            %             QIS(H, 3,  1, :, L, m, n) QIS(H, 4,  1, :, L, m, n)]);
            newQIS = [QI_1; QI_5; QI_2; QI_3; QI_4]; % old, newQIS 8x4, so now 5x4?
            % Only use cases where all 4 platforms are reported
            QNAN = double(~isNaN(newQIS));
            QNAN(isNaN(newQIS)) = NaN;anyNaN = any(isNaN(QNAN)')';
            QNAN(anyNaN,:) = NaN;
            %         ws = [W_NLP_DRS(H,:);W_NLS_DRS(H,:);W_NGE_DRS(H,:);W_OUX_DRS(H,:);...
            %             W_NLB_ICA(H,:);W_OUX_ICA(H,:);W_NLS_SPA(H,:);W_NGE_SPA(H,:)];
            %         ws = ws.*QNAN;
            meanQ = meannonan(newQIS.*QNAN);
            Qall(H,:,L,m) = meanQ;
            Qgrp_all(H,:,:,L,m) = newQIS;
        end

    end
end
OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0",...
    "NADLC1","NANLC1","NADLC2","NANLC2"];


return
