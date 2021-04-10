% AML PSAP / TAP experiments

% AML PSAP / TAP experiments

% Initial work with TAP in July or Aug resulted in it being sent back to
% Brechtel for repair on Aug 4.  After receiving the repaired system and a
% new VI, the VI would not install or run.  This seems mostly like a COM
% port issue.  Ultimately able to get TAP to run on XP machine but the SW
% still leaves much to be desired and sometimes advances spot when not
% needed or doesn't advance when it should.  Thus, in the tests below after
% Oct 16 TAP is run via Putty to generate raw serial log files.




% Aug 29: Start of AML tests
% Instruments: valve (sample/HEPA), alicat, TAP, PSAP-AAF, PSAP-PNL
% PSAPs run more or less continuously from Aug 30 to Sept 13 when I left 
% for ORACLES.

% Aug 31, TAP white filter tests, repeatability, etc.

% Sept 2: Fow referencing TAP, PSAP-aaf, PSAP-pnnl vs TSI 4100.
% P_pnl_flow = psap_pnnl_flow_ref;
% P_aaf_flow = psap_aaf_flow_ref;
% tap_aaf_flow_ref
% stap_flow_ref (conducted on Oct 14)

% Sept 2: Upgrade EPROM in PSAP-aaf.


% Oct 12, STAP received, introducing Azumi filters.

% Oct 13, STAP(azumi), PSAP AAF (Pall) PSAP PNL(Pall), TAP

% Oct 14: all filter instruments and LAS operating.  Filter put in line at
% 09:00:10 UT to check temporal response of all connected systems.

% Oct 15 (Oct 16 UT) Noticed TAP had advanced from filter 7 the night
% before to filter 4!! BAD!  From here on out I use Putty for data
% collection from TAP.

% Oct 18 Noticed negative absorption coefs during filter changes, possibly due to
% pressure change or RH.  Mikhail re-plumbed valve to draw outside air through HEPA for
% filtered tests and added TRH sensors.
% Now begin comprehensive tests with STAP, PSAP-AAF, PSAP-PNL, TAP with
% different filters,etc. 

% Test 1: Oct 18 STAP(Azumi), AAF(Azumi), PNL(Pall), TAP with RH
% start 19:30 UT, end Oct 19 15:30 UT.  Tr<0.7
% Forgot to log alicat.  TRH starts on Oct 19, 00:00
test_in = load([test_name,filesep,'test_1.mat'])

