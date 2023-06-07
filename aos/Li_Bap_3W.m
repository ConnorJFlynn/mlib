function [Bap,aae,ssa, Gn] = Li_Bap_3W(Tr,Ba, Bep, Bsp, Gn, wl)
% [Bap,aae,ssa, Gn] = Li_Bap_3W(Tr,Ba, Bep, Bsp Gn, wl)
% Requires filter transmittance, raw absorption, ext OR scat
% Accepts supplied ssa, aae, Gn

if ~isfield('wl')||isempty(wl)
  wl = [467, 528, 652];
end
if length(wl)~=3
   error('This implementation is for 3 wl only')
end
if ~isfield('Tr') || ~isfield('Ba')
   error('Absorption is required')
end
Bap = Ba;
if ~isfield('Bep')
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

   % This iteration loop simultaneously executes for all times and only computes
   % those that haven't converged. Slick!

stay = (Bep>0)&(Bap>0)&(ssa>0)&(ssa<=1.1)&&(aae>-1)&(aae<=5)&(Tr<=1)&(Tr>=0.5);
stay = all(stay);
jj = 1;
jj_ = zeros(size(stay)); jj_(stay) = jj;
stays = sum(stay);
while jj<20 && stays>0
   ssa(:,stay) = (Be(:,stay)-Bap(:,stay)) ./ Be(:,stay);
   aae(:,stay) = calc_aae(wl, Bap(:,stay));
   X = ln(Tr); Y = ssa; Z = aae;
   ii = 1; % blue
   Bap(ii,stay) = Ba(ii,stay).*(Gn(ii,1) +Gn(ii,2).*X(ii,stay) +Gn(ii,3).*Y(ii,stay) ...
      +Gn(ii,4).*Z(ii,stay) +Gn(ii,5).*X(ii,stay).*Y(ii,stay) ...
      +Gn(ii,6).*Y(ii,stay).*Z(ii,stay) +Gn(ii,7).*X(ii,stay).*Z(ii,stay) ...
      +Gn(ii,8).*X(ii,stay).*Y(ii,stay).*Z(ii,stay));
   ii = 2; % green
   Bap(ii,stay) = Ba(ii,stay).*(Gn(ii,1) +Gn(ii,2).*X(ii,stay) +Gn(ii,3).*Y(ii,stay) ...
      +Gn(ii,4).*Z(ii,stay) +Gn(ii,5).*X(ii,stay).*Y(ii,stay) ...
      +Gn(ii,6).*Y(ii,stay).*Z(ii,stay) +Gn(ii,7).*X(ii,stay).*Z(ii,stay) ...
      +Gn(ii,8).*X(ii,stay).*Y(ii,stay).*Z(ii,stay));
   ii = 3; % red
   Bap(ii,stay) = Ba(ii,stay).*(Gn(ii,1) +Gn(ii,2).*X(ii,stay) +Gn(ii,3).*Y(ii,stay) ...
      +Gn(ii,4).*Z(ii,stay) +Gn(ii,5).*X(ii,stay).*Y(ii,stay) ...
      +Gn(ii,6).*Y(ii,stay).*Z(ii,stay) +Gn(ii,7).*X(ii,stay).*Z(ii,stay) ...
      +Gn(ii,8).*X(ii,stay).*Y(ii,stay).*Z(ii,stay));
   % If properties are still changing, stay in loop
   stay(stay) = (abs(ssa(stay)- (Be(stay).*ssa(stay))./(Bep(stay).*ssa(stay)+Bap(stay))) >0.001)| (abs(aae(stay)-calc_aae(wl,Bap(stay)))>0.001);
   jj = jj+ 1;
   jj_(stay) = jj;
end
end

function aae = calc_aae(wl, Ba)
   aae = NaN(size(Ba));
   pos = all(Ba>0);
   P = polyfit(log(wl),log(Ba),2);
   dP = polyder(P)
   wl_out = wl; wl_out(1) = mean(wl(1:2)); wl_out(2) = mean([wl(1), wl(3)]); wl_out(3) = mean(wl(2:3));
   aae = -polyval(dP,wl_out);
end


end

end