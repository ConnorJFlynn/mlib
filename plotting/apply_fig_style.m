function [h, figout] = apply_fig_style(h, h_)
% [h, figout] = apply_fig_style(h, h_)
% Applies style changes to an existing figure with handle 'h' based on either the default
% settings or a supplied figure with handle 'h_' as template. 
% Returns both the handle to the modified figure and the resulting output
% file.
if ~exist('h','var');
    fig_name = getfullname('*.fig','figs','Apply settings to selected figure...');
    h = open(fig_name);
end
lg = legend('toggle'); lg = legend('toggle'); vis = get(lg,'visible');
ha = get(h,'CurrentAxes');
hx = get(ha,'Xlabel');
hy = get(ha,'Ylabel');
hz = get(ha,'Zlabel');
ht = get(ha,'Title');

if ~exist('h_','var')
    abc = menu('Use settings from...','Selected figure...','Selected "plots_*" file','Current settings');
    if abc==1
        fig_temp = getfullname('*.fig','fig_template','Select a figure to use as style template if desired.');
    elseif abc==2
        [~,plots_file,~] = fileparts(getfullname('plots_*.m','plots_file','Select "plots_*" file.'));
        eval(plots_file);
    end
end
if exist('fig_temp','var')&&exist(fig_temp,'file')
    h_ = open(fig_temp);
else
    h_ = [];
end
if isempty(h_)
    h_ = figure; plot([1:10],[1:10],'-o'); 
end
lg_ = legend('toggle');lg_ = legend('toggle');
set(h_,'visible','off');
orig_pos = get(h,'position'); 
new_pos = get(h_,'position');
new_pos(1:2) = orig_pos(1:2);
set(h,'position',new_pos);

ha_ = get(h_,'CurrentAxes');clear 'h_';
h_.ha_.Box = get(ha_,'Box');
h_.ha_.Color = get(ha_,'Color');
h_.ha_.FontAngle = get(ha_,'FontAngle');
h_.ha_.FontName = get(ha_,'FontName');
h_.ha_.FontSize = get(ha_,'FontSize');
h_.ha_.FontUnits = get(ha_,'FontUnits');
h_.ha_.FontWeight = get(ha_,'FontWeight');
h_.ha_.GridLineStyle = get(ha_,'GridLineStyle');
h_.ha_.MinorGridLineStyle = get(ha_,'MinorGridLineStyle');
h_.ha_.LineWidth = get(ha_,'LineWidth');
h_.ha_.TickLength = get(ha_,'TickLength');
h_.ha_.TickDir = get(ha_,'TickDir');
h_.ha_.XColor = get(ha_,'XColor');
h_.ha_.XDir = get(ha_,'XDir');
h_.ha_.XGrid = get(ha_,'XGrid');
h_.ha_.YColor = get(ha_,'YColor');
h_.ha_.YDir = get(ha_,'YDir');
h_.ha_.YGrid = get(ha_,'YGrid');
h_.ha_.ZColor = get(ha_,'ZColor');
h_.ha_.ZDir = get(ha_,'ZDir');
h_.ha_.ZGrid = get(ha_,'ZGrid');

h_.lg_.Box = get(lg_,'Box');
h_.lg_.Color = get(lg_,'Color');
h_.lg_.FontAngle = get(lg_,'FontAngle');
h_.lg_.FontName = get(lg_,'FontName');
h_.lg_.FontSize = get(lg_,'FontSize');
h_.lg_.FontUnits = get(lg_,'FontUnits');
h_.lg_.FontWeight = get(lg_,'FontWeight');
h_.lg_.LineWidth = get(lg_,'LineWidth');
h_.lg_.XColor = get(lg_,'XColor');
h_.lg_.XDir = get(lg_,'XDir');
h_.lg_.XGrid = get(lg_,'XGrid');
h_.lg_.YColor = get(lg_,'YColor');
h_.lg_.YDir = get(lg_,'YDir');
h_.lg_.YGrid = get(lg_,'YGrid');
h_.lg_.ZColor = get(lg_,'ZColor');
h_.lg_.ZDir = get(lg_,'ZDir');
h_.lg_.ZGrid = get(lg_,'ZGrid');
h_.lg_.Orientation = get(lg_,'Orientation');
h_.lg_.EdgeColor = get(lg_,'EdgeColor');
h_.lg_.TextColor = get(lg_,'TextColor');
%
%Orientation
%EdgeColor
%TextColor


