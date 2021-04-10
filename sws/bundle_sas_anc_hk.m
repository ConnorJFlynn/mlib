function sas =bundle_sas_anc_hk(files);
% sas =bundle_sas_anc_hk;
% bundles selected sas netcdf files into one continuous structure while
% discarding spectral data
 
if ~exist('files','var')
    files = getfullname('*SAS*.nc','sas_nc','Select SAS or SWS netcdf files to bundle.');
end
rmv = {};
if ~iscell(files)
    if ~isempty(files)
        if exist(files,'file')
            if strfind(files,'.cdf')||strfind(files,'.nc')
                sas = anc_load(files);
                vars = fieldnames(sas.ncdef.vars);                
                for v = 1:length(vars)
                    var = vars{v};
                    if length(sas.ncdef.vars.(var).dims)>1
                        rmv = [rmv,vars(v)];
                    end
                end
                sas.vdata = rmfield(sas.vdata,rmv);
                sas.ncdef.vars = rmfield(sas.ncdef.vars, rmv);
                sas.vatts = rmfield(sas.vatts, rmv);               
            end
        else
            sas = [];
        end
    else
        sas = [];
    end
else
    sas = anc_load(files{1}); close('all');
    vars = fieldnames(sas.ncdef.vars);
    for v = 1:length(vars)
        var = vars{v};
        if length(sas.ncdef.vars.(var).dims)>1
            rmv = [rmv,vars(v)];
        end
    end
    sas.vdata = rmfield(sas.vdata,rmv);
    sas.ncdef.vars = rmfield(sas.ncdef.vars, rmv);
    sas.vatts = rmfield(sas.vatts, rmv);
    
    for F = 2:length(files)
        sas_ = anc_load(files{F}); close('all');
        sas_.vdata = rmfield(sas_.vdata,rmv);
        sas_.ncdef.vars = rmfield(sas_.ncdef.vars, rmv);
        sas_.vatts = rmfield(sas_.vatts, rmv);
        sas = anc_cat(sas,sas_ );
    end
    
end
    
    

%%
% figure(98);
% plot([1:length(sws1.time)],serial2doy(sws1.time), 'o')
%%

return