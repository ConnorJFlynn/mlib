function [trace, std_spectra] = filter_cals(trace)
%% Now load spectral data for qth, si_resp, std_lamp, Gueymard ESR, total
%% Rayleigh optical depth, 

load guey
load std_lamp
load qth
load si_resp
load tod_ray
load o3_coef

filters = [];
for i =1:length(trace)
filters = sort(unique([filters, i*~isempty(trace{i})]));
end
if filters(1)==0
   filters(1) = [];
end
%%
for i=filters
    trace{i}.spc.Si_resp = interp1(Si_resp(:,1), Si_resp(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.qth = interp1(qth(:,1), qth(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.std_lamp = interp1(std_lamp(:,1), std_lamp(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.guey_esr = interp1(guey(:,1), guey(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.tod_ray = interp1(tod_ray(:,1), tod_ray(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.o3_coef = interp1(o3_coef(:,1), o3_coef(:,2), trace{i}.nm, 'pchip',0);
%     trace{i}.spc.open_ch = interp1(trace{1}.nm, trace{1}.normed.T, trace{i}.nm, 'pchip',0);
    
    trace{i}.normed.std_lamp_irradiance = trapz(trace{i}.nm, trace{i}.normed.T .* trace{i}.spc.std_lamp);
    trace{i}.normed.esr_irradiance = trapz(trace{i}.nm, trace{i}.normed.T .* trace{i}.spc.guey_esr);
    trace{i}.normed.tod_ray = trapz(trace{i}.nm, trace{i}.normed.T .* trace{i}.spc.tod_ray);
    trace{i}.normed.o3_coef = trapz(trace{i}.nm, trace{i}.normed.T .* trace{i}.spc.o3_coef);
    
    T = trace{i}.normed.T .* trace{i}.spc.guey_esr ./ trace{i}.spc.qth;
%     [trace{i}.T_esr_by_qth, trace{i}.props_esr_by_qth] = normalize_filter(trace{i}.nm, T);
      [trace{i}.esr_by_qth] = normalize_filter(trace{i}.nm, T);
    trace{i}.esr_by_qth.esr_irradiance = trapz(trace{i}.nm, trace{i}.esr_by_qth.T .* trace{i}.spc.guey_esr);

    % Now, correct original T by dividing by open channel.
    % This removes the lamp function and spectrometer function, but also
    % removes the Si responsivity that we need, so we add it back in.
    % Finally, add in the esr spectral distribution.
%     T = (trace{i}.normed.T ./ trace{i}.spc.open_ch) .* trace{i}.spc.Si_resp .* trace{i}.spc.guey_esr ;
%     [trace{i}.T_esr_Si_resp_by_open, trace{i}.props_esr_Si_resp_by_open] = normalize_filter(trace{i}.nm, T);
%     [trace{i}.esr_Si_by_open] = normalize_filter(trace{i}.nm, T);
%     trace{i}.esr_Si_by_open.esr_irradiance = trapz(trace{i}.nm, trace{i}.esr_Si_by_open.T .* trace{i}.spc.guey_esr );

%     T = (trace{i}.normed.T ./ trace{i}.spc.open_ch) .* trace{i}.spc.Si_resp .* trace{i}.spc.std_lamp ;
%     [trace{i}.std_Si_by_open] = normalize_filter(trace{i}.nm, T);
%     trace{i}.std_Si_by_open.std_lamp_irradiance = trapz(trace{i}.nm, trace{i}.std_Si_by_open.T .* trace{i}.spc.std_lamp);

end

std_spectra.ozone = o3_coef;
std_spectra.tod_ray = tod_ray;
std_spectra.qth = qth;
std_spectra.std_lamp = std_lamp;
std_spectra.guey_esr = guey;
std_spectra.Si_resp = Si_resp;


