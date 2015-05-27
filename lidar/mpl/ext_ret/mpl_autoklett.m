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

if ~exist('Sa','var')
    Sa = 40;
end
if ~exist('rec','var')
    rec = 0;
end;
Sm = 8*pi/3;
match = 0.00025;
[alpha_a, beta_a, tau_Sa] = mpl_klett(range, profile, aod, lidar_C, beta_R, Sa);
% range = range'; alpha_a = alpha_a';
tau_Sa = trapz([0,range'],[alpha_a(1), alpha_a']);
% tau_Sa = trapz([range],[alpha_a]);
%If tau_Sa and aod are not close enough, extrapolate a new Sa...
if (abs(tau_Sa-aod)>match)
    % Estimate a starting Sa by extrapolation between Sm and Sa 
    [alpha_a, beta_a, tau_Sm] = mpl_klett(range, profile, aod, lidar_C, beta_R, Sm);
%     alpha_a = alpha_a';
    tau_Sm = trapz([0,range'],[alpha_a(1), alpha_a']);
%     tau_Sm = trapz([range],[alpha_a]);

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
        while ((i<25)&&(abs(tau_Sa-aod)>match))
            i = i+1;
            Sa = Sm + (aod - tau_Sm)*(Sa-Sm)./(tau_Sa - tau_Sm);
%             Sa = Sa*aod/tau_Sa;
            [alpha_a, beta_a, tau_Sa] = mpl_klett(range, profile, aod, lidar_C, beta_R, Sa);
%             alpha_a = alpha_a';
            tau_Sa = trapz([0,range'],[alpha_a(1), alpha_a']);
%             tau_Sa = trapz([range],[alpha_a]);
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
     disp(['What!? A perfect match on record number ', num2str(rec),'?']);
end;
tau_out = tau_Sa;