%slices for Jochen

plots_ppt;
hh = [1 2];
zz = logical((mplz_day.hk.zenith>=(min(zen)-.1))&(mplz_day.hk.zenith<=(.1+max(zen)))&...
   (serial2Hh(mplz_day.time)>=min(hh))&(serial2Hh(mplz_day.time)<=max(hh)));
zz_i = find(zz);
el = 90 -(zen -0.6);
fig=figure; plot(range.*(cos(el*pi/180)),A(:,zz));

title({['Attenuated backscatter from MPL: ', datestr(mean(mplz_day.time(zz)),'yyyy-mm-dd')],['Elevation angle = ', sprintf('%2.1f degrees',el)]});
ylabel('backscatter(relative units)')
xlabel('horizontal range (km)');
clear leg
for l = length(zz_i):-1:1
   leg{l} = [datestr(mplz_day.time(zz_i(l)),'HH:MM'),' LST'];
end
legend(leg)
        pngname = ['tnmpl_el_',num2str(abs(el)),'.',datestr(daynum,'yyyy_mm_dd'),'.png'];
        print(fig, [image_base,day_dir,'\',pngname],'-dpng')
pause(.5)
plots_default
