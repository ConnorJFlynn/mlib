function [alpha_a, beta_a, Sa, tau_out] = auto_klett(range, profile, aod, lidar_C, beta_R, Sa, rec)
% [beta_a, Sa] = klett_layer(range, profile, aod, lidar_C, beta_R, Sa, rec)
% returns aerosol beta, and Sa consistent with the supplied lidar C and aod 
% (integrated to range=0 by assuming constant extinction below min(range)
% requires:
% range
% profile: attenuated lidar profile
% aod: measured aerosol optical depth at lidar wavelength
% lidar_C: lidar calibration constants such that 
% beta_R: molecular backscatter coefficient profile
% rec: the record number

if (nargin <6)
    Sa = 40;
    rec = 0;
end;
Sm = 8*pi/3;

[alpha_a, beta_a, tau_Sa] = mpl_klett(range, profile, aod, lidar_C, beta_R, Sa);
tau_Sa = trapz([0,range],[alpha_a(1), alpha_a]);
%If tau_Sa and aod are not close enough, extrapolate a new Sa...
if (abs(tau_Sa-aod)>.001)
    % Estimate a starting Sa by extrapolation between Sm and Sa 
    [alpha_a, beta_a, tau_Sm] = mpl_klett(range, profile, aod, lidar_C, beta_R, Sm);
    tau_Sm = trapz([0,range],[alpha_a(1), alpha_a]);
    Sa = Sm + (aod - tau_Sm)*(Sa-Sm)./(tau_Sa - tau_Sm);
    if Sa < Sm
        disp(['Warning! for record number ', num2str(rec)])
        disp(['Sa value would have extrapolated below Sm.  Plenty of backscatter with small observed tau.']);
        disp(['Could be inappropriate C value or wrong tau.']);
        alpha_a = NaN(size(profile));
        beta_a = NaN(size(profile));
        Sa = Sm;
        %pause
    elseif Sa > 200
        disp(['Warning! for record number ', num2str(rec)])
        disp(['Sa values would have extrapolated above 200. Too little backscatter to account for observed tau.']);
        disp(['Beam probably attenuated by non-aerosol.']);
        alpha_a = NaN(size(profile));
        beta_a = NaN(size(profile));
        Sa = 200;
        %pause
    else 
        i = 1;
        while ((i<25)&&(abs(tau_Sa-aod)>.001))
            i = i+1;
            Sa = Sa*aod/tau_Sa;
            [alpha_a, beta_a, tau_Sa] = mpl_klett(range, profile, aod, lidar_C, beta_R, Sa);
            tau_Sa = trapz([0,range],[alpha_a(1), alpha_a]);
        end;
        if i>=25
            disp(['Warning! for record number ', num2str(rec)])
            disp(['Failure to converge. Probably something wrong with this profile.'])
            disp(sprintf('Input aod: %1.3f  retrieved aod: %1.3f  Sa: %1.2f', aod, tau_Sa, Sa))
            alpha_a = NaN(size(profile));
            beta_a = NaN(size(profile));
            pause
        end
    end;
else
     disp(['What!? A perfect match on record number ', num2str(rec)],'?');
end;
tau_out = tau_Sa;