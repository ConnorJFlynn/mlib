function fig = plot_vceil(anc, ok);
midtime = mean(anc.time);
doy = floor(serial2doy0(midtime));
fig = figure; 
negs = find(anc.vars.backscatter.data<=0);
anc.vars.backscatter.data(negs) = NaN;

imagesc(serial2doy0(anc.time), anc.vars.range.data/1000, real(log(anc.vars.backscatter.data)));
axis('xy'); v = axis; axis([v(1), v(2), 0, 7]);
cv = caxis; caxis([-1,9]); colorbar;

hold on;
plot(serial2doy0(anc.time),anc.vars.first_cbh.data/1000, 'r.', ... 
    serial2doy0(anc.time), anc.vars.second_cbh.data/1000, 'b.', ... 
    serial2doy0(anc.time), anc.vars.third_cbh.data/1000, 'g.')

title(['Southern Surveyor ceilometer:  ', datestr(midtime,'yyyy-mm-dd')]);
xlabel(['day of year (Jan 1 = 0, ', datestr(midtime,'mmm dd'),...
    ' = ' ,num2str(doy), ')']);
ylabel('range (km)');
   
zoom on;
hold off;
if nargin>1
ok = menu('Ready to save graph?', 'OK')
end
[pathstr, name] = fileparts(anc.fname)
if exist([pathstr,'\..\images'],'dir')
  print('-dpng',[pathstr,'\..\images\',name, '.png']);
end
