%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code was originally written by Lan Gao (lgao@ou.edu) to calculate
% the WRF and observation collocated SSA. This version is adopted from
% the original to read in AERONET (need to prepare before running this
% code), 4STAR and WRF data and to interpolate the WRF PBLH at the
% observation time and location of AERONET and 4STAR.
%
% THIS CODE IS SPECIFICALLY THE 4STAR VERSION

% For questions, please contact lgao@ou.edu or abdulamid.fakoya@ou.edu
%
% Last Update: March 2024. (c). Abdulamid Fakoya


% WRF PBLH
clear

%% load directories and add paths

% % local directories % comment out for remote server job submission
% matpath = 'C:\Users\Abdulamid Fakoya\Documents\MATLAB';
% addpath(genpath(matpath));
% codepath = 'C:\Users\Abdulamid Fakoya\Downloads';
% addpath(genpath(codepath));
% datapath = 'D:\WRF';
% addpath(genpath(datapath));


% Server CL2EAR


cd /ourdisk/hpc/cl2ear/dont_archive/biolafak/pblh_wrf_obs/codes/
addpath /ourdisk/hpc/cl2ear/auto_archive_notyet/tape_2copies/cl2ear/Model_Output/WRF/WRF_PBLH/
addpath /ourdisk/hpc/cl2ear/auto_archive_notyet/tape_2copies/cl2ear/Model_Output/WRF/wrf2016/
addpath /ourdisk/hpc/cl2ear/dont_archive/biolafak/pblh_wrf_obs/
addpath /ourdisk/hpc/cl2ear/dont_archive/biolafak/pblh_wrf_obs/data/star/




% addpath /home/afakoya/data/star/
% addpath /home/afakoya/wrf_pblh_obs/
% addpath /data/store/from_uah/wrf2016/
% addpath /data/store/model_pbl/

%% load WRF_PBLH data

FILE_LIST1 = fullfile('/ourdisk/hpc/cl2ear/auto_archive_notyet/tape_2copies/cl2ear/Model_Output/WRF/WRF_PBLH/wrfcam5_lennys-blh*.nc');
FILE_LIST1 = dir(FILE_LIST1);

% find the date
for d = 1:length(FILE_LIST1)
   DAY_WRF_PBLH(d,1) = str2double(FILE_LIST1(d).name(20:27));
   DAY_WRF_PBLH(d,2) = str2double(FILE_LIST1(d).name(29:30)) + str2double(FILE_LIST1(d).name(31:32))/60;
end
clear d

%% load 4STAR data for each year

% This loads only one year at a time, so it has to be changed for each
% year.

load('/ourdisk/hpc/cl2ear/dont_archive/biolafak/pblh_wrf_obs/data/star/skyscans_2016_532.mat') % change dir
for d = 1:length(skyscans_2016_532.time)
   YY = year(datetime(skyscans_2016_532.time{d}));
   MM = month(datetime(skyscans_2016_532.time{d}));
   DD = day(datetime(skyscans_2016_532.time{d}));
   hh = hour(datetime(skyscans_2016_532.time{d}));
   mm = minute(datetime(skyscans_2016_532.time{d}));
   ss = second(datetime(skyscans_2016_532.time{d}));
   STAR_time(d) = hh+mm/60+ss/3600;

   if MM<10
      MM_str = ['0' num2str(MM)];
   else
      MM_str = num2str(MM);
   end
   if DD<10
      DD_str = ['0' num2str(DD)];
   else
      DD_str = num2str(DD);
   end

   STAR_DATE(d) = str2double([num2str(YY) MM_str DD_str]);

end
% clearvars -except skyscans_2016_532 FILE_LIST1 DAY_WRF_PBLH STAR_DATE STAR_time
STAR = [STAR_DATE' STAR_time' skyscans_2016_532.long skyscans_2016_532.lat skyscans_2016_532.alt skyscans_2016_532.ssa_532];

%% find the date

% Since 4STAR and AERONET matrices have already been defined, we can
% extract date information directly from the matrices

DAY_STAR = STAR(:, 1); % column should be in YYYYMMDD format
% DAY_AERONET = AERONET(:, 1); % column should be in YYYYMMDD format

% Combine and find unique dates
DAY_OBS = unique(DAY_STAR);

OUT_STAR_SSA500 = [];
OUT_STAR_SSA532 = [];
OUT_STAR_AOD500 = [];
OUT_STAR_AOD532 = [];

