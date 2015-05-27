function [range,ext] = retro_retr(z_top, topdn, z_bot, botup);
% [range,ext] = retro_retr(z_top, topdn, z_bot, botup);
% First find matching range
top_overlap = (z_top>=min(z_bot))&(z_top <=max(z_bot));
bot_overlap = (z_bot>=min(z_top))&(z_bot<= max(z_top));
% Next, see which has more elements, which will imply greater resolution
% This will be our range basis to interpolate against.
if sum(top_overlap)>=sum(bot_overlap)
   range = z_top(top_overlap);
   topdn = topdn(top_overlap);
   botup = interp1(z_bot, botup, range, 'linear','extrap');
else
   range = z_bot(bot_overlap);
   botup = botup(bot_overlap);
   topdn = interp1(z_top, topdn, range, 'linear','extrap');
end
NaNs = isNaN(topdn);
topdn(NaNs) = interp1(range(~NaNs), topdn(~NaNs), range(NaNs),'linear','extrap');
NaNs = isNaN(botup);
botup(NaNs) = interp1(range(~NaNs), botup(~NaNs), range(NaNs),'linear','extrap');
ext = retro_retr_(range, topdn, botup);
return

function ext = retro_retr_(range, topdn, botup);
ext = NaN(size(topdn));
pos = topdn>0 & botup > 0;
R = topdn(pos)./botup(pos);
dR = derivate(range(pos), R(pos));
ext(pos) = (1./(4*R)).*dR;
return

function testing = test_parent;
% Generate a synthetic atmospheric column with rayleigh alpha and beta
%%
range = [0:.025:10];
wl = 532e-9;
[T,P] = std_atm(range);
%%
%Then, with the TP profs, call ray_a_b(T,P) for Rayleigh alpha and beta.
[alpha_R, beta_R] = ray_a_b(T,P,wl);

%%
% Then generate synthetic bottom up and top down attenuated profiles.
[botup,dmp,botup_atm_trans] = lidar_atten_profs(range, T, P,wl);
[topdn, dmp, topdn_atm_trans] = topdown_atten(range, T, P, wl);

% Plot them all together.
figure; semilogx(beta_R,range,'-r', botup, range, 'g-',topdn, range, 'b-')
title('backscatter')
xlabel('backscatter (1/km.sr)')
ylabel('range');
legend('Rayleigh','bottom up', 'top down')

figure; semilogx(botup_atm_trans, range, 'g-',topdn_atm_trans,range, 'b-')
title('atmospheric transmittance')
xlabel('transmittance')
ylabel('range')
legend('bottom up','top down')

%then use Retro_retr to retrieve the extinction.
%%
sub_bot = range > 3;
sub_top =  range < 8;
[range_,ext] = retro_retr(range(sub_bot), topdn(sub_bot), range(sub_top), 0.2*botup(sub_top));

figure; semilogx(alpha_R,range, 'r-', ext,range_,'b.');
title('Initial and retrieved extinction')
xlabel('extinction (1/km)');
ylabel('range (km)');
%%

return
