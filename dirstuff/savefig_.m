function figout = savefig(fig,figout,tweak);
% figout = savefig(fig,figout,tweak);
% overloaded to support batch or interactive save if tweak is true
% fig is a figure handle
% figout is the output filename
% tweak is a boolean T/F indication to permit interaction before save
if ~exist('fig','var')
    fig = gcf;
end
if ~ishandle(fig)
    figout = fig;
    fig = gcf;
end
saveme = 0;
if exist('figout','var')&~isempty(figout)&exist(figout,'file')
    if ~exist('tweak','var')
        tweak = true;
        saveme = 1;
    end
    if isempty(figout)
    end
    if tweak
        figure(fig);zoom('on');
        saveme = menu('Ready?','OK','Skip');
    end
else
    disp('Save this figure?');
    done = false;
    while ~done
        figure(fig);zoom('on');
        saveme = menu('Save this figure?','Save...','Skip');
        if saveme == 1
            if exist('fname','var')
                [~,fname, ext] = fileparts(fname); fname = [fname,  '.*'];
              [fname, pname] = putfile(fname,'figures','Save the plot here...');
            elseif exist('figout')&~isempty(figout)
                [fname, pname] = putfile([figout,'.*'],'figures','Save the plot here...');
            else
              [fname, pname] = putfile('*.fig;*.png;*.jpg;*.emf','figures','Save the plot here...');
            end
            figout = [pname, fname];
            saveas(fig,figout);
        else
            done = true;
        end
    end
end
if saveme == 1
    saveas(fig,figout);
end
if (saveme == 2)&(~exist('figout','var')|~exist(figout,'file'))
    figout = [];
end
return