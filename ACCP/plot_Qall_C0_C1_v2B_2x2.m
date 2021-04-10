function plot_Qall_C0_C1_v2B_2x2(Qall,pptname)
% Qall = plot_Qall_C0_C1_v2B_4x2(Qall,pptname)
% Intended to detail differences between C0 and C1 retrievals and effect on
% NAD, NAN scenes with adjustments but without Obj weighting
% Accepts Qall and pptname to produce multiple plots
% % Qall(gv,plt,obi,sfc),
%v2A: 
% #1: 2x2 plot Land, NADLC and NANLC with MIP layer-resolved and profile-resolved columns 
% and row with NAD_C0_adj = (NADBC0_adj + NADLC0_adj)/2
%              NAD_C0_C1_adj = (NADBC0_adj,NADLC1_adj)/2
% #2: 2x2 
%              NAN_C0_adj = NANLC0_adj
%              NAN_C0_C1_adj = (NANLC0_adj + NANLC1_adj)/2
%
% #3: 2x2 plot OCEN, NADLC and NANLC with MIP layer-resolved and profile-resolved columns 
% and row with NAD_C0_adj = (NADBC0_adj + NADLC0_adj)/2
%              NAD_C0_C1_adj = (NADBC0_adj,NADLC1_adj)/2
% #4 2x2
%              NAN_C0_adj = NANLC0_adj
%              NAN_C0_C1_adj = (NANLC0_adj + NANLC1_adj)/2

% All layer-resolved
% Land
% #3: 3x1 plot for NADL with all layer-resolved GVs
% and row with NADLC0, NADLC0+adj,NADLC1+adj
% #4: 3x1 ploty for NAN with all layer-resolved GVs
% #5: 
% #6: 
% but rows with NANLC0, NANLC0+adj, NANLC1+adj
% OCEN
% #7: 3x1 plot for NADL with all layer-resolved GVs
% and row with NADLC0, NADLC0+adj,NADLC1+adj
% #8: 3x1 ploty for NAN with all layer-resolved GVs
% but rows with NANLC0, NANLC0+adj, NANLC1+adj

% All profile-resolved
% Land
% #9: 3x1 plot for NADL with all profile-resolved GVs
% and row with NADLC0, NADLC0+adj,NADLC1+adj
% #10: 3x1 ploty for NAN with all profile-resolved GVs
% but rows with NANLC0, NANLC0+adj, NANLC1+adj
% OCEN
% #11: 3x1 plot for NADL with all profile-resolved GVs
% and row with NADLC0, NADLC0+adj,NADLC1+adj
% #12: 3x1 ploty for NAN with all profile-resolved GVs
% but rows with NANLC0, NANLC0+adj, NANLC1+adj



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

mean_adj = SITA_Sept_adj;
NADLC0adj = mean_adj(:,1:4); 
NADBC0adj = mean_adj(:,5:8);
NANLC0adj = mean_adj(:,9:12);

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

