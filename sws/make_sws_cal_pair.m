function lights = make_sws_cal_pair(in_file)
% Reads a calibration file with light and dark.  
% Was written to let a single data file with shutter open and closed be
% substituted for the light/dark pair from the SWS calibration routine.
if exist('in_file','var') && ~isstruct(in_file)
if exist('in_file','var') && exist(in_file,'file')
lights = read_sws_raw(in_file);   
else
   lights = read_sws_raw;
end
else
   lights = in_file;
end

darks = lights;
dark = lights.shutter==1;
fields = fieldnames(lights);
for f = 2:length(fields)
   if any(size(lights.(fields{f}))==length(dark))
      lights.(fields{f})= lights.(fields{f})(:,~dark);
      darks.(fields{f})= darks.(fields{f})(:,dark);
   end
end
   


   dark = ~(darks.shutter==0);
   %%
   windowSize = 1; 
   k = 1.1;
   k = 1;
   darks.In_DN(:,dark) = k * darks.In_DN(:,dark);
   lights.Si_dark = filter(ones(1,windowSize)/windowSize,1,mean(darks.Si_DN(:,dark),2));
   lights.In_dark = filter(ones(1,windowSize)/windowSize,1,mean(darks.In_DN(:,dark),2));
   %%
   lights.dark_time =  mean(darks.time(dark));
   lights.Si_spec = lights.Si_DN - lights.Si_dark*ones([1,size(lights.Si_DN,2)]);
   lights.In_spec = lights.In_DN - lights.In_dark*ones([1,size(lights.In_DN,2)]);
   % In retrospect the noise computation is probably in error because they
   % are based on the A/D counts and not photocounts or photoelectrons - as
   % in Peter Kiedron's treatment.  Still considering the ramifications of 
   % whether the photoelectrons or the photons should be following
   % Poisson's statistics.  
   lights.Si_noise_ms = sqrt(lights.Si_DN)./ (ones(size(lights.Si_lambda))*lights.Si_ms);
   lights.In_noise_ms = sqrt(lights.In_DN)./ (ones(size(lights.In_lambda))*lights.In_ms);
   lights.Si_per_ms = lights.Si_spec ./ (ones(size(lights.Si_lambda))*lights.Si_ms);
   lights.In_per_ms = lights.In_spec ./ (ones(size(lights.In_lambda))*lights.In_ms);
    lights.Si_SNR = lights.Si_per_ms ./ lights.Si_noise_ms;
   lights.In_SNR = lights.In_per_ms ./ lights.In_noise_ms;  
     lights.avg_Si_per_ms = filter(ones(1,windowSize)/windowSize,1,mean(lights.Si_per_ms,2));
     lights.avg_In_per_ms = filter(ones(1,windowSize)/windowSize,1,mean(lights.In_per_ms,2));
     %%
     
     
     %%
     
     lights.avg_Si_SNR = filter(ones(1,windowSize)/windowSize,1,mean(lights.Si_SNR,2));
     lights.avg_In_SNR = filter(ones(1,windowSize)/windowSize,1,mean(lights.In_SNR,2));