function [status] = data1_to_data31(infile, outdir);
% Opens indicated gr_li netcdf file and carries out the following processes:
% detector dead-time correction: bit 1 ON
% background-subtraction: bit 2 is ON
% range-squared correction: bit 3 is ON
% log and 3-part noise suppression: bit 4 is ON
% With bit 0 (zero-ranged) already on, the total data_level is 1 + 2 + 4 + 8 + 16 = 31

% The first approach is a standard background subtraction using the mid-90% of bins preceding the 
% laser pulse followed by and range correction determined from the first profile in the file.  These 
% results are stored in the netcdf file as copol_532nm and depol_532nm.
%
% The second method is a 3-part approach with an initial removal of 99% of the minimum of each profile
% followed by a log, followed by a final removal of residual bkgnd determined from mid-90% of bins preceding the
% laser pulse (as in the first method).  The results are stored in the netcdf file as copol_532nm_log 
% and depol_532nm_log.

%isp(['Opening netcdf file ' cdf_file]);


if nargin >= 2, 
%     disp(['The infile is ', infile]);
%     disp(['The outdir is ', outdir]);
    cdf_file = [outdir infile]; 
elseif nargin == 1, 
%     disp(['The infile is ', infile]);
    cdf_file = infile;
else 
    disp('This function requires at least one input parameter.');
    break;
end;
% disp(['cdf_file is: ', cdf_file])
[cdfid, status] = ncmex('OPEN', cdf_file, 'NC_WRITE');
if (status < 0) ; disp(['error opening ' cdf_file ]); pause; end;

%test for history
[datatype, len, status] = ncmex('ATTINQ', cdfid, -1, 'history');
if status < 0; 
    disp(['The history global attribute does not exist in ',infile]);
    disp('This process is not meant to process raw data so exiting...');
    raw = -1;
    break;
end;

%test for data_level
[varid] = ncmex('VARID',cdfid , 'data_level');
if varid < 0;
    disp(['The data_level field does not exist in ',infile]);
    disp('This process is not meant to process raw data so exiting...');
    raw = -1;
    break;
end;    

