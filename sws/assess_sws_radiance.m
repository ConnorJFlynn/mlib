function assess_sws_radiance

anet_zrad = anet_zen_rad_via_ppl_v3;
anet_crad = read_cimel_cloudrad;

swsvis = proc_sws_a0; 
[pname, fname, ext] = fileparts(swsvis.fname); pname = [pname, filesep];
swsvis.fname = [pname, strrep(fname, '.a0.', '.b1.'), ext];
anc_save(swsvis);

swsnir = proc_sws_a0; 
[pname, fname, ext] = fileparts(swsnir.fname); pname = [pname, filesep];
swsnir.fname = [pname, strrep(fname, '.a0.', '.b1.'), ext];
anc_save(swsnir);
% Generate plot with 440, 500, 670, 870, 1020 (Si) and 1640 (InGaAs) radiances
% and transmittances (divided by TOA)
% Look for characteristic separation of clear sky and cloud

% swsvis.vdata.zen_rad

[ainb, bina] = nearest(anet_zrad.time, swsvis.time);



[ainc, cina] = nearest(anet_crad.time, swsvis.time);

%check that A and K agree, especially for longer WL

% Generate plot with time-series of ratios of nearest radiances. 




return