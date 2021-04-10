function ACCP_pngs_ppts_v18(gv, gv2)
% Shell function for reading and then plotting ACCP results
% Created June 4, 2020 by Connor.
% Expected to be modified, customized repeatedly to support various
% Collections of plots
% Incorporating mean QIs in bar plot as per Sharon's request. Does not yet
% Mask MER and RMS when QIS are invalid, display when occurs.
% v5 Include a title slide with versions of supplied data, and M1 process
% with limited GVs
% v6: modified to use plot_ACCP_cases_V3 (with OUX included), added ACCP_ppts as a namedpath
% v7: updated to current plot_ACCP_* functions
% v8: updated to use plot_ACCP_QMR_V8
% v9: updated to use read_all_ACCP_8K_samplefiles_v7
% v10: allow gv, gv2 as input args
% v11: uses plot_ACCP_cases_v7 fixing index error in NLP files
% v12: Use only supplied reso, default to RES1, calls plot_ACCP_QMR_v9, plot_ACCP_cases_V8
% v13: Adding back in RES5 for GV[48:53], else RES1, plot_ACCP_QMR_V10, plot_ACCP_cases_V9
% v14: weighted averages, plot_ACCP_QMR_v11
% v15: compute means and weighted means only for cases when all PLTF exist
% v16: Apply adjustments, prepare to write AQS for all 4 platforms (fixed
% bug passing RES5 into plot_ACCP_Q_adjust_V2 and plot_ACCP_QMR_V13
% v17: fixed RES5-related issues found by Jens. Changed order of SRFC to [OCEN, LNDD, LNDV]
% to faciliate hand-checking adjusted values since OCEN has no average. 
% Duplicate write_AQS to double-check same results wi/wio pngs.
% V18: Call ACCP_Q_adjust_V2_nopng.  Added stats.  Call plot_ACCP_Q_adjust_V3

ACCP = setnamedpath('ACCP',['C:\case_studies\ACCP\'],'Select base path to ACCP folder');
ACCP_set = setnamedpath('ACCP_set','','Select the root of the current data set');
ACCP_pngs = setnamedpath('ACCP_pngs',[],'Select a directory for AACP png files, creating if necessary.');
PPT_path = setnamedpath('ACCP_ppts',[],'Select a directory for AAPC ppt files, create if necessary.');

tic
% The clear statement is unneeded in normal usage but helps in debug
clear QIS MER RMSexit
[QIS, MER, RMS,VERS,files] = read_all_ACCP_8K_samplefiles_v7(ACCP_set);
qnan = isNaN(QIS); len = length(QIS(~qnan));

% Find unique versions for each group (based on file names) 
group = unique(VERS(:,1));
for grp = length(group):-1:1
    gi = find(strcmpi(VERS(:,1),group{grp}));
    vi(grp) = strjoin([group(grp),string(sprintf('(%3.0d files): ',length(gi))), unique(VERS(gi,7))']);
end
vi = vi';

%These are the main GVs in the current analysis as per "GV_table_template_8K_V4_comments.docx"
if ~isavar('gv')
    gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73];
end
% Capture current time in dnow to use for all datestamps in this run
dnow = now; nn = 1; n_str = ['_',num2str(nn)];

% [QI_adj_, Q_mean, Q_std,Q_min,Q_max] = stats_ACCP_Q_adjust_V2_nopng(QIS,gv);
%Increment pptname to avoid over-write
pptname = ['ACCP_3x3.QwMR.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
while isafile([PPT_path, pptname])
    nn = nn+1; n_str = ['_',num2str(nn)];
    pptname = ['ACCP_3x3.QwMR.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end

% Create a title slide for QMR ppt with number of files and versions.
figure;
tl = title({['ACCP 8k Assessment'];pptname}); set(tl,'Fontsize',16);
grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
tx = text(.1,.5,vi);set(tx,'FontSize',16);
png_name1 = ['ACCP_QMwR_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
saveas(gcf,[ACCP_pngs,png_name1]);close(gcf);
ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name1]);

pptname3 = ['ACCP.Q_adj.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
while isafile([PPT_path, pptname3])
    nn = nn+1; n_str = ['_',num2str(nn)];
    pptname3 = ['ACCP.Q_adj.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end
figure;
tl = title({['ACCP 8k Assessment'];pptname3}); set(tl,'Fontsize',16);
grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
tx = text(.1,.5,vi);set(tx,'FontSize',16);
png_name3 = ['ACCP_Q_adjusted_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
saveas(gcf,[ACCP_pngs,png_name3]);close(gcf);
ppt_add_slide_no_title([PPT_path pptname3], [ACCP_pngs,png_name3]);

% I have checked output QI_adj below and _nopng matches perfectly
[QI_adj, Q_noadj] = ACCP_Q_adjust_V3_nopng(QIS,gv,'RES1');
pltf = ["SSP0", "SSP1", "SSP2", "SSG3"];
write_AQS(QI_adj,pltf, Q_noadj);
[QI_adj_] = plot_ACCP_Q_adjust_V3(QIS,gv,'RES1', [PPT_path pptname3]);
% pltf = ["SSP0", "SSP1", "SSP2", "SSG3"];
% write_AQS(QI_adj,pltf);
% QIS_adj(H,L=obs,pltf,m=srfc);
%QIS_adj is an output which we'll use to generate 4 sheets one per (PLTF)
% Each PLTF will have 2*GV rows (GVx(land, ocean)), 3 cols (NAD, NAN, OND)

plot_ACCP_QaMR_V1(QIS,QI_adj,MER,RMS,gv,'OCEN','RES1', [PPT_path pptname]);
plot_ACCP_QaMR_V1(QIS,QI_adj,MER,RMS,gv,'LNDD','RES1', [PPT_path pptname]);
plot_ACCP_QaMR_V1(QIS,QI_adj,MER,RMS,gv,'LNDV','RES1', [PPT_path pptname])


%Increment pptname to avoid over-write
n_str = ['_',num2str(nn)];
pptname = ['ACCP_3x1.Qall_6a-i.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
while isafile([PPT_path, pptname])
    nn = nn+1; n_str = ['_',num2str(nn)];
    pptname = ['ACCP_3x1.Qall_6a-i.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end
% Create a title slide for Qall_6a-i ppt with number of files and versions.
figure;
tl = title({['ACCP 8k Assessment'];pptname}); set(tl,'Fontsize',16);
grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
tx = text(.1,.5,vi);set(tx,'FontSize',16);
png_name2 = ['ACCP_Qall6-i_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
saveas(gcf,[ACCP_pngs,png_name2]);close(gcf);
ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name2]);

% Plot breakout cases for LNDD, LNDV, OCEN
plot_ACCP_cases_V9(QIS,MER,RMS,gv,'OCEN','RES1', [PPT_path pptname]);
plot_ACCP_cases_V9(QIS,MER,RMS,gv,'LNDD','RES1', [PPT_path pptname]);
plot_ACCP_cases_V9(QIS,MER,RMS,gv,'LNDV','RES1', [PPT_path pptname]);


% If set up with M1 sub-directory, run those as well
if isadir([ACCP_set, 'M1',filesep])
    
    pptname = ['ACCP_3x3.QwMR.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    ACCP_set = [ACCP_set, 'M1',filesep];
    % Run reduced set of GVs for M1 set
    if ~isavar('gv2')
        gv2= [48:53];
    end
    clear QIS MER RMS
    [QIS, MER, RMS,VERS,files] = read_all_ACCP_8K_samplefiles_v7(ACCP_set);
    qnan = isNaN(QIS); len = length(QIS(~qnan));
    group = unique(VERS(:,1)); clear vi
    for grp = length(group):-1:1
        gi = find(strcmpi(VERS(:,1),group{grp}));
        vi(grp) = strjoin([group(grp),string(sprintf('(%3.0d files): ',length(gi))), unique(VERS(gi,7))']);
    end
    vi = vi';
    
    figure;
    tl = title({['ACCP 8k Assessment with NLP M1'];pptname}); set(tl,'Fontsize',16);
    grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
    tx = text(.1,.5,vi);set(tx,'FontSize',16);
    png_name1 = ['ACCP_QwMR_M1_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
    saveas(gcf,[ACCP_pngs,png_name1]);close(gcf);
    ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name1]);

    plot_ACCP_QMR_V13(QIS,MER,RMS,gv2,'OCEN','RES1', [PPT_path pptname]);
    plot_ACCP_QMR_V13(QIS,MER,RMS,gv2,'LNDD','RES1', [PPT_path pptname]);
    plot_ACCP_QMR_V13(QIS,MER,RMS,gv2,'LNDV','RES1', [PPT_path pptname])

    
    pptname = ['ACCP_3x1.Qall_6a-i.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    figure;
    tl = title({['ACCP 8k Assessment with NLP M1'];pptname}); set(tl,'Fontsize',16);
    grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
    tx = text(.1,.5,vi);set(tx,'FontSize',16);
    png_name2 = ['ACCP_Qall6-i_M1_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
    saveas(gcf,[ACCP_pngs,png_name2]);close(gcf);
    ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name2]);
    plot_ACCP_cases_V9(QIS,MER,RMS,gv2,'OCEN','RES1', [PPT_path pptname]);
    plot_ACCP_cases_V9(QIS,MER,RMS,gv2,'LNDD','RES1', [PPT_path pptname]);
    plot_ACCP_cases_V9(QIS,MER,RMS,gv2,'LNDV','RES1', [PPT_path pptname]);
    
end

toc

return