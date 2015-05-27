function [rate, signal, mean_dark_time, mean_dark_spec] = sasze_raw_to_rate(ze)
% Computes count rate for supplied SASZe file or prompts
 


if ~exist('ze','var')
    ze = rd_raw_SAS;
end
if ~isstruct(ze)&&exist(ze,'file')
    ze = rd_raw_SAS(ze);
end

% Computes background-subtracted normalized count rates for raw SASZe files
dark_ = ze.Shutter_open_TF==0;
light_ = ze.Shutter_open_TF==1;
dark_(2:end) = dark_(1:end-1)&dark_(2:end); 
dark_(1:end-1) = dark_(1:end-1)&dark_(2:end);
light_(2:end) = light_(1:end-1)&light_(2:end); 
light_(1:end-1) = light_(1:end-1)&light_(2:end);

%%
% Determine how many contiguous dark measurements
dark_periods = [dark_(1); diff(dark_)>0];
dark_periods_i = find(dark_periods);
% Compute mean darks and times for each of these periods
this_dark = dark_ & ze.time>=ze.time(dark_periods_i(end));
if sum(this_dark)>1
    means.time(length(dark_periods_i)) = mean(ze.time(this_dark));
    means.dark(length(dark_periods_i),:) = mean(ze.spec(this_dark,:));
else
    means.time(length(dark_periods_i)) = (ze.time(this_dark));
    means.dark(length(dark_periods_i),:) =(ze.spec(this_dark,:));
end
for dk = (length(dark_periods_i)-1):-1:1
    this_dark = dark_ & ze.time>=ze.time(dark_periods_i(dk))& ze.time<ze.time(dark_periods_i(dk+1));
    if sum(this_dark)>1
        means.time(dk) = mean(ze.time(this_dark));
        means.dark(dk,:) = mean(ze.spec(this_dark,:));
    else
        means.time(dk) = (ze.time(this_dark));
        means.dark(dk,:) =(ze.spec(this_dark,:));
    end
end
%%
if length(dark_periods_i)>1
    all_darks = interp1(means.time, means.dark, ze.time,'pchip','extrap') ;
else
    all_darks = ones(size(ze.time))*means.dark;
end
signal = ze.spec - all_darks;
rate = signal ./ (ze.t_int_ms*ones(size(ze.lambda)));
mean_dark_time = means.time;
mean_dark_spec = means.dark;

%%
% close(314)

return