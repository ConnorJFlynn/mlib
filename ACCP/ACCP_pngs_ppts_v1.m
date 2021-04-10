function ACCP_pngs_ppts_v1
% Shell function for reading and then plotting ACCP results
% Created June 4, 2020 by Connor.
% Expected to be modified, customized repeatedly to support various 
% Collections of plots

setnamedpath('ACCP',['C:\Users\Connor Flynn\Documents\GitHub\mlib\ACCPX\'],'Select base path to ACCP folder');
ACCP_set = setnamedpath('ACCP_set',[getnamedpath('ACCP'),'*'],'Select a file in the current data set');
AACP_pngs = setnamedpath('AACP_pngs',[],'Select a directory for AACP png files, creating if necessary.');

AACP_pngs = getnamedpath('AACP_pngs');
pptname = [AACP_pngs,'..',filesep,'AACP_3x3.meanQI.ppt'];

[QIS, MER, RMS] = read_all_ACCP_8K_samplefiles_cjf;

gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73];

plot_ACCP_QI_V4(QIS,MER,RMS,gv,'LNDD','RES1',pptname);
plot_ACCP_QI_V4(QIS,MER,RMS,gv,'OCEN','RES1');

plot_ACCP_DRS_V1(QIS,MER,RMS,gv,'LNDD','RES1');

return