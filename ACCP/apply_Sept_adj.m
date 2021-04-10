function QISadj = apply_Sept_adj(QIS)
% OQS = apply_OWCs(QIS)
% Accepts a 7D QIS matrix
% Loads the adjustment table in SITA_Sept_adj and applies the
% observation-grouped adjustements per platform to all Group results.

QISadj = QIS;
mean_adj = SITA_Sept_adj; 
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';

% QIS = NaN([73,length(group),length(typ),length(pltf),length(obs),length(srfc),length(res)]);
tic
for H = 1:length(GVnames)
    for OBS = 1:4
        adj = mean_adj(H,(OBS-1).*4+[1:4])';
        for pltf = 1:4
            for sfc = 1:2
                for typ = 1:62
                    for G = 1:5
                        for R = 1:5
                            QISadj(H, G,typ,:,OBS,sfc, R) = adj+squeeze(QIS(H, G,typ,:,OBS,sfc, R));
                        end
                    end
                end
            end
        end
    end
end

   
toc

return
