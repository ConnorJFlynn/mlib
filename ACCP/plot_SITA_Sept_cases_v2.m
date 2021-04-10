function plot_SITA_Sept_cases_v2(QIS,gv,sfc,obs,reso,pptname)
% plot_SITA_Sept_cases_v2(QIS,MER,RMS,gv,sfc,obs,reso,pptname)
% Attempt to incorporate both DRS and ICA casestudy breakouts


ACCP_pngs = getnamedpath('ACCP_pngs');
% *.png files named on line 125 with pattern below where n,SRFC, and vv vary
png_out = ['GV[n]_[SRFC].[GRP].Qall_8a-o.png']; %ACCP_3x1.cases

if ~isavar('pptname')
    d_now = now; n_str = [];
    pptname = ['ACCP_Q8a-o.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';

%QIS(gv,grp,typ,pltf,obs,srfc,res)

%typ = SPA RDA ICA(all,6a-i) DRS(all 6a-i)
%typ = (1) (2),(3,4-12)     (13,14-22)
% Focus only on groups with DRS (NLP, NLS, NGE, OUX)
% group = ["NLP", "NLB", "NLS", "NGE", "OUX", "CND"];
%            1             3      4      5
%% GV counter
H = length(GVnames);
%% group counter group = ["NLP", "NLB", "NLS", "NGE", "OUX", "CND"];
% i=grp;
%% typ counter
% j=typ;
%% pltf counter pltf = ["SSP0", "SSP1", "SSP2", "SSG3"];
% k=pltf;
%% obs counter obs = ["NAD", "NAN", "OND"];
% L=obs;
% %% srfc counter
srfc = ["LAND", "OCEN"];
if ~isavar('sfc') sfc = 'LNDD';end
m=find(strcmpi(sfc,srfc));
%% res counter
res = ["RES1", "RES2", "RES3", "RES4", "RES5"];
if ~isavar('reso') reso = 'RES1'; end
n = find(strcmpi(reso,res));
if ~isavar('obs')
    obs = ["NADLC0", "NADBC0", "NANLC0","ONDPC0"];
end
OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0",...
    "NADLC1","NANLC1","NADLC2","NANLC2"]; 
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
if contains(sfc,'LAND') % m == 1
    DRS_cases = DRS_land_cases; DRS_case1 = land_case; DRS_case2 = land_case+case2;
    ICA_cases = ICA_land_cases; ICA_case1 = ICA+land_case; ICA_case2 = ICA+land_case+case2;
elseif contains(sfc,'OCEN') % m == 2
    DRS_cases = DRS_ocen_cases; DRS_case1 = ocen_case; DRS_case2 = ocen_case+case2;
    ICA_cases = ICA_ocen_cases; ICA_case1 = ICA+ocen_case; ICA_case2 = ICA+ocen_case+case2;
end


group = ["NLP", "NLB", "NLS", "NGE", "OUX", "CND"];
%% there are eight combinations of group and typ that have priority - they
%% can be labeled:
%% NLP-DRSall,NLS-DRSall,NGE-DRSall,OUX-DRSall,NLB-ICAall,OUX-ICAall,NLS-SPA,NGE-SPA
%% They correspond to the following group/typ index combinations:
%% 1/13, 3/13, 4/13, 5/13, 2/3, 5/3, 3/1, 4/1
%%
GRP = ["NLP", "NLB", "NLS", "NGE", "OUX"];  
%% NLP-DRSall is something like QIS(h, 1, 13, k, L, m, n)
%% would like to plot four pltf's as grouped bars, so
%% NLP-DRSx is QIS(h, 1, 13:22, :, L, m, n)
%% NLS-DRSx is QIS(h, 3, 13:22, :, L, m, n)
%% NGE-DRSx is QIS(h, 4, 13:22, :, L, m, n)
%% OUX-DRSx is QIS(h, 5, 13:22, :, L, m, n)

% QIS = NaN([73,length(group),length(typ),length(pltf),length(obs),length(srfc),length(res)]);
% QIS(gv,grp,typ,pltf,obs,srfc,res)
% tic
for H = gv

    cf =figure(H); sb = 1;
