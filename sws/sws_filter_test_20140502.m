function sws_filt = sws_filter_test_20140502
%

% the idea is to load one filter at a time (LP, starting with longest) and
% determine stray light due to the limited spectral range.
% Then load successive filters, subtract effect of first filter, and
% proceed.
% Not obvious yet how or whether to use "open" filters.

%Here's what I think we want to do:
% Compute the dark-subtracted rate.
% Normalize versus the max value.
% Identify a wavelength region that should be corrected based on the value
% of measured spectra at this lambda max. Extend this region over the
% entire spectrometer range trending to zero near the peak wavelength and
% above.  So it is a heavyside function, more or less.

% Then load the next filter.  Subtract the normalized filter(s) at longer wavelengths
% Then identify
% For Silicon
% LP 780 03:17:04
[pname] = [fileparts(mfilename('fullpath')),filesep];
if exist([pname, 'sws_LP_780.mat'],'file')
    sws_LP_780 = load([pname, 'sws_LP_780.mat']);
else
    sws_LP_780 = read_sws_raw_2(getfullname__('*031704*.dat','sws_raw','Select SWS file for LP RG780'));
    [peak, sws_LP_780.max_ii] = max(mean(sws_LP_780.Si_rate,2));
    
    % rg_780 drawn from Schott glass table.
    Tr_780 = rg_780;
%     figure; semilogy(sws_LP_780.Si_lambda, mean(sws_LP_780.Si_rate,2)./peak, '-', Tr_780.nm, Tr_780.Tr, 'k-');
    sws_LP_780.Tr = interp1(Tr_780.nm, Tr_780.Tr,sws_LP_780.Si_lambda,'linear');

    
    figure; semilogy(sws_LP_780.Si_lambda, mean(sws_LP_780.Si_rate,2)./peak, '-', sws_LP_780.Si_lambda, 0.85.*sws_LP_780.Tr, 'k-');
    legend('Filter leakage','Schott Tr');
    
    figure; semilogy(sws_LP_780.Si_lambda, mean(sws_LP_780.Si_rate,2)./peak - 0.85.*sws_LP_780.Tr, 'k-');

    save([pname, 'sws_LP_780.mat'],'-struct','sws_LP_780');
end
filt.Si_lambda = sws_LP_780.Si_lambda;
filt.RG780_max_ii = sws_LP_780.max_ii;
filt.RG780_band = mean(sws_LP_780.Si_rate,2)./max(mean(sws_LP_780.Si_rate,2));
filt.RG780_Tr = sws_LP_780.Tr;
figure; semilogy(filt.Si_lambda, filt.RG780_band - 0.85.*filt.RG780_Tr, 'k-');zoom('on')
OK = menu('Zoom to select limited region for stray light.','Done');
    xl = xlim;
    stray_ = filt.Si_lambda>= xl(1) & filt.Si_lambda<=xl(2);
    [P,S] = polyfit(filt.Si_lambda(stray_), filt.RG780_band(stray_) - filt.RG780_Tr(stray_), 2)
semilogy(filt.Si_lambda, filt.RG780_band - filt.RG780_Tr, 'k-',filt.Si_lambda(1:filt.RG780_max_ii), polyval(P,filt.Si_lambda(1:filt.RG780_max_ii), S),'r-')

!!
%sws_LP_715 = bundle_sws_raw_2;
if exist([pname, 'sws_LP_715.mat'],'file')
    sws_LP_715 = load([pname, 'sws_LP_715.mat']);
else
    sws_LP_715 = read_sws_raw_2(getfullname__('*0314*.dat','sws_raw','Select SWS file for LP RG715'));
    [peak, sws_LP_715.max_ii] = max(mean(sws_LP_715.Si_rate,2));
    
    % rg_715 drawn from Schott glass table.
    Tr_715 = rg_715;
