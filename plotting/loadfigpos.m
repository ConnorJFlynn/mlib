function pos = loadfigpos(H)
% Loads a figure position file for H

pname = strrep(strrep(userpath,';',filesep),':',filesep);
pathdir = [pname, 'filepaths'];
if ~exist(pathdir,'dir')
    mkdir(pname, 'filepaths');
end
pathdir = [pathdir,filesep];

if ~isempty(strfind(class(H),'Figure'))
    num = H.Number;
elseif isnumeric(H)
    num = H;
end
figfile = [pathdir,'figpos.',num2str(num),'.mat'];

if exist('pos','var') && isempty(pos)
    delete(figfile);
end
if exist(figfile,'file')
    pos = load(figfile);
else
    pos = [];
end



return