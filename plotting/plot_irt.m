function fig = plot_irt(anc, ok);

if exist('ok', 'var')
    ok = 1;
else
    ok =0;
end
doy1 = round(serial2doy0(anc.time(1)));
doy2 = round(serial2doy0(anc.time(end)));
if (doy2-doy1)<1.1
        date_label = datestr(mean(anc.time),'mmm dd yyyy');
else
    date_label = [datestr(anc.time(1),'mmm dd'), '-' ...
        datestr(anc.time(end),'mmm dd yyyy')];
end

fig = figure;
plot(serial2doy0(anc.time), anc.vars.tbsky_ir.data, 'r.');
title(['Southern Surveyor sky brightness:  ', date_label]);
xlabel(['day of year (Jan 1 = 0, ', datestr(anc.time(1),'mmm dd'),...
    ' = ' ,num2str(doy1), ')']);
ylabel('Brightness Temperature (deg K)');
v = axis; axis([doy1, doy2, v(3), v(4)]);
legend('T_s_k_y');

zoom on;
hold off;
while ok==1
    v = axis;
    t1 = min(find(serial2doy0(anc.time)>=v(1)));
    t2 = max(find(serial2doy0(anc.time)<=v(2)));
    doy1 = round(serial2doy0(anc.time(t1)));
    doy2 = round(serial2doy0(anc.time(t2)));
    if (doy2-doy1)<1.1
        date_label = datestr(mean(anc.time),'mmm dd yyyy');
    else
        date_label = [datestr(anc.time(1),'mmm dd'), '-' ...
            datestr(anc.time(end),'mmm dd yyyy')];
    end
    title(['Southern Surveyor sky brightness:  ', date_label]);
    xlabel(['day of year (Jan 1 = 0, ', datestr(anc.time(t1),'mmm dd'),...
        ' = ' ,num2str(doy1), ')']);

    ok = menu('Select option: ', 'Update Graph', 'Save Graph');
end
[pathstr, name] = fileparts(anc.fname)
if exist([pathstr,'\..\images'],'dir')
    print('-dpng',[pathstr,'\..\images\',name, '.png']);
    close(fig);
    fig = 0;
end

