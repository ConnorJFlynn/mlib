function [status,out] = write_mpl_ret(mpl, filename);
%status = write_mpl_ret(mpl, mpl_id, fullfilename);

[pname, fname, ext] = fileparts(filename);

mpl_extret_template = [pname, filesep,'nc_template.mat'];

if exist(filename,'file')
   out = ancload(filename);
elseif exist(mpl_extret_template,'file')
   disp('Opening the MPL netcdf template')
   out = loadinto(mpl_extret_template);
   
   if isfield(out.vars, 'julian_day')
      %     out.vars.dayofyear = out.vars.julian_day;
      %     out.vars.dayofyear.atts.comment.data = 'For example: Jan 1 6:00 AM = 1.25';
      out.vars = rmfield(out.vars, 'julian_day');
      save(mpl_extret_template,'out');
   end
   if isfield(out.vars, 'test')
      %     out.vars.dayofyear = out.vars.julian_day;
      %     out.vars.dayofyear.atts.comment.data = 'For example: Jan 1 6:00 AM = 1.25';
      out.vars = rmfield(out.vars, 'test');
      save(mpl_extret_template,'out');
   end
   if isfield(out.vars,'aot_523nm')
      out.vars.aod_523nm =  out.vars.aot_523nm;
      out.vars = rmfield(out.vars,'aot_523nm');
      save(mpl_extret_template,'out');
   end
end
if ~exist(mpl_extret_template,'file')
   save(mpl_extret_template,'out');
end

if strcmp(filename, out.fname)&&(length(out.time)==length(mpl.time))
   % Then simply add to this existing file
   % The good records will be those with Sa > 0
   good = mpl.klett.Sa>0;
   out.vars.Sa_Klett.data(good) = mpl.klett.Sa(good);
   out.vars.lidar_C.data(good) = mpl.cal.C.*ones(size(mpl.klett.Sa(good)));
   
   

   out.vars.aod_523nm.data(good) =  mpl.klett.aod_523nm(good);
   
   % out.vars.aod_523nm.dims = out.vars.base_time.dims;
   % mpl.klett.aod_523nm
   
   out.vars.beta_a_Klett.data(:,good) =  mpl.klett.beta_a(:,good);
   out.vars.alpha_a_Klett.data(:,good) =  mpl.klett.alpha_a(:,good);
   % out.vars.beta_a_Klett.data =  mpl.klett.beta_a(mpl.r.lte_15,:);
   % out.vars.alpha_a_Klett.data =  mpl.klett.alpha_a(mpl.r.lte_15,:);
   out.vars.atten_bscat.data(:,(good)) =  mpl.prof(mpl.r.lte_15,(good));
   
   out.vars.background_signal.data(good) =  mpl.hk.bg(good);
   out.vars.energy_monitor.data(good) =  mpl.hk.energy_monitor(good);
   
   
else
   
   out.fname = [pname, filesep, fname, ext];
   out.time = mpl.time;
   out.recdim.name = 'time';
   out.recdim.length = length(out.time);
   out.dims.time.length = out.recdim.length;
   out.dims.range.length = length(mpl.range(mpl.r.lte_15));
   out.vars.Sa_Klett.data = mpl.klett.Sa;
   out.vars.lidar_C.data = mpl.cal.C.*ones(size(mpl.klett.Sa));
   missings = mpl.klett.Sa<0;
   out.vars.lidar_C.data(missings) = -9999;
   if isfield(out.vars,'aot_523nm')
      out.vars.aod_523nm =  out.vars.aot_523nm;
      out.vars = rmfield(out.vars,'aot_523nm');
   end
   out.vars.aod_523nm.data =  mpl.klett.aod_523nm;
   out.vars.aod_523nm.data(missings) = -9999;
   % out.vars.aod_523nm.dims = out.vars.base_time.dims;
   % mpl.klett.aod_523nm
   
   out.vars.beta_a_Klett.data =  mpl.klett.beta_a;
   out.vars.alpha_a_Klett.data =  mpl.klett.alpha_a;
   % out.vars.beta_a_Klett.data =  mpl.klett.beta_a(mpl.r.lte_15,:);
   % out.vars.alpha_a_Klett.data =  mpl.klett.alpha_a(mpl.r.lte_15,:);
   out.vars.atten_bscat.data =  mpl.prof(mpl.r.lte_15,:);
   
   out.vars.background_signal.data =  mpl.hk.bg;
   out.vars.energy_monitor.data =  mpl.hk.energy_monitor;
   out.vars.range.data =  mpl.range(mpl.r.lte_15);
   out.vars.beta_m.data =  mpl.sonde.beta_R(mpl.r.lte_15);
   out.vars.alpha_m.data =  mpl.sonde.alpha_R(mpl.r.lte_15);
end
% out.vars.dayofyear.data = serial2doy(out.time);


%check dims, etc.

out = timesync(out);
out = anccheck(out);
out = anccheck(out);

status = ancsave(out);
if status<0
   K = menu('There was a problem writing the file.  Set "clobber" to true?', 'Clobber', 'Rename','Abort');
   if K==1
      out.clobber = true;
      status = ancsave(out);
   elseif K==2
      [pname, fname, ext] = fileparts(out.fname);
      [outfname, outpname] = uiputfile([pname, filesep,'*.nc'],'Save as...');
      out.fname = [outpname,filesep,outfname];
      status = ancsave(out);
   else
      status = -1;
   end
end

