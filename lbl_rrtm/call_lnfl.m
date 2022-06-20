function tape3_fullname = call_lnfl(lnfl_tape5)
% tape3_fullname = call_lnfl(lnfl_tape5,tag)
% Accepts or queries for lnfl_tape5.
% if isavar(tag), appends tag to supplied/selected lnfl_tape5
% if LNFL tape5 exists, deletes.
% Copies lnfl_tape5 to lnfl_path/TAPE5
% Calls LNFL
% Copies TAPE3 to ['TAPE3.' tag] (moves instead? yes, to avoid inadvertent
% use of unknown TAPE3 output)

lnfl_path = getpname('lnfl');
if isafile('lnfl_exe.mat')
    lnfl_exe = load('lnfl_exe.mat');
else
    lnfl_exe.fname = getfullname('lnfl*','lnfl','Select lnfl executable.');
    save('lnfl_exe.mat','-struct','lnfl_exe');
end
if ~isafile(lnfl_exe.fname)
    lnfl_exe.fname = getfullname('lnfl*','lnfl','Select lnfl executable.');
    save('lnfl_exe.mat','-struct','lnfl_exe');
end
if ~isavar('lnfl_tape5')||~isfile(lnfl_tape5)
    lnfl_tape5 = getfullname('*TAPE5*','lnfl_tape5');
end
[~,tape5,ext]= fileparts(lnfl_tape5); 
tape5 = [tape5, ext];
[tape5, tag] = strtok(tape5,'.');
if ~isempty(tag)
    tag = tag(2:end);
else
    tag = input('Enter a descriptive tag for this lnfl TAPE5 file: ', 's')
end
if isafile([lnfl_path,'TAPE5'])
    delete([lnfl_path,'TAPE5']);
end
copyfile(lnfl_tape5,[lnfl_path,'TAPE5']);
tic; status = system(lnfl_exe.fname)
toc

return