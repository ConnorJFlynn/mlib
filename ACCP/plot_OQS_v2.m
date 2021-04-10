function plot_OQS_v2(OQSadj,pptname)
% plot_OQS_v2(OQSadj)
% Uses new OQS struct where weighting follows adjustment

% Plots NAN, NAN for layer and prof GVs  
% v2: quick plots after "final" reviewer adjustments before sending to VF
if ~isavar('OQSadj')
    OQS = load(getfullname([getnamedpath('VF_out'),'SITA_OQS_*.mat'],'Select an input mat file.'));
    OQSadj = OQS.OQS;
end
if ~isavar('pptname')||~isafile(pptname)
    pptname = getfullname([getnamedpath('ACCP_ppts'),'*.pptx'],'Select a PPT file...');
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

% 3x2, Rows: NAD, NAN, OND, cols Layr, Prof
% First, for profile GVs
SFC = {'Land', 'Ocean'};
nudge = [0,.02,0,0];
for Obj = [2,1,3,4]
for srfc = 1:2 % Land, Ocen
figure_(srfc); 
sq(2) = subplot(3,2,2); %for Profile, NAD, Obj6 = O(2)
bar([1:length(prof)],squeeze(OQSadj(prof,:,1,srfc,Obj)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
yl1 = ylabel('NAD');set(yl1,'rotation',0,'position',[9.7    0.55]);
title ('Profile-Resolved GVs');

sq(1) = subplot(3,2,1); % for Layer,NAD
bar([1:length(layr)],squeeze(OQSadj(layr,:,1,srfc,Obj)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('NAD');set(yl2,'rotation',0,'position',[-0.90    0.4]);
title ('Layer-resolved GVs');

sq(4) = subplot(3,2,4); %for Profile, NAN, Obj6 = O(2)
bar([1:length(prof)],squeeze(OQSadj(prof,:,2,srfc,Obj)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
yl1 = ylabel('NAN');set(yl1,'rotation',0,'position',[9.7    0.55]);


sq(3) = subplot(3,2,3); % for Layer,NAD
bar([1:length(layr)],squeeze(OQSadj(layr,:,2,srfc,Obj)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl2 = ylabel('NAN');set(yl2,'rotation',0,'position',[-0.90    0.4]);


sq(6) = subplot(3,2,6); %for Profile, NAN, Obj6 = O(2)
bar([1:length(prof)],squeeze(OQSadj(prof,:,3,srfc,Obj)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',prof_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
yl1 = ylabel('OND');
set(yl1,'rotation',0,'position',[9.7    0.55]);


sq(5) = subplot(3,2,5); % for Layer,NAD
bar([1:length(layr)],squeeze(OQSadj(layr,:,3,srfc,Obj)),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'XTickLabel',layr_x); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);

yl2 = ylabel('OND');set(yl2,'rotation',0,'position',[-0.90    0.4]);



ylim(sq,[0,1]);
mt = mtit(['Adjusted Quality Scores for Objective ',num2str(4+Obj),': ',SFC{srfc}]);
set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
n_str = '';n = 1;
fname = [ACCP_pngs,'OQSadj_O',num2str(4+Obj),'_',SFC{srfc},'.png'];
while isafile(fname)
    n = n+1; n_str = ['.',num2str(n)];
    fname = [ACCP_pngs,'OQSadj_O',num2str(4+Obj),'_',SFC{srfc},n_str,'.png'];
end
saveas(gcf,fname);
    ppt_add_slide_no_title(pptname, [fname]);
pause(2)




close(gcf);
    %OQSadj_Layer_Ocean.png
end

end



return