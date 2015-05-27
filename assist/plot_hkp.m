function hkp = plot_hkp;
hk_dir = ['C:\case_studies\assist\data\native_data\latest\assistrawS1.2011_01_02_06_00_50_RAW\'];
hk_dir = 'C:\case_studies\assist\docs\ARM\DOD\ingest\hkp\';
hks = dir([hk_dir,'*_hkp_*.csv']);
hkp = rd_hkp([hk_dir,hks(1).name]);
%%
tic
for f = 2:length(hks)
   hkp = cat_hkp(hkp,[hk_dir,hks(f).name]);
end
toc
%%
fields = fieldnames(hkp);
for f = 2:length(fields)
   if isempty(findstr(fields{f},'_status'))&&isempty(findstr(fields{f},'_time_lag'))
      good = hkp.([fields{f},'_status'])==0;
      good_ii = find(good);
      if any(good)
   plot(serial2Hh(hkp.time(good)+hkp.([fields{f},'_time_lag'])(good)), hkp.(fields{f})(good), 'og-');
      end
      if any(~good)
         hold('on');
      plot(serial2Hh(hkp.time(~good)), hkp.(fields{f})(~good), 'or');
      hold('off')
      end
   title(fields{f},'interp','none')
   end
end
%%
tic
fid_all = fopen([hk_dir,'all_hkp.dat'],'a');
for f = 1:length(hks)
   fid = fopen([hk_dir,hks(f).name],'r');
   fwrite(fid_all,fread(fid));
   fclose(fid);
end
fclose(fid_all);
toc
%%
hk_dir = 'C:\case_studies\assist\docs\ARM\DOD\ingest\hkp\';
hkp_all = rd_hkp([hk_dir,'all_hkp.dat']);
%%
hold('on');
field_str = 'power_supply_box_temp';
good_ = anc.vars.(field_str).data>-9990;
plot(serial2Hh(anc.time(good_)+double(anc.vars.([field_str,'_time_lag']).data(good_))./(24.*60.*60)), anc.vars.(field_str).data(good_), 'b.')
hold('off');
grid('on');
zoom('on');
%%
return