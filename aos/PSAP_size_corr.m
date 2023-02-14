function dono = model_psap_NK_size_factor
% Nakayama, Kondo size-dependent correction
% NK.D aerodynamid diameter nm, NK.E correction factor to divide PSAP Bond for Mie
% from Table 2, col 4 for .7 LPM
NK.D = [100,200,300,400,500,600]; NK.E = [2.23, 1.5, 1.13, 1.0, .95, .89];
% So we want to interpolate NK.E to the cmd values in X_range(ij) and multiply the
% Mie values in mini.Bap(ij) to get a modeled PSAP value including the size-dependent
% enhancement. We need to vary CMD over some range say 250 or 600 nm
% Then we apply chop diameters above some cut point and form the ratio of Mie and
% PSAP mini.Bap(ij_cut)./mini.Bap(ij)
cmd_i = 0;
cut = 250; 
for CMD = 700:-2.5:150
   cmd_i = cmd_i + 1;
   gsd = 1.5;
   dlogd = min(.025, log10(gsd)*.25);     % minimum 12 points across range;
   limit=floor(4*log(gsd)/dlogd)*dlogd;  % integral number to cover 3.5x gsd
   dx = (-limit:dlogd:limit);
   X_range = CMD * 10.^(dx);                % Log-spaced diameters
   
   Df = LogNormal(X_range, CMD, gsd);
%    figure; plot(X_range, Df,'r-o'); logx; logy;
   % nigrosin 532 nm nr = 1.649 + .238i
   nr = 1.649 + .238i;
   nke = exp(interp1(log(NK.D), log(NK.E),log(X_range),'linear','extrap'));
   nke(nke<.75) = .75;  mini.nke = nke;
   mini.Bep = NaN(size(mini.nke)); mini.Bsp = mini.Bep; mini.Bap = mini.Bep;
%    SizeDist_Optics_TB_CF(nr, X_range, Df, 532,'nobackscat',true);
   
   % Find all Df > 0.1% of max(Df)
   % For each corresponding X_range, compute a narrow lognormal df with range xr centered on X_range(ij) and
   % normalized by multipliying by Df(i) and dividing by max(df)
   % Accumulate these normalized xr and df. Compute optical properties and compare to
   % coarse log normal.

   gsd = 1.01; x_range = []; df_ = [];
   ij_ = find(Df>(0.001.*max(Df)));
   jk = find(Df>(0.001.*max(Df))&(X_range<cut));
   for ij = find(Df>(0.001.*max(Df)))
      cmd = X_range(ij);
      dlogd = min(.1, log10(gsd)*.25);     % minimum 12 points across range;
      limit=floor(4*log(gsd)/dlogd)*dlogd;  % integral number to cover 3.5x gsd
      dx = (-limit:dlogd:limit);
      xrange = cmd * 10.^(dx);                % Log-spaced diameters
      df = LogNormal(xrange, cmd, gsd);
      df = df./max(df).*Df(ij);
      out = SizeDist_Optics_TB_CF(nr, xrange, df, 532,'nobackscat',true);
      mini.Bep(ij) = out.extinction; mini.Bsp(ij) = out.scattering; mini.Bap(ij) = out.absorption;
      x_range = [x_range, xrange];
      df_ = [df_, df];
   end
   [x_range, jj] = sort(x_range);
   df_ = df_(jj);
%    SizeDist_Optics_TB_CF(nr, x_range, df_, 532,'nobackscat',true)

   % This ratio showed that the SSA from the many monomodal log-normals spanning the
   % range of the large monomodal are nearly the same.  Suggests the ratios of
%    trapz(X_range(ij_),mini.Bsp(ij_))./trapz(X_range(ij_),mini.Bep(ij_));
   me(cmd_i) =    trapz(X_range(jk)./1000,mini.Bap(jk)) ./ trapz(X_range(ij_)./1000,mini.Bap(ij_));
   psap_cuts(cmd_i) =    trapz(X_range(jk)./1000,mini.Bap(jk).*mini.Bap(jk)) ./ trapz(X_range(ij_)./1000,mini.Bap(ij_).*mini.Bap(ij_));
   
   psap(cmd_i) =    trapz(X_range(ij_)./1000,mini.nke(ij_).*mini.Bap(ij_)) ./ trapz(X_range(ij_)./1000,mini.Bap(ij_));

end
%  figure; plot(me, psap,'o-');
%  yl = ylim;
%  ylim([0,yl(2)]); 
%  title(['PSAP correction for ',num2str(cut),' nm impactor']);
%  xlabel('Mie Bap(cut) / Mie Bap(total)');
%  ylabel('PSAP / Mie')

  figure; plot(1./psap_cuts, 1./psap,'rx');
 yl = ylim;
 ylim([0,yl(2)]); 
 title(['PSAP correction for ',num2str(cut),' nm impactor']);
 xlabel('Psap Bap(total)./Psap Bap(cut) (larger==>>)');
 ylabel('Mie Bap(total)./PSAP Bap(total) ')

return