function plot_ACCP_DRS_V2(QIS,MER,RMS,gv,sfc,reso,pptname)
% plot_AACP_DRS_V1(QIS,MER,RMS,gv,srfc,res)
% Modified to focus on breakoutof DRS types
dv = 2.0;
ACCP_pngs = getnamedpath('ACCP_pngs');
% *.png files named on line 125 with pattern below where n,SRFC, and vv vary
png_out = ['GV[n]_[SRFC].[GRP].DRSx.Vvv.png'];

if ~isavar('pptname')
    pptname = [ACCP_pngs,'..',filesep,'ACCP_3x1.DRSx.ppt'];
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
    for L=1:3
        
        
        
        new_QIS = [squeeze(QIS(H, 1, 13:22, :, L, m, n));squeeze(QIS(H, 3, 13:22, :, L, m, n));...
            squeeze(QIS(H, 4, 13:22, :, L, m, n));squeeze(QIS(H, 5, 13:22, :, L, m, n))  ];
        ax(1) = subplot(3,1,L);
        % bar(squeeze(QIS(H,1:end-1,[1 3:end],k,l,1,1)),'BarWidth',0.99)
        bb = bar(new_QIS,'barwidth',1);
        if ~exist('lg','var')
            lg=legend('SSP0', 'SSP1', 'SSP2', 'SSG3');
            set(lg,'Position', [0.0386    0.8785    0.0602    0.0938]);
        end
        set(ax,'XTick',[1:40]);
        set(ax,'XTickLabel',{[group{1},' all'],'6a','6b','6c','6d','6e','6f','6g','6h','6i',...
            [group{3},' all'],'6a','6b','6c','6d','6e','6f','6g','6h','6i',...
            [group{4},' all'],'6a','6b','6c','6d','6e','6f','6g','6h','6i',...
            [group{5},' all'],'6a','6b','6c','6d','6e','6f','6g','6h','6i'})
        
        set(gca,'XTickLabelRot',30)
        set(gca,'FontSize',8);
        yl = ylabel(strjoin([obs(L)]));
        set(yl,'rotation',0); set(yl,'position',[-1.9093 0.4434]); set(yl,'FontSize',12);
        %         if ~exist('tla','var')
        %             tla=title('QI Score'); set(tla,'FontSize',12);
        %         end
        
    end % of L
    
    mt = mtit(['GV[',num2str(H),'] ',strrep(GVnames{H},'_',' '),'; sfc[',srfc{m},'] DRS breakout']);
    set(cf,'Visible',false);
    set(mt.th,'fontsize',15,'position',[0.5000    1.0200]);
    %     png_out = ['GV[n]_[SRFC].3x3.DRSx.Vvv.png'];
    png_out = ['GV[',num2str(H),']_[',srfc{m},'].DRSx.V',sprintf('%02.0f',10.*dv),'.png'];
    saveas(cf,[ACCP_pngs,png_out]); close(cf);
    
    
    ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
    
    % pause(2)
end
% toc

return