%     figure; semilogy(sws_LP_715.Si_lambda, mean(sws_LP_715.Si_rate,2)./peak, '-', Tr_715.nm, Tr_715.Tr, 'k-');
    sws_LP_715.Tr = interp1(Tr_715.nm-1.5, Tr_715.Tr,sws_LP_715.Si_lambda,'linear');
    
    figure; semilogy(sws_LP_715.Si_lambda, mean(sws_LP_715.Si_rate,2)./peak, '-', sws_LP_715.Si_lambda, sws_LP_715.Tr, 'k-');
    legend('Filter leakage','Schott RG715 Tr');
    
%     figure; semilogy(sws_LP_715.Si_lambda, mean(sws_LP_715.Si_rate,2)./peak - sws_LP_715.Tr, 'k-');
    % Looks like less than 650 or so is a reasonable limit.  Have to look at
    % Schott glass transmittance table.
    save([pname, 'sws_LP_715.mat'],'-struct','sws_LP_715');
end
RG715_band = mean(sws_LP_715.Si_rate,2);
% 0.92 scaling used to avoid driving negative.
RG715_sub_band = RG715_band - 0.85*filt.RG780_band.*(RG715_band(filt.RG780_max_ii));
[peak, sub_max_ii] = max(RG715_sub_band);
figure; semilogy(filt.Si_lambda, RG715_band/peak, 'k-',filt.Si_lambda, RG715_sub_band./peak, 'b-', filt.Si_lambda, sws_LP_715.Tr,'r-')
!!
figure; semilogy(filt.Si_lambda, RG715_sub_band./peak - sws_LP_715.Tr,'r-'); zoom('on');

    xl = xlim;
    stray_ = filt.Si_lambda>= xl(1) & filt.Si_lambda<=xl(2);
    [P2,S2] = polyfit(filt.Si_lambda(stray_), RG715_sub_band(stray_)./peak - sws_LP_715.Tr(stray_), 2);

%sws_LP_610 = bundle_sws_raw_2;
if exist([pname, 'sws_LP_610.mat'],'file')
    sws_LP_610 = load([pname, 'sws_LP_610.mat']);
else
    sws_LP_610 = read_sws_raw_2(getfullname__('*0311*.dat','sws_raw','Select SWS file for LP RG610'));
    [peak, sws_LP_610.max_ii] = max(mean(sws_LP_610.Si_rate,2));
    
    % rg_610 drawn from Schott glass table.
    Tr_610 = rg_610;
%     figure; semilogy(sws_LP_610.Si_lambda, mean(sws_LP_610.Si_rate,2)./peak, '-', Tr_610.nm, Tr_610.Tr, 'k-');
    sws_LP_610.Tr = interp1(Tr_610.nm, Tr_610.Tr,sws_LP_610.Si_lambda,'linear');
    
    figure; semilogy(sws_LP_610.Si_lambda, mean(sws_LP_610.Si_rate,2)./peak, '-', sws_LP_610.Si_lambda, sws_LP_610.Tr, 'k-');
    legend('Filter leakage','Schott Tr');
    
    figure; semilogy(sws_LP_610.Si_lambda, mean(sws_LP_610.Si_rate,2)./peak - sws_LP_610.Tr, 'k-');
    % Looks like less than 650 or so is a reasonable limit.  Have to look at
    % Schott glass transmittance table.
    save([pname, 'sws_LP_610.mat'],'-struct','sws_LP_610');
end
!!
% 570 16:47
!!

if exist([pname, 'sws_LP_570.mat'],'file')
    sws_LP_570 = load([pname, 'sws_LP_570.mat']);
else
    sws_LP_570 = read_sws_raw_2(getfullname__('*0308*.dat','sws_raw','Select SWS file for LP RG570'));
    [peak, sws_LP_570.max_ii] = max(mean(sws_LP_570.Si_rate,2));
    
    % rg_570 drawn from Schott glass table.
    Tr_570 = og_570;
