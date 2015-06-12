psap1s = anc_bundle_files(getfullname('*.nc;*.cdf','select psap1s','psap1s'));
psap1m = anc_bundle_files(getfullname('*.nc;*.cdf','select psap1m','psap1m'));


% Populate a qc field for Bab_G psap1s based on qc_transmittance_green

% Thinking about a computationally efficient means of flagging events that
% are temporally near other identified events. 
% First, map time to a regular grid.
% Then iteratively "OR" the event over the desired temporal window using
% shift_x. Then map back to the original time grid.
impactor_transition_ = psap1s.vdata.impactor_state==0  & [false, psap1s.vdata.impactor_state(2:end)~=psap1s.vdata.impactor_state(1:end-1)];
filter_change_start_ = psap1s.vdata.filter_unstable==1  & [false, psap1s.vdata.filter_unstable(1:end-1)==0 & psap1s.vdata.filter_unstable(2:end)==1];
filter_change_end_ = psap1s.vdata.filter_unstable==1  & [psap1s.vdata.filter_unstable(1:end-1)==1 & psap1s.vdata.filter_unstable(2:end)==0, false];
filter_change = filter_change_start | filter_change_end;
impactor_transition = impactor_transition_;
bad_sample_flow_ = psap1s.vdata.qc_sample_flow_rate ~=0;
bad_sample_flow = bad_sample_flow_;
bad_sample_volume_ = psap1s.vdata.sample_volume <= 0;
bad_sample_volume = bad_sample_volume_;

nn = 15; NN = 15; 

for tt = -nn:NN
   impactor_transition = shift_i(impactor_transition_, tt)| impactor_transition;
   bad_sample_flow = shift_i(bad_sample_flow_, tt)| bad_sample_flow;
   bad_sample_volume = shift_i(bad_sample_volume_, tt)| bad_sample_volume;
end

nnn = 60; NNN = 120; 
for tt = -nnn:-1
   filter_change_start = shift_i(filter_change_start_, tt)| filter_change_start;
end
for tt = 1:NNN
   filter_change_end = shift_i(filter_change_end_, tt)| filter_change_end;
end


%% for green
psap1s.ncdef.qc_Ba_G = psap1s.ncdef.vars.qc_transmittance_green;
psap1s.ncdef.qc_Ba_G.id = [];
psap1s.vdata.qc_Ba_G = zeros(size(psap1s.vdata.qc_transmittance_green));
psap1s.vatts.qc_Ba_G = psap1s.vatts.qc_transmittance_green;
psap1s.vatts.qc_Ba_G.long_name = 'Quality check results on field: Aerosol light absorption coefficient, nominal green wavelength at dry or reference RH';

% psap1s.vatts.qc_Ba_G.bit_1_description, missing
psap1s.vdata.qc_Ba_G = bitset(psap1s.vdata.qc_Ba_G,1, psap1s.vdata.Ba_G < -9998 & psap1s.vdata.Ba_G > -10000);
% psap1s.vatts.qc_Ba_G.bit_2_description, < valid_min
psap1s.vdata.qc_Ba_G = bitset(psap1s.vdata.qc_Ba_G,2, psap1s.vdata.Ba_G < -1 & psap1s.vdata.Ba_G > -9999);
% psap1s.vatts.qc_Ba_G.bit_3_description, < valid_max

psap1s.vatts.qc_Ba_G.bit_4_description = '< nn seconds before start of identified filter change';
psap1s.vatts.qc_Ba_G.bit_4_assessment = 'Bad';
psap1s.vdata.qc_Ba_G = bitset(psap1s.vdata.qc_Ba_G,4, filter_change_start);

psap1s.vatts.qc_Ba_G.bit_5_description = '< NN seconds after end of identified filter change';
psap1s.vatts.qc_Ba_G.bit_5_assessment = 'Bad';
psap1s.vdata.qc_Ba_G = bitset(psap1s.vdata.qc_Ba_G,5,filter_change_end);

Tr_too_high = psap1s.vdata.transmittance_blue>1 | psap1s.vdata.transmittance_green>1 | psap1s.vdata.transmittance_red>1;
psap1s.vatts.qc_Ba_G.bit_6_description = 'transmittance_R > 1 | transmittance_G > 1 | transmittance_B > 1';
psap1s.vatts.qc_Ba_G.bit_6_assessment = 'Bad';
psap1s.vdata.qc_Ba_G = bitset(psap1s.vdata.qc_Ba_G,6, Tr_too_high);

Tr_too_low = psap1s.vdata.transmittance_blue<0.65 | psap1s.vdata.transmittance_green<0.65 | psap1s.vdata.transmittance_red<0.65;

