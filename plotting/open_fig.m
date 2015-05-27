function open_fig
[fname, pname] = uigetfile('*.fig');
open([pname, filesep,fname]);
ok = menu('Save new file as:','*.fig','*.png','*.jpg','Cancel');

end