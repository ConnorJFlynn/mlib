
% Load aop data set
% load CAPS data set

% Plot both, maybe smooth or average CAPS to match PSAP points.
% [Ba_V,ii_,k0,k1,h0,h1,s,ssa] = compute_Virkkula_ext(Tr,Be,Ba_raw,N)
caps_fname = getfullname('*.csv','LASIC');
caps_fid = fopen(caps_fname, 'r');
A = textscan(caps_fid, '%f %s','delimiter',',','headerlines',1);
datecell = A{2};
caps.time = datenum(datecell,'mm/dd/yyyy HH:MM:SS')';
caps.B_ext = A{1}';
clear A datecell
fclose(caps_fid);
caps_1m.time = downsample(caps.time,60); caps_1m.B_ext = downsample(caps.B_ext,60);

figure; plot(caps.time, caps.B_ext,'gx'); dynamicDateTicks
aop = ARM_display_beta;
good_aop = aop.vdata.qc_Bs_G==0 & aop.vdata.qc_Ba_G_raw==0 & aop.vdata.qc_transmittance_green==0;
aop_good_1um = anc_sift(aop, good_aop&aop.vdata.impactor_state==1);
aop_good_10um = anc_sift(aop, good_aop&aop.vdata.impactor_state==10);

[ainb, bina] = nearest(caps_1m.time,aop_good_1um.time);
caps_1um.time = caps_1m.time(ainb); caps_1um.B_ext = caps_1m.B_ext(ainb);
aop_good_1um = anc_sift(aop_good_1um, bina);

[ainc, cina] = nearest(caps_1m.time,aop_good_10um.time);
caps_10um.time = caps_1m.time(ainc); caps_10um.B_ext = caps_1m.B_ext(ainc);
aop_good_10um = anc_sift(aop_good_10um, cina);


% figure; 
% s(1) = subplot(2,1,2); plot(caps_1m.time(ainc), caps_1m.B_ext(ainc), 'g.',...
%     aop_good_1um.time(cina), aop_good_1um.vdata.Bs_G(cina) + aop_good_1um.vdata.Ba_G_combined(cina),'b.');
% title('1 um impactor'); legend('CAPS-SSA B_e_x_t(G)', 'aop Bs_G + Ba_G combined')
% dynamicDateTicks;
% s(2) = subplot(2,1,1); plot(caps_1m.time(aind), caps_1m.B_ext(aind), 'g.',...
%     aop_good_10um.time(dina), aop_good_10um.vdata.Bs_G(dina) + aop_good_10um.vdata.Ba_G_combined(dina),'b.');
% dynamicDateTicks;
% title('10 um impactor')
% linkaxes(s,'xy');
% linkaxes(s,'x');

[caps_1um.Ba_G,ii_,k0,k1,h0,h1,s,caps_1um.ssa_G] = compute_Virkkula_ext(aop_good_1um.vdata.transmittance_green,...
    caps_1um.B_ext,aop_good_1um.vdata.Ba_G_raw,4);

[caps_10um.Ba_G,ii_,k0,k1,h0,h1,s,caps_10um.ssa_G] = compute_Virkkula_ext(aop_good_10um.vdata.transmittance_green,...
    caps_10um.B_ext,aop_good_10um.vdata.Ba_G_raw,4);

figure_(12); 
sb(1) = subplot(3,1,1); 
plot(caps_1um.time, caps_1um.B_ext - caps_1um.Ba_G, 'g.',...
    caps_10um.time, caps_10um.B_ext-caps_10um.Ba_G,'go',...
    aop_good_1um.time, aop_good_1um.vdata.Bs_G, 'b.',...
    aop_good_10um.time, aop_good_10um.vdata.Bs_G, 'bo'); 
legend('B_e_x_t - Ba_G CAPS PM1','B_e_x_t - Ba_G CAPS PM10','Bs G 1um', 'Bs G 10um');
ylim([-10,100]);
dynamicDateTicks
sb(2) = subplot(3,1,2); 
plot(caps_1um.time, caps_1um.Ba_G, 'g.',...
    caps_10um.time, caps_10um.Ba_G,'go',...
    aop_good_1um.time, aop_good_1um.vdata.Ba_G_combined, 'b.',...
    aop_good_10um.time, aop_good_10um.vdata.Ba_G_combined, 'bo'); 
legend('Ba_G_ _1_u_m CAPS','Ba_G_ _1_0_u_m CAPS','Ba G Combined 1um', 'Ba G Combined 10um');
ylim([-1,10]);
dynamicDateTicks
sb(3) = subplot(3,1,3); 
plot(caps_1um.time, caps_1um.ssa_G, 'g.',...
    caps_10um.time, caps_10um.ssa_G,'go',...
    aop_good_1um.time, aop_good_1um.vdata.ssa_G, 'b.',...
    aop_good_10um.time, aop_good_10um.vdata.ssa_G, 'bo'); 
ylim([-1,2]);
legend('SSA_G_ _1_u_m CAPS','SSA_G_ _1_0_u_m CAPS','SSA G Combined 1um', 'SSA G Combined 10um');
dynamicDateTicks
linkaxes(sb,'x');
