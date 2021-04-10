function retval = SizeDist_Optics(mp, sizepar1, sizepar2, lambda, varargin)
% SizeDist_Optics(mp, sizepar1, sizepar2, lambda, optional-arguments)
%
% Arguments: 
%   mp             particle refractive index 
%   sizepar1,sizepar2   count mean dia in nm, geometric std dev if scalar
%      or               d, dNdlogD(cm-3) if vector 
%   lambda         wavelength (nm)
%
% Optional arguments: 
%     'm_medium'   refractive index of surrounding medium (default 1)
%     'm_coating'  refractive index of coating (default mp)
%     'density'    particle density in g/cm3 (default 1)
%     'nobackscat' if true, don't calculate back scattering (quicker; default false)
%     'nephscats'  produce truncated scattering for TSI 3563 (default false)
%     'nephsens'   file name for neph angular sensitivity (default
%                   AndersonOgren1998.csv)
%     'cut'        actual cut size (removes large particles; default none)
%     'coating'    fractional increase in diameter due to coating (default
%                   zero; can be scalar or vector)
%     'effcore'    calculates cross-section as m2/(g of core) (default true)
%     'normalized' normalized to m2/g particles (default true).
%                   Non-normalized only works with (d, dNdlogD).
%     'resolution' bins per decade (no effect if distribution is given; default 10)
%     'vectorout'  output a vector instead of a structure (default false)
%
% Example:
%  SizeDist_Optics(1.55+0.001i, 150, 1.5, 550, 'density',1, 'nephscats',true)
%     provides ext-scat-abs-truncscat for a size distribution with
%     cmd=150nm, gsd=1.5, refridx 1.55+0.001i, wavelength 550nm
%
%  Output: If normalized, optical cross-sections per mass (m2/g); otherwise
%   Bep, Bsp, Bap (Mm-1). Also ssa (dimensionless), forcing efficiency (W/g)
%   as described in Bond&Bergstrom 2006.
%
%  Warning: This code was developed for optics of submicrometer atmospheric particles.
%  The units may appear messed up but they are in common practice.
%
%               - Tami Bond, based on Christian Maetzler's Mie-Matlab

% Original, as received in zipped file

global df dlogd x_range y_range