if ((status >=0) & (varid >=0));
    % General-use variables --- get several variables from the netcdf file what are required for 
    % both copol and depol channels. 
    % disp(['Getting general use variables...']);
    
    [time, status]  = nc_getvar(cdfid, 'time');
    if (status < 0) ; disp(['error getting ''time'' from netcdf file' ]); pause; end;
    %time is in seconds since 00:00 GMT of the current day.  Convert to fractional hours below...
    time_Hh = time / 3600;
    range  = nc_getvar(cdfid,  'range');
    [bin_resolution, status] = nc_getvar(cdfid, 'bin_resolution');
    if (status < 0) ; disp(['error getting ''bin_resolution'' from netcdf file' ]); pause; end;
    % Convert bin_resolution (initially stored in nanoseconds) to seconds.
    bin_resolution = bin_resolution * 1e-9;    
    [accumulates, staus]= nc_getvar(cdfid, 'accumulates');
    if (status < 0) ; disp(['error getting ''accumulates'' from netcdf file' ]); pause; end;
    samples = nc_getvar(cdfid, 'samples');
    [optical_power_532nm, status] = nc_getvar(cdfid, 'optical_power_532nm');
    if (status < 0) ; disp(['error getting ''optical_power_532nm'' from netcdf file' ]); pause; end;
    [time_zero_bin, status] = nc_getvar(cdfid, 'time_zero_bin');
    if (status < 0) ; disp(['error getting ''status'' from netcdf file' ]); pause; end;
    
    % get detector_A (copol)
    disp(['Beginning detector_A processing...']);
    
    % disp(['Getting detector counts and sample std dev.']);
    [detector_counts, status] = nc_getvar(cdfid, 'detector_A_532nm');
    if (status < 0) ; disp(['error getting ''detector_A_532nm'' from netcdf file' ]); pause; end;
    [sample_std, status] = nc_getvar(cdfid, 'detector_A_532nm_std');
    if (status < 0) ; disp(['error getting ''detector_A_532nm_std'' from netcdf file' ]); pause; end;
    [row,col] = size(detector_counts);
    bkgnd = zeros([1,col]);
    
    % normalize detected counts against samples, accumulates, and bin_resolution to get a count rate in Hz.
    % disp(['Normalizing to get count rate in Hz.']);
    for i = 1:col
        bkgnd_lb = 1 + floor(0.05*time_zero_bin(i));
        bkgnd_ub = floor(0.95*time_zero_bin(i));
        bkgnd(i) = mean(detector_counts(bkgnd_lb:bkgnd_ub,i));
        if (bkgnd(i)<=0);
            disp(['Mean of the ' i 'th background is less than or equal to zero!.  Detector problem?!?']);
            pause;
        end;
        % The following step adds an essentially insignificant offset to each profile, thus ensuring 
        % positive-definite values unless mean is actually zero in which case we have a problem
        detector_counts(:,i) = detector_counts(:,i) + 1e-7 * bkgnd(i);
        detector_counts(:,i) = detector_counts(:,i) / (accumulates * bin_resolution * samples(i));
        if (min(detector_counts(:,i)<=0)); 
            disp('Hey, detector_counts is zero!'); 
            pause; 
        end;
        %Also normalize the sample std 
        sample_std(:,i) = sample_std(:,i)/ (accumulates * bin_resolution * samples(i));
    end;
    
    
    % disp(['Applying deadtime correction...']);
    
    %apply deadtime correction to the detected count rate
    % y=(a+cx+ex^2)/(1+bx+dx^2) from TableCurve best fit to Perkin-Elmer data for APD SN:6850
    a  =  1.625848583;
    b  =  -0.06952347; 
    c  =  0.647395566; 
    d  =  0.000575910;  
    e  =  -0.04454093;  
    
    detector_counts_no_dtc = detector_counts; 
    X = log(detector_counts);
    detector_counts = exp((a + c*X +e*X.*X)./(1 + b*X + d*X.*X));
    clear X;
    
    % Detector_counts is now a dead-time corrected count rate. 
    % We dtc the observed sample deviations with the sqrt of the ratio of the new and old count rates 
    % disp(['Correcting sample std dev for deadtime...']);
    sample_std = sample_std .* sqrt(detector_counts./detector_counts_no_dtc);
    clear detector_counts_no_dtc;
    
    % Next, we'll determine a corrected background from the deadtime corrected rate.  
    % disp(['Calculating new background.']);
    for i = 1:col
        bkgnd_lb = 1 + floor(0.05*time_zero_bin(i));
        bkgnd_ub = floor(0.95*time_zero_bin(i));    
        bkgnd(i) = mean(detector_counts(bkgnd_lb:bkgnd_ub,i));
    end;
    
    % Get a measure of the expected statistical noise in the measurement by taking the corrected count rate, 
    % converting to a corrected total counts (by mulitplying by accumulates, samples, and bin_resolution)
    % and take the sqrt of the total counts.  This noise measure is essentially a "total" noise measure.  It 
    % is then normalized back to an "effective noise rate" in Hz. 
    % disp(['Calculating noise and normalizing it.']);
    noise = zeros([row,col]);
    for i = 1:col
        if (min(detector_counts(:,i)<=0)); 
            disp('Hey, detector_counts is zero!'); 
            pause; 
        end;
        noise(:,i) = sqrt(detector_counts(:,i) * (accumulates * bin_resolution * samples(i)));
        noise(:,i) = noise(:,i)/(accumulates * bin_resolution * samples(i));
    end;
    
    under_range = find(range <= 0);
    range(under_range) = -1;
    r2 = range .* range;
    signal = zeros([row,col]);
    signal_log = zeros([row,col]);
    
    % Now create two parallel representations of the profile:
    % The first representation is background-subtracted and range-corrected.  It is perhaps the most
    % pedagogically accurate representation since the range-squared accounts for signal attenuation due 
    % scattering into an angle, but it also under-represents signal in the near range since an overlap 
    % correction has not been applied. 
    %
    % During the range-correction, the noise and sample_std fields will also be normalized to say on par 
    % the signal.
    %
    % Thus, an alternative logarithmic representation is also generated for display purposes.  This log
    % approach approximately accounts for signal attenuation due to extinction and the pressure profile.
    % It will tend to under-represent high altitude since range-squared losses aren't recovered. 
    % disp(['Doing background subtraction and applying range-correction.']);
    for i = 1:col
        signal(:,i) = (detector_counts(:,i) - bkgnd(i));
        signal(:,i) = signal(:,i) .* r2';
        noise(:,i) = noise(:,i) .* r2';
        sample_std(:,i) = sample_std(:,i) .*r2';
    end;
    % disp(['Normalizing profiles for laser power.']);
    %Normalize for laser power
    for i = 1:col
        if (optical_power_532nm(i) <= 1); optical_power_532nm(i) = 1; end
        signal(:,i) = signal(:,i) / optical_power_532nm(i);
        noise(:,i) = noise(:,i) / optical_power_532nm(i);
        sample_std(:,i) = sample_std(:,i) / optical_power_532nm(i);   
    end
    
    % disp(['Calculating SNR for background-subtracted, range-corrected , energy-normalized profiles.']);
    signal_SNR = signal ./ noise;
    
    % disp(['Doing logarithmic processing...']);
    for i = 1:col
        %following step subtracts most (but not all of the bkbnd) retaining a positive definite value.
        signal_log(:,i) = log(detector_counts(:,i) - 0.99*min(detector_counts(:,i)));
        signal_log(:,i) = signal_log(:,i) - mean(signal_log(bkgnd_lb:bkgnd_ub,i));
    end;
    
    clear detector_counts;
    disp(['Done with detector A processing.  Writing data to netcdf file...']);
    
    [ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', cdfid);
    [name, datatype, ndims, dims, natts, status] = ncmex('VARINQ', cdfid, 'detector_A_532nm');
    [status]  = ncmex('REDEF',cdfid);
    
    %Define 'copol_532nm'  
    status = ncmex('VARDEF', cdfid, 'copol_532nm', 'NC_DOUBLE', ndims, dims);
    value = 'Copolarized elastic backscatter at 532nm';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm', 'long_name', 'NC_CHAR', length(value), value);
    value = '(Hz)*(m^2)/(microjoule)';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm', 'units', 'NC_CHAR', length(value), value);
    value = 'deadtime-corrected, background-subtracted, range-corrected, energy-normalized';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm', 'corrections_applied', 'NC_CHAR', length(value), value);
    
    %Define 'copol_532nm_log'
    status = ncmex('VARDEF', cdfid, 'copol_532nm_log', 'NC_DOUBLE', ndims, dims);
    value = 'Natural log of copolarized elastic backscatter return per bin per averaging interval.';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'long_name', 'NC_CHAR', length(value), value);
    value = 'The following three-part background suppression has process has been applied:';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'Corrections', 'NC_CHAR', length(value), value);
    value = 'First part (prior to the log) is subtraction of 99% of the minimum value';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'bkgnd_part_1', 'NC_CHAR', length(value), value);
    value = 'Second part, take the natural log of the remaining signal from above.';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'bkgnd_part_2', 'NC_CHAR', length(value), value);
    value = 'Third part (after the log) is subtraction of middle 90% of the bins preceding the laser pulse.';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'bkgnd_part_3', 'NC_CHAR', length(value), value);
    value = 'log(Hz)';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm_log', 'units', 'NC_CHAR', length(value), value);
    
    %Define 'detector_A_532nm_noise'
    status = ncmex('VARDEF', cdfid, 'detector_A_532nm_noise', 'NC_DOUBLE', ndims, dims);
    value = 'Expected statistical noise of the 532nm detector A.';
    status = ncmex('ATTPUT', cdfid, 'detector_A_532nm_noise', 'long_name', 'NC_CHAR', length(value), value);
    value = 'This value is based on the sqrt of the total detected counts.';
    status = ncmex('ATTPUT', cdfid, 'detector_A_532nm_noise', 'description', 'NC_CHAR', length(value), value);
    value = '(Hz)*(m^2)/(microjoule)';
    status = ncmex('ATTPUT', cdfid, 'detector_A_532nm_noise', 'units', 'NC_CHAR', length(value), value);
    
    %Define 'copol_532nm_SNR'
    status = ncmex('VARDEF', cdfid, 'copol_532nm_SNR', 'NC_DOUBLE', ndims, dims);
    value = 'SNR of copolarized elastic backscatter at 532nm';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm_SNR', 'long_name', 'NC_CHAR', length(value), value);
    value = 'calculated as copol_532nm / detector_A_532nm_noise';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm_SNR', 'description', 'NC_CHAR', length(value), value);
    value = 'Unitless';
    status = ncmex('ATTPUT', cdfid, 'copol_532nm_SNR', 'units', 'NC_CHAR', length(value), value);     
    
    %Update attributes of detector_A_532nm_std
    value = 'deadtime corrected, scaled on par with copol_532nm';
    status = ncmex('ATTPUT', cdfid, 'detector_A_532nm_std', 'corrections_applied', 'NC_CHAR', length(value), value);
    
    %Update attributes of detector_A_532nm_bkgnd
    value = 'deadtime corrected, scaled to Hz';
    status = ncmex('ATTPUT', cdfid, 'detector_A_532nm_bkgnd', 'corrections_applied', 'NC_CHAR', length(value), value);
    
    [status]  = ncmex('ENDEF',cdfid);
    if (status < 0) 
        disp(['error with endef' ]);  end;
    
    % initial vectors: bkgnd (non-dtc)
    % initial matrices: detector_counts, sample_std
    % remaining matrices: % signal, signal_log, noise, signal_SNR
    % remaining vectors: bkgnd (dtc)
    % remaining scalar: detector_A, role as copol, apd sn, tablecurve eqn, coefficients, note regarding saturation
    %
    
    status = ncmex('VARPUT', cdfid, 'copol_532nm', [0,0], [-1,-1], signal);
    status = ncmex('VARPUT', cdfid, 'copol_532nm_log', [0,0], [-1,-1], signal_log);
    status = ncmex('VARPUT', cdfid, 'copol_532nm_SNR', [0,0], [-1,-1], signal_SNR);
    status = ncmex('VARPUT', cdfid, 'detector_A_532nm_std', [0,0], [-1,-1], sample_std);
    status = ncmex('VARPUT', cdfid, 'detector_A_532nm_noise', [0,0], [-1,-1], noise);
    status = ncmex('VARPUT', cdfid, 'detector_A_532nm_bkgnd', [0], [-1], bkgnd);
    
    bkgnd_A = bkgnd;
    clear signal signal_log signal_SNR sample_std noise bkgnd;
    
    disp(['Done writing detector A and copol data to file...']);
    
    % get detector_B (depol)
    disp(['Beginning detector_B processing...']);
    
    % disp(['Getting detector counts and sample std dev.']);
    [detector_counts, status] = nc_getvar(cdfid, 'detector_B_532nm');
    if (status < 0) ; disp(['error getting ''detector_B_532nm'' from netcdf file' ]); pause; end;
    [sample_std, status] = nc_getvar(cdfid, 'detector_B_532nm_std');
    if (status < 0) ; disp(['error getting ''detector_B_532nm_std'' from netcdf file' ]); pause; end;
    [row,col] = size(detector_counts);
    bkgnd = zeros(1,col);
    
    % normalize detected counts against samples, accumulates, and bin_resolution to get a count rate in Hz.
    % disp(['Normalizing to get count rate in Hz.']);
    for i = 1:col
        bkgnd_lb = 1 + floor(0.05*time_zero_bin(i));
        bkgnd_ub = floor(0.95*time_zero_bin(i));
        bkgnd(i) = mean(detector_counts(bkgnd_lb:bkgnd_ub,i));
        if (bkgnd(i)<=0);
            disp(['Mean of the ' i 'th background is less than or equal to zero!.  Detector problem?!?']);
            pause;
        end;
        % The following step adds an essentially insignificant offset to each profile, thus ensuring 
        % positive-definite values unless mean is actually zero in which case we have a problem
        detector_counts(:,i) = detector_counts(:,i) + 1e-7 * bkgnd(i);
        detector_counts(:,i) = detector_counts(:,i) / (accumulates * bin_resolution * samples(i));
        if (min(detector_counts(:,i)<=0)); 
            disp('Hey, detector_counts is zero!'); 
            pause; 
        end;
        %Also normalize the sample std 
        sample_std(:,i) = sample_std(:,i)/ (accumulates * bin_resolution * samples(i));
    end;
    
    % disp(['Applying deadtime correction...']);
    
    %apply deadtime correction to the detected count rate
    % y=(a+cx+ex^2)/(1+bx+dx^2) from TableCurve best fit to Perkin-Elmer data for APD SN6850
    a =    0.155196322; 
    b =   -0.06110694 ;
    c =   0.957085978 ;
    d =   7.75267e-05 ;
    e =   -0.05769580 ;
    
    detector_counts_no_dtc = detector_counts; 
    X = log(detector_counts);
    detector_counts = exp((a + c*X +e*X.*X)./(1 + b*X + d*X.*X));
    clear X;
    
    % Detector_counts is now a dead-time corrected count rate. 
    % We dtc the observed sample deviations with the sqrt of the ratio of the new and old count rates 
    % disp(['Correcting sample std dev for deadtime...']);
    sample_std = sample_std .* sqrt(detector_counts./detector_counts_no_dtc);
    clear detector_counts_no_dtc;
    
    % Next, we'll determine a corrected background from the deadtime corrected rate.  
    % disp(['Calculating new background.']);
    for i = 1:col
        if (min(detector_counts(:,i)<=0)); 
            disp('Hey, detector_counts is zero!'); 
            pause; 
        end;
        bkgnd_lb = 1 + floor(0.05*time_zero_bin(i));
        bkgnd_ub = floor(0.95*time_zero_bin(i));    
        bkgnd(i) = mean(detector_counts(bkgnd_lb:bkgnd_ub,i));
        if (bkgnd(i)<= 0); disp(['Oh oh, non-positive backgrounds...']);end
    end;
    
    % Get a measure of the expected statistical noise in the measurement by taking the corrected count rate, 
    % converting to a corrected total counts (by mulitplying by accumulates, samples, and bin_resolution)
    % and take the sqrt of the total counts.  This noise measure is essentially a "total" noise measure.  It 
    % is then normalized back to an "effective noise rate" in Hz. 
    % disp(['Calculating noise and normalizing it.']);
    noise = zeros([row,col]);
    for i = 1:col
        noise(:,i) = sqrt(detector_counts(:,i) * (accumulates * bin_resolution * samples(i)));
        noise(:,i) = noise(:,i)/(accumulates * bin_resolution * samples(i));
    end;
    
    under_range = find(range <= 0);
    range(under_range) = -1;
    r2 = range .* range;
    signal = zeros([row,col]);
    signal_log = zeros([row,col]);
    
    % Now create two parallel representations of the profile:
    % The first representation is background-subtracted and range-corrected.  It is perhaps the most
    % pedagogically accurate representation since the range-squared accounts for signal attenuation due 
    % scattering into an angle, but it also under-represents signal in the near range since an overlap 
    % correction has not been applied. 
    %
    % During the range-correction, the noise and sample_std fields will also be normalized to say on par 
    % the signal.
    %
    % Thus, an alternative logarithmic representation is also generated for display purposes.  This log
    % approach approximately accounts for signal attenuation due to extinction and the pressure profile.
    % It will tend to under-represent high altitude since range-squared losses aren't recovered. 
    % disp(['Doing background subtraction and applying range-correction.']);
    for i = 1:col
        signal(:,i) = (detector_counts(:,i) - bkgnd(i));
        signal(:,i) = signal(:,i) .* r2';
        noise(:,i) = noise(:,i) .* r2';
        sample_std(:,i) = sample_std(:,i) .*r2';
    end;
    % disp(['Normalizing profiles for laser power.']);
    %Normalize for laser power
    for i = 1:col
        if (optical_power_532nm(i) <= 1); optical_power_532nm(i) = 1; end
        signal(:,i) = signal(:,i) / optical_power_532nm(i);
        noise(:,i) = noise(:,i) / optical_power_532nm(i);
        sample_std(:,i) = sample_std(:,i) / optical_power_532nm(i);   
    end
    
    % disp(['Calculating SNR for background-subtracted, range-corrected , energy-normalized profiles.']);
    signal_SNR = signal ./ noise;
    
    % disp(['Doing logarithmic processing...']);
    for i = 1:col
        %following step subtracts most (but not all of the bkbnd) retaining a positive definite value.
        signal_log(:,i) = log(detector_counts(:,i) - 0.99*min(detector_counts(:,i)));
        signal_log(:,i) = signal_log(:,i) - mean(signal_log(bkgnd_lb:bkgnd_ub,i));
    end;
    
    clear detector_counts;
    
    bkgnd_A_by_bkgnd_B = bkgnd_A ./ bkgnd;
    
    disp(['Done with detector B processing.  Writing data to netcdf file...']);
    
    [ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', cdfid);
    [name, datatype, ndims, dims, natts, status] = ncmex('VARINQ', cdfid, 'detector_A_532nm');
    [status]  = ncmex('REDEF',cdfid);
    
    %Define 'depol_532nm'  
    status = ncmex('VARDEF', cdfid, 'depol_532nm', 'NC_DOUBLE', ndims, dims);
    value = 'Depolarized elastic backscatter at 532nm';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm', 'long_name', 'NC_CHAR', length(value), value);
    value = '(Hz)*(m^2)/(microjoule)';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm', 'units', 'NC_CHAR', length(value), value);
    value = 'deadtime-corrected, background-subtracted, range-corrected, energy-normalized';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm', 'corrections_applied', 'NC_CHAR', length(value), value);
    
    %Define 'depol_532nm_log'
    status = ncmex('VARDEF', cdfid, 'depol_532nm_log', 'NC_DOUBLE', ndims, dims);
    value = 'Natural Log of depolarized elastic backscatter return per bin per averaging interval.';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'long_name', 'NC_CHAR', length(value), value);
    value = 'The following three-part background suppression has process has been applied:';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'Corrections', 'NC_CHAR', length(value), value);
    value = 'First part (prior to the log) is subtraction of 99% of the minimum value';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'bkgnd_part_1', 'NC_CHAR', length(value), value);
    value = 'Second part, take the natural log of the remaining signal from above.';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'bkgnd_part_2', 'NC_CHAR', length(value), value);
    value = 'Third part (after the log) is subtraction of middle 90% of the bins preceding the laser pulse.';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'bkgnd_part_3', 'NC_CHAR', length(value), value);
    value = 'log(Hz)';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm_log', 'units', 'NC_CHAR', length(value), value);
    
    %Define 'detector_B_532nm_noise'
    status = ncmex('VARDEF', cdfid, 'detector_B_532nm_noise', 'NC_DOUBLE', ndims, dims);
    value = 'Expected statistical noise of the 532nm detector B.';
    status = ncmex('ATTPUT', cdfid, 'detector_B_532nm_noise', 'long_name', 'NC_CHAR', length(value), value);
    value = 'This value is based on the sqrt of the total detected counts.';
    status = ncmex('ATTPUT', cdfid, 'detector_B_532nm_noise', 'description', 'NC_CHAR', length(value), value);
    value = '(Hz)*(m^2)/(microjoule)';
    status = ncmex('ATTPUT', cdfid, 'detector_B_532nm_noise', 'units', 'NC_CHAR', length(value), value);
    
    %Define 'depol_532nm_SNR'
    status = ncmex('VARDEF', cdfid, 'depol_532nm_SNR', 'NC_DOUBLE', ndims, dims);
    value = 'SNR of depolarized elastic backscatter at 532nm';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm_SNR', 'long_name', 'NC_CHAR', length(value), value);
    value = 'calculated as depol_532nm / detector_B_532nm_noise';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm_SNR', 'description', 'NC_CHAR', length(value), value);
    value = 'Unitless';
    status = ncmex('ATTPUT', cdfid, 'depol_532nm_SNR', 'units', 'NC_CHAR', length(value), value);     
    
    %[status] = ncmex['ENDEF', cdfid);    
    [name, datatype, ndims, dims, natts, status] = ncmex('VARINQ', cdfid, 'detector_B_532nm_bkgnd');
    %[status]  = ncmex('REDEF',cdfid);
    
    %Define 'bkgnd_A_by_bkgnd_B'
    status = ncmex('VARDEF', cdfid, 'bkgnd_A_by_bkgnd_B', datatype, ndims, dims);
    value = 'Ratio of background at 532nm from detector A to detector B.';
    status = ncmex('ATTPUT', cdfid, 'bkgnd_A_by_bkgnd_B', 'long_name', 'NC_CHAR', length(value), value);
    value = 'calculated as detector_A_532nm_bkgnd / detector_B_532nm_bkgnd';
    status = ncmex('ATTPUT', cdfid, 'bkgnd_A_by_bkgnd_B', 'description', 'NC_CHAR', length(value), value);
    value = 'Unitless';
    status = ncmex('ATTPUT', cdfid, 'bkgnd_A_by_bkgnd_B', 'units', 'NC_CHAR', length(value), value);     
    
    %Update attributes of detector_B_532nm_std
    value = 'deadtime corrected, scaled on par with depol_532nm';
    status = ncmex('ATTPUT', cdfid, 'detector_B_532nm_std', 'corrections_applied', 'NC_CHAR', length(value), value);
    
    %Update attributes of detector_B_532nm_bkgnd
    value = 'deadtime corrected, scaled to Hz';
    status = ncmex('ATTPUT', cdfid, 'detector_B_532nm_bkgnd', 'corrections_applied', 'NC_CHAR', length(value), value);
    
    [status]  = ncmex('ENDEF',cdfid);
    if (status < 0) 
        disp(['error with endef' ]);  end;
    
    % remaining scalar: detector_B, role as depol, apd sn, tablecurve eqn, coefficients, note regarding saturation
    %
    
    status = ncmex('VARPUT', cdfid, 'depol_532nm', [0,0], [-1,-1], signal);
    status = ncmex('VARPUT', cdfid, 'depol_532nm_log', [0,0], [-1,-1], signal_log);
    status = ncmex('VARPUT', cdfid, 'depol_532nm_SNR', [0,0], [-1,-1], signal_SNR);
    status = ncmex('VARPUT', cdfid, 'detector_B_532nm_std', [0,0], [-1,-1], sample_std);
    status = ncmex('VARPUT', cdfid, 'detector_B_532nm_noise', [0,0], [-1,-1], noise);
    status = ncmex('VARPUT', cdfid, 'detector_B_532nm_bkgnd', [0], [-1], bkgnd);
    status = ncmex('VARPUT', cdfid, 'bkgnd_A_by_bkgnd_B', [0], [-1], bkgnd_A_by_bkgnd_B);
    
    clear signal signal_log signal_SNR sample_std noise bkgnd bkgnd_A bkgnd_A_by_bkgnd_B;
    
    disp(['Done writing detector B and depol data to file...']);
    
    %Update data_level value
    status = nc_putvar(cdfid, 'data_level', 31);
    
    %Get history global attribute, add update, write to file. 
    att_name = 'history';
    [value,status] = ncmex('ATTGET', cdfid, 'NC_GLOBAL', att_name);
    new_value = blanks(80);
    in_str = [datestr(now,31) ' :  Promoted to 31; zero ranged, dtc, bkgnd, r2, log',10];
    new_value(1:length(in_str)) = in_str;
    value = strvcat(value, new_value); 
    [status] = ncmex('REDEF', cdfid);
    status = ncmex('ATTPUT', cdfid, 'NC_GLOBAL', att_name, 2, size(value,1)*size(value,2), value' );
    [status] = ncmex('ENDEF', cdfid);
    if status < 0;
        disp([':' att_name, ' NOT sucessfully defined.']);
    end;
    
    %%

    %%
    disp(['Closing netcdf file.']);
    status = ncmex('CLOSE', cdfid);
end;
