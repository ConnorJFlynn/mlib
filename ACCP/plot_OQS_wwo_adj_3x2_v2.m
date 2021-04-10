function plot_OQS_ww0_adj_3x2_v2(OQSadj, OQS)
% plot_OQS_ww0_adj_3x2_v2(OQSadj, OQS)
% Jens request for overlay over objective weights wi/o adjustments. Only
% for O6?
% Plots NAN, NAN for layer and prof GVs  
% v2: quick plots after "final" reviewer adjustments before sending to VF
if ~isavar('OQSadj')
    OQSadj = load(getfullname([getnamedpath(),'SITA_OQS_*.mat']));
end
% OQS(gv,pfm,obi,sfc,obj(4))
ACCP_pngs = getnamedpath('ACCP_pngs');
% Now, just the principle GVs

[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';
gv = [1:length(GVnames)];
lay = find(gv<42); prf = find(gv>41);
lay(21:22) = []; %Exclude GV21,22
prf(21:22) = []; % Exclude GV62,63
layr = [3,12,19,23,25,32];
prof = [42,44,50,51,52,53,58,64];

clear xt xtt
for xx = length(layr):-1:1
    xt(xx) = {num2str(layr(xx))};
end
for xx = length(prof):-1:1
    xtt(xx) = {num2str(prof(xx))};
end

layr_x = ["AAOD Vis Col","AEFRF PBL","AODF Vis Col","AOD UV Col","AOD Vis Col","ARIR Vis Col"];
prof_x= {"AABS UV above pbl","AABS VIS above pbl","AEXT UV above pbl",...
    "AEXT UV in pbl","AEXT Vis above pbl","AEXT Vis in pbl",...
    "AE2BR Vis above pbl","ANC above pbl"};
% OQSadj(gv,pfm,obi,sfc,obj(4))

% First, for profile GVs
SFC = {'Land', 'Ocean'};
nudge = [0,.02,0,0];
% OQS(gv,pfm,[NAD,NAN,OND],sfc,obj(4))
for srfc = 1:2 % Land, Ocen
figure_(srfc); 

sq(1) = subplot(3,2,1); hold('off');% for NAD Layr
bb = bar([1:length(layr)],squeeze(OQSadj(layr,:,1,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-.15,1]);
hold('on');sq(1).ColorOrderIndex = 1;
bar([1:length(layr)],squeeze(OQSadj(layr,:,1,srfc,2))-squeeze(OQS(layr,:,1,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-.1,1]);
set(gca,'position',[0.0669    0.6885    0.3753    0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
% yl2 = ylabel('NAD');set(yl2,'rotation',0,'position',[0,.45]);
yl2 = ylabel({'NAD =';'(NADLC1+NADBC0)/2'});
title ('Layer-resolved GVs  [thin bars for adjustments]');

sq(2) = subplot(3,2,2); hold('off');%for NAD Prof
bar([1:length(prof)],squeeze(OQSadj(prof,:,1,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-.1,1]);
hold('on');sq(2).ColorOrderIndex = 1; 
lg = legend('SSP0','SSP1','SSP2','SSG3','location','northwest');
bar([1:length(prof)],squeeze(OQSadj(prof,:,1,srfc,2))-squeeze(OQS(prof,:,1,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-.1,1]);

set(gca,'position',[0.4558    0.6885    0.4792   0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
yl1 = ylabel({'NAD =';'(NADLC1+NADBC0)/2'});
% yl1 = ylabel('NAD');set(yl1,'rotation',0,'position',[8.9862    0.54]);
title ('Profile-resolved GVs  [thin bars for adjustments]');

sq(3) = subplot(3,2,3); hold('off');% for NAN Layr
bar([1:length(layr)],squeeze(OQSadj(layr,:,2,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-0.1,1]);
hold('on');sq(3).ColorOrderIndex = 1;
bar([1:length(layr)],squeeze(OQSadj(layr,:,2,srfc,2))-squeeze(OQS(layr,:,2,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-0.1,1]);
set(gca,'position',[0.0669    0.421    0.3753    0.2365]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel({'NAN =';'(NANLC0+NANLC1)/2'});
% yl2 = ylabel('NAN');set(yl2,'rotation',0,'position',[0 0.45 ]);
% set(gca,'position',get(gca,'position')+nudge);

sq(4) = subplot(3,2,4); hold('off');%for NAN Prof
bar([1:length(prof)],squeeze(OQSadj(prof,:,2,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-0.1,1]);
hold('on');sq(4).ColorOrderIndex = 1;
bar([1:length(prof)],squeeze(OQSadj(prof,:,2,srfc,2))-squeeze(OQS(prof,:,2,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-0.1,1]);
set(gca,'position',[0.4558    0.421    0.4792   0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(4),'yaxislocation','right');
yl1 = ylabel({'NAN =';'(NANLC0+NANLC1)/2'});;
% yl1 = ylabel('NAN');set(yl1,'rotation',0,'position',[8.9862    0.54]);
% set(gca,'position',get(gca,'position')+nudge);

sq(5) = subplot(3,2,5); hold('off');% for OND Layr
bar([1:length(layr)],squeeze(OQSadj(layr,:,3,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-0.1,1]);
hold('on');sq(5).ColorOrderIndex = 1;
bar([1:length(layr)],squeeze(OQSadj(layr,:,3,srfc,2))-squeeze(OQS(layr,:,3,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-0.1,1]);
set(gca,'position',[0.0669    0.1300    0.3753    0.2365]);
% set(gca,'position',[0.1300    0.1100    0.3347    0.2157]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',layr_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl2 = ylabel('OND = ONDPC0');
% set(yl2,'rotation',0);set(yl2,'position',[0    0.45]);
set(gca,'position',get(gca,'position')+nudge);

sq(6) = subplot(3,2,6); hold('off');%for OND Prof
bar([1:length(prof)],squeeze(OQSadj(prof,:,3,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-0.1,1]);
hold('on');sq(6).ColorOrderIndex = 1;
bar([1:length(prof)],squeeze(OQSadj(prof,:,3,srfc,2))-squeeze(OQS(prof,:,3,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-0.1,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'position',[0.4558     0.1300     0.4792    0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',prof_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');
yl1 = ylabel('OND = ONDPC0');
% set(yl1,'rotation',0); set(yl1,'position',[8.987    0.55]);
set(gca,'position',get(gca,'position')+nudge);

ylim(sq,[-.15,1]);
mt = mtit(['Objective Weighted Scores: ',SFC{srfc}]);
set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
n_str = '';n = 1;
fname = [ACCP_pngs,'OQS_and_adj_',SFC{srfc},'.png'];
while isafile(fname)
    n = n+1; n_str = ['.',num2str(n)];
    fname = [ACCP_pngs,'OQS_and_adj_',SFC{srfc},n_str,'.png'];
end
saveas(gcf,fname);
pause(2)
close(gcf);
    %OQSadj_Layer_Ocean.png
end

% Now with transparency...
for srfc = 1:2 % Land, Ocen
    clear sq
figure_(srfc); 

sq(1) = subplot(3,2,1); hold('off');% for NAD Layr
bar([1:length(layr)],squeeze(OQSadj(layr,:,1,srfc,2)),'barwidth',.5,'edgecolor','k'); ylim([0,1]);
hold('on');sq(1).ColorOrderIndex = 1;
bar([1:length(layr)],squeeze(OQS(layr,:,1,srfc,2)),'barwidth',1,'edgecolor','none','facealpha',.4); 
ylim([0,1]);
set(gca,'position',[0.0669    0.6885    0.3753    0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel({'NAD =';'(NADLC1+NADBC0)/2'});
% yl2 = ylabel('NAD');set(yl2,'rotation',0,'position',[0,.45]);
title ('Layer-resolved GVs  [faint bars for unadjusted scores]');

sq(2) = subplot(3,2,2); hold('off');%for NAD Prof
bar([1:length(prof)],squeeze(OQSadj(prof,:,1,srfc,2)),'barwidth',.5,'edgecolor','k'); ylim([0,1]);
lg = legend('SSP0','SSP1','SSP2','SSG3','location','northwest');
hold('on');sq(2).ColorOrderIndex = 1;
bar([1:length(prof)],squeeze(OQS(prof,:,1,srfc,2)),'barwidth',1,'edgecolor','none','facealpha',.4); 
ylim([0,1]);
set(gca,'position',[0.4558    0.6885    0.4792   0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
yl1 = ylabel({'NAD =';'(NADLC1+NADBC0)/2'});
% yl1 = ylabel('NAD');set(yl1,'rotation',0,'position',[8.9862    0.54]);
title ('Profile-resolved GVs  [faint bars for unadjusted scores]');

sq(3) = subplot(3,2,3); hold('off');% for NAN Layr
bar([1:length(layr)],squeeze(OQSadj(layr,:,2,srfc,2)),'barwidth',.5,'edgecolor','k'); ylim([0,1]);
hold('on');sq(3).ColorOrderIndex = 1;
bar([1:length(layr)],squeeze(OQS(layr,:,2,srfc,2)),'barwidth',1,'edgecolor','none','facealpha',.4); ylim([0,1]);
set(gca,'position',[0.0669     0.421    0.3753   0.2365]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel({'NAN =';'(NANLC0+NANLC1)/2'});
% yl2 = ylabel('NAN');set(yl2,'rotation',0,'position',[0 0.45 ]);
% set(gca,'position',get(gca,'position')+nudge);

sq(4) = subplot(3,2,4); hold('off');%for NAN Prof
bar([1:length(prof)],squeeze(OQSadj(prof,:,2,srfc,2)),'barwidth',.5,'edgecolor','k'); ylim([0,1]);
hold('on');sq(4).ColorOrderIndex = 1;
bar([1:length(prof)],squeeze(OQS(prof,:,2,srfc,2)),'barwidth',1,'edgecolor','none','facealpha',.4); ylim([0,1]);
set(gca,'position',[0.4558    0.421    0.4792   0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(4),'yaxislocation','right');
yl2 = ylabel({'NAN =';'(NANLC0+NANLC1)/2'});
% yl1 = ylabel('NAN');set(yl1,'rotation',0,'position',[8.9862    0.54]);
% set(gca,'position',get(gca,'position')+nudge);

sq(5) = subplot(3,2,5); hold('off');% for OND Layr
bar([1:length(layr)],squeeze(OQSadj(layr,:,3,srfc,2)),'barwidth',.5,'edgecolor','k'); ylim([0,1]);
hold('on');sq(5).ColorOrderIndex = 1;
bar([1:length(layr)],squeeze(OQS(layr,:,3,srfc,2)),'barwidth',1,'edgecolor','none','facealpha',.4); ylim([0,1]);
set(gca,'position',[0.0669    0.1300    0.3753    0.2365]);
% set(gca,'position',[0.1300    0.1100    0.3347    0.2157]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',layr_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl1 = ylabel('OND = ONDPC0');
% yl2 = ylabel('OND');set(yl2,'rotation',0);set(yl2,'position',[0    0.45]);
set(gca,'position',get(gca,'position')+nudge);

sq(6) = subplot(3,2,6); hold('off');%for OND Prof
bar([1:length(prof)],squeeze(OQSadj(prof,:,3,srfc,2)),'barwidth',.5,'edgecolor','k'); ylim([0,1]);
hold('on');sq(6).ColorOrderIndex = 1;
bar([1:length(prof)],squeeze(OQS(prof,:,3,srfc,2)),'barwidth',1,'edgecolor','none','facealpha',.4); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'position',[0.4558     0.1300     0.4792    0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',prof_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');
yl1 = ylabel('OND = ONDPC0');
% yl1 = ylabel('OND');set(yl1,'rotation',0); set(yl1,'position',[8.987    0.55]);
set(gca,'position',get(gca,'position')+nudge);

ylim(sq,[0,1]);
mt = mtit(['Objective Weighted Scores w/wo adjustments: ',SFC{srfc}]);
set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
n_str = '';n = 1;
fname = [ACCP_pngs,'OQS_wwo_adj_alpha_',SFC{srfc},'.png'];
while isafile(fname)
    n = n+1; n_str = ['.',num2str(n)];
    fname = [ACCP_pngs,'OQS_wwo_adj_alpha_',SFC{srfc},n_str,'.png'];
end
saveas(gcf,fname);
pause(2)
close(gcf);
    %OQSadj_Layer_Ocean.png
end
% Next, for ALL layer-resovld and profile resolved GVs:

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


% OQSadj(gv,pfm,obi,sfc,obj(4))
% OQS(gv,pfm,[NAD,NAN,OND],sfc,obj(4))
oo = 2; % Objective 6, layer-resolved
SFC = {'Land', 'Ocean'};
for srfc = 1:2
figure_(srfc);
o=2; clear sq
sq(1)= subplot(3,1,1);
bb = bar([1:length(lay)],squeeze(OQSadj(lay,:,1,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-.15,1]);
hold('on');sq(1).ColorOrderIndex = 1;
bar([1:length(lay)],squeeze(OQSadj(lay,:,1,srfc,2))-squeeze(OQS(lay,:,1,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-.1,1]);
set(gca,'position',[0.1300    0.69    0.7750    0.24]);
set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xt); set(sq(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
title (['Layer-resolved GVs for Objective 6: ', SFC{srfc}]);
yl = ylabel({'NAD = ';'(NADBC0+NADLC1)/1'}); set(yl,'rotation',90); 
set(yl,'position',[-1.5    0.5000]);
lg = legend('SSP0','SSP1','SSP2','SSG3'); 
set(lg,'position',[0.0081    0.89    0.0546    0.1048]);

sq(2)= subplot(3,1,2);
bb = bar([1:length(lay)],squeeze(OQSadj(lay,:,2,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-.15,1]);
hold('on');sq(1).ColorOrderIndex = 1;
bar([1:length(lay)],squeeze(OQSadj(lay,:,2,srfc,2))-squeeze(OQS(lay,:,2,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-.15,1]);
 set(gca,'position',[0.1300    0.4166    0.7750    0.24]);
set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xt); set(sq(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel({'NAN = ';'(NANLC0+NANLC1)/1'}); set(yl,'rotation',90); 
set(yl,'position',[-1.5    0.5000]);

sq(3) = subplot(3,1,3);
bb = bar([1:length(lay)],squeeze(OQSadj(lay,:,3,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-.15,1]);
hold('on');sq(1).ColorOrderIndex = 1;
bar([1:length(lay)],squeeze(OQSadj(lay,:,3,srfc,2))-squeeze(OQS(lay,:,3,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-.15,1]);
 set(sq(3),'position',[0.1300    0.1335    0.7750    0.24]);
set(gca,'xtick',[1:length(lay)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xtx);
set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
yl = ylabel({'OND ='; 'ONDPC0'}); set(yl,'position',[-1.5    0.5000]);

nn = 1; n_str = [];
png_out = ['QO6_and_adj.layer-resolved.',SFC{srfc},n_str,'.png'];
while isafile([ACCP_pngs,png_out])
    nn = nn+1; n_str = ['_',num2str(nn)];
    png_out = ['QO6_and_adj.layer-resolved.',SFC{srfc},n_str,'.png'];
end
saveas(gcf,[ACCP_pngs,png_out]);
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
% close(gcf);
clear sq    
end

% Profile-resolved, Objective 6
for srfc = 1:2
figure_(srfc);
o=2; clear sq
sq(1)= subplot(3,1,1);hold('off')
bb = bar([1:length(prf)],squeeze(OQSadj(prf,:,1,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-.15,1]);
hold('on');sq(1).ColorOrderIndex = 1;
bar([1:length(prf)],squeeze(OQSadj(prf,:,1,srfc,2))-squeeze(OQS(prf,:,1,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-.1,1]);
set(gca,'position',[0.1300    0.69    0.7750    0.24]);
set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xtt); set(sq(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
title (['Profile-resolved GVs for Objective 6: ', SFC{srfc}]);
yl = ylabel({'NAD = ';'(NADBC0+NADLC1)/1'}); set(yl,'rotation',90); 
set(yl,'position',[-.5    0.5000]);
lg = legend('SSP0','SSP1','SSP2','SSG3'); 
set(lg,'position',[0.0081    0.89    0.0546    0.1048]);

sq(2)= subplot(3,1,2); hold('off');
bb = bar([1:length(prf)],squeeze(OQSadj(prf,:,2,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-.15,1]);
hold('on');sq(1).ColorOrderIndex = 1;
bar([1:length(prf)],squeeze(OQSadj(prf,:,2,srfc,2))-squeeze(OQS(prf,:,2,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-.15,1]);
 set(gca,'position',[0.1300    0.4166    0.7750    0.24]);
set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xtt); set(sq(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel({'NAN = ';'(NANLC0+NANLC1)/1'}); set(yl,'rotation',90); 
set(yl,'position',[-.5    0.5000]);

sq(3) = subplot(3,1,3); hold('off');
bb = bar([1:length(prf)],squeeze(OQSadj(prf,:,3,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([-.15,1]);
hold('on');sq(1).ColorOrderIndex = 1;
bar([1:length(prf)],squeeze(OQSadj(prf,:,3,srfc,2))-squeeze(OQS(prf,:,3,srfc,2)),'barwidth',.3,'edgecolor','k'); ylim([-.15,1]);
 set(sq(3),'position',[0.1300    0.1335    0.7750    0.24]);
set(gca,'xtick',[1:length(prf)]);set(gca, 'ytick',[0:.2:1]);
set(gca,'XTickLabel',xttx);
set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
yl = ylabel({'OND ='; 'ONDPC0'}); set(yl,'position',[-.5    0.5000]);

nn = 1; n_str = [];
png_out = ['QO6_and_adj.profile-resolved.',SFC{srfc},n_str,'.png'];
while isafile([ACCP_pngs,png_out])
    nn = nn+1; n_str = ['_',num2str(nn)];
    png_out = ['QO6_and_adj.profile-resolved.',SFC{srfc},n_str,'.png'];
end
saveas(gcf,[ACCP_pngs,png_out]);
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
% close(gcf);
clear sq    
       
end


%% End of ALL Objective-weighted GVs (lay, prf ) and adjustments below.

for srfc = 1:2 % Land, Ocen
clear sq
figure_(srfc+2); 
sq(1) = subplot(2,2,1); %for NAD
bar([1:length(layr)],mean(squeeze(OQSadj(layr,:,1,srfc,:)),3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
hold(sq(1),'on');  sq(1).ColorOrderIndex = 1; 
bar([1:length(layr)],max(squeeze(OQSadj(layr,:,1,srfc,:)),[],3),'barwidth',1,'edgecolor','k','facecolor','none'); ylim([0,1]);
hold(sq(1),'on');  sq(1).ColorOrderIndex = 1; 
bar([1:length(layr)],min(squeeze(OQSadj(layr,:,1,srfc,:)),[],3),'barwidth',1,'edgecolor','k','facecolor','none'); ylim([0,1]);

% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
% set(sq(1),'yaxislocation','right');
yl1 = ylabel({'NAD =';'(NADLC1+NADBC0)/2'});
title ('Layer-resolved GVs');

sq(2) = subplot(2,2,2); % for NAD
bar([1:length(prof)],mean(squeeze(OQSadj(prof,:,1,srfc,:)),3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
hold(sq(2),'on');  sq(2).ColorOrderIndex = 1; 
bar([1:length(prof)],max(squeeze(OQSadj(prof,:,1,srfc,:)),[],3),'barwidth',1,'edgecolor','k','facecolor','none'); ylim([0,1]);
hold(sq(2),'on');  sq(2).ColorOrderIndex = 1; 
bar([1:length(prof)],min(squeeze(OQSadj(prof,:,1,srfc,:)),[],3),'barwidth',1,'edgecolor','k','facecolor','none'); ylim([0,1]);

% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
yl2 = ylabel({'NAD =';'(NADLC1+NADBC0)/2'});
% yl2 = ylabel('NAD');set(yl2,'rotation',0,'position',[0,.45]);
title ('Profile-resolved GVs');

sq(3) = subplot(2,2,3); %for NAN
bar([1:length(layr)],mean(squeeze(OQSadj(layr,:,2,srfc,:)),3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
hold(sq(3),'on');  sq(3).ColorOrderIndex = 1; 
bar([1:length(layr)],max(squeeze(OQSadj(layr,:,2,srfc,:)),[],3),'barwidth',1,'edgecolor','k','facecolor','none'); ylim([0,1]);
hold(sq(3),'on');  sq(3).ColorOrderIndex = 1; 
bar([1:length(layr)],min(squeeze(OQSadj(layr,:,2,srfc,:)),[],3),'barwidth',1,'edgecolor','k','facecolor','none'); ylim([0,1]);

% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',layr_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
% set(sq(1),'yaxislocation','right');
yl2 = ylabel({'NAN =';'(NANLC0+NANLC1)/2'});


sq(4) = subplot(2,2,4); % for NAD
bar([1:length(prof)],mean(squeeze(OQSadj(prof,:,2,srfc,:)),3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
hold(sq(4),'on');  sq(4).ColorOrderIndex = 1; 
bar([1:length(prof)],max(squeeze(OQSadj(prof,:,2,srfc,:)),[],3),'barwidth',1,'edgecolor','k','facecolor','none'); ylim([0,1]);
hold(sq(4),'on');  sq(4).ColorOrderIndex = 1; 
bar([1:length(prof)],min(squeeze(OQSadj(prof,:,2,srfc,:)),[],3),'barwidth',1,'edgecolor','k','facecolor','none'); ylim([0,1]);

% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',prof_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sq(4),'yaxislocation','right');
yl2 = ylabel({'NAN =';'(NANLC0+NANLC1)/2'});
% yl2 = ylabel('NAD');set(yl2,'rotation',0,'position',[0,.45]);


ylim(sq,[0,1]);
mt = mtit(['Mean, min, max, of Objective Weighted, Adjusted Quality Scores for ',SFC{srfc}]);
set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
n_str = '';n = 1;
fname = [ACCP_pngs,'OQS_mmm_',SFC{srfc},'.png'];
while isafile(fname)
    n = n+1; n_str = ['.',num2str(n)];
    fname = [ACCP_pngs,'OQS_mmm_',SFC{srfc},n_str,'.png'];
end
saveas(gcf,fname);

pause(2)
close(gcf);

end



return