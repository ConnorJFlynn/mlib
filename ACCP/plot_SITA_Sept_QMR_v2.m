function plot_SITA_Sept_QMR_v2(QIS,MER,RMS,gv,sfc,obs,reso,pptname)
% plot_SITA_Sept_QMR_v2(QIS,MER,RMS,gv,sfc,reso,pptname)
% Accepts a subset of gv, a single sfc, and a single reso
% sfc LAND selects files with LAND tag and with cases d-f i-j m-o
% sfc OCEN selects files with OCEN and cases a-c, g-h, k-l
% Results for cases "1" and "2" are averaged together

% Produces one 3xN subplot of bar plots for QIS, MER, and RMS on horiz, Obs on vert
% v2: Modified to incorporate conditions on RES
%     RES4 for GV52-55, RES5 for GV50-51, unless missing then RES1 

ACCP_pngs = getnamedpath('ACCP_pngs');
% *.png files named with the pattern below where n,SRFC, and vv vary
png_out = ['GV[n]_[SRFC].3xN.QMR.png']; %ACCP_3x3.QMR.v5
if ~isavar('pptname')
    dnow = now; n_str = [];
    pptname = ['ACCP_QMR_3xN.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';

%QIS(gv,grp,orb/typ,pltf,obs,srfc,res)

%% GV counter
H = length(GVnames);
%% group counter group = ["NLP", "NLB", "NLS", "NGE", "OUX"];
% i=grp;
%% typ counter
% j=typ;
%% pltf counter pltf = ["SSP0", "SSP1", "SSP2", "SSG3"];
% k=pltf;
%% obs counter obs = ["NADLC0", "NADBC0", "NANLC0","ONDPC0"];
% L=obs;
% %% srfc counter
srfc = ["LAND", "OCEN"];
if ~isavar('sfc') sfc = 'LAND';end
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
    DRS_cases = DRS_land_cases;
    ICA_cases = ICA_land_cases;
elseif contains(sfc,'OCEN') % m == 2
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

xgv = [1:8,13:16,40:45]; % Exclude these GVs for NGE SPA and DRS
xgv = [];
for H = gv
    %     disp(['GV: ',num2str(gv)])
    cf =figure(H); sb = 1;
%             set(cf,'Position',[67 50 1443 741],'Visible',true);
    set(cf,'Position',[67 50 1443 741],'Visible',false); % Comment out to see plots, but slower
    clear lg tla tlb tlc
    
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
    clear max_yl max_yl2
    for LO=1:length(obs) % find OBI indices of supplied obs
        L = find(contains(OBI,obs(LO)));
%         [num2str(H),GRP(1),TYP(DRS_cases),"PFM",OBI(L),sfc,n]
        QI_1 = nanmean(squeeze(QIS(H, 1, DRS_cases, :, L, m, n))); %% NLP-DRSall is QIS(h, 1, 13, :, L, m, n)
        if all(isNaN(QI_1)) &&n~=1
            QI_1 = nanmean(squeeze(QIS(H,1,DRS_cases,:,L,m,1)));
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
        if ~isempty(intersect(H,xgv))&&L==2
            QI_3= QI_3.*NaN;
        end
        QI_4 = nanmean(squeeze(QIS(H, 5, DRS_cases, :, L, m, n))); %% OUX-DRSall is QIS(h, 5, 13, :, L, m, n)
        if all(isNaN(QI_4)) &&n~=1
            QI_4 = nanmean(squeeze(QIS(H,5,DRS_cases,:,L,m,1)));
        end
        QI_5 = nanmean(squeeze(QIS(H, 2, ICA_cases, :, L, m, n))); %% NLB-ICAall is QIS(h, 2,  3, :, L, m, n)
        if all(isNaN(QI_5)) &&n~=1
            QI_5 = nanmean(squeeze(QIS(H,2,ICA_cases,:,L,m,1))); % GV51,2,3
            % QIS = NaN([73,length(group),length(typ),length(pltf),length(obs),length(srfc),length(res)]);
        end
        %         newQIS = squeeze([QIS(H, 1, 13, :, L, m, n) QIS(H, 3, 13, :, L, m, n) ...
        %             QIS(H, 4, 13, :, L, m, n) QIS(H, 5, 13, :, L, m, n) ...
        %             QIS(H, 2,  3, :, L, m, n) QIS(H, 5,  3, :, L, m, n) ...
        %             QIS(H, 3,  1, :, L, m, n) QIS(H, 4,  1, :, L, m, n)]);
        newQIS = [QI_1; QI_2; QI_3; QI_4; QI_5]; % old, newQIS 8x4, so now 5x4?
        % Only use cases where all 4 platforms are reported
        QNAN = double(~isNaN(newQIS));
        QNAN(isNaN(newQIS)) = NaN;anyNaN = any(isNaN(QNAN)')';
        QNAN(anyNaN,:) = NaN;
%         ws = [W_NLP_DRS(H,:);W_NLS_DRS(H,:);W_NGE_DRS(H,:);W_OUX_DRS(H,:);...
%             W_NLB_ICA(H,:);W_OUX_ICA(H,:);W_NLS_SPA(H,:);W_NGE_SPA(H,:)];
%         ws = ws.*QNAN;
        meanQ = meannonan(newQIS.*QNAN);
%         weighted_Q = meannonan(newQIS .* ws)./meannonan(ws);
        % For QIs in each column (pltf),
        new_QIS = [newQIS;meanQ];
        subplot(length(obs),3,sb); sb = sb+1;
        % bar(squeeze(QIS(H,1:end-1,[1 3:end],k,l,1,1)),'BarWidth',0.99)
        bar(new_QIS,'BarWidth',0.99)
        %         t=title(strjoin(['QI Score   ',obs(l),srfc(m)]));
        
        if ~exist('lg','var')
            lg=legend('SSP0', 'SSP1', 'SSP2', 'SSG3');
            set(lg,'Position', [0.0386    0.8785    0.0602    0.0938]);
        end
        set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
            'NLB-ICA','mean'})
        set(gca,'XTickLabelRot',30)
        set(gca,'FontSize',8);
        ylim([0,1]);
        yl = ylabel(strjoin([OBI(L)]));
        set(yl,'rotation',0); set(yl,'position',[-1.9093 0.4434]); set(yl,'FontSize',12);
        if ~exist('tla','var')
            tla=title('QI Score'); set(tla,'FontSize',12);
        end
        ME_1 = nanmean(squeeze(MER(H, 1, DRS_cases, :, L, m, n)));
        if all(isNaN(ME_1)) &&n~=1
            ME_1 = nanmean(squeeze(MER(H, 1, DRS_cases, :, L, m, 1)));
        end
        ME_2 = nanmean(squeeze(MER(H, 3, DRS_cases, :, L, m, n)));
        if all(isNaN(ME_2)) &&n~=1
            ME_2 = nanmean(squeeze(MER(H, 3, DRS_cases, :, L, m, 1)));
        end
        ME_3 = nanmean(squeeze(MER(H, 4, DRS_cases, :, L, m, n)));
        if all(isNaN(ME_3)) &&n~=1
            ME_3 = nanmean(squeeze(MER(H, 4, DRS_cases, :, L, m, 1)));
        end
        ME_4 = nanmean(squeeze(MER(H, 5, DRS_cases, :, L, m, n)));
        if all(isNaN(ME_4)) &&n~=1
            ME_4 =nanmean(squeeze(MER(H, 5, DRS_cases, :, L, m, 1)));
        end
        ME_5 = nanmean(squeeze(MER(H, 2, ICA_cases, :, L, m, n)));
        if all(isNaN(ME_5)) &&n~=1
            ME_5 =  nanmean(squeeze(MER(H, 2, ICA_cases, :, L, m, 1)));
        end

        new_MER = squeeze([ME_1; ME_2; ME_3; ME_4; ME_5]);
        ss(2+3*(L-1)) = subplot(length(obs),3,sb); sb = sb+1;
        
        %bar(squeeze(MER(H,1:end-1,[1 3:end],k+1,l,1,1)))
        bar(new_MER,'BarWidth',0.99);
        set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
            'NLB-ICA' })
        set(gca,'XTickLabelRot',30); set(gca,'FontSize',8);
        if ~exist('tlb','var')
            tlb=title('Mean error'); set(tlb,'FontSize',12);
        end
        RM_1 = nanmean(squeeze(RMS(H, 1, DRS_cases, :, L, m, n)));
        if all(isNaN(RM_1)) &&n~=1
            RM_1 = nanmean(squeeze(RMS(H, 1, DRS_cases, :, L, m, 1)));
        end
        RM_2 = nanmean(squeeze(RMS(H, 3, DRS_cases, :, L, m, n)));
        if all(isNaN(RM_2)) &&n~=1
            RM_2 = nanmean(squeeze(RMS(H, 3, DRS_cases, :, L, m, 1)));
        end
        RM_3 = nanmean(squeeze(RMS(H, 4, DRS_cases, :, L, m, n)));
        if all(isNaN(RM_3)) &&n~=1
            RM_3 =nanmean(squeeze(RMS(H, 4, DRS_cases, :, L, m, 1)));
        end
        RM_4 = nanmean(squeeze(RMS(H, 5, DRS_cases, :, L, m, n)));
        if all(isNaN(RM_4)) &&n~=1
            RM_4 = nanmean(squeeze(RMS(H, 5, DRS_cases, :, L, m, 1)));
        end
        RM_5 = nanmean(squeeze(RMS(H, 2, ICA_cases, :, L, m, n)));
        if all(isNaN(RM_5)) &&n~=1
            RM_5 = nanmean(squeeze(RMS(H, 2, ICA_cases, :, L, m, 1)));
        end

        new_RMS = squeeze([RM_1; RM_2; RM_3; RM_4; RM_5]);
        ss(3*L) = subplot(length(obs),3,sb); sb = sb+1;
        bar(new_RMS,'BarWidth',0.99);
        set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
            'NLB-ICA' })
        set(gca,'XTickLabelRot',30)
        set(gca,'FontSize',8)
        if ~exist('tlc','var')
            tlc=title('RMSE'); set(tlc,'FontSize',12);
        end
    end
    
    mt = mtit(['GV[',num2str(H),'] (',strrep(GVnames{H},'_',' '), ') ',srfc{m}]);
    set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
    set(cf,'Visible',false);
    nn = 1; n_str = ['_',num2str(nn)];
    png_out = ['GV[',num2str(H),']_QRM_3xN.',srfc{m},n_str,'.png'];
    while isafile([ACCP_pngs,png_out])
        nn = nn+1; n_str = ['_',num2str(nn)];
        png_out = ['GV[',num2str(H),']_QRM_3xN.',srfc{m},n_str,'.png'];
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
