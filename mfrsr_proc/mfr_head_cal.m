function [trace, std_spectra] = mfr_head_cal(pname)
% mfr_head = mfr_head_cal(pname)
% reads a pre-existing manually saved open_channel
% Then iteratively prompts user to select filter trace files.
%for each filter:
%   find peak(wavelength,T);
%   find wavelength ranges within 20 nm above and below peak.
%   Sort ranges by T, find 1/6 lowest on each side.
%   Polyfit the 1/6 on each side as baseline
%   Subtract this baseline from all points.
%.
%   Renormalize by dividing by trapz(nm,T)
%   Find weighted lambda_center_weight with trapz(nm,T*lambda)/trapz(nm,T)
%   Find peak (in case it shifted with baseline subtraction.
%   Find FWHM (On each side of peak, find min(T>peak/2) and max(T>peak/2),
%   interpolate between to find halfmax_lamda(lower,upper)
%   Compare peak lambda and mean(halfmax_lambda) for indication of skew.
% .
%  Using normalized filter trace, compute OD for Rayleigh and Ozone
%end-for filter
%
% Now we have a filter function normalized to unity area.
% We now try dividing out the with QTH src function and check
% lambda_center_weight again.
%
% Then multiply by the Gueymard ESR or other top of atmosphere irradiance
% spectrum, renormalize by same.

nominal =[0,415, 500, 615, 673, 870, 940];
%% Process open channel 
% Process open channel differently than rest since some of the spectral
% quantities aren't meaningful for the broadband channel
% In fact, this open channel processing may be bogus since I'm not even
% sure what mat file is being loaded below...
for i =1:7;
   trace_fig(i) = figure;
end

load open_ch
i = 1;
open_filter.nominal = 'broadband';
open_filter.nm = open_ch(:,1);
open_filter.T = open_ch(:,2);
[maxT,peak_ind] = max(open_filter.T);
open_filter.peak = open_filter.nm(peak_ind);
lower_range = find(open_filter.nm(:,1)<360);
upper_range = find(open_filter.nm(:,1)>1220);
[open_filter.base_P] = polyfit(open_filter.nm([lower_range; upper_range]),open_filter.T([lower_range; upper_range]),1);
[open_filter.base_line] = polyval(open_filter.base_P,open_filter.nm);
open_filter.T_raw = open_filter.T;
open_filter.T = open_filter.T - open_filter.base_line;
trace{1}.nominal = 'broadband';
trace{1}.nm = open_filter.nm;
trace{1}.normed = normalize_filter(open_filter.nm, open_filter.T);
open_filter = rmfield(open_filter, 'nm');
open_filter = rmfield(open_filter, 'T');
open_filter = rmfield(open_filter, 'nominal');
trace{1}.raw = open_filter;
figure(trace_fig(1)); plot(trace{1}.nm, trace{1}.normed.T, 'bx', trace{1}.nm, trace{1}.normed.T, 'b');
title('Open channel')
clear upper_range lower_range maxT peak_ind open_ch open_filter
%% End of open channel
filters  = [];
%%
if ~exist('pname', 'var')
    pname = [];
end
[fname pname] = uigetfile([pname, '*.txt'], 'Pick a filter file.');

while pname~=0
   % This process expects filter files white space delimited, to have no header row, and to have an
   % uninterupted wavelength field as column 2.  (Column 1 is monochromator
   % step (unused by us).  Col 3 = ch 1 (broadband), Col 4 = ch 2 (415 nm) etc
   % User is to iteratively select one or more filter files until each filter
   % a trace has been obtained for each filter.  Previous filter data will be
   % overwritten by subsequent data in same channel.
   raw_file = load([pname, fname]);
   if size(raw_file,2)==2
      % Then this file only contains a filter trace for only one filter.
      for i =2:length(nominal)
         [max_T, max_ind] = max(raw_file(:,2));
         if any(abs(nominal(i)-raw_file(max_ind,1))<10)
            raw_filter.nominal = nominal(i);
            raw_filter.nm = raw_file(:,1);
            raw_filter.T = raw_file(:,2);
            trace{i} = process_mfr_filter(raw_filter);
            filters = sort(unique([filters, i*~isempty(trace{i})]));
            figure(trace_fig(i)); plot(trace{i}.nm, trace{i}.normed.T, 'bx', trace{i}.nm, trace{i}.normed.T, 'b');
            title(['Nominal wavelength = ',num2str(nominal(i))]);
            pause(1);
         end
      end
   else
      raw_filter.nm = raw_file(:,2);
      for i = 2:7
         if any(abs(raw_filter.nm-nominal(i))<2)
            raw_filter.nominal = nominal(i);
            raw_filter.T = raw_file(:,2+i);
            trace{i} = process_mfr_filter(raw_filter);
            filters = sort(unique([filters, i*~isempty(trace{i})]));
            figure(trace_fig(i)); plot(trace{i}.nm, trace{i}.normed.T, 'bx', trace{i}.nm, trace{i}.normed.T, 'b');
            title(['Nominal wavelength = ',num2str(nominal(i))]);
            pause(1);
         end
      end
   end
      disp(['filters = [',num2str(filters),']']);
      clear raw_file;
      [fname pname] = uigetfile([pname, '*.txt'], 'Pick a filter file.');
end
close('all')
%% Now load spectral data for qth, si_resp, std_lamp, Gueymard ESR, total
%% Rayleigh optical depth, 

load guey
load std_lamp
load qth
load si_resp
load tod_ray
load o3_coef
%%
for i=filters
    trace{i}.spc.Si_resp = interp1(Si_resp(:,1), Si_resp(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.qth = interp1(qth(:,1), qth(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.std_lamp = interp1(std_lamp(:,1), std_lamp(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.guey_esr = interp1(guey(:,1), guey(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.tod_ray = interp1(tod_ray(:,1), tod_ray(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.o3_coef = interp1(o3_coef(:,1), o3_coef(:,2), trace{i}.nm, 'pchip',0);
    trace{i}.spc.open_ch = interp1(trace{1}.nm, trace{1}.normed.T, trace{i}.nm, 'pchip',0);
    
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
    T = (trace{i}.normed.T ./ trace{i}.spc.open_ch) .* trace{i}.spc.Si_resp .* trace{i}.spc.guey_esr ;
%     [trace{i}.T_esr_Si_resp_by_open, trace{i}.props_esr_Si_resp_by_open] = normalize_filter(trace{i}.nm, T);
    [trace{i}.esr_Si_by_open] = normalize_filter(trace{i}.nm, T);
    trace{i}.esr_Si_by_open.esr_irradiance = trapz(trace{i}.nm, trace{i}.esr_Si_by_open.T .* trace{i}.spc.guey_esr );

    T = (trace{i}.normed.T ./ trace{i}.spc.open_ch) .* trace{i}.spc.Si_resp .* trace{i}.spc.std_lamp ;
    [trace{i}.std_Si_by_open] = normalize_filter(trace{i}.nm, T);
    trace{i}.std_Si_by_open.std_lamp_irradiance = trapz(trace{i}.nm, trace{i}.std_Si_by_open.T .* trace{i}.spc.std_lamp);

end
std_spectra.ozone = o3_coef;
std_spectra.tod_ray = tod_ray;
std_spectra.qth = qth;
std_spectra.std_lamp = std_lamp;
std_spectra.guey_esr = guey;