%         set(cf,'Position',[67 50 1443 741],'Visible',true);
    set(cf,'Position',[67 50 1443 741],'Visible',false);
    clear lg tla tlb tlc

    n = find(strcmpi(reso,res));% this needs to be inside the loop over H (gv)
    % to recover from the if statement below for H>53
    if H>=50&&H<=51
        % RES5
        n = 5;
    elseif H>=52 && H<= 55
        n = 4;
    end
% QIS(gv,grp,typ,pltf,obs,srfc,res)
% group = ["NLP", "NLB", "NLS", "NGE", "OUX", "CND"];    
    

for LO=1:length(obs) % find OBI indices of supplied obs
        L = find(contains(OBI,obs(LO)));
        %         [num2str(H),GRP(3),TYP(DRS_cases),"PFM",OBI(L),sfc,n]
        % NLP_(grp=1,type 13:22))
        QI_0 = QIS(H, 1, DRS_case1, :, L, m, n); QI_0_b = QIS(H, 1, DRS_case2, :, L, m, n);
        if ~all(all(isNaN(squeeze(QI_0_b)))) QI_0 = (QI_0 + QI_0_b)./2; end
        if all(all(isNaN(QI_0))) &&n~=1
            QI_0 = QIS(H, 1, DRS_case1, :, L, m, 1); QI_0_b = QIS(H, 1, DRS_case2, :, L, m, 1);
            if ~all(all(isNaN(squeeze(QI_0_b)))) QI_0 = (QI_0 + QI_0_b)./2; end
        end
        
        % NLS_DRS(grp=3,type 13:22))
        QI_1 = QIS(H, 3, DRS_case1, :, L, m, n); QI_1_b =QIS(H, 3, DRS_case2, :, L, m, n); 
        if ~all(all(isNaN(squeeze(QI_1_b)))) QI_1 = (QI_1 + QI_1_b)./2; end
        if all(all(isNaN(QI_1))) &&n~=1
            QI_1 = QIS(H, 3, DRS_case1, :, L, m, 1); QI_1_b = QIS(H, 3, DRS_case2, :, L, m, 1);
            if ~all(all(isNaN(squeeze(QI_0_b)))) QI_1 = (QI_1 + QI_1_b)./2; end
        end
        
        % NGE_DRS(grp=4,type 13:22))
        QI_2 = QIS(H, 4, DRS_case1, :, L, m, n); QI_2_b = QIS(H, 4, DRS_case2, :, L, m, n);
        if ~all(all(isNaN(squeeze(QI_2_b)))) QI_2 = (QI_2 + QI_2_b)./2; end
        if all(all(isNaN(QI_2))) &&n~=1
            QI_2 = QIS(H, 4, DRS_case1, :, L, m, 1); QI_2_b = QIS(H, 4, DRS_case2, :, L, m, 1);
            if ~all(all(isNaN(squeeze(QI_2_b)))) QI_2 = (QI_2 + QI_2_b)./2; end
        end
        
        % OUX_DRS (grp=5, type(3:12)
        QI_3 = QIS(H, 5, DRS_case1, :, L, m, n); QI_3_b = QIS(H, 5, DRS_case2, :, L, m, n); 
        if ~all(all(isNaN(squeeze(QI_3_b)))) QI_3 = (QI_3 + QI_3_b)./2; end
        if all(all(isNaN(QI_3))) &&n~=1
            QI_3 = QIS(H, 5, DRS_case1, :, L, m, 1); QI_3_b = QIS(H, 5, DRS_case2, :, L, m, 1);
            if ~all(all(isNaN(squeeze(QI_3_b)))) QI_3 = (QI_3 + QI_3_b)./2; end
        end
        
        % NLB_ICA (grp=2, type(3:12)
        QI_4 = QIS(H, 2, ICA_case1, :, L, m, n); QI_4_b = QIS(H, 2, ICA_case2, :, L, m, n); 
        if ~all(all(isNaN(squeeze(QI_4_b)))) QI_4 = (QI_4 + QI_4_b)./2; end
        if all(all(isNaN(QI_4))) &&n~=1
            QI_4 = QIS(H, 2, DRS_case1, :, L, m, 1); QI_4_b = QIS(H, 2, DRS_case2, :, L, m, 1);
            if ~all(all(isNaN(squeeze(QI_2_b)))) QI_4 = (QI_4 + QI_4_b)./2; end
        end
                   
%         new_QIS = [squeeze(QIS(H, 1, 13:22, :, L, m, n));squeeze(QIS(H, 3, 13:22, :, L, m, n))];
        
%         new_QIS = [squeeze(QI_0);squeeze(QI_1); squeeze(QI_2); squeeze(QI_3); squeeze(QI_4)];        
        new_QIS = [nanmean(squeeze(QI_0));squeeze(QI_0); nanmean(squeeze(QI_1)); squeeze(QI_1); ...
            nanmean(squeeze(QI_2)); squeeze(QI_2); nanmean(squeeze(QI_3));squeeze(QI_3); nanmean(squeeze(QI_4));squeeze(QI_4)];  
        ax(1) = subplot(length(obs),1,sb); sb = sb +1;
        % bar(squeeze(QIS(H,1:end-1,[1 3:end],k,l,1,1)),'BarWidth',0.99)
        bb = bar(new_QIS,'barwidth',1);
        if ~exist('lg','var')
            lg=legend('SSP0', 'SSP1', 'SSP2', 'SSG3');
            set(lg,'Position', [0.0386    0.8785    0.0602    0.0938]);
        end
        set(ax,'XTick',[1:length(new_QIS)]);
        if contains(sfc,'LAND')
%             Land_cases= ["8d","8e","8f","8i","8j","8m","8n","8o"];
            set(ax,'XTickLabel',{...
                [group{1},' DRS all'],'8d','8e','8f','8i','8j','8m','8n','8o',...
                [group{3},' DRS all'],'8d','8e','8f','8i','8j','8m','8n','8o',...
                [group{4},' DRS all'],'8d','8e','8f','8i','8j','8m','8n','8o',...
                [group{5},' DRS all'],'8d','8e','8f','8i','8j','8m','8n','8o',...
                [group{2},' ICA all'],'8d','8e','8f','8i','8j','8m','8n','8o'})
        elseif contains(sfc,'OCEN')
%             Ocean_cases= ["8a","8b","8c","8g","8h","8k","8l"];
            set(ax,'XTickLabel',{...
                [group{1},' DRS all'],'8a','8b','8c','8g','8h','8k','8l',...
                [group{3},' DRS all'],'8a','8b','8c','8g','8h','8k','8l',...
                [group{4},' DRS all'],'8a','8b','8c','8g','8h','8k','8l',...
                [group{5},' DRS all'],'8a','8b','8c','8g','8h','8k','8l',...
                [group{2},' ICA all'],'8a','8b','8c','8g','8h','8k','8l'})
        end
        set(gca,'XTickLabelRot',30)
        set(gca,'FontSize',8);
        ylim([0,1]);
        yl = ylabel(strjoin([OBI(L)]));
        set(yl,'rotation',0); set(yl,'position',[-1.9093 0.4434]); set(yl,'FontSize',12);
        %         if ~exist('tla','var')
        %             tla=title('QI Score'); set(tla,'FontSize',12);
        %         end
        
    end % of L
    
    mt = mtit(['GV[',num2str(H),']']);
    set(mt.th,'string',{['GV[',num2str(H),'] (',strrep(GVnames{H},'_',' '),') ',srfc{m},' Case breakout'];'QI Scores'})
    set(mt.th,'fontsize',12,'position',[0.5000    1.01500]);
    set(cf,'Visible',false);
    nn = 1; n_str = ['_',num2str(nn)];
    png_out = ['GV[',num2str(H),']_Q8a-o.',srfc{m},n_str,'.png'];
    while isafile([ACCP_pngs,png_out])
        nn = nn+1; n_str = ['_',num2str(nn)];
        png_out = ['GV[',num2str(H),']_Q8a-o.',srfc{m},n_str,'.png']; 
    end
    saveas(cf,[ACCP_pngs,png_out]); 
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]); 
    close(cf);
        
    ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
    
    % pause(2)
end
% toc

return