% Author: Tami Bond, University of Illinois, yark@uiuc.edu
% Version 2.3   29 Oct 2006
% This program is distributed under the Creative Commons by-sa license 3.0
%   (http://creativecommons.org/licenses/by-sa/3.0/).
%
% Required additional files:
%   Christian Maetzler's Mie package
%   LogNormal.m, ForcEff.m, scat_weights.m, angwt_scat.m
%   varg_val, varg_proof (utilities)
%
% nephsens file must have columns angle, scat_angsens, ref_sine,
% backscat_angsens, ref_backscatsine
%
% Modifications: 
% Oct06/tcb - Change argument structure; Add neph scattering
% Nov06/tcb - Made more general; added coating
% Jul13/tcb - Changed angular scat procedure

if nargin<1
    help SizeDist_Optics;
    return
end

% check size parameters
if size(sizepar1) ~= size(sizepar2)
    disp('Size parameter arrays must have the same dimensions');
    return
end

% check arguments
if ~varg_proof(varargin, {'m_medium', 'density', 'nobackscat', 'nephscats',...
        'cut', 'resolution', 'coating', 'm_coating', 'effcore',...
        'vectorout','nephsensfile', 'normalized'}, true)
    return
end

% Set values from user input, or use defaults 
mr = varg_val(varargin, 'm_medium', 1);
mc = varg_val(varargin, 'm_coating', mp);
fcoat = varg_val(varargin, 'coating', 0);
dens = varg_val(varargin, 'density', 1);
nobackscat = varg_val(varargin, 'nobackscat', 0);
nephscats = varg_val(varargin, 'nephscats', 0);
nephsensfile = varg_val(varargin, 'nephsensfile', 'AndersonOgren1998.csv');
cut = varg_val(varargin, 'cut', 1.e9);
resol = varg_val(varargin, 'resolution', 10);
norm2core = varg_val(varargin, 'effcore', true);
norm2volume= varg_val(varargin, 'normalized', true);
res = 1/resol;        
vecout = varg_val(varargin, 'vectorout', false);

% Check size of coating fraction
if length(fcoat)>1 & size(sizepar1) ~= size(fcoat)
    disp('Coating array must have the same dimensions');
    return
end

% Read neph angular sensitivities if required
if nephscats
   nephdat = ReadNephSens(nephsensfile);
   [theta, dtheta, scatwts] = scat_weights(...
       [nephdat.angle nephdat.scat_angsens], ...
            [nephdat.angle nephdat.bs_angsens]);
   scatidx = 2:4;

% just calculate plain old weights
else
   [theta, dtheta, scatwts] = scat_weights(); 
   scatidx = 2;
end
    
% Scalar inputs: produce equally lognormally-spaced diameters. 
% sizepar1 is cmd; sizepar2 is gsd. 
x_range = [];
df = [];
if length(sizepar1)==1

   % minimum 12 pts across range; otherwise according to resolution
   dlogd = min(res, log10(sizepar2)*.25);     % minimum 12 points across range;                                                  
   limit=floor(4*log(sizepar2)/dlogd)*dlogd;  % integral number to cover 3.5x gsd
   dx = (-limit:dlogd:limit);               
   x_range = sizepar1 * 10.^(dx);                % Log-spaced diameters
   df = LogNormal(x_range, sizepar1, sizepar2);  % frequencies for each diameter
else

   % make sure they are row vectors
   if size(sizepar1, 1)>size(sizepar1, 2)
       x_range = sizepar1';
       df = sizepar2';
   else
       x_range = sizepar1;
       df = sizepar2;
   end

   % calculate dlogd
   Nx = length(x_range);
   dlogd = [log10(x_range(2)/x_range(1))  ...
       log10(x_range(3:Nx) ./ x_range(1:(Nx-2)))/2 ...
       log10(x_range(Nx) / x_range(Nx-1))];
   
end

% remove diameters above cut size
idx = find((x_range<=cut)&(x_range>0)&isfinite(dlogd));
x_range = x_range(idx);
df = df(idx);
if length(dlogd)>1
    dlogd = dlogd(idx);
end

% Check coating fraction
if length(fcoat)==1
    fcoat = ones(size(x_range)) * fcoat;
end
iscoated = (max(fcoat)~=0);

% coating diameters
y_range = x_range .* (1+fcoat);

% Calculate x-sectional areas and volumes (volume is only total)
if norm2core
   vol_tot = pi/6 * sum(x_range.^3 .* df .* dlogd);     % Total Volume, nm3
else
   vol_tot = pi/6 * sum(y_range.^3 .* df .* dlogd);     % Total Volume, nm3
end    
x_areas = pi/4 * y_range.^2;                         % Areas, nm2
Mie_result = [];
asym = [];

% Loop through the diameters. This would be more efficient if 'if'
% statements were outside, but I don't think it matters much.
for i=1:max(size(x_range))
    xval = pi * mr*x_range(i)/lambda;
    yval = pi * mr*y_range(i)/lambda;
    
    if iscoated
       one_result = Miecoated(mp/mr, mc/mr, xval, yval, 1);
    else
       one_result = Mie(mp/mr, xval);
    end
    one_eff = one_result(1:3);
    
    % No backscattering
    if nobackscat
        
    % All scattering, including truncated neph
    else
        if iscoated
           scatcalc = angwt_scat(mp/mr, xval, theta, dtheta, scatwts, ...
            'm_coating', mc/mr, 'ycoat', yval);
        else
           scatcalc = angwt_scat(mp/mr, xval, theta, dtheta, scatwts);
        end
        one_eff = [one_eff scatcalc(scatidx)];    
    end
    
    % add results to the stack
    Mie_result = [Mie_result; one_eff];
    asym = [asym; one_result(5)];
end

% Calculate average cross-section from efficiencies
Mie_tots = Mie_result' * (x_areas .* df .* dlogd)';

% Normalize to volume
if norm2volume
   Mie_tots = Mie_tots'/vol_tot  * 1.e3/dens;            % nm2/nm3 * 1000 = m2/cm3
else
   Mie_tots = Mie_tots'  * 1.e-6;                    % nm2/cm3 * 1.e-6 = Mm-1
end

% Average asymmetry parameter
scats = Mie_result(:,2)' .* x_areas .* df .* dlogd;
asymav = (asym' * scats') ./sum(scats);

% Put information in structure
outstruc = struct();
outstruc.extinction = Mie_tots(1);
outstruc.scattering = Mie_tots(2);
outstruc.absorption = Mie_tots(3);
if ~nobackscat
    outstruc.backscat = Mie_tots(4);
end
if nephscats
   outstruc.nephscat = Mie_tots(5);
   outstruc.nephbscat = Mie_tots(6);
end

% Single scatter albedo
outstruc.ssa = Mie_tots(2)/Mie_tots(1);
Mie_tots = [Mie_tots outstruc.ssa];

% Asymmetry
outstruc.asym = asymav;
Mie_tots = [Mie_tots asymav];

% Climate forcing efficiency over 'average' surface
if ~nobackscat
    outstruc.forceff = ForcEff(outstruc.backscat, outstruc.absorption);
    Mie_tots = [Mie_tots outstruc.forceff];
end

% Write to screen if needed 
heading = [];
valstr = [];
if vecout & nargout<1
    fnm = fieldnames(outstruc);
    for i=1:length(fnm)
        if i<length(fnm)
            delim = ' : ';
        else
            delim = '';
        end
        
        var = cell2mat(fnm(i));
        heading = [heading var delim];
        valstr = [valstr num2str(outstruc.(var)) delim];
    end
disp(heading)
disp(valstr)
end

% Return appropriate value
if ~vecout
    retval = outstruc;
else
    retval = Mie_tots;
end

return

% Read nephelometer data and return in a structure. File must be
% comma-delimited with 
% columns angle, scat_angsens, ref_sine, bs_angsens, ref_sine2
function ndat = ReadNephSens(filename)
   ntxdat = dlmread(filename);
   ndat.angle = ntxdat(:,1);
   ndat.scat_angsens = ntxdat(:,2);
   ndat.ref_sine = ntxdat(:,3);
   ndat.bs_angsens = ntxdat(:,4);
   ndat.ref_sine2 = ntxdat(:,5);
return

