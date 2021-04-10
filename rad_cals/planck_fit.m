function [rad,lamp] = planck_fit(nm_in,Irad_in, nm_out)
% [rad,lamp] = planck_fit(nm_in,Irad_in, nm_out)
% Provided with lamp measurements, this routine fits a planck curve to the
% peak of the measurement, yielding the radiating temperature and thus the 
% BB radiance and scaling factor pinning the model to the measurement.
% Then, computes T_BB for all supplied wavelengths from the radiance-scaled 
% measurement, interpolate T_BB to the desired grid, and compute BB radiance
% and finally match to measurement scale. 
% Required:
%     nm_in 
%     Irad_in [arbitrary units]
% Optional: nm_out 
% Returns:
%     rad.nm ; supplied nm grid
%     rad.T_bb ; computed Brightess Temperatures at nm
%     rad.BB_rad ; equivalent BB radiances 
%     rad.N_planck_by_lamp ; scaling factor relating BB_rad to lamp.I
%     rad.Irad; scaled irradiances interpolated by T_BB

%% Lamp_F925
% General approach.  Fit the top of a Planck curve in order to better
% define the peak radiating temperature and spectral irradiance at this
% peak.  This will be the basis for scaling the entire measured curve by a 
% single factor to yield unity max irradiance for the theoretical planck curve, 
% not merely for the measured points.  Then for each measured
% wavelength of this unity-maximum curve, identify the equivalent
% brightness temperature.

% Maybe instead of dealing with unity max irradiances, I should be defining
% the scale factor and temperature that yields the best fit to the top
% point and nearest neighbor.  Will this be analytical rather than
% empirical?  

% I presume that the measured wavelength can be taken at face value, as can
% the linearity of the absolute calibration.  
figure_(67);
if ~exist('nm_in','var')||~exist('Irad_in','var')
lamp.nm = [250:10:400 450 500 555 600 654.6 700 800 900 1050 1150 1200 1300 1540 1600 1700 2000 2100 2300 2400 2500];
lamp.I = [1.806e-8, 3.203e-8, 5.299e-8, 8.343e-8, 1.26e-7, 1.832e-7,2.585e-7,3.544e-7,4.732e-7,6.197e-7,7.956e-7,...
    1.001e-6, 1.237e-6, 1.505e-6, 1.818e-6, 2.164e-6, 4.368e-6, 7.236e-6, 1.075e-5,1.353e-5, 1.665e-5, 1.878e-5, 2.178e-5,...
    2.289e-5, 2.173e-5, 2.008e-5, 1.909e-5, 1.713e-5, 1.274e-5, 1.177e-5, 1.031e-5, 6.932e-6, 6.076e-6, 4.721e-6, 4.149e-6, 3.569e-6];
lamp.units = 'W/cm^2/nm';
lamp.details = 'Spectral irradiance of Standard F-925 at 50 cm when operated at 8.000 A DC';
else
    lamp.nm = nm_in;
    lamp.I = Irad_in;
end
if ~exist('nm_out','var');
    nm = [min(lamp.nm):max(lamp.nm)];
else
    nm = nm_out;
end

b = 2.8977685e-3; % 2.8977685(51)×10?3 m·K (2002 CODATA recommended value).
%     lambda_max = b./T; T in Kelvin, lambda in meters!
%     T_max = b./lambda_max; lambda_max in meters!
%%
% First, fit a planck curve to the top portion of the lamp curve.  Use the top of
% this fitted curve to define I_max. 
% To fit this curve we'll scan over a range of temperatures and at each
% temperature determine the K-factor that minimizes residuals

[tmp, max_wi] = max(lamp.I);
W_ = lamp.I>0.75*tmp &lamp.I<1.25.*tmp; % This is the top 25%
W_ = [max_wi-2:max_wi+2];
w_i = (1-(abs(lamp.nm(W_)-lamp.nm(max_wi))./300).^3).^3;
w_i(w_i<0) = 0;
w_i(w_i>=0) = 1;
dT = .5;
% We know that the true maximum must lie between T_min and T_max, 
% Because T_peak is a local maximum of the data.
T_peak = b./(lamp.nm(max_wi).*1e-9);
T_min = b./(lamp.nm(max_wi+1).*1e-9);
T_max = b./(lamp.nm(max_wi-1).*1e-9);

% Now, we'll iteratively compute residuals between the measured curve and
% the model curve when pinning the model curve to match the measured peak.
% this in essense only tests the _shape_ of the curve, and in particular
% the shape of the peak in the vicinity of I_peak and adjacent points.
% We'll use this to find the optimal radiating temperature of the peak.

I_planck = planck_in_wl((lamp.nm.*1e-9),T_peak); 
N = I_planck(max_wi)./lamp.I(max_wi);
I_planck = I_planck./N;
resid = (w_i.*sqrt((I_planck(W_)-lamp.I(W_)).^4));

I_planck_n = planck_in_wl((lamp.nm.*1e-9),T_peak-dT); 
N = I_planck_n(max_wi)./lamp.I(max_wi);
I_planck_n = I_planck_n./N;
resid_n = (w_i.*sqrt((I_planck_n(W_)-lamp.I(W_)).^4));

I_planck_p = planck_in_wl((lamp.nm.*1e-9),T_peak+dT); 
N = I_planck_p(max_wi)./lamp.I(max_wi);
I_planck_p = I_planck_p./N;
resid_p = (w_i.*sqrt((I_planck_p(W_)-lamp.I(W_)).^4));