%     figure; semilogy(sws_LP_570.Si_lambda, mean(sws_LP_570.Si_rate,2)./peak, '-', Tr_570.nm, Tr_570.Tr, 'k-');
    sws_LP_570.Tr = interp1(Tr_570.nm, Tr_570.Tr,sws_LP_570.Si_lambda,'linear');
    
    figure; semilogy(sws_LP_570.Si_lambda, mean(sws_LP_570.Si_rate,2)./peak, '-', sws_LP_570.Si_lambda, sws_LP_570.Tr, 'k-');
    legend('Filter leakage','Schott Tr');
    
    figure; semilogy(sws_LP_570.Si_lambda, mean(sws_LP_570.Si_rate,2)./peak - sws_LP_570.Tr, 'k-');
    % Looks like less than 650 or so is a reasonable limit.  Have to look at
    % Schott glass transmittance table.
    save([pname, 'sws_LP_570.mat'],'-struct','sws_LP_570');
end
!!
% 550 16:41
!!

if exist([pname, 'sws_LP_550.mat'],'file')
    sws_LP_550 = load([pname, 'sws_LP_550.mat']);
else
    sws_LP_550 = read_sws_raw_2(getfullname__('*0304*.dat','sws_raw','Select SWS file for LP RG550'));
    [peak, sws_LP_550.max_ii] = max(mean(sws_LP_550.Si_rate,2));
    
    % rg_550 drawn from Schott glass table.
    Tr_550 = og_550;
%     figure; semilogy(sws_LP_550.Si_lambda, mean(sws_LP_550.Si_rate,2)./peak, '-', Tr_550.nm, Tr_550.Tr, 'k-');
    sws_LP_550.Tr = interp1(Tr_550.nm, Tr_550.Tr,sws_LP_550.Si_lambda,'linear');
    
    figure; semilogy(sws_LP_550.Si_lambda, mean(sws_LP_550.Si_rate,2)./peak, '-', sws_LP_550.Si_lambda, sws_LP_550.Tr, 'k-');
    legend('Filter leakage','Schott Tr');
    
    figure; semilogy(sws_LP_550.Si_lambda, mean(sws_LP_550.Si_rate,2)./peak - sws_LP_550.Tr, 'k-');
    % Looks like less than 650 or so is a reasonable limit.  Have to look at
    % Schott glass transmittance table.
    save([pname, 'sws_LP_550.mat'],'-struct','sws_LP_550');
end
!!
% 495 16:33
!!

if exist([pname, 'sws_LP_495.mat'],'file')
    sws_LP_495 = load([pname, 'sws_LP_495.mat']);
else
    sws_LP_495 = read_sws_raw_2(getfullname__('*0302*.dat','sws_raw','Select SWS file for LP RG495'));
    [peak, sws_LP_495.max_ii] = max(mean(sws_LP_495.Si_rate,2));
    
    % rg_495 drawn from Schott glass table.
    Tr_495 = gg_495;
%     figure; semilogy(sws_LP_495.Si_lambda, mean(sws_LP_495.Si_rate,2)./peak, '-', Tr_495.nm, Tr_495.Tr, 'k-');
    sws_LP_495.Tr = interp1(Tr_495.nm, Tr_495.Tr,sws_LP_495.Si_lambda,'linear');
    
    figure; semilogy(sws_LP_495.Si_lambda, mean(sws_LP_495.Si_rate,2)./peak, '-', sws_LP_495.Si_lambda, sws_LP_495.Tr, 'k-');
    legend('Filter leakage','Schott Tr');
    
    figure; semilogy(sws_LP_495.Si_lambda, mean(sws_LP_495.Si_rate,2)./peak - sws_LP_495.Tr, 'k-');
    % Looks like less than 650 or so is a reasonable limit.  Have to look at
    % Schott glass transmittance table.
    save([pname, 'sws_LP_495.mat'],'-struct','sws_LP_495');
end
!!
!!

if exist([pname, 'sws_LP_455.mat'],'file')
    sws_LP_455 = load([pname, 'sws_LP_455.mat']);
