function nc = anc_bundle_1D(filelist,N)
% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then
% loops over the user specified actions for each file.
if ~isavar('N')
    N = 25;
end
pause(.1);
if isempty(who('filelist'))||isempty(filelist)
[filelist] = getfullname('*.cdf;*.nc', 'nc_data','Please select one or more files of the same datastream');
end
rmv = {};
if ~iscell(filelist)&&~isempty(dir(filelist))
    nc = anc_load(filelist);
else
    waits = figure_; set(waits, 'MenuBar','none','ToolBar','none','NumberTitle','off',...
        'DockControls','off','units','normal','position',[.4,.4, .2 .2])
    cla; T = text(.25, .5,['Loading 1 of ', num2str(length(filelist))]); grid(gca,'off') ; 
    try 
       xticks([]);yticks([]);
    catch
    end
    pause(0.01);
    nc_ = anc_load(filelist{1}); 
    [pname, ~, ~] = fileparts(filelist{1}); 
    vars = fieldnames(nc_.ncdef.vars);
    for v = 1:length(vars)
        var = vars{v};
        if length(nc_.ncdef.vars.(var).dims)>1
            rmv = [rmv,vars(v)];
        end
    end
    sprintf('Stripping: %s ',rmv{:})
    nc_.vdata = rmfield(nc_.vdata,rmv);
    nc_.ncdef.vars = rmfield(nc_.ncdef.vars, rmv);
    nc_.vatts = rmfield(nc_.vatts, rmv);
    
    
    for i = 2:length(filelist)
        cla; T = text(.25, .5,['Loading ',num2str(i), ' of ', num2str(length(filelist))]); grid(gca,'off') ; 
        try xticks([]);yticks([]);
        catch
        end
        pause(0.01);tic
        [pname, fname, ext] = fileparts(filelist{i}); 
        disp(['Processing ', fname, ext,' : ', num2str(i), ' of ', num2str(length(filelist))]);
        %    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
        if mod(i,N)~=0
            nc__ = anc_load(filelist{i});
            nc__.vdata = rmfield(nc__.vdata,rmv);
            nc__.ncdef.vars = rmfield(nc__.ncdef.vars, rmv);
            nc__.vatts = rmfield(nc__.vatts, rmv);
            try
            nc_ = anc_cat(nc_,nc__);
            catch
               [~,fname,ex] = fileparts(nc__.fname);
               disp(['Split bundle at ',fname,ex])
               [~, ~, ex] = fileparts(nc_.fname);
               save(strrep(nc_.fname,ex,'.mat'),'-struct','nc_')
               nc_ = nc__;                 
            end
        else
            if ~isavar('nc')
                nc = nc_;
            else
               try
                nc = anc_cat(nc, nc_);
               catch
                  [~,fname, ex] = fileparts(nc_.fname);
                  disp(['Split bundle at ',fname, ex]);
                  [~, ~, ex] = fileparts(nc.fname);
                  save(strrep(nc.fname,ex,'.mat'),'-struct','nc')
                  nc = nc_;
               end
            end
            nc_ = anc_load(filelist{i});
            nc_.vdata = rmfield(nc_.vdata,rmv);
            nc_.ncdef.vars = rmfield(nc_.ncdef.vars, rmv);
            nc_.vatts = rmfield(nc_.vatts, rmv);
        end       
        disp(['Done processing ', fname,ext]); toc      
    end
    if ~isavar('nc')
        nc = nc_;
    else
        nc = anc_cat(nc, nc_);
    end
    close(waits);
    disp(' ')
    disp(['Finished processing selected files in ' pname])
    disp(' ')
end
return