%% Process the WRF Model PBLH data

for i = 1:length(DAY_OBS)

   % PBLH
   index_WRF_PBLH = find(DAY_WRF_PBLH(:,1) == DAY_OBS(i));
   if isempty(index_WRF_PBLH)
      ['No WRF PBLH data for the date: ' num2str(DAY_OBS(i))]
      continue
   else
      for N_file = 1:length(index_WRF_PBLH)
         filename1 = FILE_LIST1(index_WRF_PBLH(N_file)).name;
         % S_WRF_PBLH = ncinfo(filename1);

         lon_temp = double(ncread(filename1,'XLONG'));
         lat_temp = double(ncread(filename1,'XLAT'));
         WRF.lon(:,N_file) = unique(lon_temp(:,1));
         WRF.lat(:,N_file) = unique(lat_temp(1,:))';
         time_PBLH(N_file,1) = str2double(filename1(29:30));
         PBLH(:,:,N_file) = ncread(filename1,'blh');
         clear filename1
      end
      clear N_file
   end
end
lon_min = min(min(WRF.lon));
lat_min = min(min(WRF.lat));
lon_max = max(max(WRF.lon));
lat_max = max(max(WRF.lat));

%% WRF-CAM5 SSA, AOD, EXTINCTION, ABSORPTION at PBLH


%  This part will collocate the AERONET and 4STAR observations with WRF
%  output at the time and location and PBLH of the observations.

% Load the WRF-CAM5 data with aerosol properties
FILE_LIST3 = fullfile('/ourdisk/hpc/cl2ear/auto_archive_notyet/tape_2copies/cl2ear/Model_Output/WRF/wrf2016/wrfout_*'); % change dir
FILE_LIST3 = dir(FILE_LIST3);

for d = 1:length(FILE_LIST3)
   DAY_WRF(d,1) = str2double([FILE_LIST3(d).name(12:15) FILE_LIST3(d).name(17:18) FILE_LIST3(d).name(20:21)]);
   DAY_WRF(d,2) = str2double(FILE_LIST3(d).name(23:24));
end
clear d

% Process the WRF Model data