for sfc = 1:length(srfc)
    % First a 2x2 plot with cols: Layer-resolved and Profile
    % rows NAxLC0, NAxLC0 adj, NAxC1 adj
    % For both Land and Ocen
    
    figure_(11000+sfc);
    % Row 1: NADxC0_adj = (NADLC0_adj + NADBC0_adj)/2
    sq(2)= subplot(2,2,2);
    bar([1:length(prof)],...
        (squeeze(Qall(prof,:,1,sfc))+NADLC0adj(prof,:) + ...
        squeeze(Qall(prof,:,2,sfc))+NADBC0adj(prof,:))/2,...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
    set(gca,'position',[0.547    0.57    0.405    0.355]);
    set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
    set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
    set(gca,'yaxislocation','right');
    title ('Profile-resolved GVs');
    
    sq(1) = subplot(2,2,1);
    bar([1:length(layr)],...
        (squeeze(Qall(layr,:,1,sfc))+NADLC0adj(layr,:) + ...
        squeeze(Qall(layr,:,2,sfc))+NADBC0adj(layr,:))/2,...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
    set(gca,'position',[0.117    0.57    0.405    0.355]);
    set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
    set(sq(1),'XTickLabel',xt);% set(sq(1),'xaxislocation','top');
    set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
    yl = ylabel('(NADBC0+NADLC0)/2 + adj'); set(yl,'rotation',90); 
    set(yl,'position',[-0.0148    0.5394]);
    title('Layer-resolved GVs');
    lg = legend('SSP0','SSP1','SSP2','SSG3'); 
    set(lg,'position',[0.0081    0.89    0.0546    0.1048]);
    
    % Row 2: NADxC1_adj = (NADLC1_adj + NADBC0_adj)/1
    sq(4)= subplot(2,2,4);
    bar([1:length(prof)],...
        (squeeze(Qall(prof,:,5,sfc))+NADLC0adj(prof,:) + ...
        squeeze(Qall(prof,:,2,sfc))+NADBC0adj(prof,:))/2,...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
    set(gca,'position',[0.547    0.171    0.405    0.355]);
    set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',prof_x);
    set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
    set(gca,'yaxislocation','right');
    
    sq(3) = subplot(2,2,3);
    bar([1:length(layr)],...
        (squeeze(Qall(layr,:,5,sfc))+NADLC0adj(layr,:) + ...
        squeeze(Qall(layr,:,2,sfc))+NADBC0adj(layr,:))/2,...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
    set(gca,'position',[0.117    .171    0.405    0.355]);
        set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',layr_x);
    set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
    
    yl = ylabel('NADBC0+NADLC1)/2 + adj'); set(yl,'rotation',90); 
    set(yl,'position',[-0.0148    0.5394]);
    
    ylim(sq,[0,1]);
    mt = mtit(['Mean Quality Scores, NAD with LC0, LC1: ',srfc{sfc}]);
    set(mt.th,'fontsize',15,'position',[0.5000    1.045]);
        
    nn = 1; n_str = [num2str(nn)];
    png_out = ['Q_mip_adj_NAD_Co_C1.',srfc{sfc},n_str,'.png'];
    while isafile([ACCP_pngs,png_out])
        nn = nn+1; n_str = ['_',num2str(nn)];
        png_out = ['Q_mip_adj_NAD_Co_C1.',srfc{sfc},n_str,'.png'];
    end
    saveas(gcf,[ACCP_pngs,png_out]);
    %     set(cf,'visib',true);
    %     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
    close(gcf);
    clear sq
    ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
% 
      figure_(12000+sfc);
    % Row 1: NANxC0_adj = NANLC0_adj
    sq(2)= subplot(2,2,2);
    bar([1:length(prof)],...
        squeeze(Qall(prof,:,3,sfc))+NANLC0adj(prof,:),...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
    set(gca,'position',[0.547    0.57    0.405    0.355]);
    set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',xtt)
    set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
    set(gca,'yaxislocation','right');
    title ('Profile-resolved GVs');
    sq(1) = subplot(2,2,1);
    bar([1:length(layr)],...
        squeeze(Qall(layr,:,3,sfc))+NANLC0adj(layr,:),...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
    set(gca,'position',[0.117    0.57    0.405    0.355]);
    set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',xt);%set(sq(3),'XTickLabel',[])
    set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
    yl = ylabel('NANLC0 Adj'); set(yl,'rotation',90); 
    set(yl,'position',[-0.0148    0.5394]);
    title('Layer-resolved GVs');
    lg = legend('SSP0','SSP1','SSP2','SSG3'); 
    set(lg,'position',[0.0081    0.89    0.0546    0.1048]);
    % Row 4: NANLC0_C1_adj = (NANLC0_adj +NANLC1_adj)/2
    sq(4)= subplot(2,2,4);
    bar([1:length(prof)],...
        (squeeze(Qall(prof,:,3,sfc))+squeeze(Qall(prof,:,6,sfc)))/2+NANLC0adj(prof,:),...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);

     set(gca,'position',[0.547    0.171    0.405    0.355]);
    set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',prof_x);
    set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
    set(gca,'yaxislocation','right');
    
    sq(3) = subplot(2,2,3);
    bar([1:length(layr)],...
         (squeeze(Qall(layr,:,3,sfc))+squeeze(Qall(layr,:,6,sfc)))/2+NANLC0adj(layr,:),...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
    set(gca,'position',[0.117    .171    0.405    0.355]);;
    set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
    set(gca,'XTickLabel',layr_x);
    set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
    yl = ylabel('(NANLC0 + NANLC1)/2 + Adj'); set(yl,'rotation',90); 
    set(yl,'position',[-0.0148    0.5394]);
    
    ylim(sq,[0,1]);
    mt = mtit(['Mean Quality Scores, NAN with LC0, LC1: ',srfc{sfc}]);
    set(mt.th,'fontsize',15,'position',[0.5000    1.0500]);
        
    nn = 1; n_str = [num2str(nn)];
    png_out = ['Q_mip_adj_NAN_Co_C1.',srfc{sfc},n_str,'.png'];
    while isafile([ACCP_pngs,png_out])
        nn = nn+1; n_str = ['_',num2str(nn)];
        png_out = ['Q_mip_adj_NAN_Co_C1.',srfc{sfc},n_str,'.png'];
    end
    saveas(gcf,[ACCP_pngs,png_out]);
    %     set(cf,'visib',true);
    %     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
    close(gcf);
    clear sq
    ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);
    
    % 
    % We did NAD and NAN above for Most-important GVs.  
    % Now do for all, but divide into separate plots for layer and profile
end

clear xt xtt
for xx = length(lay):-1:1
    xt(xx) = {num2str(gv(lay(xx)))};
end
xt_ = xt;
xt(2:2:end) = {" "};
xtx= xt;
xtx(3)= {"AAOD Vis Col"};xtx(12)= {"AEFRF PBL"}; xtx(19) = {"AODF Vis Col"};
xtx(23) = {"AOD UV Col"}; xtx(25) = {"AOD Vis Col"}; xtx(32) = {"ARIR Vis Col"};

for xx = length(prf):-1:1
    xtt(xx) = {num2str(gv(prf(xx)))};
end
xtt_ = xtt;
xtt(2:2:end) = {" "};
xttx = xtt;
xttx(42-41) = {"AABS UV above pbl"};xttx(44-41) = {"AABS VIS above pbl)"};
xttx(50-41) = {"AEXT UV above pbl"};xttx(51-41) = {"AEXT UV in pbl"};
xttx(52-41) = {"AEXT Vis above pbl"};xttx(53-41) = {"AEXT Vis in pbl"};
xttx(58-41) = {"AE2BR Vis above pbl"};xttx(64-41) = {"ANC above pbl"};



for sfc = 1:length(srfc)
% OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0","NADLC1","NANLC1","NADLC2","NANLC2"];
figure_(10010+sfc); % profile-resolved, NAD
clear sq
sq(1)= subplot(2,1,1);
bar([1:length(prf)],...
        (squeeze(Qall(prf,:,1,sfc))+NADLC0adj(prf,:) + ...
        squeeze(Qall(prf,:,2,sfc))+NADBC0adj(prf,:))/2,...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.0808    0.5508    0.865    0.38]);
set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xtt); set(sq(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
title (['Profile-resolved GVs, NAD: ', srfc{sfc}]);
yl = ylabel('(NADBC0+NADLC0)/2 + adj'); set(yl,'rotation',90); 
set(yl,'position',[-0.4669    0.4355]);

lg = legend('SSP0','SSP1','SSP2','SSG3'); set(lg,'position',[0.0081    0.89    0.0546    0.1048]);

sq(2)= subplot(2,1,2);
bar([1:length(prf)],...
        (squeeze(Qall(prf,:,5,sfc))+NADLC0adj(prf,:) + ...
        squeeze(Qall(prf,:,2,sfc))+NADBC0adj(prf,:))/2,...
    'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.0780    0.1214    0.865    0.38]);
set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xttx);
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','left');
yl = ylabel('(NADBC0+NADLC1)/2+adj'); set(yl,'rotation',90); 
set(yl,'position',[-0.4669    0.4355]);

nn = 1; n_str = [num2str(nn)];
png_out = ['Qprf_adj_NAD_Co_C1.',srfc{sfc},n_str,'.png'];
while isafile([ACCP_pngs,png_out])
    nn = nn+1; n_str = ['_',num2str(nn)];
png_out = ['Qprf_adj_NAD_Co_C1.',srfc{sfc},n_str,'.png'];
end
saveas(gcf,[ACCP_pngs,png_out]);
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
close(gcf);
clear sq
ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);

figure_(10020+sfc); % layer-resolved, NAD
clear sq
sq(1)= subplot(2,1,1);
bar([1:length(lay)],...
        (squeeze(Qall(lay,:,1,sfc))+NADLC0adj(lay,:) + ...
        squeeze(Qall(lay,:,2,sfc))+NADBC0adj(lay,:))/2,...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.0808    0.5508    0.865    0.38]);
set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xt); set(sq(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
title (['Layer-resolved GVs, NAD: ', srfc{sfc}]);
yl = ylabel('(NADBC0+NADLC0)/2 + adj'); set(yl,'rotation',90); 
set(yl,'position',[-0.4669    0.4355]);

lg = legend('SSP0','SSP1','SSP2','SSG3'); set(lg,'position',[0.0081    0.89    0.0546    0.1048]);

sq(2)= subplot(2,1,2);
bar([1:length(lay)],...
        (squeeze(Qall(lay,:,5,sfc))+NADLC0adj(lay,:) + ...
        squeeze(Qall(lay,:,2,sfc))+NADBC0adj(lay,:))/2,...
    'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.0780    0.1214    0.865    0.38]);
set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xtx);
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','left');
yl = ylabel('(NADBC0+NADLC1)/2+adj'); set(yl,'rotation',90); 
set(yl,'position',[-0.4669    0.4355]);

nn = 1; n_str = [num2str(nn)];
png_out = ['Qlay_adj_NAD_Co_C1.',srfc{sfc},n_str,'.png'];
while isafile([ACCP_pngs,png_out])
    nn = nn+1; n_str = ['_',num2str(nn)];
png_out = ['Qlay_adj_NAD_Co_C1.',srfc{sfc},n_str,'.png'];
end
saveas(gcf,[ACCP_pngs,png_out]);
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
close(gcf);
clear sq
ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);

figure_(10030+sfc); % profile-resolved, NAN
clear sq
sq(1)= subplot(2,1,1);
bar([1:length(prf)],...
        (squeeze(Qall(prf,:,3,sfc))+NANLC0adj(prf,:)),...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.0808    0.5508    0.865    0.38]);
set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xtt); set(sq(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
title (['Profile-resolved GVs, NAN: ', srfc{sfc}]);
yl = ylabel('NANLC0 + adj'); set(yl,'rotation',90); 
set(yl,'position',[-0.4669    0.4355]);

lg = legend('SSP0','SSP1','SSP2','SSG3'); set(lg,'position',[0.0081    0.89    0.0546    0.1048]);

% NANLC0(3) + NANLC1(6)
sq(2)= subplot(2,1,2);
bar([1:length(prf)],...
        (squeeze(Qall(prf,:,3,sfc))+ squeeze(Qall(prf,:,6,sfc)))./2+NANLC0adj(prf,:),...
    'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.0780    0.1214    0.865    0.38]);
set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xttx);
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','left');
yl = ylabel('(NANLC0+NANLC1)/2+adj'); set(yl,'rotation',90); 
set(yl,'position',[-0.4669    0.4355]);

nn = 1; n_str = [num2str(nn)];
png_out = ['Qprf_adj_NAN_Co_C1.',srfc{sfc},n_str,'.png'];
while isafile([ACCP_pngs,png_out])
    nn = nn+1; n_str = ['_',num2str(nn)];
png_out = ['Qprf_adj_NAN_Co_C1.',srfc{sfc},n_str,'.png'];
end
saveas(gcf,[ACCP_pngs,png_out]);
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
close(gcf);
clear sq
ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);

figure_(10040+sfc); % layer-resolved, NAN
clear sq
sq(1)= subplot(2,1,1);
bar([1:length(lay)],...
        (squeeze(Qall(lay,:,3,sfc))+NANLC0adj(lay,:)),...
        'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.0808    0.5508    0.865    0.38]);
set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xt); set(sq(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
title (['Layer-resolved GVs, NAN: ', srfc{sfc}]);
yl = ylabel('NANLC0 + adj'); set(yl,'rotation',90); 
set(yl,'position',[-0.4669    0.4355]);

lg = legend('SSP0','SSP1','SSP2','SSG3'); set(lg,'position',[0.0081    0.89    0.0546    0.1048]);

sq(2)= subplot(2,1,2);
bar([1:length(lay)],...
        (squeeze(Qall(lay,:,3,sfc))+ squeeze(Qall(lay,:,6,sfc)))./2+NANLC0adj(lay,:),...
    'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.0780    0.1214    0.865    0.38]);
set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xtx);
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','left');
yl = ylabel('(NANLC0+NANLC1)/2+adj'); set(yl,'rotation',90); 
set(yl,'position',[-0.4669    0.4355]);

nn = 1; n_str = [num2str(nn)];
png_out = ['Qlay_adj_NAN_Co_C1.',srfc{sfc},n_str,'.png'];
while isafile([ACCP_pngs,png_out])
    nn = nn+1; n_str = ['_',num2str(nn)];
png_out = ['Qlay_adj_NAN_Co_C1.',srfc{sfc},n_str,'.png'];
end
saveas(gcf,[ACCP_pngs,png_out]);
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
close(gcf);
clear sq
ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);



%end layr
end

return
