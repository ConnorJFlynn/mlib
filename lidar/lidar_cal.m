function [lidar_C, od, X_cal] = lidar_cal(lidar_C, od, X_cal, z, beta_R, wavelength);
% [lidar_C, tod] = lidar_cal(lidar_C, od, X_cal, z, beta_R);
% This function accepts two of three lidar calibration elements:lidar_C, od, or X_cal.
% It returns the third (unsupplied) element.
% In addition it requires the calibration height z, 
% beta_R at the cal height is optional.  If not provided, std atm is
% assumed.
disp('buggy, not proper optical depths...')
if nargin<4
    disp('Syntax: [lidar_C, tod, X_cal] = lidar_cal(lidar_C, tod, X_cal, z, beta_R);')
    eval('help lidar_cal');
    return
end
if nargin<6
    wavelength = 523e-9;
end
if nargin <5
    %Then we assume a std atm for beta_R up to z
    range_km = [(z/100):(z/100):z];  % 100 steps up to max z
    [T,P] = std_atm(range_km);
    [alpha, beta] = ray_a_b(T,P,wavelength);
elseif nargin >= 5
    if (length(z)==1 & length(beta_R)==1)
        %Then calc the std atm profile up to z and then scale to match (z,beta_R)
        range_km = [(z/100):(z/100):z];  % 100 steps up to max z
        [T,P] = std_atm(range_km);
        [alpha, beta] = ray_a_b(T,P,wavelength);
        beta = beta * (beta_R/beta(end));
    end
    if length(z)>1 & length(beta_R)==1
        %Then take beta_R to be the value tha max.  Proceed as above
        range_km = z;  % 100 steps up to max z
        [T,P] = std_atm(range_km);
        [alpha, beta] = ray_a_b(T,P,wavelength);
        beta = beta * (beta_R/beta(end));
    end
end
% [beta_prime_R, tau_R_z] = atten_prof(range_km,alpha,beta);
tau_R_z = cumtrapz(range_km, alpha); 
beta_prime_R = beta .* exp(-2*tau);

par = find([lidar_C(1), od(1), X_cal(1)]<=0);
if length(par)==1
    switch par
        case 1
            lidar_C = (X_cal/(beta_prime_R(end)) .* exp(-2*od));
        case 2
%             lidar_C = X_cal/(beta_prime_R * exp(-2*od));
%             beta_prime_R * exp(-2*od) = X_cal/lidar_C;
%             exp(-2*od) = X_cal/(beta_prime_R * lidar_C)
%             -2*od = log(X_cal/(beta_prime_R * lidar_C));
            od = (log(beta_prime_R(end))+log(lidar_C) -log(X_cal))/2;
        case 3
            X_cal = (lidar_C*(beta_prime_R(end)) .* exp(-2*od));
    end
elseif length(par)~=1
    disp('One and only one of the following can be set to zero:');
    disp(['  lidar_C = ', num2str(lidar_C)]);
    disp(['  od = ', num2str(od)]);
    disp(['  X_cal = ', num2str(X_cal)]);
end

