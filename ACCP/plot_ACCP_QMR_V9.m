function plot_ACCP_QMR_V9(QIS,MER,RMS,gv,sfc,reso,pptname)
% plot_ACCP_QMR_V8(QIS,MER,RMS,gv,sfc,reso)
% Accepts a subset of gv, a single sfc, and a single reso
% Produces one 3x3 subplot of bar plots for QIS, MER, and RMS on horiz, Obs on vert
% Modified to incorporate conditions on RES
% Name change from plot_ACCP_QI_* to plot_ACCP_QMR_*for clarity of function
% V6: fixed many cut/paste errors associated with NaN fills. Sorry Feng and Sharon!
% V7: increment png name to prevent overwrite
% V8: removed attempts to force common y-limits for some panels
% V9: Commented out conditional res.  Use supplied reso, default RES1

ACCP_pngs = getnamedpath('ACCP_pngs');
% *.png files named with the pattern below where n,SRFC, and vv vary
png_out = ['GV[n]_[SRFC].3x3.QMR.png']; %ACCP_3x3.QMR.v5
if ~isavar('pptname')
    dnow = now; n_str = [];
    pptname = ['ACCP_3x3.QMR.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';

%QIS(gv,grp,orb/typ,pltf,obs,srfc,res)

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
for H = gv
    cf =figure(H);
%         set(cf,'Position',[67 50 1443 741],'Visible',true);
    set(cf,'Position',[67 50 1443 741],'Visible',false); % Comment out to see plots, but slower
    clear lg tla tlb tlc
    if H>=31 && H<=37
        n = 2;
    elseif H>=48 && H<=49
        n = 4;
    elseif H>=50&&H<=53
        n = 5;
    end

!Connor, check what happens with resolution (n)
    clear max_yl max_yl2
    for L=1:3 
        QI_1 = (QIS(H, 1, 13, :, L, m, n)); 
        if all(isNaN(QI_1)) &&n~=1
            QI_1 = QIS(H,1,13,:,L,m,1);
        end
        QI_2 = (QIS(H, 3, 13, :, L, m, n)); 
        if all(isNaN(QI_2)) &&n~=1
            QI_2 = QIS(H,3,13,:,L,m,1);
        end
        QI_3 = (QIS(H, 4, 13, :, L, m, n)); 
        if all(isNaN(QI_3)) &&n~=1
            QI_3 = QIS(H,4,13,:,L,m,1);
        end
        QI_4 = (QIS(H, 5, 13, :, L, m, n)); 
        if all(isNaN(QI_4)) &&n~=1
            QI_4 = QIS(H,5,13,:,L,m,1);
        end        
        QI_5 = (QIS(H, 2, 3, :, L, m, n)); 
        if all(isNaN(QI_5)) &&n~=1
            QI_5 = QIS(H,2,3,:,L,m,1); % GV51,2,3
            % QIS = NaN([73,length(group),length(typ),length(pltf),length(obs),length(srfc),length(res)]);
        end
        QI_6 = (QIS(H, 5, 3, :, L, m, n)); 
        if all(isNaN(QI_6)) &&n~=1
            QI_6 = QIS(H,5,3,:,L,m,1);
        end        
        QI_7 = (QIS(H, 3, 1, :, L, m, n)); 
        if all(isNaN(QI_7)) &&n~=1
            QI_7 = QIS(H,3,1,:,L,m,1);
        end
        QI_8 = (QIS(H, 4, 1, :, L, m, n)); 
        if all(isNaN(QI_8)) &&n~=1
            QI_8 = QIS(H,4,1,:,L,m,1);
        end        
%         newQIS = squeeze([QIS(H, 1, 13, :, L, m, n) QIS(H, 3, 13, :, L, m, n) ...
%             QIS(H, 4, 13, :, L, m, n) QIS(H, 5, 13, :, L, m, n) ...
%             QIS(H, 2,  3, :, L, m, n) QIS(H, 5,  3, :, L, m, n) ...
%             QIS(H, 3,  1, :, L, m, n) QIS(H, 4,  1, :, L, m, n)]);
        newQIS = squeeze([QI_1 QI_2 QI_3 QI_4 QI_5 QI_6 QI_7 QI_8]);      
        new_QIS = [newQIS;meannonan(newQIS)];
        subplot(3,3,1+3*(L-1))
        % bar(squeeze(QIS(H,1:end-1,[1 3:end],k,l,1,1)),'BarWidth',0.99)
        bar(new_QIS,'BarWidth',0.99)
        %         t=title(strjoin(['QI Score   ',obs(l),srfc(m)]));
        
        if ~exist('lg','var')
            lg=legend('SSP0', 'SSP1', 'SSP2', 'SSG3');
            set(lg,'Position', [0.0386    0.8785    0.0602    0.0938]);
        end
        set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
            'NLB-ICA','OUX-ICA','NLS-SPA','NGE-SPA','mean' })
        set(gca,'XTickLabelRot',30)
        set(gca,'FontSize',8);
        ylim([0,1]);
        yl = ylabel(strjoin([obs(L)]));
        set(yl,'rotation',0); set(yl,'position',[-1.9093 0.4434]); set(yl,'FontSize',12);
        if ~exist('tla','var')
            tla=title('QI Score'); set(tla,'FontSize',12);
        end
        ME_1 = (MER(H, 1, 13, :, L, m, n)); 
        if all(isNaN(ME_1)) &&n~=1
            ME_1 = MER(H,1,13,:,L,m,1);
        end
        ME_2 = (MER(H, 3, 13, :, L, m, n)); 
        if all(isNaN(ME_2)) &&n~=1
            ME_2 = MER(H,3,13,:,L,m,1);
        end
        ME_3 = (MER(H, 4, 13, :, L, m, n)); 
        if all(isNaN(ME_3)) &&n~=1
            ME_3 = MER(H,4,13,:,L,m,1);
        end
        ME_4 = (MER(H, 5, 13, :, L, m, n)); 
        if all(isNaN(ME_4)) &&n~=1
            ME_4 = MER(H,5,13,:,L,m,1);
        end        
        ME_5 = (MER(H, 2, 3, :, L, m, n)); 
        if all(isNaN(ME_5)) &&n~=1
            ME_5 = MER(H,2,3,:,L,m,1);
        end
        ME_6 = (MER(H, 5, 3, :, L, m, n)); 
        if all(isNaN(ME_6)) &&n~=1
            ME_6 = MER(H,5,3,:,L,m,1);
        end        
        ME_7 = (MER(H, 3, 1, :, L, m, n)); 
        if all(isNaN(ME_7)) &&n~=1
            ME_7 = MER(H,3,1,:,L,m,1);
        end
        ME_8 = (MER(H, 4, 1, :, L, m, n)); 
        if all(isNaN(ME_8)) &&n~=1
            ME_8 = MER(H,4,1,:,L,m,1);
        end     
