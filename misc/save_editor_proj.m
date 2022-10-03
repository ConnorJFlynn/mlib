function save_editor_proj(proj_name)
% save_editor_proj(proj_name)
% saves the current MatlabDesktop.xlm file to a desired project name for
% later reload.
% If a file extension is not provided it will default to *.ed
if ~isavar('proj_name')
    proj_name = deblank(input('Enter a project name for the open files in the editor: ', 's'));
    if isempty(proj_name)
        proj_name = ['MATLABDesktop.xml.prev']
        n = 1;
        while exist([getnamedpath('editor_projs'),projname],'file')
            n = n +1;
            proj_name = ['MATLABDesktop.xml.prev',num2str(n)];
        end
    end
end
[~,fname, ext] = fileparts(proj_name);
if isempty(ext)
    proj_name = [proj_name, '.ed'];
end

if isafile([getnamedpath('editor_projs'),proj_name])
   OK = menu(['Overwrite project file: ',proj_name, '?'],'Yes','No');
else
   OK = 1;
end
if OK == 1
fid1 = fopen([prefdir,filesep,'MATLABDesktop.xml'],'r');
fid2 = fopen([getnamedpath('editor_projs'),proj_name],'w+');

while ~feof(fid1)
    line = fgetl(fid1);
    if ~isempty(strfind(line,'<ClientData EditorFileName="'))||~isempty(strfind(line,'<ClientData RichRditorFileName='))
       if ~isavar('fid2')
          fid2 = fopen([getnamedpath('editor_projs'),proj_name],'w+');
       end
       [~,line] = strtok(line,'"'); line = strtok(line,'"');
%        [~,line] = fileparts(line);
       if ~isempty(which(line))
        fprintf(fid2,'%s \n', line);
       end
    end
end
if isavar('fid2') && fid2>0
   fclose(fid2);
end
fclose(fid1); 

end

return
