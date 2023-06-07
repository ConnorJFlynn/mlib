function [Bap,aae,ssa, Gn] = Li_Bap(Tr,Ba, Bep, Bsp, Gn, wl)
% [Bap,aae,ssa, Gn] = Li_Bap(Tr,Ba, Bep, Bsp Gn, wl)
% Requires filter transmittance, raw absorption, ext OR scat
% Accepts supplied ssa, aae, Gn
% This version is supposed to be general to any # of WLs

if ~isavar('wl')||isempty(wl)
  wl = [467; 528; 652];
end
if ~isavar('Tr') || ~isavar('Ba')
   error('Absorption is required')
end
if ~isavar('Bep')
   error('Extinction is required to be provided or as an empty field')
end
if isavar('Bep')&&isempty(Bep)&&isavar('Bsp')&&~isempty(Bsp)
   Bep = Ba + Bsp;
end
% if ~isavar('aae')||isempty(aae)
%    aae = calc_aae(wl, Bap); % Populate aae from Ba if not supplied
%    % provide  aae(BG, BR, GR)
% end
% if ~isavar('ssa')||isempty(ssa)
%    ssa = (Bep - Bap)./Bep;
% end
if ~isavar('Gn')||isempty(Gn)
   Gn = [0.35 0.49 -0.34 -0.15 -0.69 0.23 -0.55 0.79; ...
         0.30 0.48 -0.26 -0.10 -0.67 0.17 -0.63 0.77; ...
         0.24 0.35 -0.16 -0.04 -0.47 0.07 -0.57 0.73];
end

if size(Gn,1) ==1
   Gn = ones([length(wl),1])*Gn;
end

% This iteration loop simultaneously executes for all times and only computes
% those that haven't converged. Slick!
ssa = (Bep-Ba) ./ Bep;
aae = calc_aae(wl, Ba);
stay = (Bep>0)&(Ba>0)&(ssa>0)&(ssa<=1.1)&(aae>-1)&(aae<=5)&(Tr<=1)&(Tr>=0.5);
stay = all(stay);
Bap = Ba; Bap(:,~stay) = NaN;
jj = 1;
jj_ = zeros(size(stay)); jj_(stay) = jj;
stays = sum(stay);
while jj<25 && stays>0
   X = log(Tr); Y = ssa; Z = aae;
   for ii = length(wl):-1:1
      Bap_ = Ba(ii,stay).*(Gn(ii,1) +Gn(ii,2).*X(ii,stay) +Gn(ii,3).*Y(ii,stay) ...
         +Gn(ii,4).*Z(ii,stay) +Gn(ii,5).*X(ii,stay).*Y(ii,stay) ...
         +Gn(ii,6).*Y(ii,stay).*Z(ii,stay) +Gn(ii,7).*X(ii,stay).*Z(ii,stay) ...
         +Gn(ii,8).*X(ii,stay).*Y(ii,stay).*Z(ii,stay));
      Bap(ii,stay) = Bap_;
      V = [ones([1,sum(stay)]);X(ii,stay); Y(ii,stay);Z(ii,stay); X(ii,stay).*Y(ii,stay);Y(ii,stay).*Z(ii,stay);X(ii,stay).*Z(ii,stay); X(ii,stay).*Y(ii,stay).*Z(ii,stay)];
     Gg(ii,:) = (Bap(ii,stay)./Ba(ii,stay))/V;
   end
   % If properties are still changing, stay in loop
   stay(stay) = any(abs(ssa(:,stay)- (Bep(:,stay).*ssa(:,stay))./(Bep(:,stay).*ssa(:,stay)+Bap(:,stay))) >0.001)|...
      all(abs(aae(:,stay)-calc_aae(wl,Bap(:,stay)))>0.001);
   stay(stay) = ~any(isnan(Bap(:,stay)));
   ssa(:,stay) = (Bep(:,stay)-Bap(:,stay)) ./ Bep(:,stay);
   aae(:,stay) = calc_aae(wl, Bap(:,stay));
    figure_(1); plot(1:length(stay), Y, 'k',find(stay), Y(:,stay),'.',find(stay), ssa(:,stay),'.');
    figure_(2); plot(1:length(stay), Z, 'k',find(stay), Z(:,stay),'.',find(stay), aae(:,stay),'.');
   stays = sum(stay);
   jj = jj+ 1;
   jj_(stay) = jj;
end
end

function aae = calc_aae(wl, Ba)
   aae = NaN(size(Ba));
   pos = find(all(Ba>0));
   for p = pos
      P = polyfit(log(wl),log(Ba(:,p)),2);
      dP = polyder(P);
      aae(:,p) = -polyval(dP,log(wl));
   end
end

