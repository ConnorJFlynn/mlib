function ACCP_SITA_Sept_pngs_ppts_v18(gv, gv2)
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
% v6: use read_all_SITA_Sept_samplefiles_v3 (temporary fix for NGE issues
% v7: revert to reader version 1 to investigate issues in GoogleDoc
% v8: Stay with reader version 1, use plot_*cases_v3
% v9: Use new reader v4, trying to propgate NGE SSP2 to SSG3 and mask GV11
% v10: generate VF files (and fixed problem in read_all_SITA_Sept_samplefiles_v4)
% v11: generate Lidar-Only LO VF files 
% v12: use plot_SITA_Sept_cases_v4 fixing NLB problem with GV 50-55
% V13: use read*v5 propagating Kathy's NLP SSP2 into SSG3, affecting means
% V14: left space in case I forgot to save before V15
% V15: applying reviewer adjustments...
% V16: No objective averages, add adjustments and QMRadj plot
% V17: adding plot of QISadj with reduced layr and prof GVs by Objective for NAD&NAD
% for Land and Ocen after 
% V18: Apply adj before OW.
% To do: 
%   Comment out, ignore NGE GV11 results
%   Replicate 
% Calls:
%   read_all_SITA_Sept_samplefiles_v5
%   plot_SITA_Sept_cases_v4
%   plot_SITA_Sept_QMR_v3

ACCP = setnamedpath('ACCP',['C:\case_studies\ACCP\'],'Select base path to ACCP folder');
ACCP_set = setnamedpath('ACCP_set','','Select the root of the current data set');

tic
% The clear statement is unneeded in normal usage but helps in debug
clear QIS MER RMSexit
[QIS, MER, RMS,VERS,files] = read_all_SITA_Sept_samplefiles_v5(ACCP_set);
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
QISadj = apply_Sept_adj_to_QIS(QIS);
OQS = apply_OWCs_v2(QISadj); % Apply objective weights after reviewer adjustment
OQSLO = apply_OWCs_LO_v2(QISadj);
plot_OQSadj_v2(OQS);
% 

ACCP_pngs = setnamedpath('ACCP_pngs',[],'Select a directory for AACP png files, creating if necessary.');
PPT_path = setnamedpath('ACCP_ppts',[],'Select a directory for AAPC ppt files, create if necessary.');

% [QI_adj_, Q_mean, Q_std,Q_min,Q_max] = stats_ACCP_Q_adjust_V2_nopng(QIS,gv);
%Increment pptname to avoid over-write
pptname = ['ACCP_QMRadj_3xN.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
while isafile([PPT_path, pptname])
    nn = nn+1; n_str = ['_',num2str(nn)];
    pptname = ['ACCP_QMRadj_3xN.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end

% Create a title slide for QMR ppt with number of files and versions.
figure_(1);
tl = title({['ACCP SIT-A 8k Sept Assessment'];pptname}); set(tl,'Fontsize',16);
grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
tx = text(.1,.5,vi);set(tx,'FontSize',16);
png_name1 = ['ACCP_Sept_QMR_adj_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
saveas(gcf,[ACCP_pngs,png_name1]);close(gcf);
ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name1]);

%Increment pptname to avoid over-write
n_str = ['_',num2str(nn)];
pptname2 = ['ACCP_Q8a-o.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
while isafile([PPT_path, pptname2])
    nn = nn+1; n_str = ['_',num2str(nn)];
    pptname2 = ['ACCP_Q8a-o.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
end

figure_(1);
tl = title({['ACCP 8k Assessment'];pptname}); set(tl,'Fontsize',16);
grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
tx = text(.1,.5,vi);set(tx,'FontSize',16);
png_name2 = ['ACCP_Qall8a-o_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
saveas(gcf,[ACCP_pngs,png_name2]);close(gcf);
ppt_add_slide_no_title([PPT_path pptname2], [ACCP_pngs,png_name2]);

obs = ["NADLC0", "NADBC0", "NANLC0","ONDPC0"];
% So, I think I need to apply the SITA_Sept_adj adjustments to the QIS
% score, and then feed that to apply_OWCs functions.
% However, it would be valuable to see the Means, ObjMeans, MeansAdj and ObjMeansAdj

% Plot QMRadj summaries...
plot_SITA_Sept_Qadj_v1(QIS,MER,RMS,gv,obs,'RES1', [PPT_path pptname]);

% Plot QMR summaries...
plot_SITA_Sept_QMRadj_v1(QIS,MER,RMS,gv,'LAND',obs,'RES1', [PPT_path pptname]);
plot_SITA_Sept_QMRadj_v1(QIS,MER,RMS,gv,'OCEN',obs,'RES1', [PPT_path pptname]);



% Plot breakout cases for LAND, OCEN
plot_SITA_Sept_cases_v4(QIS,gv,'LAND',obs,'RES1', [PPT_path pptname2]);
plot_SITA_Sept_cases_v4(QIS,gv,'OCEN',obs,'RES1', [PPT_path pptname2]);




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
    
    plot_SITA_Sept_cases_v4(QIS,gv2,'LAND',obs,'RES1', [PPT_path pptname2]);
    plot_SITA_Sept_cases_v4(QIS,gv2,'OCEN',obs,'RES1', [PPT_path pptname2]);
    
end

toc

return