for i = 1:length(DAY_OBS)

   % PBLH

   index_WRF = find(DAY_WRF(:,1) == DAY_OBS(i));

   if isempty(index_WRF)
      disp(['No WRF data for the date: ' num2str(DAY_OBS(i))])
      continue
   else

      for N_file = 1:length(index_WRF)
         filename3 = FILE_LIST3(index_WRF(N_file)).name;

         lon_temp = double(ncread(filename3,'XLONG'));
         lat_temp = double(ncread(filename3,'XLAT'));
         WRF.lon(:,N_file) = unique(lon_temp(:,1));
         WRF.lat(:,N_file) = unique(lat_temp(1,:))';
         clear lon_temp lat_temp

         WRF.time(N_file,1) = str2double(filename3(23:24));

         % WRF_aod300 = double(ncread(filename3,'TAUAER1'));
         WRF_aod400 = double(ncread(filename3,'TAUAER2'));
         WRF_aod600 = double(ncread(filename3,'TAUAER3'));
         % WRF_aod999 = double(ncread(filename3,'TAUAER4'));

         % Using angstrom exponent, calculate AOD at 532 and 500nm

         alfa = -[log(WRF_aod400./WRF_aod600)]./[log(400/600)];
         WRF_aod500 = WRF_aod400./((400/500).^(-alfa));
         WRF_aod532 = WRF_aod400./((400/532).^(-alfa));

         % Load SSA variables
         WRF_ssa300 = double(ncread(filename3,'WAER1'));
         WRF_ssa400 = double(ncread(filename3,'WAER2'));
         WRF_ssa600 = double(ncread(filename3,'WAER3'));
         WRF_ssa999 = double(ncread(filename3,'WAER4'));

         WRF1d_ssa300 = reshape(WRF_ssa300,nzmax(WRF_ssa300),1); %reshape; can use numel instead of nzmax for dense array
         WRF1d_ssa400 = reshape(WRF_ssa400,nzmax(WRF_ssa400),1);
         WRF1d_ssa600 = reshape(WRF_ssa600,nzmax(WRF_ssa600),1);
         WRF1d_ssa999 = reshape(WRF_ssa999,nzmax(WRF_ssa999),1);

         % Interpolate to estimate SSA at 532 and 500 nm
         temp = [WRF1d_ssa300 WRF1d_ssa400 WRF1d_ssa600 WRF1d_ssa999];
         WRF_ssa500_temp = cell2mat(arrayfun(@(X) interp1([300 400 600 999],temp(X,:),500), 1:size(temp,1),'un',0));
         WRF_ssa500 = reshape(WRF_ssa500_temp, size(WRF_ssa300));

         WRF_ssa532_temp = cell2mat(arrayfun(@(X) interp1([300 400 600 999],temp(X,:),532), 1:size(temp,1),'un',0));
         WRF_ssa532 = reshape(WRF_ssa532_temp, size(WRF_ssa300));

         % Calculating the altitude from WRF (converting to meters)

         PH = double(ncread(filename3,'PH')); % PH is perturbation geopotential
         PHB = double(ncread(filename3,'PHB')); % PHB is base-state geopotential
         alt = (PH+PHB)/9.80665; % height in meters;
         WRF.alt(:,:,:,N_file) = (alt(:,:,2:end,:)-alt(:,:,1:end-1,:))/2+alt(:,:,1:end-1,:);


         H_use = nanmean([squeeze(WRF.alt(1,1,:,1)) squeeze(WRF.alt(end,end,:,1))]')';


         % H_use = nanmean([squeeze(WRF.alt(1,1,:,1)) squeeze(WRF.alt(50,50,:,2))  squeeze(WRF.alt(100,100,:,3)) squeeze(WRF.alt(end,end,:,4)) ...
         %                 squeeze(WRF.alt(1,1,:,5)) squeeze(WRF.alt(50,50,:,6))  squeeze(WRF.alt(100,100,:,7))  squeeze(WRF.alt(end,end,:,8))]')';


         for j = 1:size(WRF_aod500,3)
            WRF_SSA500_temp_TC(:,:,j) = sum(WRF_aod500(:,:,j:end).*WRF_ssa500(:,:,j:end),3)./sum(WRF_aod500(:,:,j:end),3);
            WRF_SSA532_temp_TC(:,:,j) = sum(WRF_aod532(:,:,j:end).*WRF_ssa532(:,:,j:end),3)./sum(WRF_aod532(:,:,j:end),3);
         end

         WRF_AOD400_TC = cumsum(WRF_aod400,3);
         WRF_AOD500_TC = cumsum(WRF_aod500,3);
         WRF_AOD532_TC = cumsum(WRF_aod532,3);
         WRF_AOD600_TC = cumsum(WRF_aod600,3);

         WRF.AOD400_TC(:,:,:,N_file) = WRF_AOD400_TC;
         WRF.AOD500_TC(:,:,:,N_file) = WRF_AOD500_TC;
         WRF.AOD532_TC(:,:,:,N_file) = WRF_AOD532_TC;
         WRF.AOD600_TC(:,:,:,N_file) = WRF_AOD600_TC;

         WRF.SSA500_TC(:,:,:,N_file) = WRF_SSA500_temp_TC;
         WRF.SSA532_TC(:,:,:,N_file) = WRF_SSA532_temp_TC;

         WRF_SSA500_temp_BL = nan([size(WRF_ssa500, 1)], size(WRF_ssa500, 2),length(H_use));
         WRF_SSA532_temp_BL = nan([size(WRF_ssa500, 1)], size(WRF_ssa500, 2),length(H_use));

         WRF_AOD400_BL = WRF_SSA500_temp_BL;
         WRF_AOD500_BL = WRF_SSA500_temp_BL;
         WRF_AOD532_BL = WRF_SSA500_temp_BL;
         WRF_AOD600_BL = WRF_SSA500_temp_BL;

         WRF_SSA500_temp_FT = nan([size(WRF_ssa500, 1)], size(WRF_ssa500, 2),length(H_use));
         WRF_SSA532_temp_FT = nan([size(WRF_ssa500, 1)], size(WRF_ssa500, 2),length(H_use));

         WRF_AOD400_FT = WRF_SSA500_temp_FT;
         WRF_AOD500_FT = WRF_SSA500_temp_FT;
         WRF_AOD532_FT = WRF_SSA500_temp_FT;
         WRF_AOD600_FT = WRF_SSA500_temp_FT;

         % Pre-allocate the arrays with nans.
         [nx, ny, nz] = size(WRF_aod500);
         WRF_SSA500_temp_ALT = nan(nx, ny, nz);
         WRF_SSA532_temp_ALT = nan(nx, ny, nz);
         WRF_AOD400_ALT = nan(nx, ny, nz);
         WRF_AOD500_ALT = nan(nx, ny, nz);
         WRF_AOD532_ALT = nan(nx, ny, nz);
         WRF_AOD600_ALT = nan(nx, ny, nz);

         endindex = size(WRF_aod400, 3);

         % Get the dimensions of PBLH
         [x_dim, y_dim, t_dim] = size(PBLH);

         % Initialize ftsh_values with NaNs
         ftsh_values = nan(x_dim, y_dim, t_dim);

         % Iterate over spatial and temporal dimensions observation

         for x = 1:size(PBLH, 1) % longitude

            for y = 1:size(PBLH, 2) % :-1:1 % latitude
               for t = 1: size(PBLH, 3) % :-1:1 % time

                  % Determine the PBLH index for the current (x, y, t)

                  % !!! Do not USE index_2 unless find_nearest_index is
                  % defined in path. Use the below instead
                  % index_2 = find_nearest_index(PBLH(x, y), H_use);
                  % pbl_idx(x, y) = index_2;

                  % A different indexing method to compare
                  current_PBLH_index = interp1(H_use, [1:length(H_use)], PBLH(x, y, t), 'nearest', 'extrap');
                  pbl_idx_2(x,y,t) = current_PBLH_index;

                  % Determine the Free Troposphere Start Height (FTSH)
                  % by finding the next height value in H_use after the PBLH

                  % Do not go beyond the bounds of H_use (which is
                  % technically not possible)

                  if current_PBLH_index < length(H_use)
                     % If not at the end, the FTSH is the next height value in H_use
                     ftsh_value = H_use(current_PBLH_index + 1);
                  else
                     % If PBLH corresponds to the last height or
                     % beyond, set to NaN
                     ftsh_value = NaN;
                  end

                  % Store the actual FTSH value for each (x, y, t)
                  ftsh_values(x, y, t) = ftsh_value;

                  % BL calculation - extinction weighted SSA
                  idx_BL = [1:current_PBLH_index];
                  idx_FT = [current_PBLH_index+1:endindex];

                  % For Boundary Layer (BL)

                  for idx = 1:length(idx_BL)
                     WRF_SSA500_temp_BL(x, y,idx_BL(idx)) = sum(WRF_aod500(x, y, idx_BL(1:idx)) .* WRF_ssa500(x, y, idx_BL(1:idx)), 3) ./ sum(WRF_aod500(x, y, idx_BL(1:idx)), 3);
                     WRF_SSA532_temp_BL(x, y,idx_BL(idx)) = sum(WRF_aod532(x, y, idx_BL(1:idx)) .* WRF_ssa532(x, y, idx_BL(1:idx)), 3) ./ sum(WRF_aod532(x, y, idx_BL(1:idx)), 3);

                     % Cumulative sums for BL - cumsum up to current_PBLH_index
                     % WRF_AOD400_TC = cumsum(WRF_aod400,3);
                     WRF_AOD400_BL(x, y, idx_BL(idx)) = sum(WRF_aod400(x, y, idx_BL(1:idx)),3);
                     WRF_AOD500_BL(x, y, idx_BL(idx)) = sum(WRF_aod500(x, y, idx_BL(1:idx)),3);
                     WRF_AOD532_BL(x, y, idx_BL(idx)) = sum(WRF_aod532(x, y, idx_BL(1:idx)),3);
                     WRF_AOD600_BL(x, y, idx_BL(idx)) = sum(WRF_aod600(x, y, idx_BL(1:idx)),3);
                  end

                  WRF_SSA500_temp_BL(x, y,idx_BL(idx)+1) =  WRF_SSA500_temp_BL(x, y,idx_BL(idx));
                  WRF_SSA532_temp_BL(x, y,idx_BL(idx)+1) = WRF_SSA532_temp_BL(x, y,idx_BL(idx));
                  WRF_AOD400_BL(x, y, idx_BL(idx)+1) = WRF_AOD400_BL(x, y, idx_BL(idx));
                  WRF_AOD500_BL(x, y, idx_BL(idx)+1) = WRF_AOD500_BL(x, y, idx_BL(idx));
                  WRF_AOD532_BL(x, y, idx_BL(idx)+1) = WRF_AOD532_BL(x, y, idx_BL(idx));
                  WRF_AOD600_BL(x, y, idx_BL(idx)+1) = WRF_AOD600_BL(x, y, idx_BL(idx));
                  WRF_SSA500_temp_BL(x, y,idx_BL(idx)+2) =  WRF_SSA500_temp_BL(x, y,idx_BL(idx));
                  WRF_SSA532_temp_BL(x, y,idx_BL(idx)+2) = WRF_SSA532_temp_BL(x, y,idx_BL(idx));
                  WRF_AOD400_BL(x, y, idx_BL(idx)+2) = WRF_AOD400_BL(x, y, idx_BL(idx));
                  WRF_AOD500_BL(x, y, idx_BL(idx)+2) = WRF_AOD500_BL(x, y, idx_BL(idx));
                  WRF_AOD532_BL(x, y, idx_BL(idx)+2) = WRF_AOD532_BL(x, y, idx_BL(idx));
                  WRF_AOD600_BL(x, y, idx_BL(idx)+2) = WRF_AOD600_BL(x, y, idx_BL(idx));

                  % For Free Troposphere

                  % FT calculation - extinction weighted SSA
                  for idx = 1:length(idx_FT)
                     WRF_SSA500_temp_FT(x, y, idx_FT(idx)) = sum(WRF_aod500(x, y, idx_FT(idx:end)) .* WRF_ssa500(x, y, idx_FT(idx:end)), 3) ./ sum(WRF_aod500(x, y, idx_FT(idx:end)), 3);
                     WRF_SSA532_temp_FT(x, y, idx_FT(idx)) = sum(WRF_aod532(x, y, idx_FT(idx:end)) .* WRF_ssa532(x, y, idx_FT(idx:end)), 3) ./ sum(WRF_aod532(x, y, idx_FT(idx:end)), 3);

                     % Cummulative sums for FT - cumsum above the current_PBLH_index
                     % WRF_AOD400_BL(x, y, idx_BL(idx)) = sum(WRF_aod400(x, y, idx_BL(1:idx)),3);
                     WRF_AOD400_FT(x, y, idx_FT(idx)) = sum(WRF_aod400(x, y, idx_FT(idx:end)),3);
                     WRF_AOD500_FT(x, y, idx_FT(idx)) = sum(WRF_aod500(x, y, idx_FT(idx:end)),3);
                     WRF_AOD532_FT(x, y, idx_FT(idx)) = sum(WRF_aod532(x, y, idx_FT(idx:end)),3);
                     WRF_AOD600_FT(x, y, idx_FT(idx)) = sum(WRF_aod600(x, y, idx_FT(idx:end)),3);
                  end

               end

               % % Process TC @ OBS altitude (switch for 4STAR and AERO @ Ascension)


               % STAR(:,5) contains the observation altitudes

               % Find nearest index in H_use for each STAR altitude.
               star_indices = interp1(H_use, 1:length(H_use), STAR(:,5), 'nearest', 'extrap');

               min_idx = min(star_indices); % Use the minimum index

               for alt_idx = min_idx:nz
                  range = alt_idx:nz; % Define the range from alt_idx to the end.

                  % Calculate parameters.
                  WRF_SSA500_temp_ALT(x, y, alt_idx) = sum(WRF_aod500(x, y, range) .* WRF_ssa500(x, y, range), 3) ./ sum(WRF_aod500(x, y, range), 3);
                  WRF_SSA532_temp_ALT(x, y, alt_idx) = sum(WRF_aod532(x, y, range) .* WRF_ssa532(x, y, range), 3) ./ sum(WRF_aod532(x, y, range), 3);

                  WRF_AOD400_ALT(x, y, alt_idx) = sum(WRF_aod400(x, y, range), 3);
                  WRF_AOD500_ALT(x, y, alt_idx) = sum(WRF_aod500(x, y, range), 3);
                  WRF_AOD532_ALT(x, y, alt_idx) = sum(WRF_aod532(x, y, range), 3);
                  WRF_AOD600_ALT(x, y, alt_idx) = sum(WRF_aod600(x, y, range), 3);
               end

            end

         end


         WRF.AOD400_BL(:,:,:,N_file) = WRF_AOD400_BL;
         WRF.AOD500_BL(:,:,:,N_file) = WRF_AOD500_BL;
         WRF.AOD532_BL(:,:,:,N_file) = WRF_AOD532_BL;
         WRF.AOD600_BL(:,:,:,N_file) = WRF_AOD600_BL;

         WRF.SSA500_BL(:,:,:,N_file) = WRF_SSA500_temp_BL;
         WRF.SSA532_BL(:,:,:,N_file) = WRF_SSA532_temp_BL;

         WRF.AOD400_FT(:,:,:,N_file) = WRF_AOD400_FT;
         WRF.AOD500_FT(:,:,:,N_file) = WRF_AOD500_FT;
         WRF.AOD532_FT(:,:,:,N_file) = WRF_AOD532_FT;
         WRF.AOD600_FT(:,:,:,N_file) = WRF_AOD600_FT;

         WRF.SSA500_FT(:,:,:,N_file) = WRF_SSA500_temp_FT;
         WRF.SSA532_FT(:,:,:,N_file) = WRF_SSA532_temp_FT;

         WRF.AOD400_ALT(:,:,:,N_file) = WRF_AOD400_ALT;
         WRF.AOD500_ALT(:,:,:,N_file) = WRF_AOD500_ALT;
         WRF.AOD532_ALT(:,:,:,N_file) = WRF_AOD532_ALT;
         WRF.AOD600_ALT(:,:,:,N_file) = WRF_AOD600_ALT;

         WRF.SSA500_ALT(:,:,:,N_file) = WRF_SSA500_temp_ALT;
         WRF.SSA532_ALT(:,:,:,N_file) = WRF_SSA532_temp_ALT;

         % clear PH PHB WRF_SSA*temp  WRF_ssa* WRF1d_*

      end

   end

   %% Process 4STAR data

   % Interpolate PBLH 4STAR
   index_4STAR = find(STAR(:,1) == DAY_OBS(i));
   if isempty(index_4STAR)
      disp(['No 4STAR data for the date: ' num2str(DAY_OBS(i))]);
   else
      disp(['Processing: ' num2str(DAY_OBS(i))])
      PBLH_STAR = STAR(index_4STAR,:);

      % grid for the PBLH output
      [XX,YY,TT] = ndgrid(nanmean(WRF.lon,2),nanmean(WRF.lat,2),time_PBLH);
      WRF_STAR_PBLH  = squeeze(interpn(XX,YY,TT,PBLH, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,2)))';

      PBLH_STAR = [PBLH_STAR, WRF_STAR_PBLH'];

      % grid for the FTSH output
      [XX,YY,TT] = ndgrid(nanmean(WRF.lon,2),nanmean(WRF.lat,2),time_PBLH);
      WRF_STAR_FTSH  = squeeze(interpn(XX,YY,TT,ftsh_values, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,2)))';

      PBLH_STAR = [PBLH_STAR, WRF_STAR_FTSH'];

      % grid for the aerosol properties

      % Definitions: BL = For Boundary Layer Height,
      % FT = For Model Free Troposphere (above PBLH)

      [XX1,YY1,ZZ1,TT1] = ndgrid(nanmean(WRF.lon,2), nanmean(WRF.lat,2),H_use,unique(WRF.time));

      % To calculate the TC at 4STAR, we need to interpolate the
      % WRF TC data in x, y, t (3D interp) but for the 74th level
      % in ZZ1.

      % We have to this for every wavelength
      % TC SSA 500 nm

      sliceSSA500 = squeeze(WRF.SSA500_TC(:,:,74,:));
      [XX2,YY2,TT2] = ndgrid(nanmean(WRF.lon,2), nanmean(WRF.lat,2),unique(WRF.time));
      WRF_STAR_S500_TC = interpn(XX2,YY2,TT2, sliceSSA500, PBLH_STAR(:,3), PBLH_STAR(:,4), PBLH_STAR(:,2));

      % interpolate BL and FT SSA 500nm
      WRF_STAR_S500_BL = interpn(XX1,YY1,ZZ1,TT1,WRF.SSA500_BL, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,7),PBLH_STAR(:,2));
      WRF_STAR_S500_FT = interpn(XX1,YY1,ZZ1,TT1,WRF.SSA500_FT, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,8),PBLH_STAR(:,2));
      WRF_STAR_S500_ALT = interpn(XX1,YY1,ZZ1,TT1,WRF.SSA500_ALT, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,5),PBLH_STAR(:,2));

      % TC SSA 532 nm
      sliceSSA532 = squeeze(WRF.SSA532_TC(:,:,74,:));
      WRF_STAR_S532_TC = interpn(XX2,YY2,TT2, sliceSSA532, PBLH_STAR(:,3), PBLH_STAR(:,4), PBLH_STAR(:,2));

      % interpolate BL and FT SSA 532nm
      WRF_STAR_S532_BL = interpn(XX1,YY1,ZZ1,TT1,WRF.SSA532_BL, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,7),PBLH_STAR(:,2));
      WRF_STAR_S532_FT = interpn(XX1,YY1,ZZ1,TT1,WRF.SSA532_FT, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,8),PBLH_STAR(:,2));
      WRF_STAR_S532_ALT = interpn(XX1,YY1,ZZ1,TT1,WRF.SSA532_ALT, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,5),PBLH_STAR(:,2));

      % TC AOD 500 nm
      sliceAOD500 = squeeze(WRF.AOD500_TC(:,:,74,:));
      WRF_STAR_A500_TC = interpn(XX2,YY2,TT2, sliceAOD500, PBLH_STAR(:,3), PBLH_STAR(:,4), PBLH_STAR(:,2));

      % interpolate BL and FT AOD 500nm
      WRF_STAR_A500_BL = interpn(XX1,YY1,ZZ1,TT1,WRF.AOD500_BL, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,7),PBLH_STAR(:,2));
      WRF_STAR_A500_FT = interpn(XX1,YY1,ZZ1,TT1,WRF.AOD500_FT, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,8),PBLH_STAR(:,2));
      WRF_STAR_A500_ALT = interpn(XX1,YY1,ZZ1,TT1,WRF.AOD500_ALT, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,5),PBLH_STAR(:,2));

      % TC AOD 532 nm
      sliceAOD532 = squeeze(WRF.AOD532_TC(:,:,74,:));
      WRF_STAR_A532_TC = interpn(XX2,YY2,TT2, sliceAOD532, PBLH_STAR(:,3), PBLH_STAR(:,4), PBLH_STAR(:,2));

      % interpolate BL and FT AOD 532nm
      WRF_STAR_A532_BL = interpn(XX1,YY1,ZZ1,TT1,WRF.AOD532_BL, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,7),PBLH_STAR(:,2));
      WRF_STAR_A532_FT = interpn(XX1,YY1,ZZ1,TT1,WRF.AOD532_FT, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,8),PBLH_STAR(:,2));
      WRF_STAR_A532_ALT = interpn(XX1,YY1,ZZ1,TT1,WRF.AOD532_ALT, PBLH_STAR(:,3),PBLH_STAR(:,4),PBLH_STAR(:,5),PBLH_STAR(:,2));


      %% output the model data

      OUT_STAR_SSA500 = [OUT_STAR_SSA500; [PBLH_STAR WRF_STAR_S500_BL WRF_STAR_S500_FT WRF_STAR_S500_TC WRF_STAR_S500_ALT]];
      OUT_STAR_SSA532 = [OUT_STAR_SSA532; [PBLH_STAR WRF_STAR_S532_BL WRF_STAR_S532_FT WRF_STAR_S532_TC WRF_STAR_S532_ALT]];
      OUT_STAR_AOD500 = [OUT_STAR_AOD500; [PBLH_STAR WRF_STAR_A500_BL WRF_STAR_A500_FT WRF_STAR_A500_TC WRF_STAR_A500_ALT]];
      OUT_STAR_AOD532 = [OUT_STAR_AOD532; [PBLH_STAR WRF_STAR_A532_BL WRF_STAR_A532_FT WRF_STAR_A532_TC WRF_STAR_A532_ALT]];

      clear  XX* YY* ZZ* TT* PBLH_STAR  WRF_STAR_*
   end

   disp(['Done date: ' num2str(DAY_OBS(i))])

   % save('/ourdisk/hpc/cl2ear/dont_archive/biolafak/pblh_wrf_obs/wrf_pblh_obs/results_star/OUT_STAR16_temp.mat','OUT_STAR_SSA500', 'OUT_STAR_SSA532', 'OUT_STAR_AOD500', 'OUT_STAR_AOD532')

end

% save('/ourdisk/hpc/cl2ear/dont_archive/biolafak/pblh_wrf_obs/wrf_pblh_obs/results_star/OUT_STAR16.mat','OUT_STAR_SSA500', 'OUT_STAR_SSA532', 'OUT_STAR_AOD500', 'OUT_STAR_AOD532')