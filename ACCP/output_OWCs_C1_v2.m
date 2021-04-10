function out = output_OWCs_C1_v2(OQS, adj);
% out = output_OWCs_C1(OQS, adj);
% If "adj" is provided, then it will be incorporated into the output name to 
% to distinguish whether adjustements have been applied to OQS and whether 
% the results are full or lidar-only. 
% Filenames and fieldnames reflect that.
% v1 2020-10-28: initial attempt
% v2 2021-01-03: modifying to use for VF lidar-only LO files as well.
if ~isavar('adj')
    adj = [];
end
dnow = now;

[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';
gv = [1:length(GVnames)];

% QIS(GV,GRP,TYP,PFM,OBI,SFC,REZ)
% OQS(gv,pfm,obi,sfc,obj(4))
OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0",...
    "NADLC1","NANLC1","NADLC2","NANLC2"];  
pfm = ["SSP0","SSP1","SSP2","SSG3"];
srfc = [" Land", " Ocean"];
% OQS(gv,pfm,obi,sfc,obj(4))
for OO = 1:4
    for pp = 1:length(pfm)
        NN_ = ''; NN = 1;
        OQS_file = [getnamedpath('VF_out'),'QS',adj,'_for_O',num2str(OO+4),'_',pfm{pp},'_C0C1',NN_,'.csv'];
        while isafile(OQS_file)
            NN = NN + 1; NN_ = sprintf('.v%d',NN);
            OQS_file = [getnamedpath('VF_out'),'QS',adj,'_for_O',num2str(OO+4),'_',pfm{pp},'_C0C1',NN_,'.csv'];
        end
        fid = fopen(OQS_file,'w+');
        pause(0.5);
        fprintf(fid,'%s,\t%s,\t%s,\t%s \n','GV_name', 'Nadir Daytime', 'Nadir Nighttime', 'Off nadir Daytime');
        for H = 1:length(gv)
            for ss = length(srfc):-1:1
                fprintf(fid,'%s, %2.3f, %2.3f, %2.3f \n', string([GVnames{H},srfc{ss}]), OQS(H,pp,1,ss,OO), OQS(H,pp,2,ss,OO), OQS(H,pp,3,ss,OO));
            end
        end
        [~,fname,~] = fileparts(OQS_file);
        sprintf('%s',['Closing ',fname,'.csv'])
        fclose(fid);
        pause(0.5);
    end
end

% toc
% OQS(gv,pfm,obi,sfc,obj(4))
out.OQS_struct = ['%OQS',adj,'(gv(65),pfm(4),obs(3),sfc(2),obj(4))'];
out.gv = [1:65]; 
out.pfm = ["SSP0","SSP1","SSP2","SSG3"];
out.obs = ["NAD=mean(NADLC1,NADBC0)","NAN=mean(NANLC0,NANLC1)","OND=ONDPC0"]; 
out.sfc = ["Land","Ocean"]; 
out.obj = [5:8]; 
out.(['OQS',adj]) = OQS;
save([getnamedpath('VF_out'),'SITA_OQS',adj,'_C0C1_',datestr(dnow,'yyyymmdd_HHMM'),'.mat'],'-struct','out');

% ins = squeeze(OQS(lay,1,1,2,:));
% [nanmean(ins(:)),nanstd(ins(:))]