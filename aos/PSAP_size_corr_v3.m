function dono = model_psap_NK_size_factor
% Nakayama, Kondo size-dependent correction
% NK.D aerodynamid diameter nm, NK.E correction factor to divide PSAP Bond for Mie
% from Table 2, col 4 for .7 LPM
% The idea behind this one is to operate a filter-based instrument with a leaky
% filter material with poor efficiency for small particles. Therefore the first (sample) filter 
% will leak some fraction of the fine mode aerosol, a portion of which will then
% be deposited on the reference filter.  Such a measurement will naturally
% under-represent fine mode aerosol, partly due to being lossy overall and also due
% to the deposition of some fraction of the fine mode on the reference filter.
% We may need to go back a step or two to model the PSAP measurement from Tr under
% conditions of a leaky filter. And then impose the size sensitivity from N&K.

% Ultimately, this correction relies on three things:
% 1. Existence of True measurement or Mie computation
% 2. Existence of filter-based measurement of entire size mode
% 3. Existence of truncated measurement exhibiting a different sensitivity to
%    absorber size than the full-mode. 


wl = 532; 
%      x - size parameter =2pi*radius/lambda
nr = 1.649 + .238i;
diam = [1:5000];
for d = length(diam):-1:1
   x = pi.*diam(d)./wl;
   [~,~,qext(d),qsca(d)]=bhmie(x,nr,360);
end
qabs = qext-qsca; 
% NK for Nakayama Kondo
NK.D = [100,200,300,400,500,600]; NK.E = [2.23, 1.5, 1.13, 1.0, .95, .89];
nke = exp(interp1(log(NK.D), log(NK.E),log(diam),'linear','extrap'));
nke(nke<.75) = .75;  

% So we want to interpolate NK.E to the cmd values in X_range(ij) and multiply the
% Mie values in mini.Bap(ij) to get a modeled PSAP value including the size-dependent
% enhancement. We need to vary CMD over some range say 250 or 600 nm

%Thinking this thru with the MERV filter.  Multiply the original distribution by the
%filter eff to determine the number of particles get trapped in the sample filter.
% Subtract this from the original distribution to determine the number that pass thru
% the sample filter.  Then multiply this distribution by eff again to determine the
% number that get captured by the reference filter.

% Compute the effect of this leakage and capture relative to the pure Mie calculation
% by computing the Bap for the first (sample filter) (reduced bin-wise by NK) and subtracting that of the
% second (reference) filter while also apply the Nakayama-Kondo size-dependent
% weighting. We'll ratio the leaky filter measurement over the PSAP filter
% measurement and reference this ratio against the Mie over PSAP. 
% 

cut = 200; 
fef = merv_13; 
fef.D = 1000.*fef.D; % Convert diameters to nm
filt_eff = interp1(fef.D, fef.ef,diam,'pchip');
filt_Tr = 1- filt_eff; 
% filt1_trapped = filt_eff; 
% filt1_passed = filt_Tr;
% filt_2_trapped = filt_Tr.*filt_eff;
cmd_i = 0;

clear mie_total mie_cut psap_total psap_cut

for CMD = 300:-1:90
   cmd_i = cmd_i + 1;
   gsd = 1.75;
   dlogd = min(.025, log10(gsd)*.25);     % minimum 12 points across range;
   limit=floor(4*log(gsd)/dlogd)*dlogd;   % integral number to cover 3.5x gsd
   dx = (-limit:dlogd:limit);
   X_range = CMD * 10.^(dx);                % Log-spaced diameters
   
   Df = LogNormal(X_range, CMD, gsd);
%    figure; plot(X_range, Df,'r-o'); logx; logy;
   df = interp1(X_range, Df, diam,'linear');
%  figure; plot(diam, df.*interp1(fef.D, filt_T,diam ,'linear'), '-bx'); logx; logy
   df(isnan(df)) = 0;
   ij = find(df>(0.001.*max(df)));

   
   mie_total(cmd_i) = trapz((diam(ij)), (qabs(ij).*df(ij).^2) );
   psap_total(cmd_i) = trapz((diam(ij)), (nke(ij).*qabs(ij).*df(ij).^2) );
   psap_filt1(cmd_i) = trapz((diam(ij)), (filt_eff(ij).*qabs(ij).*df(ij).^2) ); 
   psap_filt2(cmd_i) = trapz((diam(ij)), (filt_Tr(ij).*filt_eff(ij).*qabs(ij).*df(ij).^2) ); 
end

   figure_(2); scatter((psap_filt1-psap_filt2)./psap_total, mie_total./psap_total,48,[300:-1:90], 'filled')
 title(['Pallfex E70 correction, MERV15']);
 xlabel('Psap Bap(cut)./Psap Bap(total) (larger==>>)');
 ylabel('Mie Bap(total)./PSAP Bap(total) ')

 % legend([num2str(cut),' nm cut'])
%  figure; plot(me, psap,'o-');
v = axis; 

return