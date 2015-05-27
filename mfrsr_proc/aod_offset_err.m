%% This data drawn from the Excel file "All_MFRSR_Offsets.xls"
% This file and the companion aod_offset_err.m examine the observed MFRSR
% offsets (which were being incorrectly accounted for by the MFRSR ingest)
% would affect AODmfrsr_offsets.counts = [

mfrsr_offsets.counts = [
   -8.0168    1.7151   -0.8659   -2.0335   -1.4358   -1.4525
    3.9971    0.0278         0    0.0306    0.0000    0.5287
    4.0363    1.2067    1.0475    1.9497    1.0363    1.0028
   -8.4777         0   -0.9385   -1.0028   -0.9609   -1.0056
    1.0866         0         0   -0.1508         0    0.1397
   -3.4721   -1.1061   -1.8994   -1.2849   -1.9693   -3.4078
    1.6723   -0.2773   -1.0644   -0.9272   -1.6246   -0.1793
  -34.9190  -11.8352   -4.7346   -6.8101   -2.9274   -6.4525
  -27.6006   -9.7542   -4.0279   -5.5447   -2.5279   -5.4665
    2.3501   -0.0196   -0.9580   -0.4706   -0.2185    0.4230
   -3.0112    0.8824    0.4510   -0.7899   -0.1541   -0.2437
  -24.1485   -5.8375   -5.0476   -5.2101   -6.3389  -10.2325
  -14.4706   -3.8655   -3.3613   -3.4818   -4.3669   -6.8375
   -3.9832   -3.0084   -2.0140   -2.0056   -2.2073   -3.0084
   -3.0980   -1.3754   -1.0392   -1.0028   -1.4146   -1.0196
   -3.9693   -2.0000   -1.9413   -1.9777   -2.0084   -1.9888
    1.1927   -0.4106   -0.0056   -0.4106   -0.0307    0.0084
   -9.2465   -9.8683   -3.1176   -8.2073   -4.1232   -6.7787
   -7.6471   -6.2577   -1.6891   -5.0112   -2.4622   -4.4930
   -2.8908   -2.5294   -2.2045   -2.0056   -2.0224   -2.6583
    2.0084         0         0         0         0   -0.0532
   -7.4525   -3.9246   -2.6648   -3.0140   -2.6425   -2.9385
   -6.5503   -1.9497   -2.1648   -2.8464   -2.1676   -1.8966
   -4.0140   -2.0056   -1.0028   -1.9972   -1.5447   -1.0391
   ];
mfrsr_offsets.labels = {    'NIM_M1'
    'NIM_S1'
    'NSA_C1'
    'NSA_C2'
    'SGP_C1'
    'SGP_E1'
    'SGP_E3'
    'SGP_E4a'
    'SGP_E4b'
    'SGP_E6'
    'SGP_E7'
    'SGP_E9a'
    'SGP_E9b'
    'SGP_E11'
    'SGP_E12'
    'SGP_E13'
    'SGP_E16'
    'SGP_E18a'
    'SGP_E18b'
    'SGP_E24'
    'SGP_E27'
    'twp_C1'
    'twp_C2'
    'twp_C3'};
mfrsr_offsets.error_type = [ 
     2
     2
     1
     1
     1
     2
     2
     2
     2
     2
     2
     2
     2
     2
     2
     2
     2
     2
     2
     2
     2
     1
     1
     1];
 mfrsr_offsets.mean_type1 = [5.2696 1.5144 1.3031 1.8268 1.3920 1.3371];
 mfrsr_offsets.mean_type2 = [8.7608 3.3761 1.9123 2.6224 1.9907 3.0685];
 [char(mfrsr_offsets.labels), num2str(mfrsr_offsets.error_type)];
 
 
 
%%
 %test day Jan 5, 2001
 new_dod = ancload;
%

 el_gt_5 = find((90-new_dod.vars.solar_zenith_angle.data)>5);
%  figure; plot(serial2Hh(new_dod.time(el_gt_5)), 90-new_dod.vars.solar_zenith_angle.data(el_gt_5), '.');
%
el_gt_5 = find((90-new_dod.vars.solar_zenith_angle.data)>5);
 am = new_dod.vars.airmass.data(el_gt_5);
 unit_offset1 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
 unit_offset2 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
 unit_offset3 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
 unit_offset4 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
 unit_offset5 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
%
  mean_offset1 = unit_offset1*mfrsr_offsets.mean_type1(1);
  mean_offset2 = unit_offset2*mfrsr_offsets.mean_type1(2);
  mean_offset3 = unit_offset3*mfrsr_offsets.mean_type1(3);
  mean_offset4 = unit_offset4*mfrsr_offsets.mean_type1(4);  
  mean_offset5 = unit_offset5*mfrsr_offsets.mean_type1(5);
%
 dirnor1 = new_dod.vars.direct_normal_narrowband_filter1.data(el_gt_5);
 dirnor2 = new_dod.vars.direct_normal_narrowband_filter2.data(el_gt_5);
 dirnor3 = new_dod.vars.direct_normal_narrowband_filter3.data(el_gt_5);
 dirnor4 = new_dod.vars.direct_normal_narrowband_filter4.data(el_gt_5);
 dirnor5 = new_dod.vars.direct_normal_narrowband_filter4.data(el_gt_5);
 
%%
 figure; plot(serial2Hh(new_dod.time(el_gt_5)), [...
     log(dirnor1./(dirnor1-1*unit_offset1))./am;
     log(dirnor1./(dirnor1-2*unit_offset1))./am;...
     log(dirnor1./(dirnor1-3*unit_offset1))./am;...
     log(dirnor1./(dirnor1-4*unit_offset1))./am;...  
     log(dirnor1./(dirnor1-5*unit_offset1))./am],'.');
 legend('+1','+2','+3','+4','+5');
 title('filter 1 delta-tau')
  figure; plot(serial2Hh(new_dod.time(el_gt_5)), [...
     log(dirnor2./(dirnor2-1*unit_offset2))./am;
     log(dirnor2./(dirnor2-2*unit_offset2))./am;...
     log(dirnor2./(dirnor2-3*unit_offset2))./am;...
     log(dirnor2./(dirnor2-4*unit_offset2))./am;...  
     log(dirnor2./(dirnor2-5*unit_offset2))./am],'.');
 legend('+1','+2','+3','+4','+5');
  title('filter 2 delta-tau')
%%
plots_ppt;
%%
  figure;
  plot(serial2Hh(new_dod.time(el_gt_5))-6,log(dirnor1./(dirnor1-mean_offset1))./am, 'r.',...
     serial2Hh(new_dod.time(el_gt_5))-6, log(dirnor2./(dirnor2-mean_offset2))./am, 'b.');
 legend('415 nm','500 nm');
  title('Effect on AOD = log(I/(I-offset))/airmass');
  xlabel('time (LST)')
  ylabel('optical depth')
  ylim([0,5e-3]);
  xlim([xl])
  
%%
%%
  figure; plot(serial2Hh(new_dod.time(el_gt_5)), [dirnor1;dirnor2;dirnor3;dirnor4;dirnor5],'.');
 legend('filter1','filter2','filter3','filter4','filter5');
  title('Heavy AOD dirnors')
  
%%
 %light aerosol day, aod < .1
%%
new_dod = ancload; % light day is Aug 23.
 el_gt_5 = find((90-new_dod.vars.solar_zenith_angle.data)>5);
%  figure; plot(serial2Hh(new_dod.time(el_gt_5)), 90-new_dod.vars.solar_zenith_angle.data(el_gt_5), '.');
%%
el_gt_5 = find((90-new_dod.vars.solar_zenith_angle.data)>5);
 am = new_dod.vars.airmass.data(el_gt_5);
 unit_offset1 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;

 unit_offset2 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
 unit_offset3 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
 unit_offset4 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
 unit_offset5 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;

 dirnor1 = new_dod.vars.direct_normal_narrowband_filter1.data(el_gt_5);
 dirnor2 = new_dod.vars.direct_normal_narrowband_filter2.data(el_gt_5);
 dirnor3 = new_dod.vars.direct_normal_narrowband_filter3.data(el_gt_5);
 dirnor4 = new_dod.vars.direct_normal_narrowband_filter4.data(el_gt_5);
 dirnor5 = new_dod.vars.direct_normal_narrowband_filter4.data(el_gt_5);
 figure; plot(serial2Hh(new_dod.time(el_gt_5)), [...
     log(dirnor1./(dirnor1-1*unit_offset1))./am;
     log(dirnor1./(dirnor1-2*unit_offset1))./am;...
     log(dirnor1./(dirnor1-3*unit_offset1))./am;...
     log(dirnor1./(dirnor1-4*unit_offset1))./am;...  
     log(dirnor1./(dirnor1-5*unit_offset1))./am],'.');
 legend('+1','+2','+3','+4','+5');
 title('Light day: filter 1 delta-tau')
  figure; plot(serial2Hh(new_dod.time(el_gt_5)), [...
     log(dirnor2./(dirnor2-1*unit_offset2))./am;
     log(dirnor2./(dirnor2-2*unit_offset2))./am;...
     log(dirnor2./(dirnor2-3*unit_offset2))./am;...
     log(dirnor2./(dirnor2-4*unit_offset2))./am;...  
     log(dirnor2./(dirnor2-5*unit_offset2))./am],'.');
 legend('+1','+2','+3','+4','+5');
  title('Light_day: filter 2 delta-tau')

%%
%heavy aerosol day
% Sept4 = ancload;
new_dod = ancload; % light day is Sept 4.
 el_gt_5 = find((90-new_dod.vars.solar_zenith_angle.data)>5);
%  figure; plot(serial2Hh(new_dod.time(el_gt_5)), 90-new_dod.vars.solar_zenith_angle.data(el_gt_5), '.');
%
el_gt_5 = find((90-new_dod.vars.solar_zenith_angle.data)>5);
 am = new_dod.vars.airmass.data(el_gt_5);
 unit_offset1 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;

 unit_offset2 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
 unit_offset3 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
 unit_offset4 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;
 unit_offset5 = 1/new_dod.vars.nominal_calibration_factor_filter1.data;

 dirnor1 = new_dod.vars.direct_normal_narrowband_filter1.data(el_gt_5);
 dirnor2 = new_dod.vars.direct_normal_narrowband_filter2.data(el_gt_5);
 dirnor3 = new_dod.vars.direct_normal_narrowband_filter3.data(el_gt_5);
 dirnor4 = new_dod.vars.direct_normal_narrowband_filter4.data(el_gt_5);
 dirnor5 = new_dod.vars.direct_normal_narrowband_filter4.data(el_gt_5);
 figure; plot(serial2Hh(new_dod.time(el_gt_5)), [...
     log(dirnor1./(dirnor1-1*unit_offset1))./am;
     log(dirnor1./(dirnor1-2*unit_offset1))./am;...
     log(dirnor1./(dirnor1-3*unit_offset1))./am;...
     log(dirnor1./(dirnor1-4*unit_offset1))./am;...  
     log(dirnor1./(dirnor1-5*unit_offset1))./am],'.');
 legend('+1','+2','+3','+4','+5');

 title('Heavy day: filter 1 delta-tau')
%%
xl = xlim;yl = ylim;
  figure; plot(serial2Hh(new_dod.time(el_gt_5)), [...
     log(dirnor2./(dirnor2-1*unit_offset2))./am;
     log(dirnor2./(dirnor2-2*unit_offset2))./am;...
     log(dirnor2./(dirnor2-3*unit_offset2))./am;...
     log(dirnor2./(dirnor2-4*unit_offset2))./am;...  
     log(dirnor2./(dirnor2-5*unit_offset2))./am],'.');
 legend('+1','+2','+3','+4','+5');
 xlim(xl);ylim(yl)
 
  title('Heavy day: filter 2 delta-tau')