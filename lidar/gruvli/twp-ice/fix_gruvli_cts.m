function fix_gruvli_cts
%function fix_gruvli_cts
% takes no arguments, returns no value
% fixes all netcdf files found in specified directory
pname = ['D:\twp-ice\parsl_data\raw_in\lidar\'];

flist = dir([pname, '*.nc']);

for f = 1:length(flist)
   if ~flist(f).isdir
      disp(['Reading: ', flist(f).name]);
      disp(['#',num2str(f), ' of ', num2str(length(flist))]);
      nc = ancload([pname, flist(f).name]);
      std = nc.vars.detector_A_532nm_std.data;
      bin_time = nc.vars.bin_resolution.data/1000;
      tzb = nc.vars.time_zero_bin.data;
      naccs = nc.vars.accumulates.data;
      nc.vars.detector_A_532nm.data = 10 * (std.^2)/(bin_time * naccs);
      for t = length(tzb):-1:1
      nc.vars.detector_A_532nm_bkgnd.data(t) = mean(nc.vars.detector_A_532nm.data(10:tzb(t)-10,t));
      end
      std = nc.vars.detector_B_532nm_std.data;
      nc.vars.detector_B_532nm.data = 10 * (std.^2)/(bin_time * naccs);
      for t = length(tzb):-1:1
      nc.vars.detector_B_532nm_bkgnd.data(t) = mean(nc.vars.detector_B_532nm.data(10:tzb(t)-10,t));
      end
      disp(['Writing: ', flist(f).name]);
      nc.clobber = true;
      nc.vars.detector_A_532nm.datatype = 5;
      nc.vars.detector_A_532nm_bkgnd.datatype = 5;
      nc.vars.detector_B_532nm.datatype = 5;
      nc.vars.detector_B_532nm_bkgnd.datatype = 5;
      nc.quiet = true;
      status = ancsave(nc);
   end
end

function scraps
%%
load ice_ap
pos = (gl.vars.range.data > 0);
tot_cts1 = (gl.vars.detector_A_532nm.data .*  (ones(size(gl.vars.range.data))*gl.vars.samples.data)) ...
   * (gl.vars.accumulates.data * gl.vars.bin_resolution.data/1000); %Convert count rate to total cts per bin
tot_cts1 = tot_cts1/10; %Don't know why the factor of 10 is here...
tot_cts2 = (ones(size(gl.vars.range.data))*gl.vars.samples.data) .* (gl.vars.detector_A_532nm_std.data.^2);

MHz1 = (tot_cts1 ./ (ones(size(gl.vars.range.data))*gl.vars.samples.data))/(gl.vars.accumulates.data * gl.vars.bin_resolution.data/1000);
MHz2 = (tot_cts2 ./ (ones(size(gl.vars.range.data))*gl.vars.samples.data))/(gl.vars.accumulates.data * gl.vars.bin_resolution.data/1000);
MHz1 = MHz1 - (ice_ap*ones(size(gl.time)));
MHz2 = MHz2 - (ice_ap*ones(size(gl.time)));
bg1 = mean(MHz1(10:300,:));
bg2 = mean(MHz2(10:300,:));
sig1 = MHz1 - (ones(size(gl.vars.range.data))*bg1);
sig2 = MHz2 - (ones(size(gl.vars.range.data))*bg2);
r2 = (gl.vars.range.data>0).*(gl.vars.range.data.^2);
sig1_r2 = sig1 .* (r2*ones(size(gl.time)));
sig2_r2 = sig2 .* (r2*ones(size(gl.time)));
%%
