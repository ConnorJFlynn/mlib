function OQSadj = apply_Sept_adj_LO(OQS);
% OQSadj = apply_Setp_adj_LO(QIS)
% Accepts a 5D OQS matrix
% Loads the adjustment table in SITA_Sept_adj and applies the
% observation-grouped adjustements per platform to all Group results.

% This function requires LIDAR-ONLY Objective-Adjusted values
mean_adj = SITA_Sept_adj; 
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';
PFM = ["SSP0", "SSP1", "SSP2", "SSG3"];   
toc
OQSadj = OQS;

%OQS(obj,gv,obs,sfc,pltf)

srfc = [" Land", " Ocean"];
%OQSLO_adj(obj,gv,obs,sfc,pltf)
for OO = 1:4
    
    for pp = 1:length(PFM)
        NN_ = ''; NN = 1;
        OQS_file = [getnamedpath('ACCP_set'),'..',filesep,'LO_OQS',num2str(OO+4),'adj_',PFM{pp},NN_,'.csv'];
        while isafile(OQS_file)
            NN = NN + 1; NN_ = sprintf('.v%d',NN);
            OQS_file = [getnamedpath('ACCP_set'),'..',filesep,'LO_OQS',num2str(OO+4),'adj_',PFM{pp},NN_,'.csv'];
        end
        fid = fopen(OQS_file,'w+');
        fprintf(fid,'%s,\t%s,\t%s,\t%s \n','GV_name', 'Nadir Daytime', 'Nadir Nighttime', 'Off nadir Daytime');
        for H = 1:length(GVnames)
            adjs = mean_adj(H,:);
            NADadj = (adjs(1:4)+adjs(5:8))./2;  NANadj = adjs(9:12); ONDadj= adjs(13:16);
            adj = [NADadj(pp),NANadj(pp), ONDadj(pp)];
            for ss = length(srfc):-1:1
                OQ = squeeze(OQS(OO,H,:,ss,pp))';
                adjOQ = OQ + adj;
                adjOQ(adjOQ>1) = 1; adjOQ(adjOQ<0) = 0;
                adjOQ(3) = 0;
                OQSadj(OO,H,:,ss,pp) = adjOQ(:);
                fprintf(fid,'%s, %2.3f, %2.3f, %2.3f \n', string([GVnames{H},srfc{ss}]), adjOQ );
            end
        end
        fclose(fid);pause(.5)
    end
end

out.OQSLOadj = '%OQSLOadj(obj,gv,obs,sfc,pltf)';
out.obj = [5:8]; out.gv = [1:65]; out.obs = ["NAD","NAN","OND"]; out.sfc = ["Land","Ocean"]; out.plfm = ["SSP0","SSP1","SSP2","SSG3"];
out.OQSLOadj = OQSadj;
save([getnamedpath('ACCP_set'),'SITA_OQSLOadj_',datestr(now,'yyyymmdd_HHMM'),'.mat'],'-struct','out');


return