%         
%         new_MER = squeeze([MER(H, 1, 13, :, L, m, n) MER(H, 3, 13, :, L, m, n) ...
%             MER(H, 4, 13, :, L, m, n) MER(H, 5, 13, :, L, m, n) ...
%             MER(H, 2,  3, :, L, m, n) MER(H, 5,  3, :, L, m, n) ...
%             MER(H, 3,  1, :, L, m, n) MER(H, 4,  1, :, L, m, n)]);
        new_MER = squeeze([ME_1 ME_2 ME_3 ME_4 ME_5 ME_6 ME_7 ME_8]);
        ss(2+3*(L-1)) = subplot(3,3,2+3*(L-1));
        
        %bar(squeeze(MER(H,1:end-1,[1 3:end],k+1,l,1,1)))
        bar(new_MER,'BarWidth',0.99);
        set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
            'NLB-ICA','OUX-ICA','NLS-SPA','NGE-SPA' })
        set(gca,'XTickLabelRot',30); set(gca,'FontSize',8);
        if ~exist('tlb','var')
            tlb=title('Mean error'); set(tlb,'FontSize',12);
        end
        RM_1 = (RMS(H, 1, 13, :, L, m, n)); 
        if all(isNaN(RM_1)) &&n~=1
            RM_1 = RMS(H,1,13,:,L,m,1);
        end
        RM_2 = (RMS(H, 3, 13, :, L, m, n)); 
        if all(isNaN(RM_2)) &&n~=1
            RM_2 = RMS(H,3,13,:,L,m,1);
        end
        RM_3 = (RMS(H, 4, 13, :, L, m, n)); 
        if all(isNaN(RM_3)) &&n~=1
            RM_3 = RMS(H,4,13,:,L,m,1);
        end
        RM_4 = (RMS(H, 5, 13, :, L, m, n)); 
        if all(isNaN(RM_4)) &&n~=1
            RM_4 = RMS(H,5,13,:,L,m,1);
        end        
        RM_5 = (RMS(H, 2, 3, :, L, m, n)); 
        if all(isNaN(RM_5)) &&n~=1
            RM_5 = RMS(H,2,3,:,L,m,1);
        end
        RM_6 = (RMS(H, 5, 3, :, L, m, n)); 
        if all(isNaN(RM_6)) &&n~=1
            RM_6 = RMS(H,5,3,:,L,m,1);
        end        
        RM_7 = (RMS(H, 3, 1, :, L, m, n)); 
        if all(isNaN(RM_7)) &&n~=1
            RM_7 = RMS(H,3,1,:,L,m,1);
        end
        RM_8 = (RMS(H, 4, 1, :, L, m, n)); 
        if all(isNaN(RM_8)) &&n~=1
            RM_8 = RMS(H,4,1,:,L,m,1);
        end             
%         new_RMS = squeeze([RMS(H, 1, 13, :, L, m, n) RMS(H, 3, 13, :, L, m, n) ...
%             RMS(H, 4, 13, :, L, m, n) RMS(H, 5, 13, :, L, m, n) ...
%             RMS(H, 2,  3, :, L, m, n) RMS(H, 5,  3, :, L, m, n) ...
%             RMS(H, 3,  1, :, L, m, n) RMS(H, 4,  1, :, L, m, n)]);
        new_RMS = squeeze([RM_1 RM_2 RM_3 RM_4 RM_5 RM_6 RM_7 RM_8]);
         ss(3*L) = subplot(3,3,3*L);
        bar(new_RMS,'BarWidth',0.99);
        set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
            'NLB-ICA','OUX-ICA','NLS-SPA','NGE-SPA' })
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
    png_out = ['GV[',num2str(H),']_',srfc{m},'.3x3.QRM',n_str,'.png']; 
    while isafile([ACCP_pngs,png_out])
        nn = nn+1; n_str = ['_',num2str(nn)];
        png_out = ['GV[',num2str(H),']_',srfc{m},'.3x3.QRM',n_str,'.png'];
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
