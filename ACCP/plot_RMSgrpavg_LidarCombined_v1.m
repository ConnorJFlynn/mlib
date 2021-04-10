function plot_RMSgrpavg_LidarCombined_v1(RMS,pptname)
% RMS = plot_RMSgrpavg_LidarCombined_v1(RMS,pptname)
% Intended to detail differences between Lidar-Only and Combiend retrievals at Snorre's request
% as per his example figure.
% We are limited to NAD.  Makes sense to compare NADBC0 and NADLC1 since if
% clear (C0) then no real reason to do NADLC0 instead of NADBC0 other than
% for sun-angle perhaps.
% I think we want to show NADBC0 adn NADLC1 for all platforms, LAND and
% OCEN.

ACCP_pngs = getnamedpath('ACCP_pngs');
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';
gv = [1:length(GVnames)];
% mean_adj = SITA_Sept_adj;
%QIS(gv,grp,orb/typ,pltf,obs,srfc,res)
%% GV counter
H = length(GVnames);
% Now, just the principle GVs
layr = [3,12,19,23,25,32];
prof = [42,44,50,51,52,53,58,64];

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

    OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0", "NADLC1","NANLC1","NADLC2","NANLC2"];
    %         1          2        3         4         5         6       7         8
    if ~isavar('obs')
        obs = OBI;
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


lay = find(gv<42); prf = find(gv>41);
lay(21:22) = []; %Exclude GV21,22
prf(21:22) = []; % Exclude GV62,63
% toc

% mean_adj = SITA_Sept_adj;
% NADLC0adj = mean_adj(:,1:4); 
% NADBC0adj = mean_adj(:,5:8);
% NANLC0adj = mean_adj(:,9:12);

    clear xt xtt
    for xx = length(layr):-1:1
        xt(xx) = {num2str(layr(xx))};
    end
    for xx = length(prof):-1:1
        xtt(xx) = {num2str(prof(xx))};
    end
    
    layr_x = {"AAOD Vis Col","AEFRF PBL","AODF Vis Col","AOD UV Col","AOD Vis Col","ARIR Vis Col"};
    prof_x= {"AABS UV above pbl","AABS VIS above pbl","AEXT UV above pbl",...
        "AEXT UV in pbl","AEXT Vis above pbl","AEXT Vis in pbl",...
        "AE2BR Vis above pbl","ANC above pbl"};

sfc = 1   
    figure_(11009);
    clear lg sq tlr tll

%     OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0", "NADLC1","NANLC1","NADLC2","NANLC2"];
    %         1          2        3         4         5         6       7         8    
    % Row 1: NADBC0 = 2
    % over : NADLC1 = 5
    sq(2)= subplot(2,2,2);
    bb = bar([1:length(prof)],...
        squeeze(RMS(prof,:,5,sfc)),...
        'barwidth',.5,'edgecolor','k');     
    hold(sq(2),'on');  sq(2).ColorOrderIndex = 1; 
        bb2 = bar([1:length(prof)],...
        squeeze(RMS(prof,:,2,sfc)),...
        'barwidth',1,'edgecolor','k','facealpha',.3); liny;
    set(gca,'position',[0.4757    0.5700    0.4763    0.3550]);
    set(gca,'xtick',[1:length(prof)]);%set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',xtt); set(sq(2),'xaxislocation','top');
    set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
    set(gca,'yaxislocation','right');
    tlr = title (['Profile-resolved GVs for ',srfc{sfc}]);
    lg = legend('SSP0 LC1','SSP1 LC1','SSP2 LC1','SSG3 LC1','SSP0 BC0','SSP1 BC0','SSP2 BC0','SSG3 BC0');
    set(lg,'location','northwest')
    sq(1) = subplot(2,2,1);
    bar([1:length(layr)],...
        squeeze(RMS(layr,:,5,sfc)),...
        'barwidth',.5,'edgecolor','k');  %ylim([0,1]);
    hold(sq(1),'on'); sq(1).ColorOrderIndex = 1;
    bb2 = bar([1:length(layr)],...
        squeeze(RMS(layr,:,2,sfc)),...
        'barwidth',1,'edgecolor','k','facealpha',.3); %ylim([0,1]);
    set(gca,'position',[0.1170    0.5700    0.3392    0.3550]);
    set(gca,'xtick',[1:length(lay)]);%set(gca, 'ytick',[0:.2:1]);
    set(sq(1),'XTickLabel',xt); set(sq(1),'xaxislocation','top');
    set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
    yl = ylabel({'NADBC0';'NADLC1'}); set(yl,'rotation',90); 
