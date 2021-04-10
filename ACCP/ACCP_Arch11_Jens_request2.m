function blah
% Jens's request #2
% mean QI-scores averaged over objective-weighted adjusted QIs

%OQSadj(obj,gv,obs,sfc,pltf)
OQSadj = load([getnamedpath('ACCP_set'),'SITA_OQSadj_20200906_1332.mat']);
gv = OQSadj.gv;
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');

lay = find(gv<42); prf = find(gv>41); 

lay(21:22) = []; %Exclude GV21,22

prf(21:22) = []; % Exclude GV62,63

for Z = 2:-1:1
    if Z == 2 % profile
        gvs = prf;
    else
        gvs = lay; % layer
    end
    
    for obs = 3:-1:1
        for plt = 4:-1:1
            for sfc = 2:-1:1
                   temp = squeeze(OQSadj.OQSadj(:,gvs,obs,sfc,plt));
                   mean_OQSadj(Z,obs,sfc,plt) = nanmean(temp(:));
                    std_OQSadj(Z,obs,sfc,plt) = nanstd(temp(:));

            end
        end
    end
end

% I have hand-checked platform 1-4 for (O1, profile, NAD, Land)
return