psap1s.vatts.qc_Ba_G.bit_7_description = 'transmittance_R < 0.65 | transmittance_G < 0.65 | transmittance_B < 0.65';
psap1s.vatts.qc_Ba_G.bit_7_assessment = 'Bad';
psap1s.vdata.qc_Ba_G = bitset(psap1s.vdata.qc_Ba_G,7, Tr_too_low);

psap1s.vatts.qc_Ba_G.bit_8_description = 'within nn seconds of BAD sample_flow_rate';
psap1s.vatts.qc_Ba_G.bit_8_assessment = 'Bad';
psap1s.vdata.qc_Ba_G = bitset(psap1s.vdata.qc_Ba_G,8,bad_sample_flow ~=0);

psap1s.vatts.qc_Ba_G.bit_9_description = 'within nn seconds of sample_volume <= 0';
psap1s.vatts.qc_Ba_G.bit_9_assessment = 'Bad';
psap1s.vdata.qc_Ba_G = bitset(psap1s.vdata.qc_Ba_G,9,bad_sample_volume);


psap1s.vatts.qc_Ba_G.bit_10_description = 'within nn seconds of an impactor change';
psap1s.vatts.qc_Ba_G.bit_10_assessment = 'Bad';
psap1s.vdata.qc_Ba_G = bitset(psap1s.vdata.qc_Ba_G,10,impactor_transition);


%% for red
psap1s.ncdef.qc_Ba_R = psap1s.ncdef.vars.qc_transmittance_red;
psap1s.ncdef.qc_Ba_R.id = [];
psap1s.vdata.qc_Ba_R = zeros(size(psap1s.vdata.qc_transmittance_red));
psap1s.vatts.qc_Ba_R = psap1s.vatts.qc_transmittance_red;
psap1s.vatts.qc_Ba_R.long_name = 'Quality check results on field: Aerosol light absorption coefficient, nominal red wavelength at dry or reference RH';

% psap1s.vatts.qc_Ba_R.bit_1_description, missing
psap1s.vdata.qc_Ba_R = bitset(psap1s.vdata.qc_Ba_R,1, psap1s.vdata.Ba_R < -9998 & psap1s.vdata.Ba_R > -10000);
% psap1s.vatts.qc_Ba_R.bit_2_description, < valid_min
psap1s.vdata.qc_Ba_R = bitset(psap1s.vdata.qc_Ba_R,2, psap1s.vdata.Ba_R < -1 & psap1s.vdata.Ba_R > -9999);
% psap1s.vatts.qc_Ba_R.bit_3_description, < valid_max

psap1s.vatts.qc_Ba_R.bit_4_description = '< nn seconds before start of identified filter change';
psap1s.vatts.qc_Ba_R.bit_4_assessment = 'Bad';
psap1s.vdata.qc_Ba_R = bitset(psap1s.vdata.qc_Ba_R,4, filter_change_start);


psap1s.vatts.qc_Ba_R.bit_5_description = '< NN seconds after end of identified filter change';
psap1s.vatts.qc_Ba_R.bit_5_assessment = 'Bad';
psap1s.vdata.qc_Ba_R = bitset(psap1s.vdata.qc_Ba_R,5,filter_change_end);

Tr_too_high = psap1s.vdata.transmittance_blue>1 | psap1s.vdata.transmittance_green>1 | psap1s.vdata.transmittance_red>1;
psap1s.vatts.qc_Ba_R.bit_6_description = 'transmittance_R > 1 | transmittance_G > 1 | transmittance_B > 1';
psap1s.vatts.qc_Ba_R.bit_6_assessment = 'Bad';
psap1s.vdata.qc_Ba_R = bitset(psap1s.vdata.qc_Ba_R,6, Tr_too_high);

Tr_too_low = psap1s.vdata.transmittance_blue<0.65 | psap1s.vdata.transmittance_green<0.65 | psap1s.vdata.transmittance_red<0.65;

psap1s.vatts.qc_Ba_R.bit_7_description = 'transmittance_R < 0.65 | transmittance_G < 0.65 | transmittance_B < 0.65';
psap1s.vatts.qc_Ba_R.bit_7_assessment = 'Bad';
psap1s.vdata.qc_Ba_R = bitset(psap1s.vdata.qc_Ba_R,7, Tr_too_low);

psap1s.vatts.qc_Ba_R.bit_8_description = 'within nn seconds of BAD sample_flow_rate';
psap1s.vatts.qc_Ba_R.bit_8_assessment = 'Bad';
psap1s.vdata.qc_Ba_R = bitset(psap1s.vdata.qc_Ba_R,8,bad_sample_flow ~=0);