%     set(yl,'position',[0.0715    0.5394]);
        tll = title(['Layer-resolved GVs for ',srfc{sfc}]);
%     if ~isavar('lg')
%         lg = legend('SSP0 BC0','SSP1 BC0','SSP2 BC0','SSG3 BC0','SSP0 LC1','SSP1 LC1','SSP2 LC1','SSG3 LC1');
%         set(lg,'position',[0.0081    0.89    0.0546    0.1048]);
%     end
sfc = 2;
        sq(4)= subplot(2,2,4);
    bb = bar([1:length(prof)],...
        squeeze(RMS(prof,:,5,sfc)),...
        'barwidth',.5,'edgecolor','k');     
    hold(sq(4),'on');  sq(4).ColorOrderIndex = 1; 
        bb2 = bar([1:length(prof)],...
        squeeze(RMS(prof,:,2,sfc)),...
        'barwidth',1,'edgecolor','k','facealpha',.3); liny;
    set(gca,'position',[0.4757    0.171    0.4763    0.3550]);
    set(gca,'xtick',[1:length(prof)]);%set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',prof_x); %set(sql(2),'xaxislocation','top');
    set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
    set(gca,'yaxislocation','right');
    tlr = title (['Profile-resolved GVs for ',srfc{sfc}]);
    sq(3) = subplot(2,2,3);
    bar([1:length(layr)],...
        squeeze(RMS(layr,:,5,sfc)),...
        'barwidth',.5,'edgecolor','k');  %ylim([0,1]);
    hold(sq(3),'on'); sq(3).ColorOrderIndex = 1;
    bb2 = bar([1:length(layr)],...
        squeeze(RMS(layr,:,2,sfc)),...
        'barwidth',1,'edgecolor','k','facealpha',.3); %ylim([0,1]);
    set(gca,'position',[0.117    .171    0.3392    0.3550]);
    set(gca,'xtick',[1:length(lay)]);%set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',layr_x);
    set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);;
    yl = ylabel({'NADBC0';'NADLC1'}); set(yl,'rotation',90); 
    tll = title(['Layer-resolved GVs for ',srfc{sfc}]);

    mt = mtit(['Group-mean RMS for NADBC0 (faint) and NADLC1 (bold): ',srfc{sfc}]);
    set(mt.th,'fontsize',15,'position',[0.5000    1.06]);
    ylim(sq(1),[0,.3]);ylim(sq(3),[0,.3]);ylim(sq(2),[0,250]);ylim(sq(4),[0,250]);    
    nn = 1; n_str = [num2str(nn)];
    png_out = ['RMSavg_NADB_NADL.png'];
    while isafile([ACCP_pngs,png_out])
        nn = nn+1; n_str = ['_',num2str(nn)];
        png_out = ['RMSavg_NADB_NADL.',n_str,'.png'];
    end
    saveas(gcf,[ACCP_pngs,png_out]);
    ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
    
    logy(sq);
    ylim(sq(1),[1e-2,1]);ylim(sq(3),[1e-2,1]);ylim(sq(2),[2e-2,1e3]);ylim(sq(4),[2e-2,1e3]);    
        nn = 1; n_str = [num2str(nn)];
    png_out = ['RMSavg_NADB_NADL.png'];
    while isafile([ACCP_pngs,png_out])
        nn = nn+1; n_str = ['_',num2str(nn)];
        png_out = ['RMSavg_NADB_NADL.',n_str,'.png'];
    end
    saveas(gcf,[ACCP_pngs,png_out]);
    ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
    
    
    %     set(cf,'visib',true);
    %     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
    close(gcf);
    clear sq
    
% And now LC0 vs LC1
sfc = 1   
    figure_(11009);
    clear lg sq tlr tll

