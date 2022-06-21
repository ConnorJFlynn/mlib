function [tape3_fullname,tag,spc] = call_lbl(lbl_tape5)
% [tape12_fullname, tag] = call_lbl(lbl_tape5,tag)
% Accepts or queries for lbl_tape5.
% if isavar(tag), appends tag to supplied/selected lbl_tape5
% if LBL tape5 exists, deletes. if LBL tape12 exists, renames with .v
% Copies lbl_tape5 to lbl_path/TAPE5
% Calls LBLRTM
% Moves TAPE12 to ['TAPE12.' tag] 

lbl_path = getpname('lbl');
if isafile('lbl_exe.mat')
    lbl_exe = load('lbl_exe.mat');
else
    lbl_exe.fname = getfullname('lbl*','lbl','Select lblrtm executable.');
    save('lbl_exe.mat','-struct','lbl_exe');
end
if ~isafile(lbl_exe.fname)
    lbl_exe.fname = getfullname('lbl*','lbl','Select lbl executable.');
    save('lbl_exe.mat','-struct','lbl_exe');
end
if ~isavar('lbl_tape5')||~isfile(lbl_tape5)
    lbl_tape5 = getfullname('*TAPE5*','lbl_tape5');
end
[~,tape5,ext]= fileparts(lbl_tape5); 
tape5 = [tape5, ext];
[tape5, tag] = strtok(tape5,'.');
if ~isempty(tag)
    tag = tag(2:end);
else
    tag = input('Enter a descriptive tag for this lbl TAPE5 file: ', 's')
end
while isafile([lbl_path,'TAPE5'])
    delete([lbl_path,'TAPE5']);
end
v = 1;
tape12 = [lbl_path, 'TAPE12'];
while isafile(tape12)
    v = v +1; tape12 = [lbl_path, 'TAPE12','.',num2str(v)];
end
if v>1
    movefile([lbl_path, 'TAPE12'],tape12)
end
copyfile(lbl_tape5,[lbl_path,'TAPE5']);
tic; status = system(lbl_exe.fname)
toc
tape12_fullname = [lbl_path, 'TAPE12','.',tag];
movefile([lbl_path, 'TAPE12'],tape12_fullname);
try
    spc = rd_lblrtm_tape12_od(tape12_fullname);
catch
    spc = [];
end

return