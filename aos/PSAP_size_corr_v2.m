function dono = model_psap_NK_size_factor
% Nakayama, Kondo size-dependent correction
% NK.D aerodynamid diameter nm, NK.E correction factor to divide PSAP Bond for Mie
% from Table 2, col 4 for .7 LPM
wl = 532; 
%      x - size parameter =2pi*radius/lambda
nr = 1.649 + .238i;
diam = [1:5000];
for d = length(diam):-1:1
   x = pi.*diam(d)./wl;
   [~,~,qext(d),qsca(d)]=bhmie(x,nr,360);
end
qabs = qext-qsca; 
NK.D = [100,200,300,400,500,600]; NK.E = [2.23, 1.5, 1.13, 1.0, .95, .89];
nke = exp(interp1(log(NK.D), log(NK.E),log(diam),'linear','extrap'));
nke(nke<.75) = .75;  

% So we want to interpolate NK.E to the cmd values in X_range(ij) and multiply the
% Mie values in mini.Bap(ij) to get a modeled PSAP value including the size-dependent
% enhancement. We need to vary CMD over some range say 250 or 600 nm
% Then we apply chop diameters above some cut point and form the ratio of Mie and
% PSAP mini.Bap(ij_cut)./mini.Bap(ij)
cut = 200; 
cmd_i = 0;
clear mie_total mie_cut psap_total psap_cut
for CMD = 200:-1:75
   cmd_i = cmd_i + 1;
   gsd = 1.75;
   dlogd = min(.025, log10(gsd)*.25);     % minimum 12 points across range;
   limit=floor(4*log(gsd)/dlogd)*dlogd;  % integral number to cover 3.5x gsd
   dx = (-limit:dlogd:limit);
   X_range = CMD * 10.^(dx);                % Log-spaced diameters
   
   Df = LogNormal(X_range, CMD, gsd);
%    figure; plot(X_range, Df,'r-o'); logx; logy;
   df = interp1(X_range, Df, diam,'linear');
   df(isnan(df)) = 0;
   ij = find(df>(0.001.*max(df)));
   jk = find(df>(0.001.*max(df))&(diam<cut));
 % hack, not physically derived.  I think I need to multiply qabs by the geometric
 % xsec.  I don't think the log(diam) is physical
   mie_total(cmd_i) = trapz((diam(ij)), (qabs(ij).*df(ij).^2) );
   mie_cut(cmd_i) = trapz((diam(jk)), (qabs(jk).*df(jk).^2) ); 
   psap_total(cmd_i) = trapz((diam(ij)), (nke(ij).*qabs(ij).*df(ij).^2) );
   psap_cut(cmd_i) = trapz((diam(jk)), (nke(jk).*qabs(jk).*df(jk).^2) ); 
end
   figure; plot(psap_cut./psap_total, mie_total./psap_total,'-')
 title(['Pallfex E70 correction']);
 xlabel('Psap Bap(cut)./Psap Bap(total) (larger==>>)');
 ylabel('Mie Bap(total)./PSAP Bap(total) ')
 legend([num2str(cut),' nm cut'])
%  figure; plot(me, psap,'o-');


return