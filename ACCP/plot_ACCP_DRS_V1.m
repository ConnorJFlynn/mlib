function plot_ACCP_DRS_V1(QIS,MER,RMS,gv,sfc,reso,pptname)
% plot_AACP_DRS_V1(QIS,MER,RMS,gv,srfc,res)
% Modified to focus on breakoutof DRS types
dv = 1.0;
AACP_pngs = getnamedpath('AACP_pngs');
% *.png files named on line 125 with pattern below where n,SRFC, and vv vary
png_out = ['GV[n]_[SRFC].[GRP].DRSx.Vvv.png'];

if ~isavar('pptname')
pptname = [AACP_pngs,'..',filesep,'AACP_3x3.DRSx.V',sprintf('%02.0f',10.*dv),'.ppt'];
end


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
m=find(strcmp(sfc,srfc));
%% res counter 
res = ["RES1", "RES2", "RES3", "RES4", "RES5"];
if ~isavar('reso') reso = 'RES1'; end
n = find(strcmp(reso,res));
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
tic
for H = gv
       for gg = [1,3,4,5]
    cf =figure(H);
    set(cf,'Position',[67 50 1443 741],'Visible',true);
    set(cf,'Position',[67 50 1443 741],'Visible',false);    
    clear lg tla tlb tlc
 
    for L=1:3
        new_QIS = squeeze(QIS(H, gg, 13:22, :, L, m, n));
        
        subplot(3,3,1+3*(L-1))
        % bar(squeeze(QIS(H,1:end-1,[1 3:end],k,l,1,1)),'BarWidth',0.99)
        bb = bar(new_QIS,'barwidth',1);
        title(strjoin(["GV[1]", group(gg), "DRSx"]))
        if ~exist('lg','var')
            lg=legend('SSP0', 'SSP1', 'SSP2', 'SSG3');
            set(lg,'Position', [0.0386    0.8785    0.0602    0.0938]);
        end
        set(gca,'XTickLabel',{'all','6a','6b','6c','6d','6e','6f','6g','6h','6i' })
        set(gca,'XTickLabelRot',30)
        set(gca,'FontSize',8);
        yl = ylabel(strjoin([obs(L)]));
        set(yl,'rotation',0); set(yl,'position',[-1.9093 0.4434]); set(yl,'FontSize',12);
        if ~exist('tla','var')
            tla=title('QI Score'); set(tla,'FontSize',12);
        end
        new_MER = squeeze(MER(H, gg, 13:22, :, L, m, n));
        
        subplot(3,3,2+3*(L-1))
        %bar(squeeze(MER(H,1:end-1,[1 3:end],k+1,l,1,1)))
        bar(new_MER,'BarWidth',0.99);
%         t=title(strjoin(['Mean err    ',obs(l),srfc(m)]));

%         yl = ylabel(strjoin([obs(L),srfc(m)])); 
%         set(yl,'rotation',0); set(yl,'position',[-1.9093    0.4434]);
        set(gca,'XTickLabel',{'all','6a','6b','6c','6d','6e','6f','6g','6h','6i' })
        set(gca,'XTickLabelRot',30); set(gca,'FontSize',8);
        if ~exist('tlb','var')
        tlb=title('Mean error'); set(tlb,'FontSize',12);
        end
        
        new_RMS = squeeze(RMS(H, gg, 13:22, :, L, m, n));
        
        subplot(3,3,3*L)
        %bar(squeeze(RMS(H,1:end-1,[1 3:end],k+2,l,1,1)))
        bar(new_RMS,'BarWidth',0.99);
        %title(GVnames(h))
%         t=title(strjoin(['RMSE    ',obs(l),srfc(m)]))
        %ylabel('RMSE')
        set(gca,'XTickLabel',{'all','6a','6b','6c','6d','6e','6f','6g','6h','6i' })
        set(gca,'XTickLabelRot',30)
        set(gca,'FontSize',8)
        if ~exist('tlc','var')
        tlc=title('RMSE'); set(tlc,'FontSize',12);
        end
    end % of L
 
    mt = mtit(['GV[',num2str(H),'] ',strrep(GVnames{H},'_',' '),'; grp[',group{gg}, ']; sfc[',srfc{m},'] DRS breakout']); 
    set(cf,'Visible',true);
    set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
%     png_out = ['GV[n]_[SRFC].3x3.DRSx.Vvv.png'];
    png_out = ['GV[',num2str(H),']_[',srfc{m},'].',group{gg},'.DRSx.V',sprintf('%02.0f',10.*dv),'.png'];
    saveas(cf,[AACP_pngs,png_out]); close(cf);
    
    pptname = [AACP_pngs,'..',filesep,'AACP_DRSx.V',sprintf('%02.0f',10.*dv),'.ppt'];
    ppt_add_slide_no_title(pptname, [AACP_pngs,png_out]);
   end % of gg
    % pause(2)
end
toc

return
