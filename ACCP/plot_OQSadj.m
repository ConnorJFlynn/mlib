function plot_OQSadj(OQSadj)

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

layr_x = {"AAOD Vis Col","AEFRF PBL","AODF Vis Col","AOD UV Col","AOD Vis Col","ARIR Vis Col"};
prof_x= {"AABS UV above pbl","AABS VIS above pbl","AEXT UV above pbl",...
    "AEXT UV in pbl","AEXT Vis above pbl","AEXT Vis in pbl",...
    "AE2BR Vis above pbl","ANC above pbl"};

'%OQSadj(obj,gv,obs,sfc,pltf)';
% First, for profile GVs
SFC = {'Land', 'Ocean'};
nudge = [0,.02,0,0];
for srfc = 1:2 % Land, Ocen
figure_(srfc); 
sq(2) = subplot(4,2,2); %for NAN
bar([1:length(prof)],squeeze(OQSadj(1,prof,2,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
yl1 = ylabel('O5');set(yl1,'rotation',0,'position',[9.7    0.55]);
title ('NAN');

sq(1) = subplot(4,2,1); % for NAD
bar([1:length(prof)],squeeze(OQSadj(1,prof,1,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('O5');set(yl2,'rotation',0,'position',[-0.90    0.4]);
title ('NAD');

sq(4) = subplot(4,2,4); %for NAN
bar([1:length(prof)],squeeze(OQSadj(2,prof,2,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(4),'yaxislocation','right');
yl1 = ylabel('O6');set(yl1,'rotation',0); set(yl1,'position',[9.7    0.55]);
set(gca,'position',get(gca,'position')+nudge);

sq(3) = subplot(4,2,3); % for NAD
bar([1:length(prof)],squeeze(OQSadj(2,prof,1,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('O6');set(yl2,'rotation',0,'position',[-0.90    0.4]);
set(gca,'position',get(gca,'position')+nudge);

sq(6) = subplot(4,2,6); %for NAN
bar([1:length(prof)],squeeze(OQSadj(3,prof,2,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');
yl1 = ylabel('O7');set(yl1,'rotation',0); set(yl1,'position',[9.7    0.55]);
set(gca,'position',get(gca,'position')+nudge);

sq(5) = subplot(4,2,5); % for NAD
bar([1:length(prof)],squeeze(OQSadj(3,prof,1,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('O7');set(yl2,'rotation',0,'position',[-0.90    0.4]);
set(gca,'position',get(gca,'position')+nudge);

sq(8) = subplot(4,2,8); %for NAN
bar([1:length(prof)],squeeze(OQSadj(4,prof,2,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',prof_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');
yl1 = ylabel('O8');set(yl1,'rotation',0); set(yl1,'position',[9.7    0.55]);
set(gca,'position',get(gca,'position')+nudge);

sq(7) = subplot(4,2,7); % for NAD
bar([1:length(prof)],squeeze(OQSadj(4,prof,1,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',prof_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl2 = ylabel('O8');set(yl2,'rotation',0,'position',[-0.90    0.4]);
set(gca,'position',get(gca,'position')+nudge);
ylim(sq,[0,1]);
mt = mtit(['Adjusted Quality Scores for Profile-Resolved GVs: ',SFC{srfc}]);
set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
saveas(gcf,[ACCP_pngs,'OQSadj_Prof_',SFC{srfc},'.png']);
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
bar([1:length(layr)],squeeze(OQSadj(1,layr,2,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
yl1 = ylabel('O5');set(yl1,'rotation',0,'position',[9.7    0.55]);
title ('NAN');

sq(1) = subplot(4,2,1); % for NAD
bar([1:length(layr)],squeeze(OQSadj(1,layr,1,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('O5');set(yl2,'rotation',0,'position',[-0.90    0.4]);
title ('NAD');

sq(4) = subplot(4,2,4); %for NAN
bar([1:length(layr)],squeeze(OQSadj(2,layr,2,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(4),'yaxislocation','right');
yl1 = ylabel('O6');set(yl1,'rotation',0); set(yl1,'position',[9.7    0.55]);

sq(3) = subplot(4,2,3); % for NAD
bar([1:length(layr)],squeeze(OQSadj(2,layr,1,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('O6');set(yl2,'rotation',0,'position',[-0.90    0.4]);

sq(6) = subplot(4,2,6); %for NAN
bar([1:length(layr)],squeeze(OQSadj(3,layr,2,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');
yl1 = ylabel('O7');set(yl1,'rotation',0); set(yl1,'position',[9.7    0.55]);

sq(5) = subplot(4,2,5); % for NAD
bar([1:length(layr)],squeeze(OQSadj(3,layr,1,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('O7');set(yl2,'rotation',0,'position',[-0.90    0.4]);

sq(8) = subplot(4,2,8); %for NAN
bar([1:length(layr)],squeeze(OQSadj(4,layr,2,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',layr_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');
yl1 = ylabel('O8');set(yl1,'rotation',0); set(yl1,'position',[9.7    0.55]);

sq(7) = subplot(4,2,7); % for NAD
bar([1:length(layr)],squeeze(OQSadj(4,layr,1,srfc,:)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',layr_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl2 = ylabel('O8');set(yl2,'rotation',0,'position',[-0.90    0.4]);

ylim(sq,[0,1]);
mt = mtit(['Adjusted Quality Scores for Layer-Averaged GVs: ',SFC{srfc}]);
set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);

saveas(gcf,[ACCP_pngs,'OQSadj_Layer_',SFC{srfc},'.png']);
pause(2)
close(gcf);

end



return