hx_ = get(ha_,'xlabel');
h_.hx_.BackgroundColor = get(hx_,'BackgroundColor');
h_.hx_.Color = get(hx_,'Color');
h_.hx_.EdgeColor = get(hx_,'EdgeColor');
h_.hx_.FontAngle = get(hx_,'FontAngle');
h_.hx_.FontName = get(hx_,'FontName');
h_.hx_.FontSize = get(hx_,'FontSize');
h_.hx_.FontUnits = get(hx_,'FontUnits');
h_.hx_.FontWeight = get(hx_,'FontWeight');
h_.hx_.HorizontalAlignment = get(hx_,'HorizontalAlignment');
h_.hx_.LineStyle = get(hx_,'LineStyle');
h_.hx_.LineWidth = get(hx_,'LineWidth');
h_.hx_.Rotation = get(hx_,'Rotation');
h_.hx_.VerticalAlignment = get(hx_,'VerticalAlignment');

hy_ = get(ha_,'ylabel');
h_.hy_.BackgroundColor = get(hy_,'BackgroundColor');
h_.hy_.Color = get(hy_,'Color');
h_.hy_.EdgeColor = get(hy_,'EdgeColor');
h_.hy_.FontAngle = get(hy_,'FontAngle');
h_.hy_.FontName = get(hy_,'FontName');
h_.hy_.FontSize = get(hy_,'FontSize');
h_.hy_.FontUnits = get(hy_,'FontUnits');
h_.hy_.FontWeight = get(hy_,'FontWeight');
h_.hy_.HorizontalAlignment = get(hy_,'HorizontalAlignment');
h_.hy_.LineStyle = get(hy_,'LineStyle');
h_.hy_.LineWidth = get(hy_,'LineWidth');
h_.hy_.Rotation = get(hy_,'Rotation');
h_.hy_.VerticalAlignment = get(hy_,'VerticalAlignment');

hz_ = get(ha_,'zlabel');
h_.hz_.BackgroundColor = get(hz_,'BackgroundColor');
h_.hz_.Color = get(hz_,'Color');
h_.hz_.EdgeColor = get(hz_,'EdgeColor');
h_.hz_.FontAngle = get(hz_,'FontAngle');
h_.hz_.FontName = get(hz_,'FontName');
h_.hz_.FontSize = get(hz_,'FontSize');
h_.hz_.FontUnits = get(hz_,'FontUnits');
h_.hz_.FontWeight = get(hz_,'FontWeight');
h_.hz_.HorizontalAlignment = get(hz_,'HorizontalAlignment');
h_.hz_.LineStyle = get(hz_,'LineStyle');
h_.hz_.LineWidth = get(hz_,'LineWidth');
h_.hz_.Rotation = get(hz_,'Rotation');
h_.hz_.VerticalAlignment = get(hz_,'VerticalAlignment');

ht_ = get(ha_,'Title');
h_.ht_.BackgroundColor = get(ht_,'BackgroundColor');
h_.ht_.Color = get(ht_,'Color');
h_.ht_.EdgeColor = get(ht_,'EdgeColor');
h_.ht_.FontAngle = get(ht_,'FontAngle');
h_.ht_.FontName = get(ht_,'FontName');
h_.ht_.FontSize = get(ht_,'FontSize');
h_.ht_.FontUnits = get(ht_,'FontUnits');
h_.ht_.FontWeight = get(ht_,'FontWeight');
h_.ht_.HorizontalAlignment = get(ht_,'HorizontalAlignment');
h_.ht_.LineStyle = get(ht_,'LineStyle');
h_.ht_.LineWidth = get(ht_,'LineWidth');
h_.ht_.Rotation = get(ht_,'Rotation');
h_.ht_.VerticalAlignment = get(ht_,'VerticalAlignment');


h_ax = fieldnames(h_.ha_);
h_ax_x = fieldnames(h_.hx_);
h_ax_y = fieldnames(h_.hy_);
h_ax_z = fieldnames(h_.hz_);
h_ax_t = fieldnames(h_.ht_);
h_lg = fieldnames(h_.lg_);

for fields = 1:length(h_ax)
    fld = char(h_ax{fields});
    set(ha,fld,h_.ha_.(fld));
end    

for fields = 1:length(h_lg)
    fld = char(h_lg{fields});
    set(lg,fld,h_.lg_.(fld));
end

for fields = 1:length(h_ax_x)
    fld = char(h_ax_x{fields});
    set(hx,fld,h_.hx_.(fld));
end   

for fields = 1:length(h_ax_y)
    fld = char(h_ax_y{fields});
    set(hy,fld,h_.hy_.(fld));
end

for fields = 1:length(h_ax_z)
    fld = char(h_ax_z{fields});
    set(hz,fld,h_.hz_.(fld));
end   

for fields = 1:length(h_ax_t)
    fld = char(h_ax_t{fields});
    set(ht,fld,h_.ht_.(fld));
end 
figure(h);
legend('off'); 
lgg = legend('toggle'); 
set(lgg,'visible',vis);
set(h,'PaperUnits','inches');set(h,'PaperPositionMode','auto');

[pname, fname, ext] = fileparts(get(h,'filename'));
figout = savefig(h,[pname, filesep,fname,'*.*'],'true');

return