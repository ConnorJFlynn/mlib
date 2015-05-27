function data = multiscatter(options, wavelength, alt, rho_div, rho_fov, ...
                             range, ext, radius, S, ext_air, ssa, g, ...
                             ssa_air, droplet_fraction, pristine_ice_fraction);
% MULTISCATTER  Perform multiple scattering calculation for radar or lidar
%
%  This function calculates the apparent backscatter coefficient
%  accounting for multiple scattering, calling the "multiscatter" C
%  code.  It can be called in a number of different ways.
%
%  For lidar multiple scattering including both quasi-small-angle (QSA)
%  and wide-angle (WA) scattering: 
%
%    data = multiscatter(options, wavelength, alt, rho_div, rho_fov, ...
%                        range, ext, radius, S, ext_air, ssa, g, ...
%                        ssa_air, droplet_fraction, pristine_ice_fraction)
%
%  where the input variables are:
%    options: string containing space-separated settings for the code -
%      for the default options use the empty string ''
%    wavelength: instrument wavelength in m
%    alt: instrument altitude in m
%    rho_div: half-angle 1/e beam divergence in radians
%    rho_fov: half-angle receiver field-of-view in radians
%    range: vector of ranges at which the input data are located, in
%       m; the first range should be the closest to the instrument
%    ext: vector of extinction coefficients, in m-1
%    radius: vector of equivalent-area radii, in m
%    S: vector of backscatter-to-extinction ratios, in sr
%    ext_air: vector of molecular extinction coefficients, in m-1
%    ssa: vector of particle single-scatter albedos
%    g: vector of scattering asymmetry factors
%    ssa_air: vector of molecular single-scatter albedos
%    droplet_fraction: vector of fractions (between 0 and 1) of the
%       particle backscatter that is due to droplets - only affects QSA
%       returns
%    pristine_ice_fraction: vector of fractions (between 0 and 1) of the
%       particle backscatter that is due to pristine ice - only affects
%       QSA returns
%
%  For radar multiple scattering use the same form but with options
%  containing the string '-no-forward-lobe'
%
%  If the last two terms are omitted then they are assumed zero, i.e. the
%  near-backscatter phase function is assumed isotropic.  If "ssa_air" is
%  also omitted it is assumed to be 1 if wavelength < 1e-6 m and 0 if
%  wavelength > 1e-6. If "ssa" and "g" are omitted then the WA part of
%  the calculation is not performed. If "ext_air" is omitted then it is
%  assumed to be zero.
%
%  The output is written to the structure "data" containing the member
%  "bscat" which is the apparent backscatter coefficient. It also
%  includes "range", "ext" and "radius", which are the same as the input
%  values. 
%
%  Note that this function may need to be edited to indicate where the
%  "multiscatter" executable file is located.

% Location of multiscatter executable
multiscatter_exec = '/home/swrhgnrj/src/multiscatter-1.1.2/multiscatter';

% Check existence of executable
if ~exist(multiscatter_exec, 'file')
  error([multiscatter_exec ' not found']);
end

% If fewer than 9 arguments, show the help
if nargin < 9
  help multiscatter
  return
end

% Useful vectors
z = zeros(size(range));
o = ones(size(range));

% Allow for S and radius to be a single number
if length(S) == 1
  S = S.*o;
end
if length(radius) == 1
  radius = radius.*o;
end
% Open the input file and write the comments and the first line
fid = fopen('MSCATTER.DAT', 'w');
fprintf(fid, '# This file contains an input profile of atmospheric properties for\n');
fprintf(fid, '# the multiscatter code. The comand-line should be of the form:\n');
fprintf(fid, '#   ./multiscatter [options] [input_file] > [output_file]\n');
fprintf(fid, '# or\n');
fprintf(fid, '#   ./multiscatter [options] < [input_file] > [output_file]\n');
if ~isempty(options) 
  fprintf(fid, ['# Suitable options for this input file are:\n#   ' options '\n']);
else
  fprintf(fid, ['# No options are necessary for this particular file.\n']);
