function status = test_frh();

fitrh_id = get_ncid;
aos_id = get_ncid;
%%
fitrh.time = nc_time(fitrh_id);
aos.time = nc_time(aos_id);
%%
aos.BluTScatCoef_1um_RefRH = nc_getvar(aos_id, 'BluTScatCoef_1um_RefRH');
aos.BluTScatCoef_1um_WetRH = nc_getvar(aos_id, 'BluTScatCoef_1um_WetRH');
aos.TSINephRHSamp_HRH = nc_getvar(aos_id, 'TSINephRHSamp_HRH');
fitrh.Blue_fRH_3param_1um = nc_getvar(fitrh_id, 'Blue_fRH_3param_1um');
fitrh.Blue_fRH_3param_1um_fitflag = nc_getvar(fitrh_id, 'Blue_fRH_3param_1um_fitflag');
fitrh.Blue_fRH_3param_1um_npts = nc_getvar(fitrh_id, 'Blue_fRH_3param_1um_npts');
fitrh.Blue_chiSq_3param_1um = nc_getvar(fitrh_id, 'Blue_chiSq_3param_1um');
fitrh.Blue_fRH_3param_p1_1um = nc_getvar(fitrh_id, 'Blue_fRH_3param_p1_1um');
fitrh.Blue_fRH_3param_p2_1um = nc_getvar(fitrh_id, 'Blue_fRH_3param_p2_1um');
fitrh.Blue_fRH_3param_p3_1um = nc_getvar(fitrh_id, 'Blue_fRH_3param_p3_1um');
fitrh.Blue_fRH_3param_stddev_p1_1um = nc_getvar(fitrh_id, 'Blue_fRH_3param_stddev_p1_1um');
fitrh.Blue_fRH_3param_stddev_p2_1um = nc_getvar(fitrh_id, 'Blue_fRH_3param_stddev_p2_1um');
fitrh.Blue_fRH_3param_stddev_p3_1um = nc_getvar(fitrh_id, 'Blue_fRH_3param_stddev_p3_1um');
fitrh.Blue_fRH_3param_fiterror_1um = nc_getvar(fitrh_id, 'Blue_fRH_3param_fiterror_1um');
fitrh.Blue_fRH_2param_1um = nc_getvar(fitrh_id, 'Blue_fRH_2param_1um');
fitrh.Blue_fRH_2param_1um_fitflag = nc_getvar(fitrh_id, 'Blue_fRH_2param_1um_fitflag');
fitrh.Blue_fRH_2param_1um_npts = nc_getvar(fitrh_id, 'Blue_fRH_2param_1um_npts');
fitrh.Blue_chiSq_2param_1um = nc_getvar(fitrh_id, 'Blue_chiSq_2param_1um');
fitrh.Blue_fRH_2param_p1_1um = nc_getvar(fitrh_id, 'Blue_fRH_2param_p1_1um');
fitrh.Blue_fRH_2param_p2_1um = nc_getvar(fitrh_id, 'Blue_fRH_2param_p2_1um');
fitrh.Blue_fRH_2param_stddev_p1_1um = nc_getvar(fitrh_id, 'Blue_fRH_2param_stddev_p1_1um');
fitrh.Blue_fRH_2param_stddev_p2_1um = nc_getvar(fitrh_id, 'Blue_fRH_2param_stddev_p2_1um');
fitrh.Blue_fRH_2param_fiterror_1um = nc_getvar(fitrh_id, 'Blue_fRH_2param_fiterror_1um');
fitrh.Blue_min_bsp_1um = nc_getvar(fitrh_id, 'Blue_min_bsp_1um');
fitrh.Blue_min_refRH_1um = nc_getvar(fitrh_id, 'Blue_min_refRH_1um');
fitrh.Blue_max_refRH_1um = nc_getvar(fitrh_id, 'Blue_max_refRH_1um');
fitrh.Blue_min_wetRH_1um = nc_getvar(fitrh_id, 'Blue_min_wetRH_1um');
fitrh.Blue_max_wetRH_1um = nc_getvar(fitrh_id, 'Blue_max_wetRH_1um');
blue = figure;
for t = 1:length(fitrh.Blue_fRH_2param_p1_1um);
    
    a = fitrh.Blue_fRH_2param_p1_1um(t);
    b = fitrh.Blue_fRH_2param_p2_1um(t);
    da_2p = fitrh.Blue_fRH_2param_stddev_p1_1um(t);
    db_2p = fitrh.Blue_fRH_2param_stddev_p2_1um(t);
    
    coh = (1-rh);
