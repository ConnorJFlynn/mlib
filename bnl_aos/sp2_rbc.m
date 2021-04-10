function rbc = sp2_rbc(sp2);

if ~exist('sp2','var')
sp2 = anc_load('*sp2rbc*.nc','sp2rbc','Select SP2 RBC file');
end
sp2.vatts.diameter_geo
sp2.vatts.diameter_geo_bounds
sp2.vatts.N_dN_rBC
dV = (pi./6).*sp2.vdata.diameter_geo.^3;
sp2.vatts.rBC
D_cm = sp2.vdata.diameter_geo./1e4;
V_cc = (pi./6).*D_cm^3;
V_cc = (pi/6).*D_cm^3;
pi
pi./6
V_cc = (pi./6) .* (D_cm.^3);
size(V_cc)
dN_rBC_m3 = sp2.vdata.rBC.*1e6;
size(dN_rBC_m3)
dN_rBC_m3 = sp2.vdata.N_dN_rBC.*1e6;
size(dN_rBC_m3)
dV_rBC_m3 = (V_cc*ones([1,1440])).*dN_rBC_m3;
dM_rBC_m3 = 1.8e9.*dV_rBC_m3;
M_rBC_m3 = trapz(sp2.vdata.diameter_geo, dM_rBC_m3);
size(M_rBC_m3)
figure; plot(sp2.time, M_rBC_m3,'.',sp2.time, sp2.vdata.rBC,'o'); dynamicDateTicks
figure; plot(sp2.time, 25.*M_rBC_m3,'.',sp2.time, sp2.vdata.rBC,'o'); dynamicDateTicks
figure; imagesc(sp2.time, sp2.vdata.diameter_geo, real(log10(sp2.vdata.N_dN_rBC))); dynamicDateTicks; axis('xy');
ax(1) = gca;
ax(2) = gca;
linkaxes(ax,'x');
big = sp2.vdata.diameter_geo>.5;
sum(big)
D_cm(big) = 0;
V_cc = (pi./6) .* (D_cm.^3);
dV_rBC_m3 = (V_cc*ones([1,1440])).*dN_rBC_m3;
dM_rBC_m3 = 1.8e9.*dV_rBC_m3;
M_rBC_m3 = trapz(sp2.vdata.diameter_geo, dM_rBC_m3);
figure; plot(sp2.time, 25.*M_rBC_m3,'.',sp2.time, sp2.vdata.rBC,'o'); dynamicDateTicks
sp2.gatts
sp2.gatts.comment
sp2.gatts.calibration
size(dM_rBC_m3)
M_rBC_m3 = trapz(sp2.vdata.diameter_geo(sp2.vdata.diameter_geo>0.45), dM_rBC_m3(sp2.vdata.diameter_geo>0.45,:));
figure; plot(sp2.time, 25.*M_rBC_m3,'.',sp2.time, sp2.vdata.rBC,'o'); dynamicDateTicks
M_rBC_m3 = trapz(sp2.vdata.diameter_geo(sp2.vdata.diameter_geo<0.45), dM_rBC_m3(sp2.vdata.diameter_geo<0.45,:));
figure; plot(sp2.time, 25.*M_rBC_m3,'.',sp2.time, sp2.vdata.rBC,'o'); dynamicDateTicks