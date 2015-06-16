function charts_irrad = read_charts_irradiance(irad_file);
%%
if ~exist('irad_file','var')||~exist(irad_file,'file')
   disp(['Select irradiance (flux) file.']);
   infile2 = getfullname('*.dat','charts')
end
fid2 = fopen(infile2);

dmp = textscan(fid2,'%f %f %f %f \n','HeaderLines','2');
fclose(fid2);
charts_irrad.wn = dmp{1};
charts_irrad.nm = (1000*10000)./dmp{1};
charts_irrad.dir_irrad_wn = dmp{2};
charts_irrad.dir_irrad_cm = dmp{2}.*(dmp{1}.^2);
charts_irrad.dir_irrad_nm = charts_irrad.dir_irrad_cm/1e7;

charts_irrad.dif_irrad_wn = dmp{3};
charts_irrad.dif_irrad_cm = dmp{3}.*(dmp{1}.^2);
charts_irrad.dif_irrad_nm = charts_irrad.dif_irrad_cm/1e7;

charts_irrad.units_irrad_wn = ['W/(m2-c^m-1)'];
charts_irrad.units_irrad_cm = ['W/(m2-cm)'];
charts_irrad.units_irrad_nm = ['W/(m2-nm)'];


h = 6.626e-34;
c = 3e8;
Eperphoton = 6.626e-34 * 3e8 ./ (charts_irrad.nm *1e-9); 
charts_irrad.Eperphoton = Eperphoton;
