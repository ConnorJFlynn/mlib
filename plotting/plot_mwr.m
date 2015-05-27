function fig = plot_mwr(anc, ok);
midtime = mean(anc.time);
doy = floor(serial2doy0(midtime));
fig = figure; subplot(2,1,1)
plot(serial2doy0(anc.time), anc.vars.tbsky23.data, 'g', serial2doy0(anc.time), anc.vars.tbsky31.data, 'b');
title(['MWR on Southern Surveyor:  ', datestr(midtime,'yyyy-mm-dd')]);
xlabel(['day of year (Jan 1 = 0, ', datestr(midtime,'mmm dd'),...
    ' = ' ,num2str(doy), ')']);
ylabel('degrees K');
legend('23 GHz', '31 GHz');
v = axis; axis([doy, doy+1, v(3), v(4)]);

subplot(2,1,2);
[AX,H1,H2] = plotyy(serial2doy0(anc.time), anc.vars.vap.data, serial2doy0(anc.time), anc.vars.liq.data, 'plot', 'semilogy');
xlabel(['day of year (Jan 1 = 0, ', datestr(midtime,'mmm dd'),...
    ' = ' ,num2str(doy), ')']);
set(get(AX(1),'Ylabel'),'String','PWV cm');
set(get(AX(2),'Ylabel'),'String','LWP mm');
legend(AX(1), 'PWV', 'location', 'northwest');
legend(AX(2), 'LWP', 'location', 'northeast');
v = axis; axis([doy, doy+1, v(3), v(4)]);

zoom on;
hold off;
if nargin>1
ok = menu('Ready to save graph?', 'OK')
end
[pathstr, name] = fileparts(anc.fname)
if exist([pathstr,'\..\images'],'dir')
  print('-dpng',[pathstr,'\..\images\',name, '.png']);
end

