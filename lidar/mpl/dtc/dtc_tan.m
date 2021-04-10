function dtc = dtc_tan(MHz);

dtc_table = [...
    13.6, 1;
    33.9, 1.01;
    87.1 0.98;
    220.3 0.98;
    542.4 1;
    1332.2 1.02;
    2071.1 1.04;
    3101.2 1.1;
    4550.5 1.19;
    6630.3 1.29;
    9281.0 1.46;
    10855.9 1.58;
    12618.1 1.71; 
    14570.7 1.86; 
    16570.5 2.06;
    18778.5 2.29; 
    20667.1 2.62; 
    23145.1 2.94; 
    25075.1 3.42; 
    27049.1 3.99; 
    28816.7 4.71; 
    30462.6 5.61; 
    31942.1 6.74;
    33147.1 8.18; 
    33964.4 10.05;
    34434.4 12.47];
dtc_table(:,1) = dtc_table(:,1)./1000; % Converted raw Kcts to MHz

max_sig = max(max(MHz));

if max_sig > max(dtc_table(:,1))
    % Generate 2nd order polyfit in log10 in y of last three table values . 
    % (2nd order fit of three points is exact.) 
    % This fit will be used to extrapolate to observed count rates higher
    % than provided in the table.
    [P,~,mu] = polyfit(dtc_table(end-2:end,1), log10(dtc_table(end-2:end,2)),2);
    % Fill in 5 log-spaced values between supplied table and observed max
    top_sigs = 10.^(linspace(log10(dtc_table(end,1)),log10(max_sig),5))'; top_sigs(1) = [];
    
    top_dtc = 10.^(polyval(P,top_sigs,[],mu));
    %     figure; plot([dtc_table(:,1);top_sigs], [dtc_table(:,2);top_dtc], '-x',...
    %         dtc_table(:,1), dtc_table(:,2), 'r-o'); logy;
    tops = [top_sigs,top_dtc];
    dtc_table = [dtc_table; tops];
end
dtc = 10.^interp1(dtc_table(:,1),log10(dtc_table(:,2)),MHz,'linear');
% Handle observed valued < minimum tabled value by setting to unity
dtc(MHz<=dtc_table(1,1)) = 1;

return