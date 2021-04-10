function plot_C0_C1_v1(Qall,pptname)
% Qall = plot_C0_C1_v1(Qall,pptname)
% Intended to detail differences between C0 and C1 retrievals and effect on
% NAD, NAN scenes.
% Accepts Qall and pptname to produce multiple plots
% % Qall(gv,plt,obi,sfc),
%v1: Four plots:
% #1: 5x2 plot for NAD with MIP layer-resolved and profile-resolved columns 
% and row with NADLC0, NADLC1, NADBC0, NADC0, NADC1
% #2: 3x2 ploty for NAN with MIP layer-resolved and profile-resolved cols
% but rows with NANLC0, NANLC1, and NAN
% #3: 5x2 with GV 1:41
% #4: 3x2 with GV 42:65

ACCP_pngs = getnamedpath('ACCP_pngs');
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';
gv = [1:length(GVnames)];
% mean_adj = SITA_Sept_adj;
%QIS(gv,grp,orb/typ,pltf,obs,srfc,res)
%% GV counter
H = length(GVnames);
Qall = NaN(H,4,8,2);

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
    if ~isavar('obs')
        obs = ["NADLC0", "NADBC0", "NANLC0","ONDPC0"];
    end
    OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0",...
        "NADLC1","NANLC1","NADLC2","NANLC2"];
        
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
Q_LAND = squeeze(Qall(:,:,:,1));
Q_OCEN = squeeze(Qall(:,:,:,2));
lay = find(gv<42); prf = find(gv>41);
lay(21:22) = []; %Exclude GV21,22
prf(21:22) = []; % Exclude GV62,63
% toc
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

