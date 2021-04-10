function ACCP_SITA_Sept_pngs_ppts_v5(gv, gv2)
% Shell function for reading and then plotting ACCP results
% Created Sept 1, 2020 by Connor.
% Expected to be modified, customized repeatedly to support various
% Collections of plots
% MER and RMS are masked when QIS are invalid
% Incorporating mean QIs in bar plot as per Sharon's request. Does not yet
% Mask MER and RMS when QIS are invalid, display when occurs.
% v1 Include a title slide with versions of supplied data
% Implementing current analogs to QRM 3x3 and case 3x1.
% plot_ACCP_QMR_vN ==> plot_SITA_Sept_QMR_vN
% plot_ACCP_cases_vN ==> plot_SITA_Sept_cases_vN

% v1: Initial version
% v2: Now RES4 for GV52-55, RES5 for GV50-51, unless missing then RES1 
%     These changes are within the plotting routines.
% v3: use read_SITA_Sept_samplefiles_v2 which fills SSP1 and SSP2 from SSP0
% for ONDPC0 for NLB and OUX
% v4: use plot_SITA_Sept_QMR_v3 which applies nanmean
% v5: add M1 back in.

% To do: 
%   Comment out, ignore NGE GV11 results
%   Replicate 
% Calls:
%   read_all_SITA_Sept_samplefiles_v2
%   plot_SITA_Sept_cases_v2
%   plot_SITA_Sept_QMR_v3

ACCP = setnamedpath('ACCP',['C:\case_studies\ACCP\'],'Select base path to ACCP folder');
ACCP_set = setnamedpath('ACCP_set','','Select the root of the current data set');
ACCP_pngs = setnamedpath('ACCP_pngs',[],'Select a directory for AACP png files, creating if necessary.');
PPT_path = setnamedpath('ACCP_ppts',[],'Select a directory for AAPC ppt files, create if necessary.');

tic
% The clear statement is unneeded in normal usage but helps in debug
clear QIS MER RMSexit
[QIS, MER, RMS,VERS,files] = read_all_SITA_Sept_samplefiles_v2(ACCP_set);
qnan = isNaN(QIS); len = length(QIS(~qnan));

% Find unique versions for each group (based on file names) 
group = unique(VERS(:,1));
for grp = length(group):-1:1
    gi = find(strcmpi(VERS(:,1),group{grp}));
    vi(grp) = strjoin([group(grp),string(sprintf('(%3.0d files): ',length(gi))), unique(VERS(gi,7))']);
end
vi = vi';

% [~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
if ~isavar('gv')
    gv = [1:65];
end
% Capture current time in dnow to use for all datestamps in this run
dnow = now; nn = 1; n_str = ['_',num2str(nn)];

% [QI_adj_, Q_mean, Q_std,Q_min,Q_max] = stats_ACCP_Q_adjust_V2_nopng(QIS,gv);
%Increment pptname to avoid over-write
pptname = ['ACCP_QMR_3xN.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
while isafile([PPT_path, pptname])
    nn = nn+1; n_str = ['_',num2str(nn)];
    pptname = ['ACCP_QMR_3xN.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end

% Create a title slide for QMR ppt with number of files and versions.
figure_(1);
tl = title({['ACCP SIT-A 8k Sept Assessment'];pptname}); set(tl,'Fontsize',16);
grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
tx = text(.1,.5,vi);set(tx,'FontSize',16);
png_name1 = ['ACCP_Sept_QMR_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
saveas(gcf,[ACCP_pngs,png_name1]);close(gcf);
ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name1]);

%Increment pptname to avoid over-write
n_str = ['_',num2str(nn)];
pptname2 = ['ACCP_Q8a-o.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
while isafile([PPT_path, pptname2])
    nn = nn+1; n_str = ['_',num2str(nn)];
    pptname2 = ['ACCP_Q8a-o.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end

figure;
tl = title({['ACCP 8k Assessment'];pptname}); set(tl,'Fontsize',16);
grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
tx = text(.1,.5,vi);set(tx,'FontSize',16);
png_name2 = ['ACCP_Qall8a-o_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
saveas(gcf,[ACCP_pngs,png_name2]);close(gcf);
ppt_add_slide_no_title([PPT_path pptname2], [ACCP_pngs,png_name2]);

obs = ["NADLC0", "NADBC0", "NANLC0","ONDPC0"];

% Plot breakout cases for LAND, OCEN
plot_SITA_Sept_QMR_v3(QIS,MER,RMS,gv,'LAND',obs,'RES1', [PPT_path pptname]);
plot_SITA_Sept_QMR_v3(QIS,MER,RMS,gv,'OCEN',obs,'RES1', [PPT_path pptname]);

plot_SITA_Sept_cases_v2(QIS,gv,'LAND',obs,'RES1', [PPT_path pptname2]);
plot_SITA_Sept_cases_v2(QIS,gv,'OCEN',obs,'RES1', [PPT_path pptname2]);


% If set up with M1 sub-directory, run those as well
if isadir([ACCP_set, '_M1',filesep])
    
    pptname = ['ACCP_QMR_3xN.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    ACCP_set = [ACCP_set, '_M1',filesep];
    % Run reduced set of GVs for M1 set
    if ~isavar('gv2')
        gv2= [50:55];
    end
    clear QIS MER RMS
    [QIS, MER, RMS,VERS,files] = read_all_SITA_Sept_samplefiles_v2(ACCP_set);
    qnan = isNaN(QIS); len = length(QIS(~qnan));
    group = unique(VERS(:,1)); clear vi
    for grp = length(group):-1:1
        gi = find(strcmpi(VERS(:,1),group{grp}));
        vi(grp) = strjoin([group(grp),string(sprintf('(%3.0d files): ',length(gi))), unique(VERS(gi,7))']);
    end
    vi = vi';
    
    figure;
    tl = title({['ACCP SIT-A 8k Sept Assessment with NLP M1'];pptname}); set(tl,'Fontsize',16);
    grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
    tx = text(.1,.5,vi);set(tx,'FontSize',16);
    png_name1 = ['ACCP_Sept_QMR_M1_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
    saveas(gcf,[ACCP_pngs,png_name1]);close(gcf);
    ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name1]);

% Plot breakout cases for LAND, OCEN
plot_SITA_Sept_QMR_v3(QIS,MER,RMS,gv2,'LAND',obs,'RES1', [PPT_path pptname]);
plot_SITA_Sept_QMR_v3(QIS,MER,RMS,gv2,'OCEN',obs,'RES1', [PPT_path pptname]);



    pptname2 = ['ACCP_Q8a-o.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    figure;
    tl = title({['ACCP SIT-A Case-wise Assessment with NLP M1'];pptname2}); set(tl,'Fontsize',16);
    grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
    tx = text(.1,.5,vi);set(tx,'FontSize',16);
    png_name2 = ['ACCP_Qall8a-o_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
    saveas(gcf,[ACCP_pngs,png_name2]);close(gcf);
    ppt_add_slide_no_title([PPT_path pptname2], [ACCP_pngs,png_name2]);
    
    plot_SITA_Sept_cases_v2(QIS,gv2,'LAND',obs,'RES1', [PPT_path pptname2]);
    plot_SITA_Sept_cases_v2(QIS,gv2,'OCEN',obs,'RES1', [PPT_path pptname2]);
    
end

toc

return