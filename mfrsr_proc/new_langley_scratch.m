% get mfrsr data, must be "b1" level or equivalent (need cordirnor)
% compute cloudy flag (must be nominally calibrated data)
% get swflux/swanal clearsky flag
% for AM (azimuth> 0 & azimuth < 180)  
% for range of airmass = [am_min 2 3, am_max 5 6]
% compute langley1 using only goodness of fit as criteria
% compute langley1 of cloud-screen data
% compute langley1 of clearsky flag data
% compute langley1 of full screened data
% Langley1 = standard Langley
% Langley2 = non-weighted Langley (1/M vs log(V/M))
% Langley3 = ratio Langley for all channels ~= ch

% Output: 
   %mfrsr file with cloud-screened and clearsky flags
   %Langplot file with time, aimass, radiances, r_au, 
   %Lang_Io file with Io, tau, and goodness measures for
   
   %%
   mfr_pname = 'D:\case_studies\new_xmfrx_proc\alive\sgpmfrsrC1\b1\solarday\';
   mfr_fname = 'sgpmfrsrC1.a0.20050401.060000.nc';
   swanal.pname = 'D:\case_studies\new_xmfrx_proc\alive\sgp1swfanal\';
   swanal.fmask = 'sgp1swfanalbrs1longC1.c1.';
   mfr = ancload([mfr_pname, mfr_fname])
sw_file = dir([swanal.pname, swanal.fmask,datestr(mfr.time(1),'YYYYmmDD'), '*.cdf']);
   if length(sw_file)>0
      swanal = ancload([swanal.pname, sw_file(1).name]);
      [mfr.vars.clear_sky] = swanal.vars.flag_clearsky_detection;
      mfr.vars.clear_sky.data = flagor(swanal.time, swanal.vars.flag_clearsky_detection.data, mfr.time);
      clr = mfr.vars.clear_sky.data > .5;
   else
      disp(['   No swfwanal file found for ', datestr(mfr.time(1),'YYYY-mm-DD')]);
      disp(['   Proceeding as though clear.']);
      clr = true;
   end
%%
   AM = (mfr.vars.airmass.data >2 & mfr.vars.airmass.data < 6 & ...
      mfr.vars.az_angle.data < 180);
%    AM = (mfr.vars.airmass.data >0 & mfr.vars.az_angle.data < 180);
   PM = find(mfr.vars.airmass.data >2 & mfr.vars.airmass.data < 6 & ...
      mfr.vars.az_angle.data > 180);

%%

   
   %%
      Langley_all_pts{1,2,3}
      Langley_noncloud{1,2,3}
      Langley_clearsky{1,2,3}
      Langley_both{1,2,3}

      Langley_all_pts{1,2,3}
      Langley_noncloud{1,2,3}
      Langley_clearsky{1,2,3}
      Langley_both{1,2,3}