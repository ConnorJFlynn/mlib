function [this,filename] = loadinto(filename,var);
%this = loadinto(filename);
% Designed to work only with a single variable stored in a mat file
if ~exist('filename', 'var')
    [filename] = getfullname('*.mat','mat_files','Select a mat file.');
end
% filename = which(filename);

good_dir = exist(filename,'dir');
if good_dir
    filename= getfullname([filename,filesep,'*.*']);
end
% function [fullname] = getfullname(fspec,pathfile,dialo

good_file = exist(filename,'file')&~exist(filename,'dir');


if ~good_file
    fname = [];
    pname = [];
else
    % Now, test to see if the file has an path attached.
    [pname,fname, ext] = fileparts(filename);
    if isempty(pname) % Then the filepath is not complete
        [pname,fname, ext] = fileparts(which(filename));
        filename = fullfile(pname,[fname ext]);
    end
end
if isempty(pname)||isempty(fname)
    this = [];
else
    if findstr(filename, '.mat')
        if exist('var','var')
            this = load(filename,'-mat',var);
        else
            this = load(filename,'-mat');
        end
        
        if length(fieldnames(this))==1
            this = this.(char(fieldnames(this)));
        end
    else
        try,
            if exist('var','var')
                this = load(filename,'-mat',var);
            else
                this = load(filename,'-mat');
            end
            if length(fieldnames(this))==1
                this = this.(char(fieldnames(this)));
            end
        catch,
            this = load(filename,'-ascii');
        end
    end
end
return
% if findstr(filename,'.mat')
% this = load(filename,'-mat');
% else
%    this = load(filename,'-ascii');
% end

