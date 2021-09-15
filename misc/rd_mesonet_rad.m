function mnet = rd_mesonet_rad(infile)

if ~isavar('infile')||~isafile(infile)
   infile = getfullname('*.csv','mesonet','Select mesonet csv file');
end
%tic
if isafile(infile)
   
   fid = fopen(infile);
   % STID	TIME	PRES	TAIR	TMIN	TMAX	TDEW	RELH	WDIR	WSPD	WMAX	RAIN	SRAD
   A = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %*[^\n]', 'Headerlines',1,'delimiter',',');
   fclose(fid);
   mnet.site = A{1};
   A(1) = []; tmp = A{1};
   mnet.time = datenum(tmp,'yyyy-mm-ddTHH:MM');

   A(1) = []; tmp = A{1}; miss = (tmp <-990 & tmp>-1000); tmp(miss) = NaN;
   mnet.pres = tmp;
   A(1) = []; tmp = A{1}; miss = (tmp <-990 & tmp>-1000); tmp(miss) = NaN;
   mnet.T_air = tmp;
   A(1) = []; tmp = A{1}; miss = (tmp <-990 & tmp>-1000); tmp(miss) = NaN;
   mnet.T_min = tmp;
   A(1) = []; tmp = A{1}; miss = (tmp <-990 & tmp>-1000); tmp(miss) = NaN;
   mnet.T_max = tmp;
   A(1) = []; tmp = A{1}; miss = (tmp <-990 & tmp>-1000); tmp(miss) = NaN;
   mnet.T_dew = tmp;
   A(1) = []; tmp = A{1}; miss = (tmp <-990 & tmp>-1000); tmp(miss) = NaN;
   mnet.RH = tmp;
   A(1) = []; tmp = A{1}; miss = (tmp <-990 & tmp>-1000); tmp(miss) = NaN;
   mnet.W_dir = tmp;
   A(1) = []; tmp = A{1}; miss = (tmp <-990 & tmp>-1000); tmp(miss) = NaN;
   mnet.W_spd = tmp;
   A(1) = []; tmp = A{1}; miss = (tmp <-990 & tmp>-1000); tmp(miss) = NaN;
   mnet.W_max = tmp;
   A(1) = []; tmp = A{1}; miss = (tmp <-990 & tmp>-1000); tmp(miss) = NaN;
   mnet.SRad = tmp;

else
   mnet = [];
end
[meson.time, ij] = sort(mnet.time);
meson.site = mnet.site(ij);
meson.pres = mnet.pres(ij);
meson.T_air = mnet.T_air(ij);
meson.T_min = mnet.T_min(ij);
meson.T_max = mnet.T_max(ij);
meson.T_dew = mnet.T_dew(ij);
meson.RH = mnet.RH(ij);
meson.W_dir = mnet.W_dir(ij);
meson.W_spd = mnet.W_spd(ij);
meson.W_max = mnet.W_max(ij);
meson.SRad = mnet.SRad(ij);
end