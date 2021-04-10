function ACCP_pngs_ppts_v7
% Shell function for reading and then plotting ACCP results
% Created June 4, 2020 by Connor.
% Expected to be modified, customized repeatedly to support various
% Collections of plots
% Incorporating mean QIs in bar plot as per Sharon's request. Does not yet
% Mask MER and RMS when QIS are invalid, display when occurs.
% v5 Include a title slide with versions of supplied data, and M1 process
% with limited GVs
% v6: modified to use plot_ACCP_cases_V3 (with OUX included), added
% ACCP_ppts as a namedpath


ACCP = setnamedpath('ACCP',['C:\case_studies\ACCP\'],'Select base path to ACCP folder');
ACCP_set = setnamedpath('ACCP_set','','Select the root of the current data set');
ACCP_pngs = setnamedpath('ACCP_pngs',[],'Select a directory for AACP png files, creating if necessary.');
PPT_path = setnamedpath('ACCP_ppts',[],'Select a directory for AAPC ppt files, create if necessary.');

tic
% The clear statement is unneeded in normal usage but helps in debug
clear QIS MER RMS
[QIS, MER, RMS,VERS,files] = read_all_ACCP_8K_samplefiles_v6(ACCP_set);
qnan = isNaN(QIS); len = length(QIS(~qnan));

% Find unique versions for each group (based on file names) 
group = unique(VERS(:,1));
for grp = length(group):-1:1
    gi = find(strcmpi(VERS(:,1),group{grp}));
    vi(grp) = strjoin([group(grp),string(sprintf('(%3.0d files): ',length(gi))), unique(VERS(gi,7))']);
end
vi = vi';

%These are the main GVs in the current analysis as per "GV_table_template_8K_V4_comments.docx"
gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73];

% Capture current time in dnow to use for all datestamps in this run
dnow = now; n_str = '';nn = 1;

%Increment pptname to avoid over-write
pptname = ['ACCP_3x3.QMR.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
while isafile([PPT_path, pptname])
    nn = nn+1; n_str = ['_',num2str(nn)];
    pptname = ['ACCP_3x3.QMR.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end

% Create a title slide for QMR ppt with number of files and versions.
figure;
tl = title({['ACCP 8k Assessment'];pptname}); set(tl,'Fontsize',16);
grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
tx = text(.1,.5,vi);set(tx,'FontSize',16);
png_name1 = ['ACCP_QMR_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
saveas(gcf,[ACCP_pngs,png_name1]);close(gcf);
ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name1]);

% Plot QMR for LNDD, LNDV, OCEN
plot_ACCP_QMR_V7(QIS,MER,RMS,gv,'LNDD','RES1', [PPT_path pptname]);
plot_ACCP_QMR_V7(QIS,MER,RMS,gv,'LNDV','RES1', [PPT_path pptname])
plot_ACCP_QMR_V7(QIS,MER,RMS,gv,'OCEN','RES1', [PPT_path pptname]);

%Increment pptname to avoid over-write
n_str = '';nn = 1;
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
plot_ACCP_cases_V5(QIS,MER,RMS,gv,'LNDD','RES1', [PPT_path pptname]);
plot_ACCP_cases_V5(QIS,MER,RMS,gv,'LNDV','RES1', [PPT_path pptname]);
plot_ACCP_cases_V5(QIS,MER,RMS,gv,'OCEN','RES1', [PPT_path pptname]);

% If set up with M1 sub-directory, run those as well
if isadir([ACCP_set, 'M1',filesep])
    
    pptname = ['ACCP_3x3.QMR.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    ACCP_set = [ACCP_set, 'M1',filesep];
    % Run reduced set of GVs for M1 set
    gv = [48:51];
    clear QIS MER RMS
    [QIS, MER, RMS,VERS,files] = read_all_ACCP_8K_samplefiles_v6(ACCP_set);
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
    png_name1 = ['ACCP_QMR_M1_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
    saveas(gcf,[ACCP_pngs,png_name1]);close(gcf);
    ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name1]);
    
    plot_ACCP_QMR_V7(QIS,MER,RMS,gv,'LNDD','RES1', [PPT_path pptname]);
    plot_ACCP_QMR_V7(QIS,MER,RMS,gv,'LNDV','RES1', [PPT_path pptname])
    plot_ACCP_QMR_V7(QIS,MER,RMS,gv,'OCEN','RES1', [PPT_path pptname]);
    
    pptname = ['ACCP_3x1.Qall_6a-i.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    figure;
    tl = title({['ACCP 8k Assessment with NLP M1'];pptname}); set(tl,'Fontsize',16);
    grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
    tx = text(.1,.5,vi);set(tx,'FontSize',16);
    png_name2 = ['ACCP_Qall6-i_M1_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
    saveas(gcf,[ACCP_pngs,png_name2]);close(gcf);
    ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name2]);
    plot_ACCP_cases_V5(QIS,MER,RMS,gv,'LNDD','RES1', [PPT_path pptname]);
    plot_ACCP_cases_V5(QIS,MER,RMS,gv,'LNDV','RES1', [PPT_path pptname]);
    plot_ACCP_cases_V5(QIS,MER,RMS,gv,'OCEN','RES1', [PPT_path pptname]);
    
end

toc

return