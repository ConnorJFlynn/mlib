%%
figure; plot(serial2Hh(c1.time), a1.vars.Bbs_B_Dry_1um_Neph3W_1.data, 'r.', ...
    serial2Hh(c1.time), c0.vars.Bbs_B_Dry_1um_Neph3W_1.data, 'go', ...
    serial2Hh(c1.time), c1.vars.Bbs_B_Dry_1um_Neph3W_1.data, 'bx');
axis(v)
%%
figure; plot(serial2Hh(c1.time), a1.vars.Ba_B_Dry_1um_PSAP3W_1.data-c0.vars.Ba_B_Dry_1um_PSAP3W_1.data, 'r.')
%%