frh = a * (coh.^(-b));
pder_1 = da * (coh .^(-b));
pder_2 = db .* frh .* (-1*log(coh));
frh_err = sqrt(pder_1.^2 + pder_2.^2);
    
    [fit_2p, fit_2p_err] = frh_2p([30:5:85]', a, b, da_2p, db_2p);
    a = fitrh.Blue_fRH_3param_p1_1um(t);
    b = fitrh.Blue_fRH_3param_p2_1um(t);
    c = fitrh.Blue_fRH_3param_p3_1um(t);
    da = fitrh.Blue_fRH_3param_stddev_p1_1um(t);
    db = fitrh.Blue_fRH_3param_stddev_p2_1um(t);
    dc = fitrh.Blue_fRH_3param_stddev_p3_1um(t);
    [fit_3p, fit_3p_err] = frh_3p([30:5:85]', a, b, c, da, db, dc);
    [fit_3p_ldc, fit_3p_err_ldc] = frh_3p([30:5:85]', a, b, c-dc, da, db, dc);
    [fit_3p_pdc, fit_3p_err_pdc] = frh_3p([30:5:85]', a, b, c+dc, da, db, dc);
    
    figure(blue); 
    aos_times = find((aos.time >= fitrh.time(t))& (serial2Hh(aos.time)<(serial2Hh(fitrh.time(t))+1))&(aos.TSINephRHSamp_HRH>30)&(aos.TSINephRHSamp_HRH<95)&(aos.BluTScatCoef_1um_RefRH>0)&(aos.BluTScatCoef_1um_WetRH>0));
    plot(aos.TSINephRHSamp_HRH(aos_times), aos.BluTScatCoef_1um_WetRH(aos_times)./aos.BluTScatCoef_1um_RefRH(aos_times), '.', [30:5:85], [fit_2p, fit_3p]); 
end

fitrh.Green_fRH_3param_1um = nc_getvar(fitrh_id, 'Green_fRH_3param_1um');
fitrh.Green_fRH_3param_1um_fitflag = nc_getvar(fitrh_id, 'Green_fRH_3param_1um_fitflag');
fitrh.Green_fRH_3param_1um_npts = nc_getvar(fitrh_id, 'Green_fRH_3param_1um_npts');
fitrh.Green_chiSq_3param_1um = nc_getvar(fitrh_id, 'Green_chiSq_3param_1um');
fitrh.Green_fRH_3param_p1_1um = nc_getvar(fitrh_id, 'Green_fRH_3param_p1_1um');
fitrh.Green_fRH_3param_p2_1um = nc_getvar(fitrh_id, 'Green_fRH_3param_p2_1um');
fitrh.Green_fRH_3param_p3_1um = nc_getvar(fitrh_id, 'Green_fRH_3param_p3_1um');
fitrh.Green_fRH_3param_stddev_p1_1um = nc_getvar(fitrh_id, 'Green_fRH_3param_stddev_p1_1um');
fitrh.Green_fRH_3param_stddev_p2_1um = nc_getvar(fitrh_id, 'Green_fRH_3param_stddev_p2_1um');
fitrh.Green_fRH_3param_stddev_p3_1um = nc_getvar(fitrh_id, 'Green_fRH_3param_stddev_p3_1um');
fitrh.Green_fRH_3param_fiterror_1um = nc_getvar(fitrh_id, 'Green_fRH_3param_fiterror_1um');
fitrh.Green_fRH_2param_1um = nc_getvar(fitrh_id, 'Green_fRH_2param_1um');
fitrh.Green_fRH_2param_1um_fitflag = nc_getvar(fitrh_id, 'Green_fRH_2param_1um_fitflag');
fitrh.Green_fRH_2param_1um_npts = nc_getvar(fitrh_id, 'Green_fRH_2param_1um_npts');
fitrh.Green_chiSq_2param_1um = nc_getvar(fitrh_id, 'Green_chiSq_2param_1um');
fitrh.Green_fRH_2param_p1_1um = nc_getvar(fitrh_id, 'Green_fRH_2param_p1_1um');
fitrh.Green_fRH_2param_p2_1um = nc_getvar(fitrh_id, 'Green_fRH_2param_p2_1um');
fitrh.Green_fRH_2param_stddev_p1_1um = nc_getvar(fitrh_id, 'Green_fRH_2param_stddev_p1_1um');
fitrh.Green_fRH_2param_stddev_p2_1um = nc_getvar(fitrh_id, 'Green_fRH_2param_stddev_p2_1um');
fitrh.Green_fRH_2param_fiterror_1um = nc_getvar(fitrh_id, 'Green_fRH_2param_fiterror_1um');
fitrh.Green_min_bsp_1um = nc_getvar(fitrh_id, 'Green_min_bsp_1um');
fitrh.Green_min_refRH_1um = nc_getvar(fitrh_id, 'Green_min_refRH_1um');
fitrh.Green_max_refRH_1um = nc_getvar(fitrh_id, 'Green_max_refRH_1um');
fitrh.Green_min_wetRH_1um = nc_getvar(fitrh_id, 'Green_min_wetRH_1um');
fitrh.Green_max_wetRH_1um = nc_getvar(fitrh_id, 'Green_max_wetRH_1um');

for t = 1:length(fitrh.Green_fRH_2param_p1_1um);

    a = fitrh.Green_fRH_2param_p1_1um(t);
    b = fitrh.Green_fRH_2param_p2_1um(t);
    da_2p = fitrh.Green_fRH_2param_stddev_p1_1um(t);
    db_2p = fitrh.Green_fRH_2param_stddev_p2_1um(t);

    [fit_2p, fit_2p_err] = frh_2p([40:5:85]', a, b, da_2p, db_2p);

    a = fitrh.Green_fRH_3param_p1_1um(t);
    b = fitrh.Green_fRH_3param_p2_1um(t);
    c = fitrh.Green_fRH_3param_p3_1um(t);
    da = fitrh.Green_fRH_3param_stddev_p1_1um(t);
    db = fitrh.Green_fRH_3param_stddev_p2_1um(t);
    dc = fitrh.Green_fRH_3param_stddev_p3_1um(t);

    [fit_3p, fit_3p_err] = frh_3p([40:5:85]', a, b, c, da, db, dc);
end

fitrh.Red_fRH_3param_1um = nc_getvar(fitrh_id, 'Red_fRH_3param_1um');
fitrh.Red_fRH_3param_1um_fitflag = nc_getvar(fitrh_id, 'Red_fRH_3param_1um_fitflag');
fitrh.Red_fRH_3param_1um_npts = nc_getvar(fitrh_id, 'Red_fRH_3param_1um_npts');
fitrh.Red_chiSq_3param_1um = nc_getvar(fitrh_id, 'Red_chiSq_3param_1um');
fitrh.Red_fRH_3param_p1_1um = nc_getvar(fitrh_id, 'Red_fRH_3param_p1_1um');
fitrh.Red_fRH_3param_p2_1um = nc_getvar(fitrh_id, 'Red_fRH_3param_p2_1um');
fitrh.Red_fRH_3param_p3_1um = nc_getvar(fitrh_id, 'Red_fRH_3param_p3_1um');
fitrh.Red_fRH_3param_stddev_p1_1um = nc_getvar(fitrh_id, 'Red_fRH_3param_stddev_p1_1um');
fitrh.Red_fRH_3param_stddev_p2_1um = nc_getvar(fitrh_id, 'Red_fRH_3param_stddev_p2_1um');
fitrh.Red_fRH_3param_stddev_p3_1um = nc_getvar(fitrh_id, 'Red_fRH_3param_stddev_p3_1um');
fitrh.Red_fRH_3param_fiterror_1um = nc_getvar(fitrh_id, 'Red_fRH_3param_fiterror_1um');
fitrh.Red_fRH_2param_1um = nc_getvar(fitrh_id, 'Red_fRH_2param_1um');
fitrh.Red_fRH_2param_1um_fitflag = nc_getvar(fitrh_id, 'Red_fRH_2param_1um_fitflag');
fitrh.Red_fRH_2param_1um_npts = nc_getvar(fitrh_id, 'Red_fRH_2param_1um_npts');
fitrh.Red_chiSq_2param_1um = nc_getvar(fitrh_id, 'Red_chiSq_2param_1um');
fitrh.Red_fRH_2param_p1_1um = nc_getvar(fitrh_id, 'Red_fRH_2param_p1_1um');
fitrh.Red_fRH_2param_p2_1um = nc_getvar(fitrh_id, 'Red_fRH_2param_p2_1um');
fitrh.Red_fRH_2param_stddev_p1_1um = nc_getvar(fitrh_id, 'Red_fRH_2param_stddev_p1_1um');
fitrh.Red_fRH_2param_stddev_p2_1um = nc_getvar(fitrh_id, 'Red_fRH_2param_stddev_p2_1um');
fitrh.Red_fRH_2param_fiterror_1um = nc_getvar(fitrh_id, 'Red_fRH_2param_fiterror_1um');
fitrh.Red_min_bsp_1um = nc_getvar(fitrh_id, 'Red_min_bsp_1um');
fitrh.Red_min_refRH_1um = nc_getvar(fitrh_id, 'Red_min_refRH_1um');
fitrh.Red_max_refRH_1um = nc_getvar(fitrh_id, 'Red_max_refRH_1um');
fitrh.Red_min_wetRH_1um = nc_getvar(fitrh_id, 'Red_min_wetRH_1um');
fitrh.Red_max_wetRH_1um = nc_getvar(fitrh_id, 'Red_max_wetRH_1um');

for t = 1:length(fitrh.Red_fRH_2param_p1_1um);

    a = fitrh.Red_fRH_2param_p1_1um(t);
    b = fitrh.Red_fRH_2param_p2_1um(t);
    da_2p = fitrh.Red_fRH_2param_stddev_p1_1um(t);
    db_2p = fitrh.Red_fRH_2param_stddev_p2_1um(t);

    [fit_2p, fit_2p_err] = frh_2p([40:5:85]', a, b, da_2p, db_2p);

    a = fitrh.Red_fRH_3param_p1_1um(t);
    b = fitrh.Red_fRH_3param_p2_1um(t);
    c = fitrh.Red_fRH_3param_p3_1um(t);
    da = fitrh.Red_fRH_3param_stddev_p1_1um(t);
    db = fitrh.Red_fRH_3param_stddev_p2_1um(t);
    dc = fitrh.Red_fRH_3param_stddev_p3_1um(t);

    [fit_3p, fit_3p_err] = frh_3p([40:5:85]', a, b, c, da, db, dc);
    
end

%%

fitrh.Blue_fRH_3param_10um = nc_getvar(fitrh_id, 'Blue_fRH_3param_10um');
fitrh.Blue_fRH_3param_10um_fitflag = nc_getvar(fitrh_id, 'Blue_fRH_3param_10um_fitflag');
fitrh.Blue_fRH_3param_10um_npts = nc_getvar(fitrh_id, 'Blue_fRH_3param_10um_npts');
fitrh.Blue_chiSq_3param_10um = nc_getvar(fitrh_id, 'Blue_chiSq_3param_10um');
fitrh.Blue_fRH_3param_p1_10um = nc_getvar(fitrh_id, 'Blue_fRH_3param_p1_10um');
fitrh.Blue_fRH_3param_p2_10um = nc_getvar(fitrh_id, 'Blue_fRH_3param_p2_10um');
fitrh.Blue_fRH_3param_p3_10um = nc_getvar(fitrh_id, 'Blue_fRH_3param_p3_10um');
fitrh.Blue_fRH_3param_stddev_p1_10um = nc_getvar(fitrh_id, 'Blue_fRH_3param_stddev_p1_10um');
fitrh.Blue_fRH_3param_stddev_p2_10um = nc_getvar(fitrh_id, 'Blue_fRH_3param_stddev_p2_10um');
fitrh.Blue_fRH_3param_stddev_p3_10um = nc_getvar(fitrh_id, 'Blue_fRH_3param_stddev_p3_10um');
fitrh.Blue_fRH_3param_fiterror_10um = nc_getvar(fitrh_id, 'Blue_fRH_3param_fiterror_10um');
fitrh.Blue_fRH_2param_10um = nc_getvar(fitrh_id, 'Blue_fRH_2param_10um');
fitrh.Blue_fRH_2param_10um_fitflag = nc_getvar(fitrh_id, 'Blue_fRH_2param_10um_fitflag');
fitrh.Blue_fRH_2param_10um_npts = nc_getvar(fitrh_id, 'Blue_fRH_2param_10um_npts');
fitrh.Blue_chiSq_2param_10um = nc_getvar(fitrh_id, 'Blue_chiSq_2param_10um');
fitrh.Blue_fRH_2param_p1_10um = nc_getvar(fitrh_id, 'Blue_fRH_2param_p1_10um');
fitrh.Blue_fRH_2param_p2_10um = nc_getvar(fitrh_id, 'Blue_fRH_2param_p2_10um');
fitrh.Blue_fRH_2param_stddev_p1_10um = nc_getvar(fitrh_id, 'Blue_fRH_2param_stddev_p1_10um');
fitrh.Blue_fRH_2param_stddev_p2_10um = nc_getvar(fitrh_id, 'Blue_fRH_2param_stddev_p2_10um');
fitrh.Blue_fRH_2param_fiterror_10um = nc_getvar(fitrh_id, 'Blue_fRH_2param_fiterror_10um');
fitrh.Blue_min_bsp_10um = nc_getvar(fitrh_id, 'Blue_min_bsp_10um');
fitrh.Blue_min_refRH_10um = nc_getvar(fitrh_id, 'Blue_min_refRH_10um');
fitrh.Blue_max_refRH_10um = nc_getvar(fitrh_id, 'Blue_max_refRH_10um');
fitrh.Blue_min_wetRH_10um = nc_getvar(fitrh_id, 'Blue_min_wetRH_10um');
fitrh.Blue_max_wetRH_10um = nc_getvar(fitrh_id, 'Blue_max_wetRH_10um');

for t = 1:length(fitrh.Blue_fRH_2param_p1_10um);

    a = fitrh.Blue_fRH_2param_p1_10um(t);
    b = fitrh.Blue_fRH_2param_p2_10um(t);
    da_2p = fitrh.Blue_fRH_2param_stddev_p1_10um(t);
    db_2p = fitrh.Blue_fRH_2param_stddev_p2_10um(t);
    [fit_2p, fit_2p_err] = frh_2p([40:5:85]', a, b, da_2p, db_2p);
    a = fitrh.Blue_fRH_3param_p1_10um(t);
    b = fitrh.Blue_fRH_3param_p2_10um(t);
    c = fitrh.Blue_fRH_3param_p3_10um(t);
    da = fitrh.Blue_fRH_3param_stddev_p1_10um(t);
    db = fitrh.Blue_fRH_3param_stddev_p2_10um(t);
    dc = fitrh.Blue_fRH_3param_stddev_p3_10um(t);
    [fit_3p, fit_3p_err] = frh_3p([40:5:85]', a, b, c, da, db, dc);

end

fitrh.Green_fRH_3param_10um = nc_getvar(fitrh_id, 'Green_fRH_3param_10um');
fitrh.Green_fRH_3param_10um_fitflag = nc_getvar(fitrh_id, 'Green_fRH_3param_10um_fitflag');
fitrh.Green_fRH_3param_10um_npts = nc_getvar(fitrh_id, 'Green_fRH_3param_10um_npts');
fitrh.Green_chiSq_3param_10um = nc_getvar(fitrh_id, 'Green_chiSq_3param_10um');
fitrh.Green_fRH_3param_p1_10um = nc_getvar(fitrh_id, 'Green_fRH_3param_p1_10um');
fitrh.Green_fRH_3param_p2_10um = nc_getvar(fitrh_id, 'Green_fRH_3param_p2_10um');
fitrh.Green_fRH_3param_p3_10um = nc_getvar(fitrh_id, 'Green_fRH_3param_p3_10um');
fitrh.Green_fRH_3param_stddev_p1_10um = nc_getvar(fitrh_id, 'Green_fRH_3param_stddev_p1_10um');
fitrh.Green_fRH_3param_stddev_p2_10um = nc_getvar(fitrh_id, 'Green_fRH_3param_stddev_p2_10um');
fitrh.Green_fRH_3param_stddev_p3_10um = nc_getvar(fitrh_id, 'Green_fRH_3param_stddev_p3_10um');
fitrh.Green_fRH_3param_fiterror_10um = nc_getvar(fitrh_id, 'Green_fRH_3param_fiterror_10um');
fitrh.Green_fRH_2param_10um = nc_getvar(fitrh_id, 'Green_fRH_2param_10um');
fitrh.Green_fRH_2param_10um_fitflag = nc_getvar(fitrh_id, 'Green_fRH_2param_10um_fitflag');
fitrh.Green_fRH_2param_10um_npts = nc_getvar(fitrh_id, 'Green_fRH_2param_10um_npts');
fitrh.Green_chiSq_2param_10um = nc_getvar(fitrh_id, 'Green_chiSq_2param_10um');
fitrh.Green_fRH_2param_p1_10um = nc_getvar(fitrh_id, 'Green_fRH_2param_p1_10um');
fitrh.Green_fRH_2param_p2_10um = nc_getvar(fitrh_id, 'Green_fRH_2param_p2_10um');
fitrh.Green_fRH_2param_stddev_p1_10um = nc_getvar(fitrh_id, 'Green_fRH_2param_stddev_p1_10um');
fitrh.Green_fRH_2param_stddev_p2_10um = nc_getvar(fitrh_id, 'Green_fRH_2param_stddev_p2_10um');
fitrh.Green_fRH_2param_fiterror_10um = nc_getvar(fitrh_id, 'Green_fRH_2param_fiterror_10um');
fitrh.Green_min_bsp_10um = nc_getvar(fitrh_id, 'Green_min_bsp_10um');
fitrh.Green_min_refRH_10um = nc_getvar(fitrh_id, 'Green_min_refRH_10um');
fitrh.Green_max_refRH_10um = nc_getvar(fitrh_id, 'Green_max_refRH_10um');
fitrh.Green_min_wetRH_10um = nc_getvar(fitrh_id, 'Green_min_wetRH_10um');
fitrh.Green_max_wetRH_10um = nc_getvar(fitrh_id, 'Green_max_wetRH_10um');

for t = 1:length(fitrh.Green_fRH_2param_p1_10um);

    a = fitrh.Green_fRH_2param_p1_10um(t);
    b = fitrh.Green_fRH_2param_p2_10um(t);
    da_2p = fitrh.Green_fRH_2param_stddev_p1_10um(t);
    db_2p = fitrh.Green_fRH_2param_stddev_p2_10um(t);

    [fit_2p, fit_2p_err] = frh_2p([40:5:85]', a, b, da_2p, db_2p);

    a = fitrh.Green_fRH_3param_p1_10um(t);
    b = fitrh.Green_fRH_3param_p2_10um(t);
    c = fitrh.Green_fRH_3param_p3_10um(t);
    da = fitrh.Green_fRH_3param_stddev_p1_10um(t);
    db = fitrh.Green_fRH_3param_stddev_p2_10um(t);
    dc = fitrh.Green_fRH_3param_stddev_p3_10um(t);

    [fit_3p, fit_3p_err] = frh_3p([40:5:85]', a, b, c, da, db, dc);
end

fitrh.Red_fRH_3param_10um = nc_getvar(fitrh_id, 'Red_fRH_3param_10um');
fitrh.Red_fRH_3param_10um_fitflag = nc_getvar(fitrh_id, 'Red_fRH_3param_10um_fitflag');
fitrh.Red_fRH_3param_10um_npts = nc_getvar(fitrh_id, 'Red_fRH_3param_10um_npts');
fitrh.Red_chiSq_3param_10um = nc_getvar(fitrh_id, 'Red_chiSq_3param_10um');
fitrh.Red_fRH_3param_p1_10um = nc_getvar(fitrh_id, 'Red_fRH_3param_p1_10um');
fitrh.Red_fRH_3param_p2_10um = nc_getvar(fitrh_id, 'Red_fRH_3param_p2_10um');
fitrh.Red_fRH_3param_p3_10um = nc_getvar(fitrh_id, 'Red_fRH_3param_p3_10um');
fitrh.Red_fRH_3param_stddev_p1_10um = nc_getvar(fitrh_id, 'Red_fRH_3param_stddev_p1_10um');
fitrh.Red_fRH_3param_stddev_p2_10um = nc_getvar(fitrh_id, 'Red_fRH_3param_stddev_p2_10um');
fitrh.Red_fRH_3param_stddev_p3_10um = nc_getvar(fitrh_id, 'Red_fRH_3param_stddev_p3_10um');
fitrh.Red_fRH_3param_fiterror_10um = nc_getvar(fitrh_id, 'Red_fRH_3param_fiterror_10um');
fitrh.Red_fRH_2param_10um = nc_getvar(fitrh_id, 'Red_fRH_2param_10um');
fitrh.Red_fRH_2param_10um_fitflag = nc_getvar(fitrh_id, 'Red_fRH_2param_10um_fitflag');
fitrh.Red_fRH_2param_10um_npts = nc_getvar(fitrh_id, 'Red_fRH_2param_10um_npts');
fitrh.Red_chiSq_2param_10um = nc_getvar(fitrh_id, 'Red_chiSq_2param_10um');
fitrh.Red_fRH_2param_p1_10um = nc_getvar(fitrh_id, 'Red_fRH_2param_p1_10um');
fitrh.Red_fRH_2param_p2_10um = nc_getvar(fitrh_id, 'Red_fRH_2param_p2_10um');
fitrh.Red_fRH_2param_stddev_p1_10um = nc_getvar(fitrh_id, 'Red_fRH_2param_stddev_p1_10um');
fitrh.Red_fRH_2param_stddev_p2_10um = nc_getvar(fitrh_id, 'Red_fRH_2param_stddev_p2_10um');
fitrh.Red_fRH_2param_fiterror_10um = nc_getvar(fitrh_id, 'Red_fRH_2param_fiterror_10um');
fitrh.Red_min_bsp_10um = nc_getvar(fitrh_id, 'Red_min_bsp_10um');
fitrh.Red_min_refRH_10um = nc_getvar(fitrh_id, 'Red_min_refRH_10um');
fitrh.Red_max_refRH_10um = nc_getvar(fitrh_id, 'Red_max_refRH_10um');
fitrh.Red_min_wetRH_10um = nc_getvar(fitrh_id, 'Red_min_wetRH_10um');
fitrh.Red_max_wetRH_10um = nc_getvar(fitrh_id, 'Red_max_wetRH_10um');

for t = 1:length(fitrh.Red_fRH_2param_p1_10um);

    a = fitrh.Red_fRH_2param_p1_10um(t);
    b = fitrh.Red_fRH_2param_p2_10um(t);
    da_2p = fitrh.Red_fRH_2param_stddev_p1_10um(t);
    db_2p = fitrh.Red_fRH_2param_stddev_p2_10um(t);

    [fit_2p, fit_2p_err] = frh_2p([40:5:85]', a, b, da_2p, db_2p);

    a = fitrh.Red_fRH_3param_p1_10um(t);
    b = fitrh.Red_fRH_3param_p2_10um(t);
    c = fitrh.Red_fRH_3param_p3_10um(t);
    da = fitrh.Red_fRH_3param_stddev_p1_10um(t);
    db = fitrh.Red_fRH_3param_stddev_p2_10um(t);
    dc = fitrh.Red_fRH_3param_stddev_p3_10um(t);

    [fit_3p, fit_3p_err] = frh_3p([40:5:85]', a, b, c, da, db, dc);

end

status = 1;
end
%%

function [frh, frh_err] = frh_2p(rh, a, b, da, db);
%[frh, frh_err] = frh_2p(rh, a, b, da, db);
% Evaluates CMDL two-parameter fit for frh and calculates error estimate
% using returned sigmas for da and db and partial derivatives
% frh = a *((1-rh)^(-b))
% d(frh)/da = da * (1-rh)^(-b)
% d(frh)/db = frh * (-log(1-rh)) * db
if rh > 1
    rh = rh/100;
end
coh = (1-rh);
frh = a * (coh.^(-b));
pder_1 = da * (coh .^(-b));
pder_2 = db .* frh .* (-1*log(coh));
frh_err = sqrt(pder_1.^2 + pder_2.^2);

end


function [frh, frh_err] = frh_3p(rh, a, b, c,  da, db, dc);
%[frh, frh_err] = frh_3p(rh, a, b, c,  da, db, dc);
% Evaluates CMDL three-parameter fit for frh and calculates error estimate
% using returned sigmas and partial derivatives
% frh = a .* (1 + b .* (rh.^c));
% d(frh)/da = 1 + b .* (rh.^c);
% d(frh)/db = a .* (rh.^c);
% d(frh)/dc = a .* b .* (rh.^c) .* log(rh);

if rh > 1
    rh = rh/100;
end
frh = a .* (1 + b .* (rh.^c));
pder_1 = da .* (1 + b .* (rh.^c));
pder_2 = db .* a .* (rh.^c);
pder_3 = db .* (a .* b .* (rh.^c) .* log(rh));
frh_err = sqrt(pder_1.^2 + pder_2.^2 + pder_3.^2);
end