function [QI_adj] = ACCP_Q_adjust_V2_nopng(QIS,gv,reso,pptname)
% ACCP_Q_adj_V2(QIS,MER,RMS,gvreso)
% Accepts a subset of gv and a single reso
% Produces one 3x3 subplot of QIS bar plots with LNDD, LNDV, and OCEN on horiz, Obs on vert
% Modified to incorporate conditions on RES
% Name change from plot_ACCP_QI_* to plot_ACCP_QMR_*for clarity of function
% V6: fixed many cut/paste errors associated with NaN fills. Sorry Feng and Sharon!
% V7: increment png name to prevent overwrite
% V8: removed attempts to force common y-limits for some panels
% V9: Commented out conditional res.  Use supplied reso, default RES1
% V10: Added RES5 (for GV 48-53) else RES1
% V11: Adding in column for weighted means, and weights
% V12: Compute mean and weighted Qs only for cases where all plfm exist
% V13: Mask NGE DRS and SPA for NAN and limited gvs (xgv)
% V14,V15: Version jump. Not sure about V14. V15, fixes copy-paste-error
% affecting NGE SPA
% V1: new plotting function to incorporate Adjusted QIs, remove MER, RMS,
% replace with LNDD, LNDV, OCEN
% Rename to "ACCP_Q_adjust_V2_nopng" since no plots
% ACCP_pngs = getnamedpath('ACCP_pngs');
% % *.png files named with the pattern below where n,SRFC, and vv vary
% png_out = ['GV[n].Q_adj.png']; %ACCP_3x3.QMR.v5
% if ~isavar('pptname')
%     dnow = now; n_str = [];
%     pptname = ['ACCP.Q_adj.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
% end
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';

% gv = H, L = obs, m = SRFC
%QIS(gv,grp,typ,pltf,obs,srfc,res)

QI_adj = NaN(size(QIS));
QI_adj = squeeze(QI_adj(:,1,1,:,:,:,1));
% QIS_adj(H,pltf,L,srfc)
% QI_adj(H,P,L,m) =52xx4x3x3
% QI_adj = squeeze(QIS(:,1,:,:,:,1));


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
% if ~isavar('sfc') sfc = 'LNDD';end
% m=find(strcmpi(sfc,srfc));
%% res counter
res = ["RES1", "RES2", "RES3", "RES4", "RES5"];
if ~isavar('reso') reso = 'RES1'; end
n = find(strcmpi(reso,res));
obs = ["NAD", "NAN", "OND"];
%% there are eight combinations of group and typ that have priority - they
%% can be labeled:
%% NLP-DRSall,NLS-DRSall,NGE-DRSall,OUX-DRSall,NLB-ICAall,OUX-ICAall,NLS-SPA,NGE-SPA
%% They correspond to the following group/typ index combinations:
%% 1/13, 3/13, 4/13, 5/13, 2/3, 5/3, 3/1, 4/1
%%
%% NLP-DRSall is something like QIS(h, 1, 13, k, L, m, n)
%% would like to plot four pltf's as grouped bars, so
%% NLP-DRSall is QIS(h, 1, 13, :, L, m, n)
%% NLS-DRSall is QIS(h, 3, 13, :, L, m, n)
%% NGE-DRSall is QIS(h, 4, 13, :, L, m, n)
%% OUX-DRSall is QIS(h, 5, 13, :, L, m, n)
%% NLB-ICAall is QIS(h, 2,  3, :, L, m, n)
%% OUX-ICAall is QIS(h, 5,  3, :, L, m, n)
%% NLS-SPA    is QIS(h, 3,  1, :, L, m, n)
%% NGE-SPA    is QIS(h, 4,  1, :, L, m, n)
% QIS = NaN([73,length(group),length(typ),length(pltf),length(obs),length(srfc),length(res)]);
% tic

W_NLP_DRS = NLP_DRS_weights; W_NLS_DRS = NLS_DRS_weights;
W_NGE_DRS = NGE_DRS_weights; W_OUX_DRS = OUX_DRS_weights;

W_NLB_ICA = NLB_ICA_weights; W_OUX_ICA = OUX_ICA_weights;
W_NLS_SPA = NLS_SPA_weights; W_NGE_SPA = NGE_SPA_weights;
% [adj] = ACCP_QI_adj_v1;
[adj] = ACCP_QI_adj_v2;
xgv = [1:8,13:16,40:45]; % Exclude these GVs for NGE SPA and DRS
for H = gv
    n = find(strcmpi(reso,res));
    if H>=48&&H<=53
        % RES5
        n = 5;
    end
% gv = adj(:,1);
% NAD = adj(:,[2:5]);
% NAN = adj(:,[6:9]);
% OND = adj(:,[10:13]);

    adj_gv = interp1(adj(:,1), [1:length(adj(:,1))],H,'nearest');
    for L=1:3 % obs counter obs = ["NAD", "NAN", "OND"];
        adj_L = adj(adj_gv,1+[1:4]+4.*(L-1));
        for m = 1:3 % srfc = ["LNDD", "LNDV", "OCEN"];
            QI_1 = (QIS(H, 1, 13, :, L, m, n)); %% NLP-DRSall is QIS(h, 1, 13, :, L, m, n)
            if all(isNaN(QI_1)) &&n~=1
                QI_1 = QIS(H,1,13,:,L,m,1);
            end
            QI_2 = (QIS(H, 3, 13, :, L, m, n)); %% NLS-DRSall is QIS(h, 3, 13, :, L, m, n)
            if all(isNaN(QI_2)) &&n~=1
                QI_2 = QIS(H,3,13,:,L,m,1);
            end
            QI_3 = (QIS(H, 4, 13, :, L, m, n)); %% NGE-DRSall is QIS(h, 4, 13, :, L, m, n)
            if all(isNaN(QI_3)) && (n~=1)
                QI_3 = QIS(H,4,13,:,L,m,1);
            end
            if ~isempty(intersect(H,xgv))&&L==2
                QI_3= QI_3.*NaN;
            end
            QI_4 = (QIS(H, 5, 13, :, L, m, n)); %% OUX-DRSall is QIS(h, 5, 13, :, L, m, n)
            if all(isNaN(QI_4)) &&n~=1
                QI_4 = QIS(H,5,13,:,L,m,1);
            end
            QI_5 = (QIS(H, 2, 3, :, L, m, n)); %% NLB-ICAall is QIS(h, 2,  3, :, L, m, n)
            if all(isNaN(QI_5)) &&n~=1
                QI_5 = QIS(H,2,3,:,L,m,1); % GV51,2,3
                % QIS = NaN([73,length(group),length(typ),length(pltf),length(obs),length(srfc),length(res)]);
            end
            QI_6 = (QIS(H, 5, 3, :, L, m, n)); %% OUX-ICAall is QIS(h, 5,  3, :, L, m, n)
            if all(isNaN(QI_6)) &&n~=1
                QI_6 = QIS(H,5,3,:,L,m,1);
            end
            QI_7 = (QIS(H, 3, 1, :, L, m, n)); %% NLS-SPA  is QIS(h, 3,  1, :, L, m, n)
            if all(isNaN(QI_7)) &&n~=1
                QI_7 = QIS(H,3,1,:,L,m,1);
            end
            QI_8 = (QIS(H, 4, 1, :, L, m, n)); %% NGE-SPA    is QIS(h, 4,  1, :, L, m, n)
            if all(isNaN(QI_8)) &&n~=1
                QI_8 = QIS(H,4,1,:,L,m,1);
            end
            if ~isempty(intersect(H,xgv))&&L==2
                QI_8= QI_8.*NaN;
            end
            %         newQIS = squeeze([QIS(H, 1, 13, :, L, m, n) QIS(H, 3, 13, :, L, m, n) ...
            %             QIS(H, 4, 13, :, L, m, n) QIS(H, 5, 13, :, L, m, n) ...
            %             QIS(H, 2,  3, :, L, m, n) QIS(H, 5,  3, :, L, m, n) ...
            %             QIS(H, 3,  1, :, L, m, n) QIS(H, 4,  1, :, L, m, n)]);
            newQIS = squeeze([QI_1 QI_2 QI_3 QI_4 QI_5 QI_6 QI_7 QI_8]);
            % Only use cases where all 4 platforms are reported
            QNAN = double(~isNaN(newQIS));
            QNAN(isNaN(newQIS)) = NaN;anyNaN = any(isNaN(QNAN)')';
            QNAN(anyNaN,:) = NaN;
            ws = [W_NLP_DRS(H,:);W_NLS_DRS(H,:);W_NGE_DRS(H,:);W_OUX_DRS(H,:);...
                W_NLB_ICA(H,:);W_OUX_ICA(H,:);W_NLS_SPA(H,:);W_NGE_SPA(H,:)];
            ws = ws.*QNAN;
            meanQ = meannonan(newQIS.*QNAN);
            weighted_Q = meannonan(newQIS .* ws)./meannonan(ws);
            %QIS(gv,grp,orb/typ,pltf,obs,srfc,res)
            % QI_adj(H,P,L,m) =52xx4x3x3
            QI_adj(H,:,L,m) = weighted_Q + adj_L; %L=obs, m = SRFC
            % For QIs in each column (pltf),
%             new_QIS = [newQIS; weighted_Q; squeeze(QI_adj(H,L,:,m))'];
            % QIS_adj(H,L=obs,pltf,m=srfc); 
            %QIS_adj is an output which we'll use to generate 4 sheets one per (PLTF)
            % Each PLTF will have 2*GV rows (GVx(land, ocean)), 3 cols (NAD, NAN, OND)
            
%             subplot(3,3,m+3*(L-1))
%             % bar(squeeze(QIS(H,1:end-1,[1 3:end],k,l,1,1)),'BarWidth',0.99)
%             bar(new_QIS,'BarWidth',0.99)
%             %         t=title(strjoin(['QI Score   ',obs(l),srfc(m)]));
%             
%             if ~exist('lg','var')
%                 lg=legend('SSP0', 'SSP1', 'SSP2', 'SSG3');
%                 set(lg,'Position', [0.0386    0.8785    0.0602    0.0938]);
%             end
%             set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
%                 'NLB-ICA','OUX-ICA','NLS-SPA','NGE-SPA','mean wt.','adjusted' })
%             set(gca,'XTickLabelRot',30)
%             set(gca,'FontSize',8);
%             ylim([0,1]);
%             if m==1
%                 yl = ylabel(strjoin([obs(L)]));
%                 set(yl,'rotation',0); set(yl,'position',[-1.9093 0.4434]); set(yl,'FontSize',12);
%             end
%             if L==1
%                 tla=title([srfc{m}]); set(tla,'FontSize',12);
%             end
        end % of m loop
    end
    
%     mt = mtit(['GV[',num2str(H),'] (',strrep(GVnames{H},'_',' '), ') Adj QIs']);
%     set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
%     set(cf,'Visible',false);
%     nn = 1; n_str = ['_',num2str(nn)];
%     png_out = ['GV[',num2str(H),'].Q_adj',n_str,'.png'];
%     while isafile([ACCP_pngs,png_out])
%         nn = nn+1; n_str = ['_',num2str(nn)];
%         png_out = ['GV[',num2str(H),'].Q_adj',n_str,'.png'];
%     end
%     
%     saveas(cf,[ACCP_pngs,png_out]);
%     %     set(cf,'visib',true);
%     %     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
%     close(cf);
%     ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
    
    % pause(2)
end
% toc

return