figure_(111);
sq(2)= subplot(4,2,2);
bar([1:length(prf)],Q_LAND(gv(prf),:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prf)]);
set(gca,'XTickLabel',xtt_); set(sq(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sq(2),'yaxislocation','right');
title ('Profile-resolved GVs');

sq(1) = subplot(4,2,1);
bar([1:length(lay)],Q_LAND(gv(lay),:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.0781    0.7357    0.5413    0.18]);
set(gca,'xtick',[1:length(lay)]);
set(sq(1),'XTickLabel',xt_);set(sq(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel('NADLC0'); set(yl,'rotation',90); set(yl,'position',[-1.5    0.5000]);
title('Layer-resolved GVs');
lg = legend('SSP0','SSP1','SSP2','SSG3'); set(lg,'position',[0.0081    0.89    0.0546    0.1048]);

sq(4)= subplot(4,2,4);
bar([1:length(prf)],Q_LAND(gv(prf),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sq(4),'position',[0.6293    0.5324    0.3301    0.18]);
set(gca,'xtick',[1:length(prf)]);
set(gca,'XTickLabel',[])
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sq(4),'yaxislocation','right');

sq(3) = subplot(4,2,3);
bar([1:length(lay)],Q_LAND(gv(lay),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sq(3),'position',[0.0782    0.5324    0.5413    0.18]);
set(gca,'xtick',[1:length(lay)]);
set(gca,'XTickLabel',xt);set(sq(3),'XTickLabel',[])
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel('NADBC0'); set(yl,'rotation',90); set(yl,'position',[-1.5    0.5000]);

sq(6)= subplot(4,2,6);
bar([1:length(prf)],Q_LAND(gv(prf),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sq(6),'position',[0.6293    0.332    0.3301    0.18]);
set(gca,'xtick',[1:length(prf)]);
set(gca,'XTickLabel',[]);
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sq(6),'yaxislocation','right');

sq(5) = subplot(4,2,5);
bar([1:length(lay)],Q_LAND(gv(lay),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sq(5),'position',[0.0782    0.332    0.5413    0.18]);
set(gca,'xtick',[1:length(lay)]);
set(gca,'XTickLabel',xt);set(gca,'XTickLabel',[])
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl = ylabel('NANLC0'); set(yl,'rotation',90); set(yl,'position',[-1.5    0.5000]);

sq(8)= subplot(4,2,8);
bar([1:length(prf)],Q_LAND(gv(prf),:,4),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sq(8),'position',[0.6293    0.1315    0.3301    0.18]);
set(gca,'xtick',[1:length(prf)]);
set(sq(8),'XTickLabel',xttx);
set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
set(sq(8),'yaxislocation','right');

sq(7) = subplot(4,2,7);
bar([1:length(lay)],Q_LAND(gv(lay),:,4),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sq(7),'position',[0.0782    0.1315    0.5413    0.18]);
set(gca,'xtick',[1:length(lay)]);
set(sq(7),'XTickLabel',xtx);
set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
yl = ylabel('ONDPC0'); set(yl,'rotation',90); set(yl,'position',[-1.5    0.5000]);

ylim(sq,[0,1]);
mt = mtit(['Adjusted Quality Scores: LAND']);
set(mt.th,'fontsize',15,'position',[0.5000    1.0600]);

nn = 1; n_str = [num2str(nn)];
png_out = ['Qadj[all].Land.',n_str,'.png'];
while isafile([ACCP_pngs,png_out])
    nn = nn+1; n_str = ['_',num2str(nn)];
    png_out = ['Qadj[all].Land.',n_str,'.png'];
end
saveas(gcf,[ACCP_pngs,png_out]);
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
close(gcf);

ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);

% Now OCEAN
figure_(112);

sqo(2)= subplot(4,2,2);
bar([1:length(prf)],Q_OCEN(gv(prf),:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prf)]);
set(gca,'XTickLabel',xtt_); set(sqo(2),'xaxislocation','top');
%  set(gca,'XTickLabel',xtt);set(gca,'XTickLabel',[])
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sqo(2),'yaxislocation','right');
title ('Profile-resolved GVs');

sqo(1) = subplot(4,2,1);
bar([1:length(lay)],Q_OCEN(gv(lay),:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(gca,'position',[0.0781    0.7357    0.5413    0.18]);
set(gca,'xtick',[1:length(lay)]);
set(sqo(1),'XTickLabel',xt_);set(sqo(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel('NADLC0'); set(yl,'rotation',90); set(yl,'position',[-1.5    0.5000]);
title('Layer-resolved GVs');
lg = legend('SSP0','SSP1','SSP2','SSG3'); set(lg,'position',[0.0081    0.8746    0.0546    0.1048]);

sqo(4)= subplot(4,2,4);
bar([1:length(prf)],Q_OCEN(gv(prf),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sqo(4),'position',[0.6293    0.5324    0.3301    0.18]);
set(gca,'xtick',[1:length(prf)]);
set(gca,'XTickLabel',xtt);set(gca,'XTickLabel',[])
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sqo(4),'yaxislocation','right');

sqo(3) = subplot(4,2,3);
bar([1:length(lay)],Q_OCEN(gv(lay),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sqo(3),'position',[0.0782    0.5324    0.5413    0.18]);
set(gca,'xtick',[1:length(lay)]);
set(gca,'XTickLabel',xt);set(sqo(3),'XTickLabel',[])
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel('NADBC0'); set(yl,'rotation',90); set(yl,'position',[-1.5    0.5000]);

sqo(6)= subplot(4,2,6);
bar([1:length(prf)],Q_OCEN(gv(prf),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sqo(6),'position',[0.6293    0.332    0.3301    0.18]);;
set(gca,'xtick',[1:length(prf)]);
set(gca,'XTickLabel',xtt);set(sqo(6),'XTickLabel',[])
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sqo(6),'yaxislocation','right');

sqo(5) = subplot(4,2,5);
bar([1:length(lay)],Q_OCEN(gv(lay),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sqo(5),'position',[0.0782    0.332    0.5413    0.18]);
set(gca,'xtick',[1:length(lay)]);
set(gca,'XTickLabel',xt);set(gca,'XTickLabel',[])
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl = ylabel('NANLC0'); set(yl,'rotation',90); set(yl,'position',[-1.5    0.5000]);

sqo(8)= subplot(4,2,8);
bar([1:length(prf)],Q_OCEN(gv(prf),:,4),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sqo(8),'position',[0.6293    0.1315    0.3301    0.18]);
set(gca,'xtick',[1:length(prf)]);
set(sqo(8),'XTickLabel',xttx);
set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
set(sqo(8),'yaxislocation','right');

sqo(7) = subplot(4,2,7);
bar([1:length(lay)],Q_OCEN(gv(lay),:,4),'barwidth',1,'edgecolor','none'); ylim([0,1]);
set(sqo(7),'position',[0.0782    0.1315    0.5413    0.18]);
set(gca,'xtick',[1:length(lay)]);
set(sqo(7),'XTickLabel',xtx);
set(gca,'XTickLabelRot',45); set(gca,'FontSize',10);
yl = ylabel('ONDPC0'); set(yl,'rotation',90); set(yl,'position',[-1.5    0.5000]);


ylim(sqo,[0,1]);
mt = mtit(['Adjusted Quality Scores: Ocean']);
set(mt.th,'fontsize',15,'position',[0.5000    1.06]);

png_out = ['Qadj[all].OCEN.',n_str,'.png'];
while isafile([ACCP_pngs,png_out])
    nn = nn+1; n_str = ['_',num2str(nn)];
    png_out = ['Qadj[all].OCEN.',n_str,'.png'];
end

saveas(gcf,[ACCP_pngs,png_out]);
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
close(gcf);

ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);

% Now, just the principle GVs
layr = [3,12,19,23,25,32];
prof = [42,44,50,51,52,53,58,64];

clear xt xtt
for xx = length(layr):-1:1
    xt(xx) = {num2str(gv(layr(xx)))};
end
for xx = length(prof):-1:1
    xtt(xx) = {num2str(gv(prof(xx)))};
end

layr_x = {"AAOD Vis Col","AEFRF PBL","AODF Vis Col","AOD UV Col","AOD Vis Col","ARIR Vis Col"};
prof_x= {"AABS UV above pbl","AABS VIS above pbl","AEXT UV above pbl",...
    "AEXT UV in pbl","AEXT Vis above pbl","AEXT Vis in pbl",...
    "AE2BR Vis above pbl","ANC above pbl"};


figure_(1111);
sql(2)= subplot(4,2,2);
bar([1:length(prof)],Q_LAND(prof,:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sql(2),'yaxislocation','right');
title ('Profile-resolved GVs');

sql(1) = subplot(4,2,1);
bar([1:length(layr)],Q_LAND(gv(layr),:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
%  set(gca,'position',[0.0781    0.7357    0.5413    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(sql(1),'XTickLabel',xt);%set(sql(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel('NADLC0'); set(yl,'rotation',90); % set(yl,'position',[-1.5    0.5000]);
title('Layer-resolved GVs');
lg = legend('SSP0','SSP1','SSP2','SSG3');
set(lg,'position',[0.0245    0.8740    0.0530    0.0796]);% set(lg,'position',[0.0081    0.89    0.0546    0.1048]);

sql(4)= subplot(4,2,4);
bar([1:length(prof)],Q_LAND(gv(prof),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(4),'position',[0.6293    0.5324    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
%  set(gca,'XTickLabel',[])
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sql(4),'yaxislocation','right');

sql(3) = subplot(4,2,3);
bar([1:length(layr)],Q_LAND(gv(layr),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(3),'position',[0.0782    0.5324    0.5413    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt);%set(sql(3),'XTickLabel',[])
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel('NADBC0'); set(yl,'rotation',90); %set(yl,'position',[-1.5    0.5000]);

sql(6)= subplot(4,2,6);
bar([1:length(prof)],Q_LAND(gv(prof),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(6),'position',[0.6393    0.3235    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt);
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sql(6),'yaxislocation','right');

sql(5) = subplot(4,2,5);
bar([1:length(layr)],Q_LAND(gv(layr),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(5),'position',[0.0782    0.3235    0.5413    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt);% set(gca,'XTickLabel',[])
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel('NANLC0'); set(yl,'rotation',90); %set(yl,'position',[-1.5    0.5000]);

sql(8)= subplot(4,2,8);
bar([1:length(prof)],Q_LAND(gv(prof),:,4),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(8),'position',[0.6293    0.1315    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(sql(8),'XTickLabel',prof_x);
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sql(8),'yaxislocation','right');

sql(7) = subplot(4,2,7);
bar([1:length(layr)],Q_LAND(gv(layr),:,4),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(7),'position',[0.0782    0.1315    0.5413    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(sql(7),'XTickLabel',layr_x);
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl = ylabel('ONDPC0'); set(yl,'rotation',90); %et(yl,'position',[-1.5    0.5000]);
ylim(sql,[0,1]);

mt = mtit(['Adjusted Quality Scores: LAND']);
set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);

nn = 1; n_str = [num2str(nn)];
png_out = ['Qadj[reduced].Land.',n_str,'.png'];
while isafile([ACCP_pngs,png_out])
    nn = nn+1; n_str = ['_',num2str(nn)];
    png_out = ['Qadj[reduced].Land.',n_str,'.png'];
end
saveas(gcf,[ACCP_pngs,png_out]);
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
close(gcf);

ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);

% Now OCEAN
figure_(1112);
clear sql
sql(2)= subplot(4,2,2);
bar([1:length(prof)],Q_OCEN(prof,:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(gca,'position',[0.6293    0.7357    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt); %set(sql(2),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sql(2),'yaxislocation','right');
title ('Profile-resolved GVs');

sql(1) = subplot(4,2,1);
bar([1:length(layr)],Q_OCEN(gv(layr),:,1),'barwidth',1,'edgecolor','none'); ylim([0,1]);
%  set(gca,'position',[0.0781    0.7357    0.5413    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(sql(1),'XTickLabel',xt);%set(sql(1),'xaxislocation','top');
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel('NADLC0'); set(yl,'rotation',90); % set(yl,'position',[-1.5    0.5000]);
title('Layer-resolved GVs');
lg = legend('SSP0','SSP1','SSP2','SSG3');
set(lg,'position',[0.0245    0.8740    0.0530    0.0796]);

sql(4)= subplot(4,2,4);
bar([1:length(prof)],Q_OCEN(gv(prof),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(4),'position',[0.6293    0.5324    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
%  set(gca,'XTickLabel',[])
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sql(4),'yaxislocation','right');

sql(3) = subplot(4,2,3);
bar([1:length(layr)],Q_OCEN(gv(layr),:,2),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(3),'position',[0.0782    0.5324    0.5413    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt);%set(sql(3),'XTickLabel',[])
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel('NADBC0'); set(yl,'rotation',90); %set(yl,'position',[-1.5    0.5000]);

sql(6)= subplot(4,2,6);
bar([1:length(prof)],Q_OCEN(gv(prof),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(6),'position',[0.6393    0.3235    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xtt);
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
set(sql(6),'yaxislocation','right');

sql(5) = subplot(4,2,5);
bar([1:length(layr)],Q_OCEN(gv(layr),:,3),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(5),'position',[0.0782    0.3235    0.5413    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(gca,'XTickLabel',xt);% set(gca,'XTickLabel',[])
set(gca,'XTickLabelRot',0); set(gca,'FontSize',10);
yl = ylabel('NANLC0'); set(yl,'rotation',90); %set(yl,'position',[-1.5    0.5000]);

sql(8)= subplot(4,2,8);
bar([1:length(prof)],Q_OCEN(gv(prof),:,4),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(8),'position',[0.6293    0.1315    0.3301    0.18]);
set(gca,'xtick',[1:length(prof)]);set(gca, 'ytick',[0:.2:1])
set(sql(8),'XTickLabel',prof_x);
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
set(sql(8),'yaxislocation','right');

sql(7) = subplot(4,2,7);
bar([1:length(layr)],Q_OCEN(gv(layr),:,4),'barwidth',1,'edgecolor','none'); ylim([0,1]);
% set(sql(7),'position',[0.0782    0.1315    0.5413    0.18]);
set(gca,'xtick',[1:length(layr)]);set(gca, 'ytick',[0:.2:1])
set(sql(7),'XTickLabel',layr_x);
set(gca,'XTickLabelRot',30); set(gca,'FontSize',10);
yl = ylabel('ONDPC0'); set(yl,'rotation',90); %et(yl,'position',[-1.5    0.5000]);

ylim(sql,[0,1]);
mt = mtit(['Adjusted Quality Scores: Ocean']);
set(mt.th,'fontsize',15,'position',[0.5000    1.0400]);

nn = 1; n_str = [num2str(nn)];
png_out = ['Qadj[reduced].OCEN.',n_str,'.png'];
while isafile([ACCP_pngs,png_out])
    nn = nn+1; n_str = ['_',num2str(nn)];
    png_out = ['Qadj[reduced].OCEN.',n_str,'.png'];
end
saveas(gcf,[ACCP_pngs,png_out]);
%     set(cf,'visib',true);
%     saveas(cf,[ACCP_pngs,strrep(png_out,'.png','.fig')]);
close(gcf);

ppt_add_slide_no_title(pptname, [ACCP_pngs,png_out]);



return
