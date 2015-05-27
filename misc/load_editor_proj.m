function [SUCCESS,MESSAGE,MESSAGEID] = load_editor_proj(proj_name)
% saves the current MatlabDesktop.xlm file to a desired project name for
% later reload.

% Open the designated xml project file
% Find all instances of <ClientData EditorFileName="
% Parse the corresponding string
% Then open each checking for existence.


if ~exist('proj_name','var')
    list_editor_proj
    projname = getfullname_('*.ed; *.prev','editor_projs','Select editor project or MatlabDesktop.xml.prev file.');
%     projname = [prefdir,filesep,'MATLABDesktop.xml.prev'];
else
    [pn,fn,ex] = fileparts(proj_name);
    if isempty(ex)
        proj_name = [proj_name, '.ed'];
    end
    projname = [prefdir, filesep,proj_name];
end
if exist(projname,'file')
    fid = fopen(projname,'r');
    while ~feof(fid)
        line = fgetl(fid);
        found = strfind(line,'<ClientData EditorFileName="');
        if ~isempty(found)
            mark = found+length('<ClientData EditorFileName="');
            open_me = textscan(line(mark:end),'%s',1,'delimiter','"');
            open_me = open_me{:};
            if exist(open_me{:},'file')
                edit(open_me{:});
            end
        end
    end
    fclose(fid);
else
    disp('No project file with that name.')
end

return

