function ACCP_pngs_ppts_v6
% Shell function for reading and then plotting ACCP results
% Created June 4, 2020 by Connor.
% Expected to be modified, customized repeatedly to support various
% Collections of plots
% Incorporating mean QIs in bar plot as per Sharon's request. Does not yet
% Mask MER and RMS when QIS are invalid, display when occurs.
% v5 Include a title slide with versions of supplied data, and M1 process
% with limited GVs
% v6: modified to use plot_ACCP_cases_V3 (with OUX included) 

ACCP = setnamedpath('ACCP',['C:\case_studies\ACCP\'],'Select base path to ACCP folder');
ACCP_set = setnamedpath('ACCP_set','','Select the root of the current data set');
ACCP_pngs = setnamedpath('ACCP_pngs',[],'Select a directory for AACP png files, creating if necessary.');
PPT_path = [ACCP_pngs, '..',filesep];
tic
% The clear statement is unneeded in normal usage but helps in debug
clear QIS MER RMS
[QIS, MER, RMS,VERS,files] = read_all_ACCP_8K_samplefiles_v4(ACCP_set);
qnan = isNaN(QIS); len = length(QIS(~qnan));
% Find unique versions for each group (based on file names)
group = unique(VERS(:,1));
for grp = length(group):-1:1
    gi = find(strcmpi(VERS(:,1),group{grp}));
    vi(grp) = strjoin([group(grp),string(sprintf('(%1.0d files): ',length(gi))), unique(VERS(gi,7))']);
end
vi = vi';

gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73];

dnow = now; n_str = '';n = 0;

pptname = ['ACCP_3x3.QMR.v5.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
while isafile([PPT_path, pptname])
    n = n+1; n_str = num2str(n);
    pptname = ['ACCP_3x3.QMR.v5.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end

figure;
tl = title({['ACCP 8k Assessment'];pptname}); set(tl,'Fontsize',16);
grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
tx = text(.1,.5,vi);set(tx,'FontSize',16);
png_name1 = ['ACCP_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
saveas(gcf,[ACCP_pngs,png_name1]);close(gcf);
ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name1]);

plot_ACCP_QMR_V5(QIS,MER,RMS,gv,'LNDD','RES1', [PPT_path pptname]);
plot_ACCP_QMR_V5(QIS,MER,RMS,gv,'LNDV','RES1', [PPT_path pptname])
plot_ACCP_QMR_V5(QIS,MER,RMS,gv,'OCEN','RES1', [PPT_path pptname]);

pptname = ['ACCP_3x1.Qall_6a-i.v2.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
figure;
tl = title({['ACCP 8k Assessment'];pptname}); set(tl,'Fontsize',16);
grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
tx = text(.1,.5,vi);set(tx,'FontSize',16);
png_name2 = ['ACCP_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
saveas(gcf,[ACCP_pngs,png_name2]);close(gcf);
ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name2]);
plot_ACCP_cases_V3(QIS,MER,RMS,gv,'LNDD','RES1', [PPT_path pptname]);
plot_ACCP_cases_V3(QIS,MER,RMS,gv,'LNDV','RES1', [PPT_path pptname]);
plot_ACCP_cases_V3(QIS,MER,RMS,gv,'OCEN','RES1', [PPT_path pptname]);


if isadir([ACCP_set, 'M1',filesep])
    
    pptname = ['ACCP_3x3.QMR.v5.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    ACCP_set = [ACCP_set, 'M1',filesep];
    gv = [48:51];% Only extinction GVs for "M1"
    clear QIS MER RMS
    [QIS, MER, RMS,VERS,files] = read_all_ACCP_8K_samplefiles_v4(ACCP_set);
    qnan = isNaN(QIS); len = length(QIS(~qnan));
    group = unique(VERS(:,1)); clear vi
    for grp = length(group):-1:1
        gi = find(strcmpi(VERS(:,1),group{grp}));
        vi(grp) = strjoin([group(grp),string(sprintf('(%1.0d files): ',length(gi))), unique(VERS(gi,7))']);
    end
    vi = vi';
    
    figure;
    tl = title({['ACCP 8k Assessment with NLP M1'];pptname}); set(tl,'Fontsize',16);
    grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
    tx = text(.1,.5,vi);set(tx,'FontSize',16);
    png_name1 = ['ACCP_title_M1_',datestr(dnow,'yyyy-mm-dd'),'.png'];
    saveas(gcf,[ACCP_pngs,png_name1]);close(gcf);
    ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name1]);
    
    plot_ACCP_QMR_V5(QIS,MER,RMS,gv,'LNDD','RES1', [PPT_path pptname]);
    plot_ACCP_QMR_V5(QIS,MER,RMS,gv,'LNDV','RES1', [PPT_path pptname])
    plot_ACCP_QMR_V5(QIS,MER,RMS,gv,'OCEN','RES1', [PPT_path pptname]);
    
    pptname = ['ACCP_3x1.Qall_6a-i.v2.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    figure;
    tl = title({['ACCP 8k Assessment with NLP M1'];pptname}); set(tl,'Fontsize',16);
    grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
    tx = text(.1,.5,vi);set(tx,'FontSize',16);
    png_name2 = ['ACCP_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
    saveas(gcf,[ACCP_pngs,png_name2]);close(gcf);
    ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name2]);
    plot_ACCP_cases_V3(QIS,MER,RMS,gv,'LNDD','RES1', [PPT_path pptname]);
    plot_ACCP_cases_V3(QIS,MER,RMS,gv,'LNDV','RES1', [PPT_path pptname]);
    plot_ACCP_cases_V3(QIS,MER,RMS,gv,'OCEN','RES1', [PPT_path pptname]);
    
end

% pptname = [ACCP_pngs,'..',filesep,'ACCP_3x1.DRSx.ppt'];
% plot_ACCP_DRS_V3(QIS,MER,RMS,gv,'LNDD','RES1', pptname);
% plot_ACCP_DRS_V3(QIS,MER,RMS,gv,'OCEN','RES1', pptname);
toc

return