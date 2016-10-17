% AML PSAP / TAP experiments

tic; psap_pnl_i = rd_psapi_aml; toc;
P_pnl_flow = psap_pnnl_flow_ref;
pnl_flow_tsi = polyval(P_pnl_flow, psap_pnl_i.flow_sm);
figure; plot(psap_pnl_i.time, [psap_pnl_i.Ba_B_sm, psap_pnl_i.Ba_G_sm, psap_pnl_i.Ba_R_sm],'-');dynamicDateTicks
legend('Ba B sm pnl','Ba G sm pnl','Ba R sm pnl');


tic; psap_aaf_i = rd_psapr_aml; toc;
P_aaf_flow = psap_aaf_flow_ref;
aaf_flow_tsi = polyval(P_aaf_flow, psap_aaf_i.flow_sm);

aaf_flow_corr = psap_aaf_i.flow_sm./aaf_flow_tsi;
figure; plot(psap_aaf_i.time, [psap_aaf_i.Ba_B_sm.*aaf_flow_corr, psap_aaf_i.Ba_G_sm.*aaf_flow_corr, psap_aaf_i.Ba_R_sm.*aaf_flow_corr],'-');dynamicDateTicks
legend('Ba B sm aaf','Ba G sm aaf','Ba R sm aaf');

stap = rd_stap;

flow_tsi = stap_flow_ref(stap.flow_sm);
stap_flow_corr = stap.flow_sm./stap.flow_tsi;
figure; plot(stap.time, [stap.Ba_B_sm.*stap_flow_corr, stap.Ba_G_sm.*stap_flow_corr, stap.Ba_R_sm.*stap_flow_corr],'-');dynamicDateTicks
legend('Ba B sm stap','Ba G sm stap','Ba R sm stap');



tap = rd_tap_tty
tap = rd_tap_bmi_raw;

% aggregate data, copy all AML test data to D drive
raw_taps = getfullname('RAW_TAP_*.dat','tap_tty', 'Select raw BMI TAP files');
done = false; n = 1;
while ~done
    [tap, raw] = rd_tap_bmi_raw(raw_taps{n});
    if isempty(tap)
        n = n+1
    else
        done = true;
    end
end
disp('Done finding first good file.')

for r = (n+1):length(raw_taps)
    [~,fstem,ext] = fileparts(raw_taps{r});
    disp(['starting ',fstem,ext]);
    [tap_, raw_] = rd_tap_bmi_raw(raw_taps{r});
    
    if ~isempty(tap_)
        tap = cat_timeseries(tap, tap_);
    end
end

