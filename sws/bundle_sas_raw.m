function sas =bundle_sas_raw(files);
% sas =bundle_sas_raw;
% bundles selected raw sas files into one continuous structure 
% Uses rd_raw_sas and catsas 
if ~exist('files','var')
    files = getfullname('SAS*.csv','sas_raw','Select raw SAS files to bundle.');
end

if ~iscell(files)
    if ~isempty(files)
        if exist(files,'file')
            if strfind(files,'.mat')
                sas = load(files);
            else
                sas = rd_raw_SAS(files);
            end
        else
            sas = [];
        end
    else
        sas = [];
    end
else
    sas = rd_raw_SAS(files{1});
    for F = 2:length(files)
        sas = catsas(sas, rd_raw_SAS(files{F}));        
    end
    
end
    
    

%%
% figure(98);
% plot([1:length(sws1.time)],serial2doy(sws1.time), 'o')
%%

return