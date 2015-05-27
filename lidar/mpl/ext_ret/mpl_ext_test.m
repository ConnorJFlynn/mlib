function [alpha_a , beta_a , tau_a_new , range_out] = mpl_ext(in, range_bounds,  Sa)
% [alpha_a, beta_a, tau_new, range_out] = mpl_ext(in, range_bounds,  Sa)
% range, profile, tau_a, sonde,  lidar_C,
% returns aerosol alpha, beta, and tau_aerosol
% requires:
%   incoming structure with the following
%   in.range    --> range dimension
%   in.r        --> lidar structure of subranges
%   in.prof     --> attenuated lidar profile (measured)
%   in.sonde    --> beta_R, alpha_R, atten_prof, 
%   in.tau_a    --> based on mfrsrod.aod_523
%   in.lidar_C  --> lidar calibration constant = in.prof(z_top) / (atten_ray(z_top) * exp(-2*tau_a))
% This incoming structure is like the lidar structure except it is for only one profile/time
%
%   range_bounds and Sa are optional.
%   range_bounds default = [range(2), in.sonde.max_alt]
%   default Sa = 30
% returns 
%   alpha_a(subrange)
%   beta_a(subrange)
%   tau_a(subrange)
%   range_out=range(subrange)
% with subrange=find((range>=range_bounds(1))&(range<=range_bounds(2)))


if (nargin == 1)
    bound = [0.075,in.sonde.max_alt];
    Sa = 30;
elseif (nargin == 2)
    Sa = 30;
    if max(size(range_bounds))==1
        range_bounds = [range_bounds,in.sonde.max_alt]
    elseif max(size(range_bounds))>2
        disp('Input bounds should have no more than two elements.  Using defaults instead.');
        range_bounds = [0.075,in.sonde.max_alt];
    else
        if (range_bounds(1) >= range_bounds(2))
            disp('Bounds should have the format [min_range max_range].  Using defaults instead.');
            range_bounds = [0.075,in.sonde.max_alt];
        end;
    end;
end;
Sr = 8 * pi / 3;
in;

subrange = find((in.range >= range_bounds(1))&(in.range <= range_bounds(2)));
tau_R = local_val(range_bounds(2), in.range(subrange), in.sonde.tau(subrange));
tau = tau_R + in.tau_a;

z_top = max(subrange); %The top-most range indice
beta(z_top) = in.prof(z_top)/(in.lidar_C*exp(-2*tau));
Y(z_top) = in.prof(z_top);

for z = z_top-1:-1:subrange(1) 
   Y(z) = in.prof(z)*exp(-2*(Sa-Sr)*trapz(in.range(z_top:-1:z),in.sonde.beta_R(z_top:-1:z)));
   beta(z) = Y(z)/(in.lidar_C*exp(-2*tau) - 2*Sa*trapz(in.range(z_top:-1:z),Y(z_top:-1:z)));
end

beta_a(subrange) = beta(subrange) - in.sonde.beta_R(subrange)';
beta_a = beta_a';
alpha_a = Sa * beta_a;
range_out(subrange) = in.range(subrange);
range_out = range_out';
tau_a_new = trapz(in.range(subrange),alpha_a(subrange));
