function OpenFigure

k = menu('Select an action:','Open figure','Open figures...','Convert to png');
if k==1
    [status, fname, pname] = getfile('*.fig');
    if status>1
        if exist([pname, fname],'file')==2
            open([pname,fname]);
        else
            disp(['Unable to open ',[pname,fname],' as a ''.fig'' file.']);
        end
    end
elseif k==2
    pname = uigetdir;
    figs = dir([pname, filesep,'*.fig']);
    for m = length(figs):-1:1
        fig(m) = open([pname,filesep,figs(m).name]);
    end
elseif k==3
    pname = uigetdir; pname = [pname, filesep];
    figs = dir([pname, '*.fig']);
    for m = length(figs):-1:1
        fig = open([pname,filesep,figs(m).name]);
        set(fig,'visible','off');
        [pname, fname, ext] = fileparts([pname,filesep,figs(m).name]);
        if ~exist([pname,'\png'])
            mkdir(pname, 'png');
        end
        print(fig,[pname,'\png\',fname,'.png'],'-dpng');
        close(fig);
    end
end    