function readfig()
% Show figure and output current view of column data to TSV file.

% Browse to figure file.
[filename, dirname] = uigetfile('*.fig');
if (filename == 0)
    return;
end

% Open figure and drill down to stored data.
fighandle = openfig([dirname,filename]);

% Prompt user to save data.
response = menu('Save 2D data to TSV file?', 'Yes', 'No');
if (response ~= 1)
    return;
end

level1 = get(fighandle, 'Children');
for i = 1:length(level1)
    if (isempty(get(level1(i), 'Tag')) & ~isprop(level1(i), 'CData'))
        level0 = get(level1(i), 'Children');
        if (isprop(level0, 'XData'))
            xdata = get(level0, 'XData');
            xlimits = get(level1(i), 'XLim');
            xtitle = 'X Values';
            if (isprop(level1(i), 'XLabel'))
                xtitleobj = get(level1(i), 'XLabel');
                xt = get(xtitleobj, 'String');
                if (~strcmp(xt,''))
                    xtitle = xt;
                end
            end
        end
        if (isprop(level0, 'YData'))
            ydata = get(level0, 'YData');
            ylimits = get(level1(i), 'YLim');
            ytitle = 'Y Values';
            if (isprop(level1(i), 'YLabel'))
                ytitleobj = get(level1(i), 'YLabel');
                yt = get(ytitleobj, 'String');
                if (~strcmp(yt,''))
                    ytitle = yt;
                end
            end
        end
        %if (isprop(level0, 'CData'))
        %    cdata = get(level0, 'CData');
        %    clim = get(level1, 'CLim');
        %end
        break;
    end
end

% Keep only values in current range.
if (exist('xdata','var') & exist('ydata','var'))
    [p,n,e,v] = fileparts([dirname,filename]);
    tsvfile = [p,filesep,n,'.tsv'];
    fid = fopen(tsvfile,'w');
    fprintf(fid,'%s\t%s\n',xtitle,ytitle);
    if (iscell(ydata))
        for i = 1:length(ydata)
            data = prepdata(xdata{i},ydata{i},xlimits,ylimits);
            fprintf(fid,'%f\t%f\n',data);
            fprintf(fid,'\n\n\n\n');
        end
    else
        data = prepdata(xdata,ydata,xlimits,ylimits);
        fprintf(fid,'%f\t%f\n',data);
    end
    fclose(fid);
end

return


function data = prepdata(x,y,xlimits,ylimits)

xinds = find(x >= xlimits(1) & x <= xlimits(2));
yinds = find(y >= ylimits(1) & y <= ylimits(2));
inds = intersect(xinds, yinds);
x = x(inds);
y = y(inds);
data = [x;y];

return

