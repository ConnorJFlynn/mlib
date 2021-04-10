function dtc = dtc_34184(MHz);
% for miniMPL at Christchurch, NZ
dtc_col_1 = [0 19.4, 48.3, 121.0 303.9 749.5 1832.5 2804.9 4285.1 6381.1 9060.7];
dtc_col_1 = [dtc_col_1, 10629.1 12579.1 14657.4 16578.5 18760, 20646.9];
dtc_col_1 = [dtc_col_1, 22549.2 24819.3 26746.9 28420.3 29952.2 31394.2];
dtc_col_1 = [dtc_col_1, 32527.2 33577.3 34577.5];
dtc_col_2 = [1 1 1.01 1.01 1.01 1.03 1.06 1.1 1.14 1.21 1.35 1.42 1.53 1.67 1.84 2.06];
dtc_col_2 = [dtc_col_2 2.34 2.71 3.11 3.63 4.31 5.14 6.18 7.48 9.12 11.16];
dtc_table = [dtc_col_1', dtc_col_2'];
dtc_table(:,1) = dtc_table(:,1)./1000; % Converted raw Kcts to MHz

% Very hard to read some of the numbers 5, 6 8
% To reduce likelihood of transcription error, I checked the values above 
% Against the vendor-supplied polynomial.  Looks good to within 2%
% Hand-checked couple of marginal outliers but transcription is good
%test_dtc = polyval(double(ap_hex.vdata.dt_coeff),1000.*dtc_table(:,1));

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