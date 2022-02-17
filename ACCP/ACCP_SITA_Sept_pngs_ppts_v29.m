function ACCP_SITA_Sept_pngs_ppts_v29(gv, gv2, do_plot)
% ACCP_SITA_Sept_pngs_ppts_v28(gv, gv2, do_plot)
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
% FYI: Introduction of C1,C2 and LIC has unexepected sneaky effects when
% applying adjustments or computing objective weights unless the bounds of
% the related averaging functions are expanded accordingly.  Functions
% within ObjQIS_v2 do so, but be cautious with older code versions.
% v29, generate output for Tyler Thorsen
% v28, Update propagated fields, incorporate new ObjQIS, apply_OW_C1_v2, output_OWs_C1_v2
% v27, Incorporate LIC results
% v26, 2020-10-28: refactoring to avoid ambiguous OQS files without clear
% indication of whether adjustmeents are applied or not.  Dangerous!
% v25: Preparing slides for Jens Oct presentation.3x2, objective weighted,
% w/wo adjustements opaque, and transparent.
% V24: Apply Oct adj and output Objective weights to VF files.
% V23: add in RMS lidar-only and combined plots as per Snorre
% V22: more C0 C1 plots
% V21: Incorporate boolean for plots.  Incorporate cirrus scores.
% V19: propagate v18 changes into section for M1 at the end.
% V18: Apply adj before OW.
% V17: adding plot of QISadj with reduced layr and prof GVs by Objective for NAD&NAD
% for Land and Ocen after
% V16: No objective averages, add adjustments and QMRadj plot
% V15: applying reviewer adjustments...
% V14: left space in case I forgot to save before V15
% V13: use read*v5 propagating Kathy's NLP SSP2 into SSG3, affecting means
% v12: use plot_SITA_Sept_cases_v4 fixing NLB problem with GV 50-55
% v11: generate Lidar-Only LO VF files
% v10: generate VF files (and fixed problem in read_all_SITA_Sept_samplefiles_v4)
% v9: Use new reader v4, trying to propgate NGE SSP2 to SSG3 and mask GV11
% v8: Stay with reader version 1, use plot_*cases_v3
% v7: revert to reader version 1 to investigate issues in GoogleDoc
% v6: use read_all_SITA_Sept_samplefiles_v3 (temporary fix for NGE issues
% v5: add M1 back in.
% v4: use plot_SITA_Sept_QMR_v3 which applies nanmean
% v3: use read_SITA_Sept_samplefiles_v2 which fills SSP1 and SSP2 from SSP0
% for ONDPC0 for NLB and OUX
% v2: Now RES4 for GV52-55, RES5 for GV50-51, unless missing then RES1
%     These changes are within the plotting routines.
% v1: Initial version


% To do: clarify the code used to apply the adjustments, distinguishing
% from the original issues and the new (final) Oct adjustments
% Calls:
%   read_all_SITA_Sept_samplefiles_v8
%   plot_C0_C1_v1
%   plot_SITA_Sept_cases_v4
%   plot_SITA_Sept_QMR_v3

if ~isavar('gv')
    gv = [1:65];
end
% gv2 (used for M1) defaults to 50:55.  Specify as [] if desired to exclude M1 gvs
if ~isavar('gv2')
    gv2= [50:55];
end
if islogical(gv2)
    do_plot = gv2;
    gv2= [50:55];
end
% do_plot(1): QMRadj
% do_plot(2): Qadj
% do_plot(3): Q8a-o cases
% do_plot(4): QMRadj, M1
% do_plot(5): Qcases, M1
% do_plot(6): OQS, Objective-weighted, QS

if ~isavar('do_plot')
    do_plot = true(1,7);
end
if islogical(do_plot)&&length(do_plot)==1
    do_plot = true(1,7)&do_plot;
end

% Capture current time in dnow to use for all datestamps in this run
dnow = now; nn = 1; n_str = ['_',num2str(nn)];

ACCP = setnamedpath('ACCP',['C:\case_studies\ACCP\'],'Select base path to ACCP folder');
ACCP_set = setnamedpath('ACCP_set','','Select the root of the current data set');

tic
% The clear statement is unneeded in normal usage but helps in debug
clear QIS MER RMSexit
[QIS, MER, RMS,VERS,files] = read_all_SITA_Sept_samplefiles_v8(ACCP_set);
% Find unique versions for each group (based on file names)
group = unique(VERS(:,1));
for grp = length(group):-1:1
    gi = find(strcmpi(VERS(:,1),group{grp}));
    vi(grp) = strjoin([group(grp),string(sprintf('(%3.0d files): ',length(gi))), unique(VERS(gi,7))']);
end
vi = vi';
qnan = isNaN(QIS); len = length(QIS(~qnan));
qnan = isNaN(RMS); len = length(RMS(~qnan));
% Not really used.  Mainly just informative...
[Qall, Qgrp] = compute_Qall2(QIS); % No objective weighting applied, only mean over objective-specified cases
[meanRMSE, Rgrp] = compute_Qall2(RMS);
[meanMER, Mgrp] = compute_Qall2(MER);

%These are objective-weighted output, with and without adjustments.
% OWQadj are provided to VF team as ASCII files
% [OWQadj,OWQ] = ObjQIS(QIS);
[OWQadj,OWQ] = ObjQIS_v2_thor(QIS,true, 'adj'); % Calls apply_OWs_C1_v2 and output_OWs_C1_v2

ACCP_pngs = setnamedpath('ACCP_pngs',[],'Select a directory for AACP png files, creating if necessary.');
PPT_path = setnamedpath('ACCP_ppts',[],'Select a directory for AAPC ppt files, create if necessary.');

OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0",...
    "NADLC1","NANLC1","NADLC2","NANLC2"];% All defined obs modes
obs = ["NADLC0", "NADBC0", "NANLC0","ONDPC0"];% Clear sky retrievals
obc = ["NADLC1","NANLC1","NADLC2","NANLC2"]; %These involved cloud C1, C2 conditions

if do_plot(1)
    %Increment pptname to avoid over-write
    pptname = ['ACCP_QMRadj_3xN.',datestr(dnow,'yyyymmdd'),'.pptx'];
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

    % So, I think I need to apply the SITA_Sept_adj adjustments to the QIS
    % score, and then feed that to apply_OWCs functions.
    % However, it would be valuable to see the Means, ObjMeans, MeansAdj and ObjMeansAdj

    % Plot QMR summaries...
    % Each group individually averaged, then avg over group, then adjusted
    plot_SITA_Sept_QMRadj_v1(QIS,MER,RMS,gv,'LAND',obs,'RES1', [PPT_path pptname]);
    plot_SITA_Sept_QMRadj_v2(QIS,MER,RMS,gv,'OCEN',obs,'RES1', [PPT_path pptname]); %With LIC
    plot_SITA_Sept_QMRadj_v1(QIS,MER,RMS,gv,'LAND',obc,'RES1', [PPT_path pptname]);
    plot_SITA_Sept_QMRadj_v1(QIS,MER,RMS,gv,'OCEN',obc,'RES1', [PPT_path pptname]);
    
    if do_plot(2)
        % Plot QMRadj summaries... Land and Ocean, separate plots
        %Prf,lay, prof, layr resolved plots for NADLC0, NADBC0, NADLC0, ONDPC0
        plot_SITA_Sept_Qadj_v1(QIS,MER,RMS,gv,obs,'RES1', [PPT_path pptname]);
    end
end

if do_plot(3)
    %Increment pptname to avoid over-write
    n_str = ['_',num2str(nn)];
    pptname2 = ['ACCP_Q8a-o.',datestr(dnow,'yyyymmdd'),'.pptx'];
    while isafile([PPT_path, pptname2])
        nn = nn+1; n_str = ['_',num2str(nn)];
        pptname2 = ['ACCP_Q8a-o.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    end
    
    figure_(1);
    tl = title({['ACCP 8k Assessment'];pptname2}); set(tl,'Fontsize',16);
    grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
    tx = text(.1,.5,vi);set(tx,'FontSize',16);
    png_name2 = ['ACCP_Qall8a-o_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
    saveas(gcf,[ACCP_pngs,png_name2]);close(gcf);
    ppt_add_slide_no_title([PPT_path pptname2], [ACCP_pngs,png_name2]);
    
    % Plot breakout cases for LAND, OCEN
    plot_SITA_Sept_cases_v4(QIS,gv,'LAND',obs,'RES1', [PPT_path pptname2]);
    plot_SITA_Sept_cases_v4(QIS,gv,'OCEN',obs,'RES1', [PPT_path pptname2]);
    plot_SITA_Sept_cases_v4(QIS,gv,'LAND',obc,'RES1', [PPT_path pptname2]);
    plot_SITA_Sept_cases_v4(QIS,gv,'OCEN',obc,'RES1', [PPT_path pptname2]);
    
end
% DON'T USE: QISadj = apply_Sept_adj_2(QIS);  It is WRONG!!!
% Use apply_Oct_adj_to_QIS, returns QISadj of same dimensionality as QIS
% Then send to apply_OWCs_C1_v1
% Jens wants to see objective weights with and without adjustments for 2
% (Land/Ocen) 3x2 figures (cols: layr, prof, rows: NAD, NAN, OND) 
% I need to call "apply_OWCs_C1_v1" twice, once for QIS, once for QISadj
if do_plot(7)
  
if ~isavar('nn') nn = 1; end
    n_str = ['_',num2str(nn)];
    pptname3 = ['ACCP_Co_C1.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    while isafile([PPT_path, pptname3])
        nn = nn+1; n_str = ['_',num2str(nn)];
        pptname3 = ['ACCP_Co_C1.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
    end
    
    figure_(1);
    tl = title({['ACCP 8k Assessment'];pptname3}); set(tl,'Fontsize',16);
    grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
    tx = text(.1,.5,vi);set(tx,'FontSize',16);
    png_name3 = ['ACCP_Qall8a-o_CoC1_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
    saveas(gcf,[ACCP_pngs,png_name3]);close(gcf);
    ppt_add_slide_no_title([PPT_path pptname3], [ACCP_pngs,png_name3]);   
    plot_Qoall_C0_C1_v2B_2x2_alpha(Qall,[PPT_path pptname3]);% No adjustments
    plot_RMSgrpavg_LidarCombined_v2(meanRMSE, [PPT_path pptname3]);
    % Now with RMS for LC0, LC1 and also BC0 and LC1
    
end
%     plot_Qall_C0_C1_v2A(Qall,[PPT_path pptname3]);
% plot_Qall_C0_C1_v1(Qall,[PPT_path pptname3]);

% Use apply_Oct_adj_to_QIS, returns QISadj of same dimensionality as QIS
% Then send to apply_OWCs_C1_v1
% Then output VF files?

% I don't think plot_SITA_Oct_Qadj_v1 handles C1 cases...
% plot_SITA_Oct_Qadj_v1(QIS,MER,RMS,gv,obs,'RES1', [PPT_path pptname]);



% this first set of objective weights are applied to QIS without
% adjustments just to make it easier to confirm calculations are correct.
% OQS_C0 = apply_OWCs_v2(QIS,false); % Apply objective weights after reviewer adjustment
% OQS_C1 = apply_OWCs_C1_v1(QIS,false); %Apply objective weights with C1
% OQS_C0_by_grp = apply_OWCs_C0_v1_by_grp(QIS,false);
% OQS_C1_by_grp = apply_OWCs_C1_v1_by_grp(QIS,false);

% This second set is applied after adjustments which were derived from C0
% results only.
% OQS_C0 = apply_OWCs_v2(QISadj,false); % Apply objective weights after reviewer adjustment
% OQ_C1 = apply_OWCs_C1_v1(QIS,false); %Apply objective weights with C1 to unadjusted QIS
% OQS_C1 = apply_OWCs_C1_v1(QISadj,false); %Apply objective weights with C1
% 

% OQS_C0_by_grp = apply_OWCs_C0_v1_by_grp(QISadj,false);
% OQS_C1_by_grp = apply_OWCs_C1_v1_by_grp(QISadj,false);

% This block of code is just to permit examination of before/after
% objective weighted scores averaged over all groups, and for results from
% a select group (group 2 is NLB)
% g_ii = 0;
% g_ii = g_ii+1; obi = 1 ;sfc = 1; obj = 5; obj = obj-4;
% [OQS_C1(g_ii,:,obi,sfc,obj)./OQS_C0(g_ii,:,obi,sfc,obj); squeeze(OQS_C1_by_grp(g_ii,2,:,obi,sfc,obj)./OQS_C0_by_grp(g_ii,2,:,obi,sfc,obj))']

% OQSLO = apply_OWCs_LO_v2(QISadj);
% OWQadj,OWQ
% plot_OQSadj_v2 displays results provided to VF group for selected GVs
if do_plot(6)
    plot_OQS_wwo_adj_3x2_AGU(OWQadj,OWQ);
    plot_OQSadj_v2(OWQadj);
    plot_OQS_wwo_adj_3x2_v2(OWQadj,OWQ);% wi/wo adjustments, transparent overlay
   
end

% If set up with M1 sub-directory, run those as well
% if isadir([ACCP_set, '_M1',filesep])
%     clear QIS MER RMS
%     [QIS, MER, RMS,VERS,files] = read_all_SITA_Sept_samplefiles_v7(ACCP_set);
%     qnan = isNaN(QIS); len = length(QIS(~qnan));
%     group = unique(VERS(:,1)); clear vi
%     for grp = length(group):-1:1
%         gi = find(strcmpi(VERS(:,1),group{grp}));
%         vi(grp) = strjoin([group(grp),string(sprintf('(%3.0d files): ',length(gi))), unique(VERS(gi,7))']);
%     end
%     vi = vi';
%     if do_plot(4)
%         %     pptname = ['ACCP_QMR_3xN.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
%         pptname = ['ACCP_QMRadj_3xN.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
%         ACCP_set = [ACCP_set, '_M1',filesep];
%         % Run reduced set of GVs for M1 set
%         if ~isavar('gv2')
%             gv2= [50:55];
%         end
%         
%         figure;
%         tl = title({['ACCP SIT-A 8k Sept Assessment with NLP M1'];pptname}); set(tl,'Fontsize',16);
%         grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
%         tx = text(.1,.5,vi);set(tx,'FontSize',16);
%         png_name1 = ['ACCP_Sept_QMR_M1_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
%         saveas(gcf,[ACCP_pngs,png_name1]);close(gcf);
%         ppt_add_slide_no_title([PPT_path pptname], [ACCP_pngs,png_name1]);
%         
%         % Plot breakout cases for LAND, OCEN
%         plot_SITA_Sept_QMRadj_v1(QIS,MER,RMS,gv2,'LAND',obs,'RES1', [PPT_path pptname]);
%         plot_SITA_Sept_QMRadj_v1(QIS,MER,RMS,gv2,'OCEN',obs,'RES1', [PPT_path pptname]);
%         plot_SITA_Sept_QMRadj_v1(QIS,MER,RMS,gv2,'LAND',obc,'RES1', [PPT_path pptname]);
%         plot_SITA_Sept_QMRadj_v1(QIS,MER,RMS,gv2,'OCEN',obc,'RES1', [PPT_path pptname]);
%         %     plot_SITA_Sept_QMR_v3(QIS,MER,RMS,gv2,'LAND',obs,'RES1', [PPT_path pptname]);
%         %     plot_SITA_Sept_QMR_v3(QIS,MER,RMS,gv2,'OCEN',obs,'RES1', [PPT_path pptname]);
%     end
%     if do_plot(5)
%         pptname2 = ['ACCP_Q8a-o.',datestr(dnow,'yyyymmdd'),n_str,'.pptx'];
%         figure;
%         tl = title({['ACCP SIT-A Case-wise Assessment with NLP M1'];pptname2}); set(tl,'Fontsize',16);
%         grid('off'); xticks([]);yticks([]);set(gca, 'box','on');
%         tx = text(.1,.5,vi);set(tx,'FontSize',16);
%         png_name2 = ['ACCP_Qall8a-o_title_',datestr(dnow,'yyyy-mm-dd'),'.png'];
%         saveas(gcf,[ACCP_pngs,png_name2]);close(gcf);
%         ppt_add_slide_no_title([PPT_path pptname2], [ACCP_pngs,png_name2]);
%         
%         plot_SITA_Sept_cases_v4(QIS,gv2,'LAND',obs,'RES1', [PPT_path pptname2]);
%         plot_SITA_Sept_cases_v4(QIS,gv2,'OCEN',obs,'RES1', [PPT_path pptname2]);
%         plot_SITA_Sept_cases_v4(QIS,gv2,'LAND',obc,'RES1', [PPT_path pptname2]);
%         plot_SITA_Sept_cases_v4(QIS,gv2,'OCEN',obc,'RES1', [PPT_path pptname2]);
%     end
% end


toc

return