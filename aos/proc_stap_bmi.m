function stap = proc_stap_bmi(stap,spot_area, ss)

if ~isavar('raw') || isempty(raw)
   stap = rd_stap_bmi;
end
if ~isavar('spot_area')||isempty(spot_area)
	% spot area = 0.188" in diam = 0.094" rad = 2.3876 mm ==> 17.91 mm^2
   spot_area = 17.91; 
end
if ~isavar('ss')||isempty(ss)
   ss = 30;
end
tic; 
disp('Computing flow sm');
    ss = 30;
    dt = ss./(24*60*60); % 8-second half-width, 16-second full-width
    stap.flow_sm = sliding_polyfit(stap.time, stap.sample_flow, dt);
figure; plot(stap.time, stap.sample_flow, '.',stap.time, stap.flow_sm,'r.')
disp(toc);tic; disp('Computing smoothed transmittances')
stap.trans_B_sm = sliding_polyfit(stap.time,stap.trans_B,dt./2);disp(toc);tic; 
stap.trans_G_sm = sliding_polyfit(stap.time,stap.trans_G,dt./2);disp(toc);tic; 
stap.trans_R_sm = sliding_polyfit(stap.time,stap.trans_R,dt./2);disp(toc);tic; 
figure; plot(stap.time, [stap.trans_B_sm, stap.trans_G_sm, stap.trans_R_sm],'-');
dynamicDateTicks; legend('trans B sm', 'trans G sm','trans R sm');

tic; disp('Computing Ba B sm')
[stap.Ba_B_sm] = smooth_Bab(stap.time, stap.flow_sm, stap.trans_B_sm, ss, spot_area );
disp(toc);tic;disp('Computing Ba G sm')
[stap.Ba_G_sm] = smooth_Bab(stap.time, stap.flow_sm, stap.trans_G_sm,ss,spot_area );
disp(toc);tic;disp('Computing Ba R sm')
[stap.Ba_R_sm] = smooth_Bab(stap.time, stap.flow_sm, stap.trans_R_sm,ss,spot_area );
disp(toc);disp('Done computing absorption coefs (no filter-loading correction)')

stap.Ba_B_Bond =  stap.Ba_B_sm.* WeissBondOgren(stap.trans_B);
stap.Ba_G_Bond =  stap.Ba_G_sm.* WeissBondOgren(stap.trans_G);
stap.Ba_R_Bond =  stap.Ba_R_sm.* WeissBondOgren(stap.trans_R);
% stap = load(getfullname('*.mat','tap_bmi'));


figure; plot(stap.time, [stap.Ba_B_Bond, stap.Ba_G_Bond, stap.Ba_R_Bond],'.',...
   stap.time-1./(24*60), [stap.Ba_B, stap.Ba_G, stap.Ba_R],'.' );dynamicDateTicks
legend('Ba B stap sm','Ba G stap sm','Ba R stap sm','Ba B bmi','Ba G bmi','Ba R bmi');
dynamicDateTicks

if iscell(stap.fname)
ins = [stap.pname, stap.fname{1}];
else
   ins = [stap.pname, stap.fname];
end
[~,title_str] = fileparts(ins);
title(title_str,'interp','none')
saveas(gcf,strrep(ins,'.TXT','.fig'))
save(strrep(ins,'.TXT','.mat'),'-struct','stap');

return