%mfr1 = ancload;
mfr2 = ancload;
%%
good2 = ones(size(mfr2.time));
%C = BITSET(A,BIT,V)
good2 = bitset(good2,1, mfr2.vars.aerosol_optical_depth_filter1.data < 0.0);
good2 = bitset(good2,2, mfr2.vars.solar_zenith_angle.data > 84);
good2 = bitset(good2,3, mfr2.vars.solar_zenith_angle.data > 90);
good2 = bitset(good2,4, mfr2.vars.variability_flag.data > 1e-5);
good2 = bitset(good2,5, mfr2.vars.variability_flag.data > 1e-4);
good2 = bitset(good2,6, (mfr2.vars.Ozone_column_amount.data < sscanf(mfr2.vars.Ozone_column_amount.atts.valid_min.data,'%g'))| ...
    (mfr2.vars.Ozone_column_amount.data > sscanf(mfr2.vars.Ozone_column_amount.atts.valid_max.data,'%g')));
good2 = bitset(good2,7, 0);
good2 = bitset(good2,8, mfr2.vars.total_optical_depth_filter2.data <0);
good2 = bitset(good2,9, mfr2.vars.aerosol_optical_depth_filter2.data >2);
%%
bad_bits = uint32(0);
for b = [1 3 5 8], bad_bits = bitset(bad_bits,b), end
bad2 = logical(bitand(uint32(good2),bad_bits)>0);
indet_bits = uint32(0);
for b = [2 4 6 7 9], indet_bits = bitset(indet_bits,b), end
indet2 = logical(bitand(uint32(good2),indet_bits)>0);
%%
figure; plot(serial2Hh(mfr2.time), mfr2.vars.aerosol_optical_depth_filter1.data, 'r.', ...
serial2Hh(mfr2.time(~bad2)), mfr2.vars.aerosol_optical_depth_filter1.data(~bad2), 'b.',...
serial2Hh(mfr2.time(~bad2&~indet2)), mfr2.vars.aerosol_optical_depth_filter1.data(~bad2&~indet2), 'g.');
axis(v); 
%%
qc = (mfr2.vars.qc_aerosol_optical_depth_filter1.data);
qc_bad = logical(bitand(qc,double(bad_bits))>0);
qc_indet = logical(bitand(qc,double(indet_bits))>0);
figure; plot(serial2Hh(mfr2.time), mfr2.vars.aerosol_optical_depth_filter1.data, 'r.', ...
serial2Hh(mfr2.time(~qc_bad)), mfr2.vars.aerosol_optical_depth_filter1.data(~qc_bad), 'b.',...
serial2Hh(mfr2.time(~qc_bad&~qc_indet)), mfr2.vars.aerosol_optical_depth_filter1.data(~qc_bad&~qc_indet), 'g.');
axis(v); 