else
    sws_LP_455 = read_sws_raw_2(getfullname__('*0259*.dat','sws_raw','Select SWS file for LP RG455'));
    [peak, sws_LP_455.max_ii] = max(mean(sws_LP_455.Si_rate,2));
    
    % rg_455 drawn from Schott glass table.
    Tr_455 = gg_455;
%     figure; semilogy(sws_LP_455.Si_lambda, mean(sws_LP_455.Si_rate,2)./peak, '-', Tr_455.nm, Tr_455.Tr, 'k-');
    sws_LP_455.Tr = interp1(Tr_455.nm, Tr_455.Tr,sws_LP_455.Si_lambda,'linear');
    
    figure; semilogy(sws_LP_455.Si_lambda, mean(sws_LP_455.Si_rate,2)./peak, '-', sws_LP_455.Si_lambda, sws_LP_455.Tr, 'k-');
    legend('Filter leakage','Schott Tr');
    
    figure; semilogy(sws_LP_455.Si_lambda, mean(sws_LP_455.Si_rate,2)./peak - sws_LP_455.Tr, 'k-');
    % Looks like less than 650 or so is a reasonable limit.  Have to look at
    % Schott glass transmittance table.
    save([pname, 'sws_LP_455.mat'],'-struct','sws_LP_455');
end
% 395 16:20
!!

if exist([pname, 'sws_LP_395.mat'],'file')
    sws_LP_395 = load([pname, 'sws_LP_395.mat']);
else
    sws_LP_395 = read_sws_raw_2(getfullname__('*0256*.dat','sws_raw','Select SWS file for LP RG395'));
    [peak, sws_LP_395.max_ii] = max(mean(sws_LP_395.Si_rate,2));
    
    % rg_395 drawn from Schott glass table.
    Tr_395 = gg_395;
%     figure; semilogy(sws_LP_395.Si_lambda, mean(sws_LP_395.Si_rate,2)./peak, '-', Tr_395.nm, Tr_395.Tr, 'k-');
    sws_LP_395.Tr = interp1(Tr_395.nm, Tr_395.Tr,sws_LP_395.Si_lambda,'linear');
    
    figure; semilogy(sws_LP_395.Si_lambda, mean(sws_LP_395.Si_rate,2)./peak, '-', sws_LP_395.Si_lambda, sws_LP_395.Tr, 'k-');
    legend('Filter leakage','Schott Tr');
    
    figure; semilogy(sws_LP_395.Si_lambda, mean(sws_LP_395.Si_rate,2)./peak - sws_LP_395.Tr, 'k-');
    % Looks like less than 650 or so is a reasonable limit.  Have to look at
    % Schott glass transmittance table.
    save([pname, 'sws_LP_395.mat'],'-struct','sws_LP_395');
end


%BG38 15:45
!!

if exist([pname, 'sws_SP_KG5.mat'],'file')
    sws_SP_KG5 = load([pname, 'sws_SP_KG5.mat']);
else
    sws_SP_KG5 = read_sws_raw_2(getfullname__('*0250*.dat','sws_raw','Select SWS file for LP RG395'));
    [peak, sws_SP_KG5.max_ii] = max(mean(sws_SP_KG5.Si_rate,2));
    
    % rg_395 drawn from Schott glass table.
    Tr_kg5 = kg5;
%     figure; semilogy(sws_SP_KG5.Si_lambda, mean(sws_SP_KG5.Si_rate,2)./peak, '-', Tr_kg5.nm, Tr_kg5.Tr, 'k-');
    sws_SP_KG5.Tr = interp1(Tr_kg5.nm, Tr_kg5.Tr,sws_SP_KG5.Si_lambda,'linear');
    
    figure; semilogy(sws_SP_KG5.Si_lambda, mean(sws_SP_KG5.Si_rate,2)./peak, '-', sws_SP_KG5.Si_lambda, sws_SP_KG5.Tr, 'k-');
    legend('Filter leakage','Schott Tr');
    
    figure; semilogy(sws_SP_KG5.Si_lambda, mean(sws_SP_KG5.Si_rate,2)./peak - sws_SP_KG5.Tr, 'k-');
    % Looks like less than 650 or so is a reasonable limit.  Have to look at
    % Schott glass transmittance table.
    save([pname, 'sws_SP_KG5.mat'],'-struct','sws_SP_KG5');
