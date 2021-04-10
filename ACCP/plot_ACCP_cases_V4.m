function plot_ACCP_cases_V4(QIS,MER,RMS,gv,sfc,reso,pptname)
% plot_AACP_cases_V4(QIS,MER,RMS,gv,srfc,res)
% Attempt to incorporate both DRS and ICA casestudy breakouts
% Removing DRS groups that have only provided DRS_all, adding ICA groups
% Added NLS Snorres
% Added OUX for DRS, ICA, fixed cut-paste index errors
% v4: Increment png filename to avoid overwrite
dv = 4.0;
ACCP_pngs = getnamedpath('ACCP_pngs');
% *.png files named on line 125 with pattern below where n,SRFC, and vv vary
png_out = ['GV[n]_[SRFC].[GRP].Qall_6a-i.Vvv.png']; %ACCP_3x1.cases

if ~isavar('pptname')
    d_now = now; n_str = [];
    pptname = ['ACCP_3x1.Qall_6a-i.v3.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];;
end
%pptname = ['ACCP_3x1.Qall_6a-i.v2.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];

[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.xlsx'],'Sheet1');
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
srfc = ["LNDD", "LNDV", "OCEN"];
if ~isavar('sfc') sfc = 'LNDD';end
m=find(strcmpi(sfc,srfc));
%% res counter
res = ["RES1", "RES2", "RES3", "RES4", "RES5"];
if ~isavar('reso') reso = 'RES1'; end
n = find(strcmpi(reso,res));
obs = ["NAD", "NAN", "OND"];

group = ["NLP", "NLB", "NLS", "NGE", "OUX", "CND"];
%% there are eight combinations of group and typ that have priority - they
%% can be labeled:
%% NLP-DRSall,NLS-DRSall,NGE-DRSall,OUX-DRSall,NLB-ICAall,OUX-ICAall,NLS-SPA,NGE-SPA
%% They correspond to the following group/typ index combinations:
%% 1/13, 3/13, 4/13, 5/13, 2/3, 5/3, 3/1, 4/1
%%
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
    
    cf =figure(H);
    %     set(cf,'Position',[67 50 1443 741],'Visible',true);
    set(cf,'Position',[67 50 1443 741],'Visible',false);
    clear lg tla tlb tlc
    if H>=31 && H<=37
        n = 2;
    elseif H>=48 && H<=49
        n = 4;
    elseif H>=50&&H<=53
        n = 5;
    end
% QIS(gv,grp,typ,pltf,obs,srfc,res)

% group = ["NLP", "NLB", "NLS", "NGE", "OUX", "CND"];    
    
% typ(1:5)   "SPA", "RDA", "ICAall", "ICA6a", "ICA6b", 
% typ(6:10)  "ICA6c", "ICA6d", "ICA6e","ICA6f","ICA6g", 
% typ(11:15) "ICA6h", "ICA6i", "DRSall", "DRS6a", "DRS6b", 
% typ(16:20) "DRS6c", "DRS6d", "DRS6e", "DRS6f","DRS6g", 
% typ(21:22) "DRS6h", "DRS6i"];


    for L=1:3
        % NLP_(grp=1,type 13:22))
        QI_1 = (QIS(H, 3, 13:22, :, L, m, n)); 
        if all(all(isNaN(QI_1))) &&n~=1
            QI_1 = QIS(H, 3, 13:22, :, L, m, 1);
        end
        
        % NLS_DRS(grp=3,type 13:22))
        QI_1 = (QIS(H, 3, 13:22, :, L, m, n)); 
        if all(all(isNaN(QI_1))) &&n~=1
            QI_1 = QIS(H, 3, 13:22, :, L, m, 1);
        end
        % NGE_DRS(grp=4,type 13:22))
        QI_2 = (QIS(H, 4, 13:22, :, L, m, n));
        if all(all(isNaN(QI_2))) &&n~=1
            QI_2 = QIS(H, 4, 13:22, :, L, m, 1);
        end
        % NLB_ICA (grp=2, type(3:12)
        QI_3 = (QIS(H, 2, 3:12, :, L, m, n)); 
        if all(all(isNaN(QI_3))) &&n~=1
            QI_3 = QIS(H, 2, 3:12, :, L, m, 1);
        end
        % OUX_ICA (grp=5, type(3:12)
        QI_4 = (QIS(H, 5, 3:12, :, L, m, n)); 
        if all(all(isNaN(QI_4))) &&n~=1
            QI_4 = QIS(H, 5, 3:12, :, L, m, 1);
        end
        % OUX_DRS (grp=5, type(13:22)
        QI_5 = (QIS(H, 5, 13:22, :, L, m, n)); 
        if all(all(isNaN(QI_5))) &&n~=1
            QI_5 = QIS(H, 5, 13:22, :, L, m, 1);
        end              
        
%         new_QIS = [squeeze(QIS(H, 1, 13:22, :, L, m, n));squeeze(QIS(H, 3, 13:22, :, L, m, n))];
        
        new_QIS = [squeeze(QI_1); squeeze(QI_2); squeeze(QI_3); squeeze(QI_4); squeeze(QI_5)];        
        ax(1) = subplot(3,1,L);
        % bar(squeeze(QIS(H,1:end-1,[1 3:end],k,l,1,1)),'BarWidth',0.99)
        bb = bar(new_QIS,'barwidth',1);
        if ~exist('lg','var')
            lg=legend('SSP0', 'SSP1', 'SSP2', 'SSG3');
            set(lg,'Position', [0.0386    0.8785    0.0602    0.0938]);
        end
        set(ax,'XTick',[1:length(new_QIS)]);
        set(ax,'XTickLabel',{[group{3},' DRS all'],'6a','6b','6c','6d','6e','6f','6g','6h','6i',...
            [group{4},' DRS all'],'6a','6b','6c','6d','6e','6f','6g','6h','6i',...
            [group{2},' ICA all'],'6a','6b','6c','6d','6e','6f','6g','6h','6i',...
            [group{5},' ICA all'],'6a','6b','6c','6d','6e','6f','6g','6h','6i',...
            [group{5},' DRS all'],'6a','6b','6c','6d','6e','6f','6g','6h','6i'})
        
        set(gca,'XTickLabelRot',30)
        set(gca,'FontSize',8);
        ylim([0,1]);
        yl = ylabel(strjoin([obs(L)]));
        set(yl,'rotation',0); set(yl,'position',[-1.9093 0.4434]); set(yl,'FontSize',12);
        %         if ~exist('tla','var')
        %             tla=title('QI Score'); set(tla,'FontSize',12);
        %         end
        
    end % of L
    
    mt = mtit(['GV[',num2str(H),']']);
    set(mt.th,'string',{['GV[',num2str(H),'] (',strrep(GVnames{H},'_',' '),') ',srfc{m},' DRS breakout'];'QI Scores'})
    set(mt.th,'fontsize',12,'position',[0.5000    1.01500]);
    set(cf,'Visible',false);
    nn = 1; n_str = [];
    png_out = ['GV[',num2str(H),']_',srfc{m},'.Qall_6a-i.V',sprintf('%02.0f',10.*dv),n_str,'.png'];
    while isafile([ACCP_pngs,png_out])
        nn = nn+1; n_str = ['_',num2str(nn)];
        png_out = ['GV[',num2str(H),']_',srfc{m},'.Qall_6a-i.V',sprintf('%02.0f',10.*dv),n_str,'.png']; 
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