T = T_peak;
plot(lamp.nm(W_), lamp.I(W_),'bo',lamp.nm, lamp.I,'k-',...
    lamp.nm, I_planck_n,'r-',lamp.nm, I_planck,'g-',lamp.nm, I_planck_p,'b-');
delta_nm = max(lamp.nm(W_))-min(lamp.nm(W_));
if (min(lamp.nm)<(min(lamp.nm(W_))-delta_nm)) && (max(lamp.nm)>(max(lamp.nm(W_))+delta_nm))
    xl = [(min(lamp.nm(W_))-delta_nm),(max(lamp.nm(W_))+delta_nm)];
else
ok = menu('Hit okay', 'ok');
xl = xlim;
end
xlim(xl)
[mean(resid_n), mean(resid), mean(resid_p)];
while mean(resid_p)<mean(resid) && mean(resid)<mean(resid_n) && T<T_max
%         while (resid>resid_n||resid>resid_p)&&T<T_max
            T = T+dT;
            I_planck_n = I_planck; 
            resid_n = resid; 
            I_planck = I_planck_p; 
            resid = resid_p; 
            I_planck_p = planck_in_wl(lamp.nm.*1e-9,T+dT);
            N = I_planck_p(max_wi)./lamp.I(max_wi);
            I_planck_p = I_planck_p./N;
            resid_p = (w_i.*sqrt((I_planck_p(W_)-lamp.I(W_)).^4));
    plot(lamp.nm(W_), lamp.I(W_),'bo',lamp.nm, lamp.I,'k-',...
        lamp.nm, I_planck_n,'r-',lamp.nm, I_planck,'g-',lamp.nm, I_planck_p,'b-');
    xlim(xl);
%  [mean(resid_n), mean(resid), mean(resid_p)]
        end
    while mean(resid_n)<mean(resid) && mean(resid)<mean(resid_p) && T>T_min
%         while (resid>resid_n||resid>resid_p)&&T>T_min
            T = T-dT;
            I_planck_p = I_planck;  
            resid_p = resid; 
            I_planck = I_planck_n; 
            resid = resid_n; 
            I_planck_n = planck_in_wl(lamp.nm.*1e-9,T-dT);
            N = I_planck_n(max_wi)./lamp.I(max_wi);
            I_planck_n = I_planck_n./N;
            resid_n = (w_i.*sqrt((I_planck_n(W_)-lamp.I(W_)).^4));
    plot(lamp.nm(W_), lamp.I(W_),'bo',lamp.nm, lamp.I,'k-',...
        lamp.nm, I_planck_n,'r-',lamp.nm, I_planck,'g-',lamp.nm, I_planck_p,'b-');
    xlim(xl);
%     [mean(resid_n), mean(resid), mean(resid_p)]
        end
    %%
    plot(lamp.nm, lamp.I,'k-',lamp.nm(W_), lamp.I(W_),'bo',lamp.nm, I_planck,'g-');
    xlim(xl);
    xlabel('wavelength [nm]');
    ylabel('irradiance [W/(cm^2*nm)]')
    legend('calibration','points in fit','fitted planck curve')
    title({['Lamp irradiance and Planck curve fitted to peak'];['T=',sprintf('%2.0f K',T),...
        ', Lambda max=',sprintf('%2.0f nm',1e9.*(b./T))]});
    %%

    % So at this point, I have T for an optimized BB curve passing through I_max.
    % Next, compute I_T for that T, and the ratio between I_T_max and
    % I_T_900nm which is the location of the measured maximum.
    % This provides a scale-factor pinning the provided Irradiance to the BB Radiance curve.
    
    lamp.T_peak = T;
    lamp.Lambda_peak = 1e9.*(b./T); 
    [maxI,max_ii] = max(lamp.I); 
    lamp.N = planck_in_wl(lamp.nm(max_ii).*1e-9,T)./lamp.I(max_ii);
    lamp.T_bb = BrightnessTemp_vs_nm(lamp.I.*lamp.N, lamp.nm);
    rad.nm = nm;
    rad.T_bb = interp1(lamp.nm, lamp.T_bb, rad.nm, 'pchip','extrap');
    rad.BB_rad = planck_in_wl(rad.nm.*1e-9, rad.T_bb); 
    rad.N_planck_by_lamp = N;
    rad.Irad = rad.BB_rad./rad.N_planck_by_lamp;
    rad.Lambda_peak = lamp.Lambda_peak;
    rad.T_peak = lamp.T_peak;
    % Now, interpolate lamp_T_bb to the supplied wavelength scale in nm
    % Then compute radiances at those temperatures and wavelengths, scaled
    % by N.
    
    %%
    figure_(67); s(1) = subplot(2,1,1);
        plot(lamp.nm, lamp.T_bb,'k-');
    xlim(xl);
    ylabel('T_B [K]')
%     legend('calibration','points in fit','fitted planck curve')
    title(['Brightness temperature of irradiance calibration curve']);
s(2) = subplot(2,1,2);
title('Corresponding Planck curve at SWS wavelengths')
plot(lamp.nm, lamp.I,'bo',rad.nm, rad.Irad,'k-');
        xlim(xl);
        ylabel('irad');
        xlabel('Wavelength [nm]');
        legend('Calibrations','fitted Planck')
        linkaxes(s,'x');
%             [mean(resid_n), mean(resid), mean(resid_p)]
%%
% save('fun.mat')
% mat = load('fun.mat');
%%

return