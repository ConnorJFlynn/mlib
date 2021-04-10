function outfilename = extract_plot_data(hfig, extras)
% outfilename = extract_fig_data(hfig,extras)
% Intended to extract column-ordered data from plots and generate ASCII
% column-ordered output
% If no hfig provided, prompted to select window or figure file
% Optional argument "extras" for specifying delimiter, output path,
% filename stem, fieldname, and whether to trim data to limits.
% extras.delimiter = ',' '\t'
% extras.trim = true;
% extras.ext = 'csv'; 'tsv' 'txt' 'dat'
% extras.pname = 'C:\Users\d3k014\Documents\MATLAB\extract_out\';
% extras.dsname = 'asiaop1flynnM1';
% extras.plotname = 'Ba_combined';

if isempty(who('hfig'))|| isempty(hfig)
    fig = menu('Select an open figure window or a file:','Figure Window','Select a File...');
    if fig>1
        fig_file = getfullname('*.fig','fig','Select a Matlab figure file.');
        hfig = open(fig_file);
    else
        menu('Select OK after clicking on image...','OK')
        hfig = gcf;
    end
end

if ~isempty(who('extras'))&&isfield(extras,'delimiter')
    delimiter = extras.delimiter;
else
    delimiter = ',';
end
if ~isempty(who('extras'))&&isfield(extras,'trim')&&isempty(extras.trim)
    extras.trim = (menu('Extract entire time series or limit to visible axes?','Entire', 'Visible'))>1;
end
leg = findobj(hfig,'Type','legend');
if length(leg)>1
    menu('Select the axes to extract.  Hit OK when ready.','OK');
    pause(0.25);
    leg = get(gca,'Legend');
end

leg_str = leg.String;
d = findall(gca, '-property', 'xdata');
xydatas = flipud(arrayfun(@(h) get(h, {'xdata','ydata', 'type'}), d, 'Uniform', 0));

v = axis; xl = [v(1) v(2)]; yl = [v(3) v(4)];
%
%     for L = length(leg_str):-1:2
for L = 1:length(xydatas)
    if L>length(leg_str)
        leg_str(L) = {sprintf('Col_%d',L)};
    end
    if L ==1
        out.x = xydatas{1}{1,1};
        out.y = xydatas{1}{1,2};
        if ~isempty(who('extras'))&&isfield(extras,'trim')&&extras.trim
            trim = out.x<min(xl)|out.x>max(xl)|out.y<min(yl)|out.y>max(yl);
            out.x(trim) = []; out.y(trim) = [];
        end
    else
        tmp.x = xydatas{L}{1,1};
        tmp.y = xydatas{L}{1,2};
        if ~isempty(who('extras'))&&isfield(extras,'trim')&&extras.trim
            trim = tmp.x<min(xl)|tmp.x>max(xl)|tmp.y<min(yl)|tmp.y>max(yl);
            tmp.x(trim) = []; tmp.y(trim) = [];
        end
        if length(out.x)~=length(tmp.x)||~all(out.x==tmp.x)
            if ~isempty(who('out_'))
                clear out_;
            end
            tmp_x = [out.x, tmp.x];
            out_x = unique(tmp_x);
            tmp_y = NaN(size(out_x));
            out_.y(L,:) = tmp_y;
            ij = interp1(out_x,(1:length(out_x)),tmp.x,'nearest');
            out_.y(L,ij) = tmp.y;
            ij = interp1(out_x,(1:length(out_x)),out.x,'nearest');
            for y = size(out.y,1):-1:1
                out_.y(y,:) = tmp_y;
                out_.y(y,ij) = out.y(y,:);
            end
            out.x = out_x; out.y = out_.y;
        else
            out.y = [out.y; tmp.y];
        end
    end
end
% Adjust legend if ui
% So, now we have out with .x and .y portions.
out_time = false;
if all(out.x>datenum(1972,1,1))&&all(out.x<now)
    out_time = true;
end
if out_time
    x_label = ('YYYY-MM-DD HH:MM:SS, YYYY, MM, DD, hh, mm, ss.fff');
    d_str = datestr(out.x,'yyyy-mm-dd HH:MM:SS')';
    fmt_str = ['%d, %d, %d, %d, %d, %g ',repmat(', %g',[1,size(out.y,1)]) '\n'];
else
    % then x-axis doesn't seem to be time so grab the xlabel string
    hax = gca; 
%     x_label = [strtok(hax.XLabel.String) ' '];
    x_label = strrep(hax.XLabel.String,delimiter,'');
    if isempty(x_label)
        x_label = 'X axis';
    end
    fmt_str = ['%g',repmat(', %g',[1,size(out.y,1)]) '\n'];
end

fmt_str = strrep(fmt_str,',',delimiter);
if out_time
    Ntime = datevec(out.x)';
    out_block = [Ntime', out.y']';
else
    out_block = [out.x',out.y']';
end
% out_txt = sprintf(fmt_str,out_block);

header_row = x_label;
for LG = 1:length(leg_str)
    leg_str(LG) = strrep(leg_str(LG),',','');
    header_row = [header_row, ', ',leg_str{LG}];
end
header_row = strrep(header_row,',',delimiter);
if ~isempty(who('extras'))&&isfield(extras,'pname')&&isdir(extras.pname)
    outpath = extras.pname;
else
    outpath = getnamedpath('ascii_out');
end

outmask = ('*.csv;*.dat;*.txt');
if ~strcmp(delimiter,',') 
    outmask = ('*.tsv;*.dat;*.txt'); 
end
% datastream name if supplied
if ~isempty(who('extras'))&&isfield(extras,'dsname')
    dsname = extras.dsname;
end
% plot name if supplied
if ~isempty(who('extras'))&&isfield(extras,'plotname')
    plotname = extras.plotname;
end
if out_time
    datestamp = {datestr(out.x(1),'yyyymmdd'), datestr(out.x(end),'yyyymmdd')};
    datestamp = unique(datestamp);
    if length(datestamp)>1
        datestamp = [datestamp{1},'_',datestamp{2}];
    end
end
if ~isempty(who('extras'))&&isfield(extras,'ext')
    ext = extras.ext;
elseif strcmp(delimiter,',')
    ext = 'csv';
elseif strcmp(delimiter,'/n')
    ext = 'tsv';
else
    ext = 'dat';
end
if iscell(datestamp) datestamp = datestamp{1};end
if ~isempty(who('extras'))&&~isempty(who('datestamp'))&&~isempty(who('plotname'))&&~isempty(who('dsname'))
    outfile = [dsname, '.',datestamp,'.', plotname, '.',ext];
    [fname_, pname_] =putfile([outpath outfile]);
else
    [fname_, pname_] = putfile(outmask,'out_dat','Save file as...');
end


if ~strcmp(outpath, pname_)
    setnamedpath('ascii_out',pname_);
end
outfilename = [pname_, fname_];
fid = fopen(outfilename,'w');
fprintf(fid, '%s \n',strrep(header_row,'\t',char(9)));
for X = 1:length(out.x)
    if out_time
        ffs = ['%s',delimiter, ' '];
        fprintf(fid,ffs,d_str(:,X));
        fprintf(fid,fmt_str, out_block(:,X));
%         out_txt = [sprintf(ffs,d_str(:,X)),sprintf(fmt_str, out_block(:,X))];
    else
        fprintf(fid,fmt_str, out_block(:,X));
%         out_txt = [sprintf(fmt_str, out_block(:,X))];        
    end
end
fclose(fid);

return