end

%BG40 15:57
!!

if exist([pname, 'sws_SP_BG40.mat'],'file')
    sws_SP_BG40 = load([pname, 'sws_SP_BG40.mat']);
else
    sws_SP_BG40 = read_sws_raw_2(getfullname__('*0247*.dat','sws_raw','Select SWS file for LP RG395'));
    [peak, sws_SP_BG40.max_ii] = max(mean(sws_SP_BG40.Si_rate,2));
    
    % rg_395 drawn from Schott glass table.
    Tr_bg40 = bg40;
%     figure; semilogy(sws_SP_BG40.Si_lambda, mean(sws_SP_BG40.Si_rate,2)./peak, '-', Tr_bg40.nm, Tr_bg40.Tr, 'k-');
    sws_SP_BG40.Tr = interp1(Tr_bg40.nm, Tr_bg40.Tr,sws_SP_BG40.Si_lambda,'linear');
    
    figure; semilogy(sws_SP_BG40.Si_lambda, mean(sws_SP_BG40.Si_rate,2)./peak, '-', sws_SP_BG40.Si_lambda, sws_SP_BG40.Tr, 'k-');
    legend('Filter leakage','Schott BG40 Tr');
    
    figure; semilogy(sws_SP_BG40.Si_lambda, mean(sws_SP_BG40.Si_rate,2)./peak - sws_SP_BG40.Tr, 'k-');
    % Looks like less than 650 or so is a reasonable limit.  Have to look at
    % Schott glass transmittance table.
    save([pname, 'sws_SP_BG40.mat'],'-struct','sws_SP_BG40');
end

%KG5 16:04
!!

if exist([pname, 'sws_SP_BG38.mat'],'file')
    sws_SP_BG38 = load([pname, 'sws_SP_BG38.mat']);
else
    sws_SP_BG38 = read_sws_raw_2(getfullname__('*0244*.dat','sws_raw','Select SWS file for LP RG395'));
    [peak, sws_SP_BG38.max_ii] = max(mean(sws_SP_BG38.Si_rate,2));
    
    % rg_395 drawn from Schott glass table.
    Tr_bg38 = bg38;
%     figure; semilogy(sws_SP_BG38.Si_lambda, mean(sws_SP_BG38.Si_rate,2)./peak, '-', Tr_bg38.nm, Tr_bg38.Tr, 'k-');
    sws_SP_BG38.Tr = interp1(Tr_bg38.nm, Tr_bg38.Tr,sws_SP_BG38.Si_lambda,'linear');
    
    figure; semilogy(sws_SP_BG38.Si_lambda, mean(sws_SP_BG38.Si_rate,2)./peak, '-', sws_SP_BG38.Si_lambda, sws_SP_BG38.Tr, 'k-');
    legend('Filter leakage','Schott BG38 Tr');
    
    figure; semilogy(sws_SP_BG38.Si_lambda, mean(sws_SP_BG38.Si_rate,2)./peak - sws_SP_BG38.Tr, 'k-');
    % Looks like less than 650 or so is a reasonable limit.  Have to look at
    % Schott glass transmittance table.
    save([pname, 'sws_SP_BG38.mat'],'-struct','sws_SP_BG38');
end


%SP 1300 16:13

%LP 1350 17:23
%LP 1200 17:16


%
% For InGaAs
% sws_LP_1350 = bundle_sws_raw_2;
% sws_LP_1200 = bundle_sws_raw_2;
% 
% sws_SP_1300 = bundle_sws_raw_2;
%





return