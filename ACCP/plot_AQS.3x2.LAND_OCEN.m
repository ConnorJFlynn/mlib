% Bar charts, 
lay = find(gv<42); prf = find(gv>41); 
 m = 3; 
lay_ = lay;
lay(19:20) = [];
prf_ = prf; 
prf(19:20) = [];
% QI_adj(H,P,L,m) =52xx4x3x3
% obs L = ["NAD", "NAN", "OND"];
% srfc m = ["LNDD", "LNDV", "OCEN"];
 Q_LAND = mean(QI_adj(:,:,:,1:2),4);
 Q_OCEN = QI_adj(:,:,:,3);
 plt = 1; obs = 3;
 Qs = QI_adj(gv(prf),1,obs,3); [gv(prf)',Qs(:)]
 Qs = QI_adj(gv(prf),1,obs,3);
[nanmean(Qs(:)),nanstd(Qs(:))]
 Qs = QI_adj(gv(prf),2,obs,3);
[nanmean(Qs(:)),nanstd(Qs(:))]
 Qs = QI_adj(gv(prf),3,obs,3);
[nanmean(Qs(:)),nanstd(Qs(:))]
 Qs = QI_adj(gv(prf),4,obs,3);
[nanmean(Qs(:)),nanstd(Qs(:))]
clear xt xtt
 for xx = length(lay):-1:1
     xt(xx) = {num2str(gv(lay(xx)))};
 end
for xx = length(prf):-1:1
    xtt(xx) = {num2str(gv(prf(xx)))};
end
 figure_(111); 
sq(1) = subplot(3,2,1);
 bar([1:length(lay)],Q_LAND(gv(lay),:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
 set(gca,'position',[0.0836    0.7093    0.4865    0.2157]);
 set(gca,'xtick',[1:length(lay)]);
 set(gca,'XTickLabel',xt);
 set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl = ylabel('NAD'); set(yl,'rotation',0); set(yl,'position',[-1.5    0.5000]);
lg = legend('SSP0','SSP1','SSP2','SSG3'); set(lg,'position',[0.0081    0.8746    0.0546    0.1048]);

sq(2)= subplot(3,2,2);
 bar([1:length(prf)],Q_LAND(gv(prf),:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
 set(gca,'position',[0.5892    0.7093    0.3535    0.2157]);
 set(gca,'xtick',[1:length(prf)]);
 set(gca,'XTickLabel',xtt);
 set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');

sq(3) = subplot(3,2,3);
 bar([1:length(lay)],Q_LAND(gv(lay),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
 set(gca,'position',[0.0836    0.4066    0.4865    0.2157]);
 set(gca,'xtick',[1:length(lay)]);
 set(gca,'XTickLabel',xt);
 set(gca,'XTickLabelRot',30); set(sq(3),'FontSize',10);
yl = ylabel('NAN'); set(yl,'rotation',0); set(yl,'position',[-1.5    0.4860 ]);

sq(4)= subplot(3,2,4);
 bar([1:length(prf)],Q_LAND(gv(prf),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
 set(gca,'position',[0.5892    0.4081    0.3535    0.2157]);
 set(gca,'xtick',[1:length(prf)]);
 set(gca,'XTickLabel',xtt);
 set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
 set(gca,'yaxislocation','right');


sq(5) = subplot(3,2,5);
 bar([1:length(lay)],Q_LAND(gv(lay),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
  set(gca,'position',[0.0836     0.1100   0.4865    0.2157]);
 set(gca,'xtick',[1:length(lay)]);
         set(gca,'XTickLabel',xt);
        set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl = ylabel('OND'); set(yl,'rotation',0);set(yl,'position',[-1.5    0.4860 ]);
xlabel('Layer-resolved GVs');
sq(6)= subplot(3,2,6);
 bar([1:length(prf)],Q_LAND(gv(prf),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
 set(gca,'position',[0.5892    0.1100    0.3535    0.2157]);
 set(gca,'xtick',[1:length(prf)]);
         set(gca,'XTickLabel',xtt);
        set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');
xlabel('Profile-resolved GVs')
ylim(sq,[0,1]);
 mt = mtit(['Adjusted Quality Scores: LAND (average of LNDD & LNDV)']);
    set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);

    
 figure_(112); 
 sqo(1) = subplot(3,2,1);
 bar([1:length(lay)],Q_OCEN(gv(lay),:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
 set(gca,'position',[0.0836    0.7093    0.4865    0.2157]);
 set(gca,'xtick',[1:length(lay)]);
 set(gca,'XTickLabel',xt);
 set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
 yl = ylabel('NAD'); set(yl,'rotation',0); set(yl,'position',[-1.5    0.5000]);
lg = legend('SSP0','SSP1','SSP2','SSG3'); set(lg,'position',[0.0081    0.8746    0.0546    0.1048]);

sqo(2)= subplot(3,2,2);
bar([1:length(prf)],Q_OCEN(gv(prf),:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.5892    0.7093    0.3535    0.2157]);
set(gca,'xtick',[1:length(prf)]);
set(gca,'XTickLabel',xtt);
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(gca,'yaxislocation','right');

sqo(3) = subplot(3,2,3);
 bar([1:length(lay)],Q_OCEN(gv(lay),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
 set(gca,'position',[0.0836    0.4066    0.4865    0.2157]);
 set(gca,'xtick',[1:length(lay)]);
 set(gca,'XTickLabel',xt);
 set(gca,'XTickLabelRot',30); set(sq(3),'FontSize',10);
yl = ylabel('NAN'); set(yl,'rotation',0); set(yl,'position',[-1.5    0.4860 ]);

sqo(4)= subplot(3,2,4);
 bar([1:length(prf)],Q_OCEN(gv(prf),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
 set(gca,'position',[0.5892    0.4081    0.3535    0.2157]);
 set(gca,'xtick',[1:length(prf)]);
 set(gca,'XTickLabel',xtt);
 set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
 set(gca,'yaxislocation','right');


sqo(5) = subplot(3,2,5);
 bar([1:length(lay)],Q_OCEN(gv(lay),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
  set(gca,'position',[0.0836     0.1100   0.4865    0.2157]);
 set(gca,'xtick',[1:length(lay)]);
         set(gca,'XTickLabel',xt);
        set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl = ylabel('OND'); set(yl,'rotation',0);set(yl,'position',[-1.5    0.4860 ]);
xlabel('Layer-resolved GVs');
sqo(6)= subplot(3,2,6);
 bar([1:length(prf)],Q_OCEN(gv(prf),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
 set(gca,'position',[0.5892    0.1100    0.3535    0.2157]);
 set(gca,'xtick',[1:length(prf)]);
 set(gca,'XTickLabel',xtt);
 set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
 set(gca,'yaxislocation','right');
xlabel('Profile-resolved GVs')
ylim(gca,[0,1]);
 mt = mtit(['Adjusted Quality Scores: OCEN']);
    set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);
    
    
 