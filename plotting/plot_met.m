function fig = plot_met(anc, ok);
if exist('ok', 'var')
    ok = 1;
else
    ok =0;
end
doy1 = round(serial2doy0(anc.time(1)));
doy2 = round(serial2doy0(anc.time(end)));
if (doy2-doy1)<1.1
        date_label = datestr(mean(anc.time),'mmm dd yyyy');
        doy2 = doy1+1;
else
    date_label = [datestr(anc.time(1),'mmm dd'), '-' ...
        datestr(anc.time(end),'mmm dd yyyy')];
end

fig = figure;

subplot(2,1,1)
[AX,H1,H2] = plotyy(serial2doy0(anc.time), anc.vars.temperature.data, serial2doy0(anc.time), anc.vars.rh.data, 'plot', 'plot');
set(get(AX(1),'Ylabel'),'String','degrees C');
set(get(AX(2),'Ylabel'),'String','RH %');
legend(AX(1), 'Air Temp', 'location', 'northwest');
legend(AX(2), 'RH%', 'location', 'northeast');
v = axis; 
title(['Southern Surveyor met data:  ', date_label]);

subplot(2,1,2);
no_rain = find(anc.vars.rainrate.data<=0);
   anc.vars.rainrate.data(no_rain) = NaN;
[AX,H1,H2] = plotyy(serial2doy0(anc.time), anc.vars.pressure.data, serial2doy0(anc.time(no_rain)), anc.vars.rainrate.data(no_rain), 'plot', 'semilogy');
x_str = ['day of year (Jan 1 = 0, ', datestr(anc.time(1),'mmm dd'),...
    ' = ' ,num2str(doy1), ')'];
set(get(AX(1),'Xlabel'),'String',x_str);
set(get(AX(1),'Ylabel'),'String','pressure (mB)');
set(get(AX(2),'Ylabel'),'String','rainrate (mm/hr)');
legend(AX(1), 'Atm. Pressure', 'location', 'northwest');
legend(AX(2), 'Rainrate', 'location', 'northeast');
v = axis;
zoom on;
hold off;
if nargin>1
ok = menu('Ready to save graph?', 'OK')
end
[pathstr, name] = fileparts(anc.fname)
if exist([pathstr,'\..\images'],'dir')
  print('-dpng',[pathstr,'\..\images\',name, '.png']);
end
