% Use either procedure process_raw_file or process_raw_files to 
% call several functions which apply successive "promotions" to 
% the data.
% 
% raw_to_data0: 
%   copies raw file to output dir and casts profiles into type float
% data_0_to_1: 
%   re-ranges to put zero range at first (zeroth) bin
% data_1_to_3: 
%   converts from total counts to count rate Hz
% grli_dtc_maxcts: 
%   apply dead time corrs based on max counts
% grli_base_corr: 
%   Applies background subtraction (of two types), range-correction, log, 
%   and SNR determination.  Populates: copol_532nm ,copol_532nm_log, copol_532nm_SNR, 
%   depol_532nm, depol_532nm_log, depol_532nm_SNR, depol_ratio_532nm, 
%   depol_strength_532nm, bkgnd_A_by_bkgnd_B

