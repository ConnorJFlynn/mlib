function [SUCCESS,MESSAGE,MESSAGEID] = load_editor_proj(proj_name)
% saves the current MatlabDesktop.xlm file to a desired project name for
% later reload.

% Open the designated xml project file
% Find all instances of <ClientData EditorFileName="
% Parse the corresponding string
% Then open each checking for existence.


if ~isavar('proj_name')
    list_editor_proj
    projname = getfullname('*.ed; *.prev','editor_projs','Select editor project or MatlabDesktop.xml.prev file.');
else
    [pn,fn,ex] = fileparts(proj_name);
    if isempty(ex)
        proj_name = [proj_name, '.ed'];
    end
    projname = [getnamedpath('editor_projs'), proj_name];
end
if isafile(projname)
    fid = fopen(projname,'r');
    while ~feof(fid)
        line = fgetl(fid);
        if isafile(line)
                edit(line);
        else
            [~,line] = filepartsh(line);
            if ~isempty(which(line))
               disp(['Could not find "',line,'" on explicit path.'])
               disp(['Opening version found within Matlab path.'])
               edit([fname,ext]);
            end
        end
    end
    fclose(fid);
else
    disp('No project file with that name.')
end

return

