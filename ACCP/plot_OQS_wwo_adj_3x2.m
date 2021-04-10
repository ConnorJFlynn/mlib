function plot_OQS_ww0_adj_3x2(OQSadj, OQS)
% plot_OQS_ww0_adj_3x2(OQSadj, OQS)
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
bar([1:length(layr)],squeeze(OQSadj(layr,:,1,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
hold('on');sq(1).ColorOrderIndex = 1;
bar([1:length(layr)],squeeze(OQS(layr,:,1,srfc,2)),'barwidth',.2,'edgecolor','k'); ylim([0,1]);
set(gca,'position',[0.0669    0.6885    0.3753    0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
% yl2 = ylabel('NAD');set(yl2,'rotation',0,'position',[0,.45]);
yl2 = ylabel({'NAD =';'(NADLC1+NADBC0)/2'});
title ('Layer-resolved GVs  [thin bars for unadjusted scores]');

sq(2) = subplot(3,2,2); hold('off');%for NAD Prof
bar([1:length(prof)],squeeze(OQSadj(prof,:,1,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
hold('on');sq(2).ColorOrderIndex = 1; 
lg = legend('SSP0','SSP1','SSP2','SSG3','location','northwest');
bar([1:length(prof)],squeeze(OQS(prof,:,1,srfc,2)),'barwidth',.2,'edgecolor','k'); ylim([0,1]);

set(gca,'position',[0.4558    0.6885    0.4792   0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
yl1 = ylabel({'NAD =';'(NADLC1+NADBC0)/2'});
% yl1 = ylabel('NAD');set(yl1,'rotation',0,'position',[8.9862    0.54]);
title ('Profile-resolved GVs  [thin bars for unadjusted scores]');

sq(3) = subplot(3,2,3); hold('off');% for NAN Layr
bar([1:length(layr)],squeeze(OQSadj(layr,:,2,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
hold('on');sq(3).ColorOrderIndex = 1;
bar([1:length(layr)],squeeze(OQS(layr,:,2,srfc,2)),'barwidth',.2,'edgecolor','k'); ylim([0,1]);
set(gca,'position',[0.0669    0.421    0.3753    0.2365]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel({'NAN =';'(NANLC0+NANLC1)/2'});
% yl2 = ylabel('NAN');set(yl2,'rotation',0,'position',[0 0.45 ]);
% set(gca,'position',get(gca,'position')+nudge);

sq(4) = subplot(3,2,4); hold('off');%for NAN Prof
bar([1:length(prof)],squeeze(OQSadj(prof,:,2,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
hold('on');sq(4).ColorOrderIndex = 1;
bar([1:length(prof)],squeeze(OQS(prof,:,2,srfc,2)),'barwidth',.2,'edgecolor','k'); ylim([0,1]);
set(gca,'position',[0.4558    0.421    0.4792   0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(4),'yaxislocation','right');
yl1 = ylabel({'NAN =';'(NANLC0+NANLC1)/2'});;
% yl1 = ylabel('NAN');set(yl1,'rotation',0,'position',[8.9862    0.54]);
% set(gca,'position',get(gca,'position')+nudge);

sq(5) = subplot(3,2,5); hold('off');% for OND Layr
bar([1:length(layr)],squeeze(OQSadj(layr,:,3,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
hold('on');sq(5).ColorOrderIndex = 1;
bar([1:length(layr)],squeeze(OQS(layr,:,3,srfc,2)),'barwidth',.2,'edgecolor','k'); ylim([0,1]);
set(gca,'position',[0.0669    0.1300    0.3753    0.2365]);
% set(gca,'position',[0.1300    0.1100    0.3347    0.2157]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',layr_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl2 = ylabel('OND = ONDPC0');
% set(yl2,'rotation',0);set(yl2,'position',[0    0.45]);
set(gca,'position',get(gca,'position')+nudge);

sq(6) = subplot(3,2,6); hold('off');%for OND Prof
bar([1:length(prof)],squeeze(OQSadj(prof,:,3,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
hold('on');sq(6).ColorOrderIndex = 1;
bar([1:length(prof)],squeeze(OQS(prof,:,3,srfc,2)),'barwidth',.2,'edgecolor','k'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'position',[0.4558     0.1300     0.4792    0.2365]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',prof_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');
yl1 = ylabel('OND = ONDPC0');
% set(yl1,'rotation',0); set(yl1,'position',[8.987    0.55]);
set(gca,'position',get(gca,'position')+nudge);

ylim(sq,[0,1]);
mt = mtit(['Objective Weighted Scores w/wo adjustments: ',SFC{srfc}]);
set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
n_str = '';n = 1;
fname = [ACCP_pngs,'OQS_wwo_adj_',SFC{srfc},'.png'];
while isafile(fname)
    n = n+1; n_str = ['.',num2str(n)];
    fname = [ACCP_pngs,'OQS_wwo_adj_',SFC{srfc},n_str,'.png'];
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

% Next, for column/layer GVs:
'%OQSadj(obj,gv,obs,sfc,pltf)';
SFC = {'Land', 'Ocean'};
for srfc = 1:2 % Land, Ocen
figure_(srfc+2); 
sq(2) = subplot(4,2,2); %for NAN
bar([1:length(layr)],squeeze(OQSadj(layr,:,2,srfc,1)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
yl1 = ylabel('O5');set(yl1,'rotation',0,'position',[9.7    0.55]);
title ('NAN');

sq(1) = subplot(4,2,1); % for NAD
bar([1:length(layr)],squeeze(OQSadj(layr,:,1,srfc,1)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('O5');set(yl2,'rotation',0,'position',[-0.90    0.4]);
title ('NAD');

sq(4) = subplot(4,2,4); %for NAN
bar([1:length(layr)],squeeze(OQSadj(layr,:,2,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(4),'yaxislocation','right');
yl1 = ylabel('O6');set(yl1,'rotation',0); set(yl1,'position',[9.7    0.55]);

sq(3) = subplot(4,2,3); % for NAD
bar([1:length(layr)],squeeze(OQSadj(layr,:,1,srfc,2)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('O6');set(yl2,'rotation',0,'position',[-0.90    0.4]);

sq(6) = subplot(4,2,6); %for NAN
bar([1:length(layr)],squeeze(OQSadj(layr,:,2,srfc,3)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');
yl1 = ylabel('O7');set(yl1,'rotation',0); set(yl1,'position',[9.7    0.55]);

sq(5) = subplot(4,2,5); % for NAD
bar([1:length(layr)],squeeze(OQSadj(layr,:,1,srfc,3)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('O7');set(yl2,'rotation',0,'position',[-0.90    0.4]);

sq(8) = subplot(4,2,8); %for NAN
bar([1:length(layr)],squeeze(OQSadj(layr,:,2,srfc,4)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',layr_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');
yl1 = ylabel('O8');set(yl1,'rotation',0); set(yl1,'position',[9.7    0.55]);

sq(7) = subplot(4,2,7); % for NAD
bar([1:length(layr)],squeeze(OQSadj(layr,:,1,srfc,4)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',layr_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl2 = ylabel('O8');set(yl2,'rotation',0,'position',[-0.90    0.4]);

ylim(sq,[0,1]);
mt = mtit(['Adjusted Quality Scores for Layer-Averaged GVs: ',SFC{srfc}]);
set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
n_str = '';n = 1;
fname = [ACCP_pngs,'OQSadj_Layer_',SFC{srfc},'.png'];
while isafile(fname)
    n = n+1; n_str = ['.',num2str(n)];
    fname = [ACCP_pngs,'OQSadj_Layer_',SFC{srfc},n_str,'.png'];
end
saveas(gcf,fname);

pause(2)
close(gcf);

end



return