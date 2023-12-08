function [ssa, zrad] = ret_ssa_sbdart(wl, aod, sza, ddr, sfa, g)
%function [ssa,zrad] = ret_ssa_sbdart(wl, aod, sza, ddr, sfa, g)
% Iteratively calls SBDART to converge on an SSA consistent with AOD and DDR
% aod,sza, ddr are required
% wl, sfa, and g will be assumed as .415 (415 nm), .05, and .7
% (w/m2/um/str)
if ~isavar('aod')||isempty(aod)||~isavar('ddr')||isempty(ddr)||~isavar('sza')||isempty(sza)
  error('AOD, ddr, and sza are all required for ret_ssa_sbdart')
end

if ~isavar('wl')||isempty(wl)
   wl = .415;
end
if wl > 2 % Then it is probably in nm so convert to um
   wl = wl/1000;
end

if ~isavar('sfa')||isempty(sfa)
   sfa = .05;
end
if ~isavar('g')||isempty(g);
   g = .7;
end

 % aod = .15; ddr = 3.121; sza = 51.86; clear qry

qry.wlinf=wl;
qry.wlsup=wl;
qry.wlbaer = wl;
qry.QBAER=aod; 
qry.SZA = sza; % solar zenith angle in degrees

qry.gbaer = g; % asymmetry parameter
qry.isalb = 0; 
qry.albcon = sfa; % surface albedo


qry.iout=1;
qry.NF=3;
qry.idatm=2;
qry.isat=0;

qry.SAZA=180;
qry.NSTR=20;
qry.CORINT='.true.';
qry.IAER=3; % oceanic
qry.IAER=5; %user defined aerosol
% case with MFRSR AOD(415nm) = 0.15; DDR = 3.12; sfa = 0.04; sza = 51.9
qry.RHAER=0.8;

% qry.zout = [0,0];
qry.PHI=[0];
qry.VZEN =[qry.SZA];

ssa_(1) = 0;
qry.wbaer = ssa_(1);  % single scattering albedo
 [out] = qry_sbdart(qry);
dirh = out{end}; dirn = dirh./cosd(qry.SZA); dif = out{end-2} - dirh; 
ddr_(1) = dirn./dif;

ssa_(2) = 1;
qry.wbaer = ssa_(2);  % single scattering albedo
 [out] = qry_sbdart(qry);
dirh = out{end}; dirn = dirh./cosd(qry.SZA); dif = out{end-2} - dirh; 
ddr_(2) = dirn./dif;

P = polyfit(ddr_,ssa_,1); ssa_ddr = polyval(P,ddr);

qry.wbaer = ssa_ddr;  % single scattering albedo
 [out] = qry_sbdart(qry);
dirh = out{end}; dirn = dirh./cosd(qry.SZA); dif = out{end-2} - dirh; 
ddr_ssa = dirn./dif;

% [ddr_, ij] = sort([ddr, ddr_ssa]);

while abs(ddr-ddr_ssa)./ddr_ssa > 0.01

   if ddr_ssa < ddr
      ssa_(1) = ssa_ddr;
      qry.wbaer = ssa_(1);  % single scattering albedo
      [out] = qry_sbdart(qry);
      dirh = out{end}; dirn = dirh./cosd(qry.SZA); dif = out{end-2} - dirh;
      ddr_(1) = dirn./dif;
   else
      ssa_(2) = ssa_ddr;
      qry.wbaer = ssa_(2);  % single scattering albedo
      [out] = qry_sbdart(qry);
      dirh = out{end}; dirn = dirh./cosd(qry.SZA); dif = out{end-2} - dirh;
      ddr_(2) = dirn./dif;
   end
   P = polyfit(ddr_,ssa_,1); ssa_ddr = polyval(P,ddr);

   qry.wbaer = ssa_ddr;  % single scattering albedo
   [out] = qry_sbdart(qry);
   dirh = out{end}; dirn = dirh./cosd(qry.SZA); dif = out{end-2} - dirh;
   ddr_ssa = dirn./dif;
end

ssa = ssa_ddr;

qry.iout=6;
qry.VZEN =0; 
      [out] = qry_sbdart(qry);
      zrad = out.rad;
return


      % WL,         FFV,     TOPDN,      TOPUP,      TOPDIR,     BOTDN,      BOTUP,      BOTDIR
     % dirh = w_(end); dirn = dirh./cosd(qry.SZA); dif = w_(end-2) - dirh; ddr = dirn./dif; % ddr = 3.12
     % dirh = out{end}; dirn = dirh./cosd(qry.SZA); dif = out{end-2} - dirh; ddr = dirn./dif; % tau .145, ssa .0 ddr =  5.5147
     % dirh = out{end}; dirn = dirh./cosd(qry.SZA); dif = out{end-2} - dirh; ddr = dirn./dif; % tau .145, ssa = 1 ddr =  2.5442