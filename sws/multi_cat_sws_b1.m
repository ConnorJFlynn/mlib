clear; 

indir = getdir('sgpswsC1*.cdf', 'swsb1');
[files] = dir_('sgpswsC1*.cdf',indir);
%%
         maxmem = 60*60*2048;
for s = 1:length(files);
    sws_  = ancloadcoords([indir,files(1).name]);
       recs = round(maxmem./sws_.dims.wavelength.length);
    display(['Processing ',num2str(1),' of ', num2str(sws_.dims.time.length), ' by ', num2str(recs)]);
    sws_cat = ancloadpart(sws_, 1, recs);
    V = datevec(sws_cat.time);
      sws_cat = ancsift(sws_cat,sws_cat.dims.time,[true;diff(V(:,5))==1]);

     for r = (1+recs):recs:sws_.dims.time.length
          display(['Processing ',num2str(r),' of ', num2str(sws_.dims.time.length), ' by ', num2str(recs)]);
      sws = ancloadpart(sws_, r, recs);
      V = datevec(sws.time);
      sws = ancsift(sws,sws.dims.time,[true;diff(V(:,5))==1]);
      sws_cat = anccat(sws_cat, sws);
     end
end

disp('done')

%%
figure; 
lines = plot(sws_cat.vars.wavelength.data, sws_cat.vars.zen_spec_calib.data,'-');
recolor(lines,serial2doy(sws_cat.time)); colorbar;
%%