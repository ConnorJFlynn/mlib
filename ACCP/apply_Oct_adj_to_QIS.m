function [QISadj, adj] = apply_Oct_adj_to_QIS(QIS);
% QISadj = apply_Oct_adj_to_QIS(QIS)
% Accepts a 7D QIS matrix
% QIS(GV,GRP,TYP,PFM,OBI,SFC,REZ)
% QIS(65, 6, 62,  4, 4(8) , 2, 5]);
% Loads the adjustment table in SITA_Sept_adj and applies the
% observation-grouped adjustments per platform to all Group results.

% Modified to include set adjustements to NADLC1 and NANLC1 equal to NADLC0 and NANLC0
mean_adj = SITA_Oct_adj; 
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';
PFM = ["SSP0", "SSP1", "SSP2", "SSG3"];   
OBS = ["NADLC0","NADBC0", "NANLC0","ONDPC0"];

OBI = ["NADLC0", "NADBC0", "NANLC0", "ONDPC0","NADLC1","NANLC1","NADLC2","NANLC2"];

adj = NaN(length(GVnames),length(PFM),6);
for plt = 1:4
     for ob = 1:4
        adj(:,plt,ob) = mean_adj(:,plt + 4*(ob-1));
     end
     adj(:,plt,5) = mean_adj(:,plt);
     adj(:,plt,6) = mean_adj(:,plt+8);
end

QISadj = NaN(size(QIS));
for gr = 1:6
    for typ = 1:62
        for sfc = 1:2
            for res = 1:5
%                 QISadj(:,gr,typ,:,1:4,sfc,res) = adj;
                QISadj(:,gr,typ,:,1:6,sfc,res) = adj;
            end
        end
    end
end
% test with:
% tmp =squeeze(QISadj(1,1,1,:,1:4,1,1)); tmp(:)'
% gv = 1; gr = 2; typ = 3,sfc = 2,res = 1;
% tmp = squeeze(QISadj(gv,gr,typ,:,1:4,src,res); tmp(:)'

QISadj = QIS + QISadj;

return
