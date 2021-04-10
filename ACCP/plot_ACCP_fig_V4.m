function plot_ACCP_fig_V4(QIS,MER,RMS,gv,sfc,reso)
% plot_AACP_fig_V3(QIS,MER,RMS,gvi,grp,typ,pltf,obs,srfc,res)
% plot_AACP_fig_V3(QIS,MER,RMS,grp,typ,pltf,obs,srfc,res)
[~, ~, GVnames] = xlsread('C:\Users\Connor Flynn\Documents\GitHub\mlib\ACCP\GVnames.xlsx','Sheet1');
AACP_pngs = setnamedpath('AACP_pngs',[],'Select a directory for AACP png files.')
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';
dv = 1.0;
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
m=find(strcmp(sfc,srfc));
%% res counter 
res = ["RES1", "RES2", "RES3", "RES4", "RES5"];
if ~isavar('reso') reso = 'RES1'; end
n = find(strcmp(reso,res));
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
tic
for H = gv
    cf =figure(H);
    set(cf,'Position',[67 50 1443 741],'Visible',true);
%     set(cf,'Position',[67 50 1443 741],'Visible',false);
    clear lg tla tlb tlc
    for L=1:3
        new_QIS = squeeze([QIS(H, 1, 13, :, L, m, n) QIS(H, 3, 13, :, L, m, n) ...
            QIS(H, 4, 13, :, L, m, n) QIS(H, 5, 13, :, L, m, n) ...
            QIS(H, 2,  3, :, L, m, n) QIS(H, 5,  3, :, L, m, n) ...
            QIS(H, 3,  1, :, L, m, n) QIS(H, 4,  1, :, L, m, n)]);
        
        subplot(3,2,1+2*(L-1))
        % bar(squeeze(QIS(H,1:end-1,[1 3:end],k,l,1,1)),'BarWidth',0.99)
        bb = bar(new_QIS,'BarWidth',0.99);
%         t=title(strjoin(['QI Score   ',obs(l),srfc(m)]));

        if ~exist('lg','var')
            lg=legend('SSP0', 'SSP1', 'SSP2', 'SSG3');
            set(lg,'Position', [0.0386    0.8785    0.0602    0.0938]);
        end
        set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
            'NLB-ICA','OUX-ICA','NLS-SPA','NGE-SPA' })
        set(gca,'XTickLabelRot',30)
        set(gca,'FontSize',8);
                yl = ylabel(strjoin([obs(L),srfc(m)])); 
        set(yl,'rotation',0); set(yl,'position',[-1 0.4434]); set(yl,'FontSize',12);
        if ~exist('tla','var')
            tla=title('QI Score'); set(tla,'FontSize',12);
        end
        new_MER = squeeze([MER(H, 1, 13, :, L, m, n) MER(H, 3, 13, :, L, m, n) ...
            MER(H, 4, 13, :, L, m, n) MER(H, 5, 13, :, L, m, n) ...
            MER(H, 2,  3, :, L, m, n) MER(H, 5,  3, :, L, m, n) ...
            MER(H, 3,  1, :, L, m, n) MER(H, 4,  1, :, L, m, n)]);
        new_RMS = squeeze([RMS(H, 1, 13, :, L, m, n) RMS(H, 3, 13, :, L, m, n) ...
            RMS(H, 4, 13, :, L, m, n) RMS(H, 5, 13, :, L, m, n) ...
            RMS(H, 2,  3, :, L, m, n) RMS(H, 5,  3, :, L, m, n) ...
            RMS(H, 3,  1, :, L, m, n) RMS(H, 4,  1, :, L, m, n)]);
        
        subplot(3,2,2+2*(L-1));
        RMS_new = [];
        for RR = size(new_RMS,1):-1:1
            tmp = [new_RMS(RR,:);new_RMS(RR,:)]';
            RMS_new = [RMS_new;tmp];
        end
            

        %bar(squeeze(MER(H,1:end-1,[1 3:end],k+1,l,1,1)))
        bb = bar(RMS_new,'stacked','BarWidth',0.99);
%         t=title(strjoin(['Mean err    ',obs(l),srfc(m)]));

%         yl = ylabel(strjoin([obs(L),srfc(m)])); 
%         set(yl,'rotation',0); set(yl,'position',[-1.9093    0.4434]);
        set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
            'NLB-ICA','OUX-ICA','NLS-SPA','NGE-SPA' })
        set(gca,'XTickLabelRot',30); set(gca,'FontSize',8);
        if ~exist('tlb','var')
        tlb=title('Mean error'); set(tlb,'FontSize',12);
        end
        

        
        subplot(3,2,2*L)
        %bar(squeeze(RMS(H,1:end-1,[1 3:end],k+2,l,1,1)))
        bar(new_RMS,'BarWidth',0.99);
        %title(GVnames(h))
%         t=title(strjoin(['RMSE    ',obs(l),srfc(m)]))
        %ylabel('RMSE')
        set(gca,'XTickLabel',{'NLP-DRS','NLS-DRS','NGE-DRS','OUX-DRS',...
            'NLB-ICA','OUX-ICA','NLS-SPA','NGE-SPA' })
        set(gca,'XTickLabelRot',30)
        set(gca,'FontSize',8)
        if ~exist('tlc','var')
        tlc=title('RMSE'); set(tlc,'FontSize',12);
        end
    end
    mt = mtit(['GV[',num2str(H),'] ',strrep(GVnames{H},'_',' ')]); set(cf,'Visible',false);
    set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
    png_out = ['GV[',num2str(H),']_',GVnames{H},'.3x3.V',sprintf('%02.0f',10.*dv),'.png'];
    saveas(cf,[AACP_pngs,png_out]); close(cf);
    pptname = [AACP_pngs,'..',filesep,'AACP_3x3.V',sprintf('%02.0f',10.*dv),'.ppt'];
    ppt_add_slide_no_title(pptname, [AACP_pngs,png_out]);

    % pause(2)
end
toc

return
