function vis = usda_vis_mfrsr(infile);

%UYYY,UM,UD,Uh,Um,Us,   UDy   ,LYYY,LM,LD,Lh,Lm,Ls,   LDy   ,   Zen  ,  Airmass ,   ODunf ,   OD415 ,   OD500 ,   OD610 ,   OD665 ,   OD860 ,   OD940 ,  O3 
if ~exist('infile','var')
   [fname, pname]= uigetfile('*.csv');
   infile = [pname, fname];
end
if ~exist(infile,'file')
   [fname, pname]= uigetfile('*.csv');
   infile = [pname, fname];
end
raw = loadit(infile);
vis.time = (raw(:,7)-1+datenum('2005-01-01','yyyy-mm-dd'));
vis.zen = raw(:,15);
vis.airmass = raw(:,16);
vis.od_500 = raw(:,19);
vis.od_610 = raw(:,20);
vis.od_665 = raw(:,21);
vis.od_860 = raw(:,22);
vis.O3 = raw(:,24);
