function [status] = C1a_corrs(fid_datan, fid_C1)

% This process accepts two open cdfids; the first is an existing lidar file of data_n format
% The second is for a new lidar file of C1 format.  
% Values are read from datan, corrections applied, and saved to C1.

% Limitations: hard-coded for a 2000 Hz pulse rep.

load grli_20020711a_cals; 

% detA_dt = 2.04e-8;
% detB_dt = 2.14e-8;

old_var = 'range';
new_var = 'range';
[range_in,status] = nc_getvar(fid_datan,old_var);
if status < 0 ; disp(['Problem getting values for: ' new_var]); end;
range_out = range_in(range_img);
[status] = nc_putvar(fid_C1, new_var, range_out);
if status < 0 ; disp(['Problem copying values for: ' new_var]); end;

% Copol processing
detA_in = nc_getvar(fid_datan, 'detector_A_532nm');
detA = detA_in;
% Resize lidar profile to include only positive values.
% This drops the size from from 4000 bins to 2595 bins.
% detA = detA(range_sub,:);
% This drops the size from from 2000 bins to 1922 bins.
detA = detA([lr_2k; ur_2k],:);
[bins,times] = size(detA);

% Subtract a pre-saved afterpulse profile fitted/smoothed through TableCurve
%detA = detA - detA_ap_fit_Hz * ones(1,times);
detA = detA - detA_ap_fit_Hz_2k * ones(1,times);
% Determine background and subtract it.
%detA_bg = mean(detA(range_bg,:))';
detA_bg = mean(detA(range_bg_2k,:))';
detA = detA - ones(bins,1)*detA_bg';

% Retrieve laser optical power and divide detA by it.
optical_power = nc_getvar(fid_datan, 'optical_power_532nm');
if (any(optical_power>0))
  optical_power(find(optical_power==0)) = mean(optical_power(find(optical_power ~= 0)));
else
   optical_power(:) = 1;
end;
detA = detA ./ (ones(bins,1)*(optical_power));
% Multiply by range-correction factor F_test while re-sizing to sonde range.
% F_t has been hand-tweaked to reduce impact of first few bins
% full_corr does not have any far range correction.
detA = detA .* (full_corr*ones(1,times));
%detA = detA(range_sonde,:) .* ((F_t)*ones(1,times));
%detA = detA(range_sonde,:) .* ((F_test)*ones(1,times)); 
% Finally, resize results into range_img of 15km
detA = detA(range_img,:)/5e3;
detA_in = detA_in(range_img,:);
good_cnts = find(detA_in~=0);
[sample_std, status] = nc_getvar(fid_datan, 'detector_A_532nm_std');
sample_std = sample_std(range_img,:);
if (status < 0) ; disp(['error getting ''detector_A_532nm_std'' from netcdf file' ]); pause; end;
%sample_std is scaled to the square root of the ratio of the corrected and uncorrected detector counts
sample_std(good_cnts) = sample_std(good_cnts) .* sqrt(detA(good_cnts) ./ detA_in(good_cnts));
% 	figure; imagesc(detA);
%    axis('xy')
% 	title('DetA F-corrected');
%    colorbar('vert');
%   	figure; imagesc(detA([find((range_both>0)&(range_both<4000))],:));
%    axis('xy')
% 	title('Near DetA');
%    colorbar('vert');
% save result in fid_C1
disp('writing copol_532nm to fid_C1' );
[status] = nc_putvar(fid_C1, 'copol_532nm_std', sample_std);
clear sample_std;
[status] = nc_putvar(fid_C1, 'copol_532nm', detA);
% clear detA_in;
[det_SNR, status] = nc_getvar(fid_datan, 'copol_532nm_SNR');
[status] = nc_putvar(fid_C1, 'copol_532nm_SNR', det_SNR(range_img,:));
clear det_SNR;
% Depol processing
detB_in = nc_getvar(fid_datan, 'detector_B_532nm');
detB = detB_in;
% Resize lidar profile to include only positive values.
% This drops the size from from 4000 bins to 2595 bins.
%detB = detB(range_sub,:);
% This drops the size from from 2000 bins to 1922 bins.
detB = detB([lr_2k; ur_2k],:);

[bins,times] = size(detB);
% detB_rawHz = detB ./ (1+detB*detB_dt);
%figure; imagesc(exp(detB(range_img,:) ./ detB_rawHz(range_img,:)));
% Subtract a pre-saved afterpulse profile fitted/smoothed through TableCurve
detB = detB - detB_ap_fit_Hz_2k * ones(1,times);
% Determine background and subtract it.

detB_bg = mean(detB(range_bg_2k,:))';
%detB_bg = mean(detB(range_bg,:))';
detB = detB - ones(bins,1)*detB_bg';

% Retrieve laser optical power and divide detB by it.
%optical_power = nc_getvar(fid_datan, 'optical_power_532nm');
detB = detB ./ (ones(bins,1)*(optical_power));
% Multiply by range-correction factor F_test while re-sizing to sonde range.
%detB = detB(range_sonde,:) .* ((F_test)*ones(1,times));
%detB = detB(range_sonde,:) .* ((F_t)*ones(1,times));
detB = detB .* (full_corr*ones(1,times));
% Finally, resize results into range_img of 15km
detB = detB(range_img,:)/5e3;
detB_in = detB_in(range_img,:);
good_cnts = find(detB_in~=0);
[sample_std, status] = nc_getvar(fid_datan, 'detector_B_532nm_std');
sample_std = sample_std(range_img,:);
if (status < 0) ; disp(['error getting ''detector_B_532nm_std'' from netcdf file' ]); pause; end;
%sample_std is scaled to the square root of the ratio of the corrected and uncorrected detector counts
sample_std(good_cnts) = sample_std(good_cnts) .* sqrt(detB(good_cnts) ./ detB_in(good_cnts));
% 	figure; imagesc(detB);
%    axis('xy')
% 	title('DetB F-corrected');
%    colorbar('vert');
% save result in fid_C1
disp('writing depol_532nm to fid_C1' );
[status] = nc_putvar(fid_C1, 'depol_532nm_std', sample_std);
clear sample_std;
[det_SNR, status] = nc_getvar(fid_datan, 'depol_532nm_SNR');
dep_range = find(det_SNR>5);
detA_to_detB = .04; % determined by eye judging from depolarization of cirrus and blue sky.
detB = detB * detA_to_detB;
[status] = nc_putvar(fid_C1, 'depol_532nm', detB);
clear detB_in;
det_SNR = det_SNR(range_img,:);
[status] = nc_putvar(fid_C1, 'depol_532nm_SNR', det_SNR(range_img,:));
 good_sig = find((detA>0)&(detB>0));
 depol_ratio = zeros(size(detB));
 %depol_ratio(good_sig) = detB(good_sig)./(detA(good_sig));
 depol_ratio(good_sig) = detB(good_sig)./(detB(good_sig) + detA(good_sig));
 depol_strength = depol_ratio .* (det_SNR.^2);

[status] = nc_putvar(fid_C1, 'depol_ratio_532nm', depol_ratio(range_img,:));
[status] = nc_putvar(fid_C1, 'depol_strength_532nm', depol_strength(range_img,:));
