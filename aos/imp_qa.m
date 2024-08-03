function imp_qa

%debug a strange issue at AWR with the impactor and the hourly averaged
%pressure differentials.
a1_files = getfullname('*aosimp*.a1.*.nc','impa1', 'Select a1 impactor files');
impa1 = anc_bundle_files(a1_files);
impa1_vals = unique(impa1.vdata.impactor_state)
b1_files = getfullname('*aosimp*.b1.*.nc','impb1', 'Select b1 impactor files');
impb1 = anc_bundle_files(b1_files);
impb1_vals = unique(impb1.vdata.impactor_state);
neph_files = getfullname('*aosneph*.a1.*.nc','neph', 'Select neph files');
neph = anc_bundle_files(neph_files);
tmp = impb1.vdata.impactor_state;
figure_(4); plot(neph.time, neph.vdata.P_Neph_Dry,'k.',...
   impb1.time+ nadanan(tmp~=1), impb1.vdata.P_Neph_Dry ,'o',...
   impb1.time+ nadanan(tmp~=10), impb1.vdata.P_Neph_Dry ,'o',...
   impb1.time+ nadanan(tmp~=0), impb1.vdata.P_Neph_Dry ,'o');
dynamicDateTicks; legend('neph P raw', 'P 1 um', 'P 10 um','P 0 um')
xl = xlim;
ax(1) = gca;
figure_(5); plot(impa1.time, impa1.vdata.impactor_state,'r.',...
   impb1.time, impb1.vdata.impactor_state,'ko'); 
dynamicDateTicks;legend('impactor raw','impactor b1')
ax(2) = gca;
linkaxes(ax,'x'); xlim(xl);

figure_(6); plot(impa1.time, diff2(impa1.time).*24.*60, 'r.'...
   , impb1.time, diff2(impb1.time).*24.*60,'ko', ...
   neph.time, diff2(neph.time).*24.*60, 'cx'); 
legend('imp a1','imp b1','neph');
ylabel('delta t [mins]')
ax(3) = gca;
linkaxes(ax,'x'); xlim(xl);dynamicDateTicks

figure_(7); plot(neph.time, neph.vdata.T_Neph_Dry,'o'); legend('T Neph');
ax(4) = gca; linkaxes(ax,'x'); xlim(xl);dynamicDateTicks;
% Looks like the neph times are wrong in the a1 until ~20:45 on 18th. 
% We'll have to check that the neph PC clock is synced. 
% Also check raw data file and a1, but it is almost certainly in the raw





return