end
fprintf(fid, '# The file format consists of any number of comment lines starting\n');
fprintf(fid, '# with "#", followed by a line of 5 data values:\n');
fprintf(fid, '#   1. number of points in profile\n');
fprintf(fid, '#   2. instrument wavelength (m)\n');
fprintf(fid, '#   3. transmitter 1/e half-width (radians)\n');
fprintf(fid, '#   4. receiver half-width (radians)\n');
fprintf(fid, '#      (1/e half-width if the "-gaussian-receiver" option\n');
fprintf(fid, '#       is specified, top-hat half-width otherwise)\n'); 
fprintf(fid, '#   5. instrument altitude (m)\n');
fprintf(fid, '# The subsequent lines contain 4 or more elements:\n');
fprintf(fid, '#   1. range above ground, starting with nearest point to instrument (m)\n');
fprintf(fid, '#   2. extinction coefficient of cloud/aerosol only (m-1)\n');
fprintf(fid, '#   3. equivalent-area particle radius of cloud/aerosol (m)\n');
fprintf(fid, '#   4. extinction-to-backscatter ratio of cloud/aerosol (sterad)\n');
fprintf(fid, '#   5. extinction coefficient of air (m-1) (default 0)\n');
fprintf(fid, '#   6. single scattering albedo of cloud/aerosol\n');
fprintf(fid, '#   7. scattering asymmetry factor of cloud/aerosol\n');
fprintf(fid, '#   8. single scattering albedo of air (isotropic scattering)\n');
fprintf(fid, '#   9. fraction of cloud/aerosol backscatter due to droplets\n');
fprintf(fid, '#  10. fraction of cloud/aerosol backscatter due to pristine ice\n');
fprintf(fid, '# Note that elements 6-8 correspond to the wide-angle\n');
fprintf(fid, '# multiple-scattering calculation and if this is omitted then only\n');
fprintf(fid, '# the quasi-small-angle multiple-scattering calculation is performed.\n');
fprintf(fid, '# For more help on how to run the code, type:\n');
fprintf(fid, '#   ./multiscatter -help\n');

fprintf(fid, '%d %g %g %g %g\n', ...
        [length(range) wavelength rho_div rho_fov alt]);

% Set variables that may be missing
if nargin < 15
  pristine_ice_fraction = z;
  if nargin < 14
    droplet_fraction = z;
    if nargin < 13
      if wavelength > 1e-6
        ssa_air = z;
      else
        ssa_air = o;
      end
    end
  end
end

if nargin >= 12
  % Allow g, ssa, ssa_air and *_fraction to be single values
  if length(g) == 1
    g = g.*o;
  end
  if length(ssa) == 1
    ssa = ssa.*o;
  end
  if length(ssa_air) == 1
    ssa_air = ssa_air.*o;
  end
  if length(droplet_fraction) == 1
    droplet_fraction = droplet_fraction.*o;
  end
  if length(pristine_ice_fraction) == 1
    pristine_ice_fraction = pristine_ice_fraction.*o;
  end
  % Wide-angle calculation
  fprintf(fid, '%g %g %g %g %g %g %g %g %g %g\n', ...
          [range(:) ext(:) radius(:) S(:) ext_air(:) ssa(:) g(:) ...
           ssa_air(:) droplet_fraction(:) pristine_ice_fraction(:)]');
elseif nargin >= 10
  % Small-angle calculation only, with specified molecular extinction
  fprintf(fid, '%g %g %g %g %g\n', ...
          [range(:) ext(:) radius(:) S(:) ext_air(:)]');
else
  % Small-angle calculation only, with no molecular extinction
  fprintf(fid, '%g %g %g %g\n', ...
          [range(:) ext(:) radius(:) S(:)]');
end

fclose(fid);

% Run executable and read output
command_line = [multiscatter_exec ' ' options ' < MSCATTER.DAT 2> STDERR.TXT'];
disp(['! ' command_line]);

[status, output] = unix(command_line);
if status
  output
  unix('cat STDERR.TXT');
  error('An error occurred in running the executable');
end

try
  output = str2num(output);
catch
  output
  unix('cat STDERR.TXT');
  error('Problem interpretting output as a table of numbers');
end

% Create a structure containing the output variables
data.range = output(:,2);
data.ext = output(:,3);
data.radius = output(:,4);
data.bscat = output(:,5);

if size(output, 2) > 5
  data.bscat_single = output(:,6);
  data.bscat_double = output(:,7);
  data.bscat_triple_plus = output(:,8);
  data.bscat_air_single = output(:,9);
  data.bscat_air_double = output(:,10);
  data.bscat_air_triple_plus = output(:,11);
  
  data.Es = output(:,12);
  data.Em = output(:,13);
  data.width_Es = output(:,14);
  data.width_Em = output(:,15);
  data.theta_Es = output(:,16);
  data.theta_Em = output(:,17);
  data.corr_Es = output(:,18);
  data.corr_Em = output(:,19);
end
