function [dark_out] = sws_dark_rate(sws)

% General idea for darks is to examine a group of them to 1) exclude
% outliers and 2) determine a best "average" value of the remaining darks
% Looks like 10 minute intervals computed on some finer step (5 min?) is good.
% Could adapt this to yield different darks for different integration times
% Could also convert all to rate without loss of generality, irrespective
% of seperate processing of darks for different integrations.


if ~isfield(sws,'lambda') && isfield(sws.vdata,'wavelength')
   sws = sws_raw_sub(sws);
end
rate = sws.spec ./ (sws.t_int_ms * ones(size(sws.lambda)));
tstep = (5 * 60)./(24*60*60);% 1 minute step
hwin = (5 * 50)./(24*60*60); % 5 minute half-width window
times_out = length([(sws.time(1)+hwin):tstep:(sws.time(end)-hwin)]);
%Around here put in logic to handle darks with different integration times
dark_out.time = zeros([times_out,1]);
dark_out.dark_rate = zeros([times_out,length(sws.lambda)]);
to = 0;
for t = (sws.time(1)+hwin):tstep:(sws.time(end)-hwin)
   to = to +1;
   win = (sws.time>= (t-hwin)) & (sws.time <= (t+hwin))&sws.Shutter_open_TF==0;
   ts = sws.time(win);
   mins = min(rate(win,:),[],2);
   maxs = max(rate(win,:),[],2);
   good = rpoly_mad(ts,mins,1,3);
   good2 = rpoly_mad(ts,maxs,1,3);
   good = good & good2;
%    if sum(good)<length(good)
%       disp('Screening out erratic darks')
%    end
   spc = rate(win,:);
   eq = {'1';'X'};
   [K] = fit_it(serial2doy(ts(good)),spc(good,:),eq);
   dark_out.time(to) = mean(ts(good));
   dark_out.dark_rate(to,:) = eval_eq(serial2doy(mean(ts(good))),K,eq);
end
bad = isnan(dark_out.time); dark_out.time(bad) = []; dark_out.dark_rate(bad,:) = [];
return