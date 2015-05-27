function [filter, std_spectra] = get_head_corrs(arg)
%[filter, std_spectra] = get_head_corrs(arg)
if nargin<1
   disp('get_head_corrs requires an input arg with element head_id')
   corrs = [];
   return
end
if ~isfield(arg, 'raw_corrpath')
   raw_corrpath = uigetdir('D:\case_studies\new_xmfrx_proc\','Select raw corrs path');
   arg.raw_corrpath = [raw_corrpath, '/'];
end
filter_trace_path = [arg.raw_corrpath, 'filter_traces/'];

solardir = dir([arg.raw_corrpath,'CosCorr*']);
cos_corrs = read_solarfile([arg.raw_corrpath,solardir(1).name], arg.lat);
for f = 1:7
   disp(['Generating hemispheric cosine correction for channel ',num2str(f)'])
   dif_corrs(f) = hemisp_correction(cos_corrs(f));
end
det_corrs = get_det_corrs(arg.head_id);

[trace, std_spectra] = mfr_head_cal(filter_trace_path);

for f = 7:-1:1
filter(f).cos_corrs = cos_corrs(f);
filter(f).dif_corrs = dif_corrs(f);
filter(f).trace = trace(f); 
filter(f).det_corrs = det_corrs(f);
end

function det_corrs = get_det_corrs(head_id)
if strcmp(head_id,'1050')
   %from CalibInfo.sgpmfrsrC1.030501.0 with header line: 
% MULTIFILTER32 7 23 $F584 $1050 37741.58495 NONSTANDARD
det_corrs{1}.sens = -0.0006478;
det_corrs{2}.sens = -0.28152 * 0.7989 * 0.9636; 
det_corrs{3}.sens = -0.35649 * 1.0791 * 0.9748; 
det_corrs{4}.sens = -0.75465 * 1.0512 * 0.9991;
det_corrs{5}.sens = -1.10580 * 0.9743 * 0.9849;
det_corrs{6}.sens = -1.79495 * 1.0632 * 1.0037;
det_corrs{7}.sens =  -2.52701;
% 
% det_sens(1) = -0.0006478;
% det_sens(2) = -0.28152 * 0.7989 * 0.9636; 
% det_sens(3) = -0.35649 * 1.0791 * 0.9748; 
% det_sens(4) = -0.75465 * 1.0512 * 0.9991; 
% det_sens(5) = -1.10580 * 0.9743 * 0.9849; 
% det_sens(6) = -1.79495 * 1.0632 * 1.0037;
% det_sens(7) =  -2.52701;


% These offsets are OLD Yankee offsets, don't use them.
% det_corrs{1}.offset  =  0.0300;
% det_corrs{2}.offset  =   3.61;
% det_corrs{3}.offset  =  3.05; 
% det_corrs{4}.offset  =  2.81; 
% det_corrs{5}.offset  =  2.80; 
% det_corrs{6}.offset  =  2.42; 
% det_corrs{7}.offset  = 1.93;

%These offsets were re-measured by John after the diffuser was
%replaced in 9/6/2002
det_corrs{1}.offset  =  -0.020;
det_corrs{2}.offset  =  -0.260;
det_corrs{3}.offset  =  -0.190; 
det_corrs{4}.offset  =  -0.250; 
det_corrs{5}.offset  =  -0.270;
det_corrs{6}.offset  =  -0.280; 
det_corrs{7}.offset  =  -0.260;


det_corrs{1}.gain  = -2.7260 * 2;
det_corrs{2}.gain  = -3.9880 * 2;
det_corrs{3}.gain  = -1.2040 * 2;
det_corrs{4}.gain  = -0.993 * 2; 
det_corrs{5}.gain  = -0.801 * 2; 
det_corrs{6}.gain  = -0.992 * 2; 
det_corrs{7}.gain  = -1.607 * 2;


% gain(1) = -2726.0 * 2;
% gain(2) = -3988.0 * 2;
% gain(3) = -1204.0 * 2;
% gain(4) = -993.0 * 2; 
% gain(5) = -801.0 * 2; 
% gain(6) = -992.0 * 2; 
% gain(7) = -1607.0 * 2;
elseif strcmp(head_id,'1316')
   %from Y433.Head$1316.Offsets.dat 
% These det_sens are no longer applied in the new processing 
% since calibration is by Langley only.
det_corrs{1}.sens  = NaN;
det_corrs{2}.sens  = NaN; 
det_corrs{3}.sens  = NaN; 
det_corrs{4}.sens  = NaN; 
det_corrs{5}.sens  = NaN; 
det_corrs{6}.sens  = NaN;
det_corrs{7}.sens  = NaN;
% 
% det_sens(1) = NaN;
% det_sens(2) = NaN; 
% det_sens(3) = NaN; 
% det_sens(4) = NaN; 
% det_sens(5) = NaN; 
% det_sens(6) = NaN;
% det_sens(7) =  NaN;

% These offfset values are new.
% Previously no offsets were applied in the previous CalibInfo file.

det_corrs{1}.offset  = -0.140;
det_corrs{2}.offset  = -0.325;
det_corrs{3}.offset  = -0.360;
det_corrs{4}.offset  = -0.440;
det_corrs{5}.offset  = -0.350;
det_corrs{6}.offset  = -0.340;
det_corrs{7}.offset  = -0.230;

% offset(1) =  -0.140;
% offset(2) =  -0.325;
% offset(3) =  -0.360;
% offset(4) =  -0.440;
% offset(5) =  -0.350;
% offset(6) =  -0.340;
% offset(7) =  -0.230;

% These logger gains were determined directly from the actual counts in
% response to +/- 0.5V.  They are virtually identical to previous applied
% values
det_corrs{1}.gain  = -5.460 ;
det_corrs{2}.gain  = -8.012 ;
det_corrs{3}.gain  = -2.414 ;
det_corrs{4}.gain  = -1.995 ;
det_corrs{5}.gain  = -1.606 ;
det_corrs{6}.gain  = -1.968 ;
det_corrs{7}.gain  = -3.228 ;


% gain(1) = -5.460 ;
% gain(2) = -8.012 ;
% gain(3) = -2.414 ;
% gain(4) = -1.995 ;
% gain(5) = -1.606 ;
% gain(6) = -1.968 ;
% gain(7) = -3.228 ;
elseif strcmp(head_id,'F7F')

   det_corrs{1}.sens  = NaN;
det_corrs{2}.sens  = NaN; 
det_corrs{3}.sens  = NaN; 
det_corrs{4}.sens  = NaN; 
det_corrs{5}.sens  = NaN; 
det_corrs{6}.sens  = NaN;
det_corrs{7}.sens  = NaN;
% These offfset values are bogus temporary values.

det_corrs{1}.offset  = 0;
det_corrs{2}.offset  = 0;
det_corrs{3}.offset  = 0;
det_corrs{4}.offset  = 0;
det_corrs{5}.offset  = 0;
det_corrs{6}.offset  = 0;
det_corrs{7}.offset  = 0;

% offset(1) =  -0.140;
% offset(2) =  -0.325;
% offset(3) =  -0.360;
% offset(4) =  -0.440;
% offset(5) =  -0.350;
% offset(6) =  -0.340;
% offset(7) =  -0.230;

% These logger gains are bogus values
det_corrs{1}.gain  = -5.460 ;
det_corrs{2}.gain  = -8.012 ;
det_corrs{3}.gain  = -2.414 ;
det_corrs{4}.gain  = -1.995 ;
det_corrs{5}.gain  = -1.606 ;
det_corrs{6}.gain  = -1.968 ;
det_corrs{7}.gain  = -3.228 ;

else 
   

   det_corrs{1}.sens  = NaN;
det_corrs{2}.sens  = NaN; 
det_corrs{3}.sens  = NaN; 
det_corrs{4}.sens  = NaN; 
det_corrs{5}.sens  = NaN; 
det_corrs{6}.sens  = NaN;
det_corrs{7}.sens  = NaN;
% These offfset values are bogus temporary values.

det_corrs{1}.offset  = 0;
det_corrs{2}.offset  = 0;
det_corrs{3}.offset  = 0;
det_corrs{4}.offset  = 0;
det_corrs{5}.offset  = 0;
det_corrs{6}.offset  = 0;
det_corrs{7}.offset  = 0;

% offset(1) =  -0.140;
% offset(2) =  -0.325;
% offset(3) =  -0.360;
% offset(4) =  -0.440;
% offset(5) =  -0.350;
% offset(6) =  -0.340;
% offset(7) =  -0.230;

% These logger gains are bogus values
det_corrs{1}.gain  = -1 ;
det_corrs{2}.gain  = -1 ;
det_corrs{3}.gain  = -1 ;
det_corrs{4}.gain  = -1  ;
det_corrs{5}.gain  = -1  ;
det_corrs{6}.gain  = -1  ;
det_corrs{7}.gain  = -1 ;

   
   
end

% det_corrs.det_sens = det_sens; 
% det_corrs.offset =  offset;
% det_corrs.gain = gain;
