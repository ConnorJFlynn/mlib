function fix_aod_series(fiq, in_dir);
if ~exist('fiq','var')||isempty(fiq)
   fiq = loadinto(getfullname_('*.mat','fiq','Select a common langley file (with IQF).'));
end
if isfield(fiq,'IQF')
   fiq = fiq.IQF;
end
if ~exist('in_dir','var')
   in_dir = getdir([],'aod_dir','Select directory containing aod files to be corrected.')
end
if exist(in_dir,'dir')
   in_file = dir([in_dir,'*.cdf']);
elseif exist(in_dir,'file') %then it is just a filename, not a directory
   [in_dir, in_file(1).name,ext] = fileparts(in_dir);
   in_dir = [in_dir, filesep];
   in_file(1).name = [in_file(1).name, ext];
end
% 
% for ff = 1:length(in_file)
%    disp(['Getting time from : ',in_file(ff).name, ]);
%    disp(['File #',num2str(ff), ' of ',num2str(length(in_file)),'.']);
%    %    old_day = ancload(['F:\case_studies\fkb\fkbmfrsraod1michM1.c1\fkbmfrsraod1michM1.c1.20070502.000000.cdf']);
%    %    day = ancload(['F:\case_studies\fkb\fkbmfrsraod1flynnM1.c0\fkbmfrsraod1michM1.c1.20070502.000000.cdf']);
%    day = ancload([in_dir, in_file(ff).name]);
%    day_time = mean(day.time);
%    this.time(ff) = day_time;
%    P = gaussian(fiq.time,this.time(ff),10);
%    for ii = 1:5;
%       this.Io_new.(['filter',num2str(ii)])(ff) = trapz(fiq.time,fiq.(['filter',num2str(ii)]).*P)./trapz(fiq.time,P);
%    end
% end
% for ii = 1:5;
%    NoNaNs = ~isNaN(fiq.(['filter',num2str(ii)]));
%    this.Io_int.(['filter',num2str(ii)]) = interp1(fiq.time(NoNaNs), fiq.(['filter',num2str(ii)])(NoNaNs), this.time,'linear','extrap');
% end


for ff = 1:length(in_file)
   disp(['Processing: ',in_file(ff).name, ]);
   disp(['File #',num2str(ff), ' of ',num2str(length(in_file)),'.']);
   %    old_day = ancload(['F:\case_studies\fkb\fkbmfrsraod1michM1.c1\fkbmfrsraod1michM1.c1.20070502.000000.cdf']);
   %    day = ancload(['F:\case_studies\fkb\fkbmfrsraod1flynnM1.c0\fkbmfrsraod1michM1.c1.20070502.000000.cdf']);
   day = ancload([in_dir, in_file(ff).name]);
   day_time = mean(day.time);
   this.time(ff) = day_time;
   P = gaussian(fiq.time,day_time,30);
   for ii = 1:5;
      Io_new.(['filter',num2str(ii)]) = trapz(fiq.time,fiq.(['filter',num2str(ii)]).*P)./trapz(fiq.time,P);
   end
   day = apply_Io_corr(Io_new, day);
end

return

function day = apply_Io_corr(Io_new, day);
% apply_Io_corr(Io_new, day);
% required: Io_new.filter[1:5] 
% prompt for day file if not supplied
% Applies corrections to tau, aod, and irradiances for new Io value.
if ~exist('Io_new','var')||isempty(Io_new)
   error('New Io values are required as input.')
end
if ~exist('day','var')||isempty(day)
   day = ancload;
end

   for ii = 1:5;
      Io_old.(['filter',num2str(ii)]) = sscanf(day.vars.(['direct_normal_narrowband_filter',num2str(ii)]).atts.(['Gueymard_TOA_filter',num2str(ii)]).data,'%f');
%       Io = sscanf(new_mfr.vars.direct_normal_narrowband_filter5.atts.Gueymard_TOA_filter5.data,'%f');
      day.vars.(['Io_filter',num2str(ii)]).data = single(Io_new.(['filter',num2str(ii)]));
      MdTau.(['filter',num2str(ii)]) = log(Io_new.(['filter',num2str(ii)])./Io_old.(['filter',num2str(ii)]));
      pos = (day.vars.(['total_optical_depth_filter',num2str(ii)]).data>-9000)&(day.vars.(['aerosol_optical_depth_filter',num2str(ii)]).data>-9000);
      OD_gas.(['filter',num2str(ii)]) = NaN(size(day.vars.(['total_optical_depth_filter',num2str(ii)]).data));
      tod = NaN(size(day.vars.(['total_optical_depth_filter',num2str(ii)]).data));
      dirn_1au = tod;
      OD_gas.(['filter',num2str(ii)])(pos) = day.vars.(['total_optical_depth_filter',num2str(ii)]).data(pos) ...
         - day.vars.(['aerosol_optical_depth_filter',num2str(ii)]).data(pos);
      day.vars.(['total_optical_depth_filter',num2str(ii)]).data(pos) = day.vars.(['total_optical_depth_filter',num2str(ii)]).data(pos) ...
         + MdTau.(['filter',num2str(ii)])./day.vars.airmass.data(pos);
% The following three lines confirm the MdTau correction for tau
%       dirn_1au(pos) = day.vars.(['direct_normal_narrowband_filter',num2str(ii)]).data(pos).*(day.vars.sun_to_earth_distance.data.^2);
%       atm_tran = dirn_1au(pos) ./Io_new.(['filter',num2str(ii)]);
%       tod(pos) = log(1./atm_tran)./day.vars.airmass.data(pos);
      %%
      day.vars.(['aerosol_optical_depth_filter',num2str(ii)]).data(pos) = day.vars.(['total_optical_depth_filter',num2str(ii)]).data(pos) ...
         - OD_gas.(['filter',num2str(ii)])(pos);
      rad_corr = (Io_new.(['filter',num2str(ii)])./Io_old.(['filter',num2str(ii)]));
      day.vars.(['hemisp_narrowband_filter',num2str(ii)]).data(pos) = (rad_corr).*day.vars.(['hemisp_narrowband_filter',num2str(ii)]).data(pos);
      day.vars.(['diffuse_hemisp_narrowband_filter',num2str(ii)]).data(pos) = (rad_corr).*day.vars.(['diffuse_hemisp_narrowband_filter',num2str(ii)]).data(pos);
      day.vars.(['direct_horizontal_narrowband_filter',num2str(ii)]).data(pos) = (rad_corr).*day.vars.(['direct_horizontal_narrowband_filter',num2str(ii)]).data(pos);
      day.vars.(['direct_normal_narrowband_filter',num2str(ii)]).data(pos) = (rad_corr).*day.vars.(['direct_normal_narrowband_filter',num2str(ii)]).data(pos);
      day.vars.(['atmos_trans_filter',num2str(ii)]) = day.vars.(['direct_normal_narrowband_filter',num2str(ii)]);
      day.vars.(['atmos_trans_filter',num2str(ii)]).data(pos) = day.vars.(['direct_normal_narrowband_filter',num2str(ii)]).data(pos)/ Io_new.(['filter',num2str(ii)]);
      day.vars.(['atmos_trans_filter',num2str(ii)]).atts.long_name.data = ['atmospheric transmittance filter ',num2str(ii)];
      day.vars.(['atmos_trans_filter',num2str(ii)]).atts.units.data = 'unitless';
   end
   day.fname = [day.fname,'.nc'];
   day.clobber = true;
   day.quiet = true;
   day = anccheck(day);
   ancsave(day);