%     OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0", "NADLC1","NANLC1","NADLC2","NANLC2"];
    %         1          2        3         4         5         6       7         8    
    % Row 1: NADBC0 = 2
    % over : NADLC1 = 5
    sq(2)= subplot(2,2,2);
    bb = bar([1:length(prof)],...
        squeeze(RMS(prof,:,5,sfc)),...
        'barwidth',.5,'edgecolor','k');     
    hold(sq(2),'on');  sq(2).ColorOrderIndex = 1; 
        bb2 = bar([1:length(prof)],...
        squeeze(RMS(prof,:,1,sfc)),...
        'barwidth',1,'edgecolor','k','facealpha',.3); liny;
    set(gca,'position',[0.4757    0.5700    0.4763    0.3550]);
    set(gca,'xtick',[1:length(prof)]);%set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',xtt); set(sq(2),'xaxislocation','top');
    set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
    set(gca,'yaxislocation','right');
    tlr = title (['Profile-resolved GVs for ',srfc{sfc}]);
    lg = legend('SSP0 LC1','SSP1 LC1','SSP2 LC1','SSG3 LC1','SSP0 LC0','SSP1 LC0','SSP2 LC0','SSG3 LC0');
    set(lg,'location','northwest')
    sq(1) = subplot(2,2,1);
    bar([1:length(layr)],...
        squeeze(RMS(layr,:,5,sfc)),...
        'barwidth',.5,'edgecolor','k');  %ylim([0,1]);
    hold(sq(1),'on'); sq(1).ColorOrderIndex = 1;
    bb2 = bar([1:length(layr)],...
        squeeze(RMS(layr,:,1,sfc)),...
        'barwidth',1,'edgecolor','k','facealpha',.3); %ylim([0,1]);
    set(gca,'position',[0.1170    0.5700    0.3392    0.3550]);
    set(gca,'xtick',[1:length(lay)]);%set(gca, 'ytick',[0:.2:1]);
    set(sq(1),'XTickLabel',xt); set(sq(1),'xaxislocation','top');
    set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
    yl = ylabel({'NADBC0';'NADLC1'}); set(yl,'rotation',90); 
%     set(yl,'position',[0.0715    0.5394]);
        tll = title(['Layer-resolved GVs for ',srfc{sfc}]);
%     if ~isavar('lg')
%         lg = legend('SSP0 BC0','SSP1 BC0','SSP2 BC0','SSG3 BC0','SSP0 LC1','SSP1 LC1','SSP2 LC1','SSG3 LC1');
%         set(lg,'position',[0.0081    0.89    0.0546    0.1048]);
%     end
sfc = 2;
        sq(4)= subplot(2,2,4);
    bb = bar([1:length(prof)],...
        squeeze(RMS(prof,:,5,sfc)),...
        'barwidth',.5,'edgecolor','k');     
    hold(sq(4),'on');  sq(4).ColorOrderIndex = 1; 
        bb2 = bar([1:length(prof)],...
        squeeze(RMS(prof,:,2,sfc)),...
        'barwidth',1,'edgecolor','k','facealpha',.3); liny;
    set(gca,'position',[0.4757    0.171    0.4763    0.3550]);
    set(gca,'xtick',[1:length(prof)]);%set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',prof_x); %set(sql(2),'xaxislocation','top');
    set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
    set(gca,'yaxislocation','right');
    tlr = title (['Profile-resolved GVs for ',srfc{sfc}]);
    sq(3) = subplot(2,2,3);
    bar([1:length(layr)],...
        squeeze(RMS(layr,:,5,sfc)),...
        'barwidth',.5,'edgecolor','k');  %ylim([0,1]);
    hold(sq(3),'on'); sq(3).ColorOrderIndex = 1;
    bb2 = bar([1:length(layr)],...
        squeeze(RMS(layr,:,2,sfc)),...
        'barwidth',1,'edgecolor','k','facealpha',.3); %ylim([0,1]);
    set(gca,'position',[0.117    .171    0.3392    0.3550]);
    set(gca,'xtick',[1:length(lay)]);%set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',layr_x);
    set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);;
    yl = ylabel({'NADBC0';'NADLC1'}); set(yl,'rotation',90); 
    tll = title(['Layer-resolved GVs for ',srfc{sfc}]);

    mt = mtit(['Group-mean RMS for NADLC0 (faint) and NADLC1 (bold): ',srfc{sfc}]);
    set(mt.th,'fontsize',15,'position',[0.5000    1.06]);
    ylim(sq(1),[0,.3]);ylim(sq(3),[0,.3]);ylim(sq(2),[0,250]);ylim(sq(4),[0,250]);    
    nn = 1; n_str = [num2str(nn)];
    png_out = ['RMSavg_NADB_NADL.png'];
    while isafile([ACCP_pngs,png_out])
        nn = nn+1; n_str = ['_',num2str(nn)];
        png_out = ['RMSavg_NADB_NADL.',n_str,'.png'];
    end
    saveas(gcf,[ACCP_pngs,png_out]);
    ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
    
    logy(sq);
    ylim(sq(1),[1e-2,1]);ylim(sq(3),[1e-2,1]);ylim(sq(2),[2e-2,1e3]);ylim(sq(4),[2e-2,1e3]);    
        nn = 1; n_str = [num2str(nn)];
    png_out = ['RMSavg_NADB_NADL.png'];
    while isafile([ACCP_pngs,png_out])
        nn = nn+1; n_str = ['_',num2str(nn)];
        png_out = ['RMSavg_NADB_NADL.',n_str,'.png'];
    end
    saveas(gcf,[ACCP_pngs,png_out]);
    ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
    
    
    %     set(cf,'visib',true);
    %     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
    close(gcf);
    clear sq
    

