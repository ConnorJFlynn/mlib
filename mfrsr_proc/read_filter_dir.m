function [ftrace] = read_filter_dir(pname, fmask)
% [trace, std_spectra] = read_filter_traces(pname,fmask)
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


%% Process open channel
% Process open channel differently than rest since some of the spectral
% quantities aren't meaningful for the broadband channel
% In fact, this open channel processing may be bogus since I'm not even
% sure what mat file is being loaded below...
% for i =1:6;
%    trace_fig(i) = figure;
% end

% load open_ch
% i = 1;
% open_filter.nominal = 'broadband';
% open_filter.nm = open_ch(:,1);
% open_filter.T = open_ch(:,2);
% [maxT,peak_ind] = max(open_filter.T);
% open_filter.peak = open_filter.nm(peak_ind);
% lower_range = find(open_filter.nm(:,1)<360);
% upper_range = find(open_filter.nm(:,1)>1220);
% [open_filter.base_P] = polyfit(open_filter.nm([lower_range; upper_range]),open_filter.T([lower_range; upper_range]),1);
% [open_filter.base_line] = polyval(open_filter.base_P,open_filter.nm);
% open_filter.T_raw = open_filter.T;
% open_filter.T = open_filter.T - open_filter.base_line;
% trace{1}.nominal = 'broadband';
% trace{1}.nm = open_filter.nm;
% trace{1}.normed = normalize_filter(open_filter.nm, open_filter.T);
% open_filter = rmfield(open_filter, 'nm');
% open_filter = rmfield(open_filter, 'T');
% open_filter = rmfield(open_filter, 'nominal');
% trace{1}.raw = open_filter;
% figure(trace_fig(1)); plot(trace{1}.nm, trace{1}.normed.T, 'bx', trace{1}.nm, trace{1}.normed.T, 'b');
% title('Open channel')
% clear upper_range lower_range maxT peak_ind open_ch open_filter
%% End of open channel

%%
if ~exist('fmask', 'var')
   fmask = '*.*';
end
if ~exist('pname', 'var')
   pname = [];
   while length(pname)==0
      [fname pname] = uigetfile([pname, '*.*'], 'Pick a filter file.');
   end
end
pname = [pname, filesep];
ftrace = struct([]);
file_list = dir([pname, fmask]);

if length(file_list)>0
   for f =1:length(file_list)
      if ~file_list(f).isdir
         [ftrace] = read_filter_file([pname, '/',file_list(f).name], ftrace);
      end
   end
   [ftrace] = filter_cals(ftrace);
%    filters = [];
%    for i =1:length(ftrace)
%       filters = sort(unique([filters, i*~isempty(ftrace{i})]));
%    end
%    filters
end

% close('all')


