function tap = proc_tap_bmi(raw,spot_area, ss)
if ~isavar('raw')||isempty(raw)
   raw = rd_tap_bmi_Baylor;
end
if ~isavar('spot_area')||isempty(spot_area)
   spot_area = 30.721; % mm^2 Default spot size for E70 filter
end

if ~isavar('ss')||isempty(ss)
   ss = 60;
end
   

tap.time = raw.time;
tap.Ba_R_raw = raw.Ba_R_bmi; 
tap.Ba_G_raw = raw.Ba_G_bmi;
tap.Ba_B_raw = raw.Ba_B_bmi;
tap.Tr_R = ((raw.Sig_R - raw.Sig_Dark)./(raw.Ref_R-raw.Ref_Dark));
tap.Tr_G = ((raw.Sig_G - raw.Sig_Dark)./(raw.Ref_G-raw.Ref_Dark));
tap.Tr_B = ((raw.Sig_B - raw.Sig_Dark)./(raw.Ref_B-raw.Ref_Dark));

actives = unique(raw.active_spot); actives = actives(actives>0);
for a = 1:length(actives)
   i = find(raw.active_spot==actives(a),1,'first');
   tap.Tr_R(i:end) = tap.Tr_R(i:end)./tap.Tr_R(i);
   tap.Tr_G(i:end) = tap.Tr_G(i:end)./tap.Tr_G(i);
   tap.Tr_B(i:end) = tap.Tr_B(i:end)./tap.Tr_B(i);
end

% figure; plot(tap.time, [tap.Tr_B,tap.Tr_G, tap.Tr_R], '-');
% tap.sample_flow = raw.sample_flow;

tic; 
disp('Computing flow sm'); % This minimizes digitization noise 
dt = ss./(24*60*60); % dt is full-width so sliding polyfit is over +/- dt/2
tap.flow_sm = smooth(raw.sample_flow, 30);

% figure; plot(tap.time, smooth(tap.sample_flow,30),'.',tap.time, tap.flow_sm,'-');
% dynamicDateTicks; legend('sample flow raw','smoothed');

% disp(toc);tic;disp('Computing Ba B sm')
[tap.Ba_B_sm] = Bap_ss(tap.time, tap.flow_sm, tap.Tr_B,ss,spot_area );
% disp(toc);tic;disp('Computing Ba G sm')
[tap.Ba_G_sm] = Bap_ss(tap.time, tap.flow_sm, tap.Tr_G,ss,spot_area );
% disp(toc);tic;disp('Computing Ba R sm')
[tap.Ba_R_sm] = Bap_ss(tap.time, tap.flow_sm, tap.Tr_R,ss,spot_area );
% disp(toc);disp('Done computing absorption coefs (no filter-loading correction)')

% tap = load(getfullname('*.mat','tap_bmi'));

tap.Ba_B_Bond =  tap.Ba_B_sm.* WeissBondOgren(tap.Tr_B);
tap.Ba_G_Bond =  tap.Ba_G_sm.* WeissBondOgren(tap.Tr_G);
tap.Ba_R_Bond =  tap.Ba_R_sm.* WeissBondOgren(tap.Tr_R);

% correct for EMFAB
tap.Ba_B_Bond =  tap.Ba_B_Bond./1.07;
tap.Ba_G_Bond =  tap.Ba_G_Bond./1.07;
tap.Ba_R_Bond =  tap.Ba_R_Bond./1.07;

% xl = xlim; yl = ylim;
% Adjust TAP time for BMI processing by 30 sec to account for 60s average
% figure; plot(tap.time , [tap.Ba_G_Bond],'.',...
%    tap.time- .5./(24.*60), [tap.Ba_G_raw],'.');dynamicDateTicks
% legend('Ba G tap','Ba G bmi');
% ylim(yl); xlim(xl);

return