% clear xt xtt
% for xx = length(lay):-1:1
%     xt(xx) = {num2str(gv(lay(xx)))};
% end
% xt_ = xt;
% xt(2:2:end) = {" "};
% xtx= xt;
% xtx(3)= {"AAOD Vis Col"};xtx(12)= {"AEFRF PBL"}; xtx(19) = {"AODF Vis Col"};
% xtx(23) = {"AOD UV Col"}; xtx(25) = {"AOD Vis Col"}; xtx(32) = {"ARIR Vis Col"};
% 
% for xx = length(prf):-1:1
%     xtt(xx) = {num2str(gv(prf(xx)))};
% end
% xtt_ = xtt;
% xtt(2:2:end) = {" "};
% xttx = xtt;
% xttx(42-41) = {"AABS UV above pbl"};xttx(44-41) = {"AABS VIS above pbl)"};
% xttx(50-41) = {"AEXT UV above pbl"};xttx(51-41) = {"AEXT UV in pbl"};
% xttx(52-41) = {"AEXT Vis above pbl"};xttx(53-41) = {"AEXT Vis in pbl"};
% xttx(58-41) = {"AE2BR Vis above pbl"};xttx(64-41) = {"ANC above pbl"};



% for sfc = 1:length(srfc)
% % OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0","NADLC1","NANLC1","NADLC2","NANLC2"];
% figure_(10010+sfc); % profile-resolved, NAD
% clear sq
% sq(1)= subplot(2,1,1);
% bar([1:length(prf)],...
%         (squeeze(RMS(prf,:,5,sfc))+NADLC0adj(prf,:) + ...
%         squeeze(RMS(prf,:,2,sfc))+NADBC0adj(prf,:))/2,...
%     'barwidth',.5,'edgecolor','none'); ylim([0,1]);
%  hold(sq(1),'on');  sq(1).ColorOrderIndex = 1; 
% bar([1:length(prf)],...
%         (squeeze(RMS(prf,:,1,sfc))+NADLC0adj(prf,:) + ...
%         squeeze(RMS(prf,:,2,sfc))+NADBC0adj(prf,:))/2,...
%         'barwidth',1,'edgecolor','none','facealpha',.3); ylim([0,1]);
% set(gca,'position',[0.0808    0.5508    0.865    0.38]);
% set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
% set(gca,'XTickLabel',xtt); set(sq(1),'xaxislocation','top');
% set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
% title (['Profile-resolved GVs, NAD, NAN: ', srfc{sfc}]);
% yl = ylabel({'(NADBC0+NADLC1)/2+adj';'(NADBC0+NADLC0)/2 + adj'}); set(yl,'rotation',90); 
% set(yl,'position',[-0.4669    0.4355]);
% 
% lg = legend('SSP0','SSP1','SSP2','SSG3'); set(lg,'position',[0.0081    0.89    0.0546    0.1048]);
% 
% sq(2)= subplot(2,1,2);
% bar([1:length(prf)],...
%         (squeeze(RMS(prf,:,3,sfc))+ squeeze(RMS(prf,:,6,sfc)))./2+NANLC0adj(prf,:),...
%     'barwidth',.5,'edgecolor','none'); ylim([0,1]);
%  hold(sq(2),'on');  sq(2).ColorOrderIndex = 1; 
%  bar([1:length(prf)],...
%         (squeeze(RMS(prf,:,3,sfc))+NANLC0adj(prf,:)),...
%         'barwidth',1,'edgecolor','none','facealpha',.3); ylim([0,1]);
% set(gca,'position',[0.0780    0.1214    0.865    0.38]);
% set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
% set(gca,'XTickLabel',xttx);
% set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
% set(sq(2),'yaxislocation','left');
% yl = ylabel({'NANLC0 + adj';'(NANLC0+NANLC1)/2+adj'}); set(yl,'rotation',90);
% set(yl,'position',[-0.4669    0.4355]);
% 
% nn = 1; n_str = [num2str(nn)];
% png_out = ['Qprf_adj_NAD_Co_C1.',srfc{sfc},n_str,'.png'];
% while isafile([ACCP_pngs,png_out])
%     nn = nn+1; n_str = ['_',num2str(nn)];
% png_out = ['Qprf_adj_NAD_Co_C1.',srfc{sfc},n_str,'.png'];
% end
% saveas(gcf,[ACCP_pngs,png_out]);
% %     set(cf,'visib',true);
% %     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
% close(gcf);
% clear sq
% ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
% 
% figure_(10020+sfc); % layer-resolved, NAD
% clear sq
% sq(1)= subplot(2,1,1);
% bar([1:length(lay)],...
%         (squeeze(RMS(lay,:,5,sfc))+NADLC0adj(lay,:) + ...
%         squeeze(RMS(lay,:,2,sfc))+NADBC0adj(lay,:))/2,...
%     'barwidth',.5,'edgecolor','none'); ylim([0,1]);
%  hold(sq(1),'on');  sq(1).ColorOrderIndex = 1; 
% bar([1:length(lay)],...
%         (squeeze(RMS(lay,:,1,sfc))+NADLC0adj(lay,:) + ...
%         squeeze(RMS(lay,:,2,sfc))+NADBC0adj(lay,:))/2,...
%         'barwidth',1,'edgecolor','none','facealpha',.3); ylim([0,1]);
% set(gca,'position',[0.0808    0.5508    0.865    0.38]);
% set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
% set(gca,'XTickLabel',xtt); set(sq(1),'xaxislocation','top');
% set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
% title (['Layer-resolved GVs, NAD, NAN: ', srfc{sfc}]);
% yl = ylabel({'(NADBC0+NADLC1)/2+adj';'(NADBC0+NADLC0)/2 + adj'}); set(yl,'rotation',90); 
% set(yl,'position',[-0.4669    0.4355]);
% 
% lg = legend('SSP0','SSP1','SSP2','SSG3'); set(lg,'position',[0.0081    0.89    0.0546    0.1048]);
% 
% sq(2)= subplot(2,1,2);
% bar([1:length(lay)],...
%         (squeeze(RMS(lay,:,3,sfc))+ squeeze(RMS(lay,:,6,sfc)))./2+NANLC0adj(lay,:),...
%     'barwidth',.5,'edgecolor','none'); ylim([0,1]);
%  hold(sq(2),'on');  sq(2).ColorOrderIndex = 1; 
%  bar([1:length(lay)],...
%         (squeeze(RMS(lay,:,3,sfc))+NANLC0adj(lay,:)),...
%         'barwidth',1,'edgecolor','none','facealpha',.3); ylim([0,1]);
% set(gca,'position',[0.0780    0.1214    0.865    0.38]);
% set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
% set(gca,'XTickLabel',xttx);
% set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
% set(sq(2),'yaxislocation','left');
% yl = ylabel({'NANLC0 + adj';'(NANLC0+NANLC1)/2+adj'}); set(yl,'rotation',90);
% set(yl,'position',[-0.4669    0.4355]);
% 
% nn = 1; n_str = [num2str(nn)];
% png_out = ['Qlay_adj_NAD_Co_C1.',srfc{sfc},n_str,'.png'];
% while isafile([ACCP_pngs,png_out])
%     nn = nn+1; n_str = ['_',num2str(nn)];
% png_out = ['Qlay_adj_NAD_Co_C1.',srfc{sfc},n_str,'.png'];
% end
% saveas(gcf,[ACCP_pngs,png_out]);
% %     set(cf,'visib',true);
% %     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
% close(gcf);
% clear sq
% ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
% 
% 
% %end layr
% end

return
