function lights = read_sws_cal_pair;
% Reads a pair of selected calibration files for light and dark.  Compute
% stuff.
lights = read_sws_raw(getfullname('*.*','sws_cal_light'));
[pname,fname, ext] = fileparts(lights.filename);
if exist([pname,filesep, '..',filesep,'dark'],'dir')
   dk_files = dir([pname,filesep, '..',filesep,'dark',filesep,'*.mat']);
   if length(dk_files)==1
         darks = loadinto([pname,filesep,'..',filesep,'dark',filesep,dk_files(1).name]);
   else
      dk_files = dir([pname,filesep, '..',filesep,'dark',filesep,'*.dat']);
      if length(dk_files)==1
         darks = read_sws_raw(getfullname([pname,filesep,'..',filesep,'dark',filesep,dk_files(1).name]));
      end
   end
   if ~exist('darks','var')
      darks = read_sws_raw(getfullname([pname,filesep, '..',filesep,'dark',filesep,'*.dat;*.mat']));
   end
else
      darks = read_sws_raw(getfullname([pname,filesep, '..',filesep,'*.dat;*.mat']));
end
   dark = ~(darks.shutter==0);
   %%
   windowSize = 1; 
   k = 1.1;
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
     figure; plot(lights.Si_lambda, lights.avg_Si_per_ms,'-',lights.In_lambda, lights.avg_In_per_ms,'-');
     xlabel(['Wavelength [nm]']);
     ylabel(['Cts / ms']);
     [pname, fname, ext] = fileparts(lights.filename);
     lights.fname = [fname, ext];
     title({lights.fname;['Integration times, Si: ',sprintf('%2.0f',unique(lights.Si_ms)),' InGaAs: ',sprintf('%2.0f',unique(lights.In_ms))]})
     return