function sas =bundle_sas_raw_aux(files);
% sas =bundle_sas_raw;
% bundles selected raw sas files into one continuous structure while
% discarding spectral data
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
                sas = rd_raw_SAS(files);close('all')
                sas = rmfield(sas,{'spec','rate','sig', 'lambda','labels','fname','pname','header','lambda_fit','pix_range'});
            end
        else
            sas = [];
        end
    else
        sas = [];
    end
else
    sas = rd_raw_SAS(files{1}); close('all');
    sas = rmfield(sas,{'spec','rate','sig', 'lambda','labels','fname','pname','header','lambda_fit','pix_range'});
    for F = 2:length(files)
        sas_ = rd_raw_SAS(files{F}); close('all');
        sas_ = rmfield(sas_,{'spec','rate','sig', 'lambda','labels','fname','pname','header','lambda_fit','pix_range'});
        sas = cat_struct(sas,sas_ );        
    end
    
end
    
    

%%
% figure(98);
% plot([1:length(sws1.time)],serial2doy(sws1.time), 'o')
%%

return