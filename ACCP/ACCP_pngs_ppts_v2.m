function ACCP_pngs_ppts_v2
% Shell function for reading and then plotting ACCP results
% Created June 4, 2020 by Connor.
% Expected to be modified, customized repeatedly to support various
% Collections of plots
% Incorporating mean QIs in bar plot as per Sharon's request. Does not yet
% incorporate weights.

ACCP = setnamedpath('ACCP',['C:\case_studies\ACCP\'],'Select base path to ACCP folder');
ACCP_set = setnamedpath('ACCP_set','','Select the root of the current data set');
ACCP_pngs = setnamedpath('ACCP_pngs',[],'Select a directory for AACP png files, creating if necessary.');

clear QIS MER RMS
[QIS, MER, RMS] = read_all_ACCP_8K_samplefiles_v3(ACCP_set);


tic
gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73];
% gv = [20:22 47:52];
% gv = 22;
pptname = [ACCP_pngs,'..',filesep,'ACCP_3x3.QMR.v5.',datestr(now,'yyyymmdd'),'.ppt'];
plot_ACCP_QMR_V5(QIS,MER,RMS,gv,'LNDD','RES1', pptname);
plot_ACCP_QMR_V5(QIS,MER,RMS,gv,'OCEN','RES1', pptname);

pptname = [ACCP_pngs,'..',filesep,'ACCP_3x1.all_6a-i.v2.',datestr(now,'yyyymmdd'),'.ppt'];
plot_ACCP_cases_V2(QIS,MER,RMS,gv,'LNDD','RES1', pptname);
plot_ACCP_cases_V2(QIS,MER,RMS,gv,'OCEN','RES1', pptname);

% pptname = [ACCP_pngs,'..',filesep,'ACCP_3x1.DRSx.ppt'];
% plot_ACCP_DRS_V3(QIS,MER,RMS,gv,'LNDD','RES1', pptname);
% plot_ACCP_DRS_V3(QIS,MER,RMS,gv,'OCEN','RES1', pptname);


return