function Arch11_Jens_request1(QIS,MER,RMS,gv,sfc,obs,reso,pptname)

% Jens's request #1: two summary plots (LAND OCEN) for a all mean adjusted
% QI scores separated into layer and profile GVs. 
% Jen's wanted NADLC0, NADBC0, NANLC0, and ONDPC0 but will accept NAD, NAN, OND

[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';

mean_adj = SITA_Sept_adj;
lay = find(gv<42); prf = find(gv>41); 
lay(21:22) = []; %Exclude GV21,22
prf(21:22) = []; % Exclude GV62,63

% QIS = NaN([65,length(GRP),length(TYP),length(PFM),length(OBI),length(SFC),length(REZ)]);

 Q_LAND = mean(QIS(:,:,:,1:2),4);
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


for Z = 2:-1:1
    if Z == 2 % profile
        gvs = prf;
    else
        gvs = lay; % layer
    end    
    for O = 4:-1:1
        for obs = 3:-1:1
            for plt = 4:-1:1
                for sfc = 2:-1:1
                   mean_OQSadj(O,Z,obs,sfc,plt) = nanmean(squeeze(OQSadj.OQSadj(O,gvs,obs,sfc,plt)));
                   std_OQSadj(O,Z,obs,sfc,plt) = nanstd(squeeze(OQSadj.OQSadj(O,gvs,obs,sfc,plt)));
                end
            end
        end
    end
end









);
% Bar charts, 

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
    
    
 