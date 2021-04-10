function OQS_LO = apply_OWs_LO_v3(QIS)
% OQS_LO = apply_OWs_LO_v3(QIS)
% Accepts a 7D QIS matrix
% Applies Objective-specific weights based on TYP
% Adds Obj[5-8] dimension while eliminating GRP, TYP, and RES dims to produce 5D OQS
% Reduces 4 OBS to 3 OBS NAD = NADLC0
% NAD = NADLC0
% NAN from NANLC0
% OND =0
% Q-scores are averaged only for groups where GVs were provided for platforms
% Produces 16 files (4 Objectives, 4 platforms) with rows for all GV, Ocean and Land
% and columns for NAD, NAN, and OND
% v3 generates no ASCII output files.

% QIS(GV,GRP,TYP,pfm,OBI,SFC,REZ)
% OQS_LO(gv,pfm,obi,sfc,obj(4))
pfm = ["SSP0","SSP1","SSP2","SSG3"];
OQS_LO = NaN([65,4,3,2,4]);
OCW = ACCP_Obj_Case_Weights;

[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.SIT-A_Sept.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';
gv = [1:length(GVnames)];
% Map the enumerated Objective cases to indices in GIS
% Ocean_cases= ["8a","8b","8c","8g","8h","8k","8l"]; [a:c g:h k:l] [1:3 7:8 11:12]
% Land_cases= ["8d","8e","8f","8i","8j","8m","8n","8o"]; [d:f i:j m:o] [4:6 9:10 13:15]
ocen_case = [1:3 7:8 11:12];
land_case = [4:6 9:10 13:15];
case1 = 0; case2 = 15;
DRS = 0; ICA = 30;

DRS_land_cases = [case1+land_case  case2+land_case];
ICA_land_cases = ICA + [case1+land_case  case2+land_case];

DRS_ocen_cases = [ocen_case  case2+ocen_case];
ICA_ocen_cases = ICA+[ocen_case  case2+ocen_case];

OCW_land = OCW(land_case,:); OCW_lands = [OCW_land;OCW_land];
OCW_ocen = OCW(ocen_case,:); OCW_ocens = [OCW_ocen;OCW_ocen];
GRP = ["NLP", "NLB", "NLS", "NGE", "OUX"];                  %5
%% NLP-DRSall is QIS(h, 1, DRS_cases, :, L, m, n)
%% NLS-DRSall is QIS(h, 3, DRS_cases, :, L, m, n)
%% NGE-DRSall is QIS(h, 4, DRS_cases, :, L, m, n)
%% OUX-DRSall is QIS(h, 5, DRS_cases, :, L, m, n)
%% NLB-ICAall is QIS(h, 2, ICA_cases, :, L, m, n)

% This averaging has to be done carefully since we only want to use results
% for which all four platforms are defined, and we want to use the
% GV-specific SATM RES when available else default to RES=1

for OO = 1:4
    for sfc = 1:2
        for H = gv
            
            if sfc == 1
                DRS_cases = DRS_land_cases;
                ICA_cases = ICA_land_cases;
                OCWs = OCW_lands(:,OO);
            else
                DRS_cases = DRS_ocen_cases;
                ICA_cases = ICA_ocen_cases;
                OCWs = OCW_ocens(:,OO);
            end
            R = 1;
            %RES4 for GV52-55, RES5 for GV50-51
            if H>=50&&H<=51
                % RES5
                R = 5;
            elseif H>=52 && H<= 55
                R = 4;
            end
            
            L = 1; % for NADLC0
            grp = 1; % NLP-DRSall is QIS(h, 1, DRS_cases, :, L, m, n)
            QI_1 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, R));
            OQ_1 = nanmean(QI_1.*(OCWs*ones([1,length(pfm)])));
            if all(isNaN(OQ_1)) &&R~=1
                QI_1 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, 1));
                OQ_1 = nanmean(QI_1.*(OCWs*ones([1,length(pfm)])));
            end
            
            grp = 3;% NLS-DRSall is QIS(h, 3, DRS_cases, :, L, m, n)
            QI_2 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, R));
            OQ_2 = nanmean(QI_2.*(OCWs*ones([1,length(pfm)])));
            if all(isNaN(OQ_2)) &&R~=1
                QI_2 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, 1));
                OQ_2 = nanmean(QI_2.*(OCWs*ones([1,length(pfm)])));
            end
            
            grp = 4;% NGE-DRSall is QIS(h, 4, DRS_cases, :, L, m, n)
            QI_3 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, R));
            OQ_3 = nanmean(QI_3.*(OCWs*ones([1,length(pfm)])));
            if all(isNaN(OQ_3)) &&R~=1
                QI_3 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, 1));
                OQ_3 = nanmean(QI_3.*(OCWs*ones([1,length(pfm)])));
            end
            
            grp = 5; % OUX-DRSall is QIS(h, 5, DRS_cases, :, L, m, n)
            QI_4 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, R));
            OQ_4 = nanmean(QI_4.*(OCWs*ones([1,length(pfm)])));
            if all(isNaN(OQ_4)) &&R~=1
                QI_4 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, 1));
                OQ_4 = nanmean(QI_4.*(OCWs*ones([1,length(pfm)])));
            end
            
            grp =2; % NLB-ICAall is QIS(h, 2, ICA_cases, :, L, m, n)
            QI_5 = squeeze(QIS(H, grp, ICA_cases,  :,L, sfc, R));
            OQ_5 = nanmean(QI_5.*(OCWs*ones([1,length(pfm)])));
            if all(isNaN(OQ_5)) &&R~=1
                QI_5 = squeeze(QIS(H, grp, ICA_cases,  :,L, sfc, 1));
                OQ_5 = nanmean(QI_5.*(OCWs*ones([1,length(pfm)])));
            end
            new_OQ = [OQ_1; OQ_2; OQ_3; OQ_4; OQ_5]; % old, newQIS 8x4, so now 5x4?
            % Only use cases where all 4 platforms are reported
            ONAN = double(~isNaN(new_OQ));
            ONAN(isNaN(new_OQ)) = NaN; anyNaN = any(isNaN(ONAN)')'; ONAN(anyNaN,:) = NaN;
            meanOQ_NADLC0 = meannonan(new_OQ.*ONAN)./mean(OCWs); % These are mean Qs for this GV and Objective weights.
            % OQS_LO(gv,pfm,obi,sfc,obj(4))
            OQS_LO(H,:,1,sfc,OO) = meanOQ_NADLC0;
            
            L = 3; % for NANLC0
            grp = 1; % NLP-DRSall is QIS(h, 1, DRS_cases, :, L, m, n)
            QI_1 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, R));
            OQ_1 = nanmean(QI_1.*(OCWs*ones([1,length(pfm)])));
            if all(isNaN(OQ_1)) &&R~=1
                QI_1 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, 1));
                OQ_1 = nanmean(QI_1.*(OCWs*ones([1,length(pfm)])));
            end
            
            grp = 3;% NLS-DRSall is QIS(h, 3, DRS_cases, :, L, m, n)
            QI_2 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, R));
            OQ_2 = nanmean(QI_2.*(OCWs*ones([1,length(pfm)])));
            if all(isNaN(OQ_2)) &&R~=1
                QI_2 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, 1));
                OQ_2 = nanmean(QI_2.*(OCWs*ones([1,length(pfm)])));
            end
            
            grp = 4;% NGE-DRSall is QIS(h, 4, DRS_cases, :, L, m, n)
            QI_3 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, R));
            OQ_3 = nanmean(QI_3.*(OCWs*ones([1,length(pfm)])));
            if all(isNaN(OQ_3)) &&R~=1
                QI_3 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, 1));
                OQ_3 = nanmean(QI_3.*(OCWs*ones([1,length(pfm)])));
            end
            
            grp = 5; % OUX-DRSall is QIS(h, 5, DRS_cases, :, L, m, n)
            QI_4 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, R));
            OQ_4 = nanmean(QI_4.*(OCWs*ones([1,length(pfm)])));
            if all(isNaN(OQ_4)) &&R~=1
                QI_4 = squeeze(QIS(H, grp, DRS_cases,  :,L, sfc, 1));
                OQ_4 = nanmean(QI_4.*(OCWs*ones([1,length(pfm)])));
            end
            
            grp =2; % NLB-ICAall is QIS(h, 2, ICA_cases, :, L, m, n)
            QI_5 = squeeze(QIS(H, grp, ICA_cases,  :,L, sfc, R));
            OQ_5 = nanmean(QI_5.*(OCWs*ones([1,length(pfm)])));
            if all(isNaN(OQ_5)) &&R~=1
                QI_5 = squeeze(QIS(H, grp, ICA_cases,  :,L, sfc, 1));
                OQ_5 = nanmean(QI_5.*(OCWs*ones([1,length(pfm)])));
            end
            new_OQ = [OQ_1; OQ_2; OQ_3; OQ_4; OQ_5]; % old, newQIS 8x4, so now 5x4?
            % Only use cases where all 4 platforms are reported
            ONAN = double(~isNaN(new_OQ));
            ONAN(isNaN(new_OQ)) = NaN; anyNaN = any(isNaN(ONAN)')'; ONAN(anyNaN,:) = NaN;
            meanOQ_NANLC0 = meannonan(new_OQ.*ONAN)./mean(OCWs); % These are mean Qs for this GV and Objective weights.
            OQS_LO(H,:,2,sfc,OO) = meanOQ_NANLC0;
            
            L = 4; % for ONDPC0
            
            OQS_LO(H,:,3,sfc,OO) = 0;
            %OQS_LO(obj,gv,obs,sfc,pltf
            
        end %of OWC loop
    end
end
% apply zero min, unity max to OQS_LO
OQS_LO(OQS_LO<0)=0; OQS_LO(OQS_LO>1)=1;


% srfc = [" Land", " Ocean"];
% % OQS(gv,pfm,obi,sfc,obj(4))
% for OO = 1:4
%     for pp = 1:length(pfm)
%         NN_ = ''; NN = 1;
%         OQS_file = [getnamedpath('ACCP_set'),'..',filesep,'LidarOnly_QS_for_O',num2str(OO+4),'_',pfm{pp},NN_,'.csv'];
%         while isafile(OQS_file)
%             NN = NN + 1; NN_ = sprintf('.v%d',NN);
%             OQS_file = [getnamedpath('ACCP_set'),'..',filesep,'LidarOnly_QS_for_O',num2str(OO+4),'_',pfm{pp},NN_,'.csv'];
%         end
%         fid = fopen(OQS_file,'w+');
%         pause(0.5);
%         fprintf(fid,'%s,\t%s,\t%s,\t%s \n','GV_name', 'Nadir Daytime', 'Nadir Nighttime', 'Off nadir Daytime');
%         for H = 1:length(gv)
%             for ss = length(srfc):-1:1
%                 fprintf(fid,'%s, %2.3f, %2.3f, %2.3f \n', string([GVnames{H},srfc{ss}]), OQS(H,pp,1,ss,OO), OQS(H,pp,2,ss,OO), OQS(H,pp,3,ss,OO));
%             end
%         end
%         [~,fname,~] = fileparts(OQS_file);
%         sprintf('%s',['Closing ',fname,'.csv'])
%         fclose(fid);
%         pause(0.5);
%     end
% end

% toc
% OQS(gv,pfm,obi,sfc,obj(4))
% out.OQS_struct = '%OQS(gv(65),pfm(4),obs(3),sfc(2),obj(4))';
% out.gv = [1:65]; out.pfm = ["SSP0","SSP1","SSP2","SSG3"];
% out.obs = ["NAD=mean(NADL,NADB)","NAN","OND"]; out.sfc = ["Land","Ocean"]; 
% out.obj = [5:8]; 
% out.OQS = OQS;
% save([getnamedpath('ACCP_set'),'SITA_OQS_',datestr(now,'yyyymmdd_HHMM'),'.mat'],'-struct','out');


return
