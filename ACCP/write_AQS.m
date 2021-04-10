function write_AQS(QI_adj,pltf,Q_noadj);
% write_AQS(QI_adj,pltf);
% writes CSV files of ACCP "adjusted" average weighted QI scores for all
% reported GVs, one for each supplpied pltf
% Added ability to accept and output unadjusted Q as "Q_noadj"
[~, ~, GVnames] = xlsread([getnamedpath('ACCP'),'GVnames.xlsx'],'Sheet1');
GVnames = string(GVnames);
GVnames(ismissing(GVnames)) = '';

dnow = now; nn = 1; n_str = ['_v',num2str(nn)];

%Increment pptname to avoid over-write
% fname = ['SIT-A_8K_AQS_',pltf{1},n_str,'.csv'];
% while isafile([getnamedpath('ACCP'), fname])
%     nn = nn+1; n_str = ['_',num2str(nn)];
%     fname = ['SIT-A_8K_AQS_',pltf{pl},n_str,'.csv'];
% end

% QIS_adj(H,pltf,L=obs,m=srfc);
dnow = now;
for pl = 1:length(pltf)
    fname = ['SIT-A_8K_AQS_',pltf{pl},n_str,'.csv'];
    while isafile([getnamedpath('ACCP'), fname])
        nn = nn+1; n_str = ['_v',num2str(nn)];
        fname = ['SIT-A_8K_AQS_',pltf{pl},n_str,'.csv'];
    end
    fid = fopen([getnamedpath('ACCP'),fname],'w');
    sprintf('%s %s',fname, ', QI scores. Land = (LNDD+LNDV)/2   Created:',datestr(dnow,'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid,'%s %s %s \n',fname, ', QI scores. Land = (LNDD+LNDV)/2 Created:',datestr(dnow,'yyyy-mm-dd HH:MM:SS'));
    sprintf('%s','GV#, GV Name, Nadir Daytime, Nadir Nighttime, Off-nadir Daytime')
    fprintf(fid, '%s \n','GV#, GV Name, Nadir Daytime, Nadir Nighttime, Off-nadir Daytime');
    
    AQS = squeeze(QI_adj(:,pl,:,:));
    
    for gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73]
        QS = AQS(gv,:,3); %OCEN is srfc(3)
        outstr = {strjoin([num2str(gv),',',GVnames{gv},"Ocean", sprintf(', %1.2f', QS)])};
        sprintf('%s', outstr{:})
        fprintf(fid, '%s \n', outstr{:});
        QS = mean([AQS(gv,:,1);AQS(gv,:,2)]); % Taking mean of LNDD and LNDV
        outstr = {strjoin([num2str(gv),',',GVnames{gv},"Land", sprintf(', %1.2f', QS)])};
        sprintf('%s', outstr{:})
        fprintf(fid, '%s \n', outstr{:});
    end
    fclose(fid);
    
end
if isavar('Q_noadj')&&all(size(Q_noadj)==size(QI_adj))
for pl = 1:length(pltf)
    fname = ['SIT-A_8K_Q_noadj_',pltf{pl},n_str,'.csv'];
    while isafile([getnamedpath('ACCP'), fname])
        nn = nn+1; n_str = ['_v',num2str(nn)];
        fname = ['SIT-A_8K_AQS_',pltf{pl},n_str,'.csv'];
    end
    fid = fopen([getnamedpath('ACCP'),fname],'w');
    sprintf('%s %s',fname, ', QI scores. Land = (LNDD+LNDV)/2   Created:',datestr(dnow,'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid,'%s %s %s \n',fname, ', QI scores. Land = (LNDD+LNDV)/2 Created:',datestr(dnow,'yyyy-mm-dd HH:MM:SS'));
    sprintf('%s','GV#, GV Name, Nadir Daytime, Nadir Nighttime, Off-nadir Daytime')
    fprintf(fid, '%s \n','GV#, GV Name, Nadir Daytime, Nadir Nighttime, Off-nadir Daytime');
    
    AQS = squeeze(Q_noadj(:,pl,:,:));
    
    for gv = [1:16 21:22 27:28 31:57 62:63 68:69 72:73]
        QS = AQS(gv,:,3); %OCEN is srfc(3)
        outstr = {strjoin([num2str(gv),',',GVnames{gv},"Ocean", sprintf(', %1.2f', QS)])};
        sprintf('%s', outstr{:})
        fprintf(fid, '%s \n', outstr{:});
        QS = mean([AQS(gv,:,1);AQS(gv,:,2)]); % Taking mean of LNDD and LNDV
        outstr = {strjoin([num2str(gv),',',GVnames{gv},"Land", sprintf(', %1.2f', QS)])};
        sprintf('%s', outstr{:})
        fprintf(fid, '%s \n', outstr{:});
    end
    fclose(fid);
    
end
end

end