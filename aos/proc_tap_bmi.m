function tap = proc_tap_bmi(raw,spot_area, ss)
if ~isavar('raw')||isempty(raw)
   raw = rd_tap_bmi;
end
if ~isavar('spot_area')||isempty(spot_area)
   spot_area = 30.721; % mm^2 Default spot size for E70 filter
end

if ~isavar('ss')||isempty(ss)
   ss = 30;
end
   

tap.time = raw.time;
tap.Ba_R_raw = raw.Ba_R_bmi'; 
tap.Ba_G_raw = raw.Ba_G_bmi';
tap.Ba_B_raw = raw.Ba_B_bmi';
tap.Tr_R = ((raw.Sig_R - raw.Sig_Dark)./(raw.Ref_R-raw.Ref_Dark))';
tap.Tr_G = ((raw.Sig_G - raw.Sig_Dark)./(raw.Ref_G-raw.Ref_Dark))';
tap.Tr_B = ((raw.Sig_B - raw.Sig_Dark)./(raw.Ref_B-raw.Ref_Dark))';

actives = unique(raw.active_spot);
for a = 1:length(actives)
   i = find(raw.active_spot==actives(a),1,'first');
   tap.Tr_R(i:end) = tap.Tr_R(i:end)./tap.Tr_R(i);
   tap.Tr_G(i:end) = tap.Tr_G(i:end)./tap.Tr_G(i);
   tap.Tr_B(i:end) = tap.Tr_B(i:end)./tap.Tr_B(i);
end

figure; plot(tap.time, [tap.Tr_B,tap.Tr_G, tap.Tr_R], '-');
tap.sample_flow = raw.sample_flow';

tic; 
disp('Computing flow sm');

dt = ss./(24*60*60); % dt is full-width so sliding polyfit is over +/- dt/2
tap.flow_sm = sliding_polyfit(tap.time, tap.sample_flow, dt);



figure; plot(tap.time, tap.sample_flow,'o',tap.time, tap.flow_sm,'-');
dynamicDateTicks; legend('sample flow raw','smoothed');
disp(toc);tic; disp('Computing smoothed transmittances')
tap.trans_B_sm = sliding_polyfit(tap.time, tap.Tr_B,dt./2);
tap.trans_G_sm = sliding_polyfit(tap.time, tap.Tr_G,dt./2);
tap.trans_R_sm = sliding_polyfit(tap.time, tap.Tr_R,dt./2);
 
% ss is half width
disp(toc);tic;disp('Computing Ba B sm')
[tap.Ba_B_sm] = smooth_Bab(tap.time, tap.flow_sm, tap.trans_B_sm,ss,spot_area );
disp(toc);tic;disp('Computing Ba G sm')
[tap.Ba_G_sm] = smooth_Bab(tap.time, tap.flow_sm, tap.trans_G_sm,ss,spot_area );
disp(toc);tic;disp('Computing Ba R sm')
[tap.Ba_R_sm] = smooth_Bab(tap.time, tap.flow_sm, tap.trans_R_sm,ss,spot_area );
disp(toc);disp('Done computing absorption coefs (no filter-loading correction)')

% tap = load(getfullname('*.mat','tap_bmi'));
figure; plot(tap.time, [tap.Tr_B,tap.Tr_G,tap.Tr_R],'.',...
 tap.time, [tap.trans_B_sm,tap.trans_G_sm,tap.trans_R_sm],'.'  );dynamicDateTicks
legend('Tr_B raw','Tr B raw','Tr R raw','Tr B smooth', 'Tr G smooth', 'Tr R smooth');
dynamicDateTicks

tap.Ba_B_Bond =  tap.Ba_B_sm.* WeissBondOgren(tap.trans_B_sm);
tap.Ba_G_Bond =  tap.Ba_G_sm.* WeissBondOgren(tap.trans_G_sm);
tap.Ba_R_Bond =  tap.Ba_R_sm.* WeissBondOgren(tap.trans_R_sm);

figure; plot(tap.time, [tap.Ba_B_Bond, tap.Ba_G_Bond, tap.Ba_R_Bond],'.',...
   tap.time, [tap.Ba_B_raw,tap.Ba_G_raw,tap.Ba_R_raw],'.');dynamicDateTicks
legend('Ba B tap','Ba G tap','Ba R tap','Ba B bmi','Ba G bmi', 'Ba R bmi');
ylim([0,50])

return