psap1s.vatts.qc_Ba_R.bit_9_description = 'within nn seconds of sample_volume <= 0';
psap1s.vatts.qc_Ba_R.bit_9_assessment = 'Bad';
psap1s.vdata.qc_Ba_R = bitset(psap1s.vdata.qc_Ba_R,9,bad_sample_volume);


psap1s.vatts.qc_Ba_R.bit_10_description = 'within nn seconds of an impactor change';
psap1s.vatts.qc_Ba_R.bit_10_assessment = 'Bad';
psap1s.vdata.qc_Ba_R = bitset(psap1s.vdata.qc_Ba_R,10,impactor_transition);


%% for blue
psap1s.ncdef.qc_Ba_B = psap1s.ncdef.vars.qc_transmittance_blue;
psap1s.ncdef.qc_Ba_B.id = [];
psap1s.vdata.qc_Ba_B = zeros(size(psap1s.vdata.qc_transmittance_blue));
psap1s.vatts.qc_Ba_B = psap1s.vatts.qc_transmittance_blue;
psap1s.vatts.qc_Ba_B.long_name = 'Quality check results on field: Aerosol light absorption coefficient, nominal blue wavelength at dry or reference RH';

% psap1s.vatts.qc_Ba_B.bit_1_description, missing
psap1s.vdata.qc_Ba_B = bitset(psap1s.vdata.qc_Ba_B,1, psap1s.vdata.Ba_B < -9998 & psap1s.vdata.Ba_B > -10000);
% psap1s.vatts.qc_Ba_B.bit_2_description, < valid_min
psap1s.vdata.qc_Ba_B = bitset(psap1s.vdata.qc_Ba_B,2, psap1s.vdata.Ba_G < -1 & psap1s.vdata.Ba_G > -9999);
% psap1s.vatts.qc_Ba_B.bit_3_description, < valid_max

psap1s.vatts.qc_Ba_B.bit_4_description = '< nn seconds before start of identified filter change';
psap1s.vatts.qc_Ba_B.bit_4_assessment = 'Bad';
psap1s.vdata.qc_Ba_B = bitset(psap1s.vdata.qc_Ba_B,4, filter_change_start);


psap1s.vatts.qc_Ba_B.bit_5_description = '< NN seconds after end of identified filter change';
psap1s.vatts.qc_Ba_B.bit_5_assessment = 'Bad';
psap1s.vdata.qc_Ba_B = bitset(psap1s.vdata.qc_Ba_B,5,filter_change_end);

Tr_too_high = psap1s.vdata.transmittance_blue>1 | psap1s.vdata.transmittance_green>1 | psap1s.vdata.transmittance_red>1;
psap1s.vatts.qc_Ba_B.bit_6_description = 'transmittance_R > 1 | transmittance_G > 1 | transmittance_B > 1';
psap1s.vatts.qc_Ba_B.bit_6_assessment = 'Bad';
psap1s.vdata.qc_Ba_B = bitset(psap1s.vdata.qc_Ba_B,6, Tr_too_high);

Tr_too_low = psap1s.vdata.transmittance_blue<0.65 | psap1s.vdata.transmittance_green<0.65 | psap1s.vdata.transmittance_red<0.65;

psap1s.vatts.qc_Ba_B.bit_7_description = 'transmittance_R < 0.65 | transmittance_G < 0.65 | transmittance_B < 0.65';
psap1s.vatts.qc_Ba_B.bit_7_assessment = 'Bad';
psap1s.vdata.qc_Ba_B = bitset(psap1s.vdata.qc_Ba_B,7, Tr_too_low);

psap1s.vatts.qc_Ba_B.bit_8_description = 'within nn seconds of BAD sample_flow_rate';
psap1s.vatts.qc_Ba_B.bit_8_assessment = 'Bad';
psap1s.vdata.qc_Ba_B = bitset(psap1s.vdata.qc_Ba_B,8,bad_sample_flow ~=0);

psap1s.vatts.qc_Ba_B.bit_9_description = 'within nn seconds of sample_volume <= 0';
psap1s.vatts.qc_Ba_B.bit_9_assessment = 'Bad';
psap1s.vdata.qc_Ba_B = bitset(psap1s.vdata.qc_Ba_B,9,bad_sample_volume);


psap1s.vatts.qc_Ba_B.bit_10_description = 'within nn seconds of an impactor change';
psap1s.vatts.qc_Ba_B.bit_10_assessment = 'Bad';
psap1s.vdata.qc_Ba_B = bitset(psap1s.vdata.qc_Ba_B,10,impactor_transition);

psap1s = anc_check(psap1s);
[pname, fname] = fileparts(psap1s.fname); pname = [pname, filesep];
save([pname, fname, '.mat'],'-struct','psap1s');



ARM_ds_display(psap1s);
