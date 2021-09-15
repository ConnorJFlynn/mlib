function nc = anc_bundle_files(filelist,N)
% nc = anc_bundle_files(filelist,N)
% Attempts to concatenate all files in filelist into a single nc struct
% Reads files in groups of N for improved memory handling
% Fails if one of the files has different dimensionality
% loops over the user specified actions for each file.
if ~isavar('N')
    N = 25;
end
pause(.1);
if isempty(who('filelist'))||isempty(filelist)
[filelist] = getfullname('*.cdf;*.nc', 'nc_data','Please select one or more files of the same datastream');
end
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
    
    for i = 2:length(filelist)
        cla; T = text(.25, .5,['Loading ',num2str(i), ' of ', num2str(length(filelist))]); grid(gca,'off') ; 
        try xticks([]);yticks([]);
        catch
        end
        pause(0.01);
        [pname, fname, ext] = fileparts(filelist{i}); 
        disp(['Processing ', fname, ext,' : ', num2str(i), ' of ', num2str(length(filelist))]);
        %    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
        if mod(i,N)~=0
            nc_ = anc_cat(nc_,anc_load(filelist{i}));
        else
            if ~isavar('nc')
                nc = nc_;
            else
                nc = anc_cat(nc, nc_);
            end
            nc_ = anc_load(filelist{i});
        end       
        disp(['Done processing ', fname,ext]);        
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