% Test 2-void: Oct 19 STAP(Azumi), AAF(Pall), PNL(Azumi)
% Void because I forgot to turn PSAP data saving ON.
% STAP died Oct 19. :-(

% Test 3: Oct 20  AAF(Pall), PNL (Azumi)
% start Thursday Oct 20 in afternoon (UT?)
% end Sat Oct 22



% Test 4, Oct 22 AAF(Azumi), PNNL(Pall)
% Start Sat Oct 22 afternoon
% End Mon Oct 24, 17:20, Tr<0.2(aaf), 0.3(pnl)
% Good tests (3&4) but flows are all different.

% Test 5, Oct 24, AAF(Pall), PNL(Pall), all flows adjusted to 1 LPM TSI
% start Oct 24 18:00 UT?
% End Oct 25 18:51 UT. Forgot to reset Tr at beginning? 

psap_aaf_spot_diameter = 4.94; % 4.94 mm
tap_spot_diam = 6.8; % 6.8 mm diam = 38.48 mm^2 area actually 36.3168
 valve = rd_aml_valve;
 ali = rd_aml_alicat;
 trh = rd_aml_trh;
 [psapo_pnl] = rd_psapi_aml;
 P_pnl_flow = psap_pnnl_flow_ref;
 pnl_flow_tsi = polyval(P_pnl_flow, psapo_pnl.flow_sm);
 pnl_flow_corr = psapo_pnl.flow_sm./pnl_flow_tsi;
 figure; plot(psapo_pnl.time, [psapo_pnl.Ba_B_sm.*pnl_flow_corr],'b-');dynamicDateTicks
legend('Ba_B pnl')
 
test.psap_aaf_spot_diameter = psap_aaf_spot_diameter;
test.tap_spot_diam = tap_spot_diam;
test.valve = valve;
test.trh = trh;
psapo_pnl.P_pnl_flow = P_pnl_flow;
psapo_pnl.pnl_flow_tsi = pnl_flow_tsi;
psapo_pnl.pnl_flow_corr = pnl_flow_corr;
test.psapo_pnl = psapo_pnl;



 [psapr_aaf,psapo_aaf] = rd_psapro_aml;
 P_aaf_flow = psap_aaf_flow_ref;
 aaf_flow_tsi = polyval(P_aaf_flow, psapr_aaf.flow_sm);
aaf_flow_corr = psapr_aaf.flow_sm./aaf_flow_tsi;
psapr_aaf.P_aaf_flow = P_aaf_flow;
psapr_aaf.aaf_flow_tsi = aaf_flow_tsi;
psapr_aaf.aaf_flow_corr = aaf_flow_corr;
test.psapr_aaf = psapr_aaf;  test.psapo_aaf = psapo_aaf;

figure; plot(psapr_aaf.time, [psapr_aaf.Ba_B_sm.*aaf_flow_corr],'b-');dynamicDateTicks
legend('Ba_B aaf');
 
 tap = process_raw_tap;
 [P_tap_flow] =tap_aaf_flow_ref;
tap_flow_tsi = polyval(P_tap_flow, tap.flow_sm);
tap_flow_corr =tap.flow_sm./tap_flow_tsi;
tap.P_tap_flow = P_tap_flow;
tap.tap_flow_tsi = tap_flow_tsi;
tap.tap_flow_corr = tap_flow_corr;
test.tap = tap;

test_name = uigetdir;
test_num = 'test_6';
save([test_name,filesep,[test_num,'.mat']],'-struct','test')
test_in = load([test_name,filesep,[test_num,'.mat']])
figure; plot(tap.time, [tap.Ba_B_sm.*tap_flow_corr.*38.48./17.81],'c-');dynamicDateTicks
legend('Ba B tap, (38.48/17.81 spot-correction)');ax(1) = gca;
%Zoom in to a time period near the beginning of the test to normalize
%values against each other.
xl = xlim;
xl_pnl = psapo_pnl.time> xl(1)&psapo_pnl.time<xl(2);
xl_aaf = psapr_aaf.time>xl(1) & psapr_aaf.time<xl(2);
xl_tap = tap.time>xl(1)&tap.time<xl(2);
mean_pnl_xl = mean(psapo_pnl.Ba_B_sm(xl_pnl).*pnl_flow_corr(xl_pnl));
mean_aaf_xl = mean(psapr_aaf.Ba_B_sm(xl_aaf).*aaf_flow_corr(xl_aaf));
mean_tap_xl = mean(tap.Ba_B_sm(xl_tap).*tap_flow_corr(xl_tap));
mean_psap = mean([mean_pnl_xl, mean_aaf_xl]); %This is just the mean of the two PSAPs.
% We'll attribute differences in this ratio to differences in spot-size
% since we've already acounted for flows, the filter media is the same, and
% loading is negligible at the beginning of the run.

pnl_spot_corr = mean_psap./mean_pnl_xl;
aaf_spot_corr = mean_psap./mean_aaf_xl;
tap_spot_corr = mean_psap./mean_tap_xl;
plot(psapo_pnl.time, [psapo_pnl.Ba_B_sm.*pnl_flow_corr.*pnl_spot_corr],'b-',...
    psapr_aaf.time, [psapr_aaf.Ba_B_sm.*aaf_flow_corr.*aaf_spot_corr],'-c',...
    tap.time, [tap.Ba_B_sm.*tap_flow_corr.*tap_spot_corr],'k-');
legend('Ba_B PNNL','Ba_B AAF','Ba_B TAP'); 
xlabel('Time [UTC]');
ylabel('Apparent Absorption [1/Mm]');
title({'PNNL AML PSAP and TAP tests, 2016-10-24';'All using Pallflex and sample flow 1 LPM sample flow'})
dynamicDateTicks;


figure; plot(tap.time, tap.flow_sm,'r-');legend('tap flow');dynamicDateTicks
ax(2) = gca;linkaxes(ax,'x');

% Test 6, Oct 25, AAF(Azumi), PNL(Azumi), all flows adjusted to 1 LPM TSI
% Start 19:30 UT Oct 25
% End 17:00 Oct 26

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

