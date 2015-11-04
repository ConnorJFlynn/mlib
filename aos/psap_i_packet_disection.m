Related to missing psapR files and to AAF processing of PSAP I string in psap_raw files

Check R raw file to psapr netcdf.
Checking 2015-05-29

D:\case_studies\aos\BNL_AOS\raw_and_mentor_qc_formats\raw_psap



maoaospsap3wS1.00.20150529.031101.raw.maomaosas1.psap3w.01s.00.20150529.020000.raw.tsv
maoaospsap3wS1.00.20150529.031101.raw.maomaosas1.psap3wI.01s.00.20150529.020000.raw.tsv
"ss,NN,flow,time,dark_sig, dark_ref, gain
2015-05-29	02:46:38.898	150528215040	"40,22,a982999e,c822,fffff4,fffffe,01"	closed	453.300000	9.140000
signal_sum, reference_sum, N_conv_x_16, sum_overrange
2015-05-29	02:46:39.898	150528215041	"41,d7ee2b3359,86ecccf1ba,7361e0,83"	closed	453.300000	10.020000
2015-05-29	02:46:40.898	150528215042	"42,c87f6f41fd,f278b515ee,6f3fa0,f4"	closed	453.300000	5.470000
2015-05-29	02:46:41.898	150528215043	"43,34ac021d40,7abfaf8af0,2566a0,88"	closed	453.300000	5.730000

maoaospsap3wS1.00.20150529.031101.raw.maomaosas1.psap3wR.01s.00.20150529.020000.raw.tsv
Date	Time	               Inst. Time	   Blu_sum	Blu_ref	N  Over_N Grnen signal sum	Green ref. sum	Green sample count	Green overflow count	Red signal sum	Red ref. sum	Red sample count	Red overflow count	Dark Signal sum	Dark ref. sum	Dark sample count	Dark overflow count	Mass flow output, 1 sec	Mass flow	Flags
2015-05-29	02:46:38.773	150528215040	0171693e	02120dcf	12c	00	0242a36e	023aebbb	12c	00	00a957cd	00bff91e	12c	00	fffff28a	fffffe23	12c	00	1657	1.012	0781
2015-05-29	02:46:39.773	150528215041	017168d2	021210d7	12c	00	0242a347	023aeeaa	12c	00	00a9553e	00bff8d0	12c	00	fffff498	ffffff67	12c	00	1657	1.012	0781
2015-05-29	02:46:40.773	150528215042	01716917	021210ac	12c	00	0242a31d	023aec81	12c	00	00a955cf	00bffae5	12c	00	fffff3a1	fffffc2c	12c	00	1657	1.012	0781
2015-05-29	02:46:41.773	150528215043	01716708	02120fff	12c	00	0242a09f	023aeb4e	12c	00	00a95685	00bffb7d	12c	00	fffff5ef	fffffe5a	12c	00	1657	1.012	0781

Seems to be a 1-second or 1-record offset between psap_R.tsv and psapr.nc


psap_r = anc_load;
datestr(psap_r.time(10000))
29-May-2015 02:46:39
psap_r.vdata.blue_signal_sum(10000)
=   24209618

Check R file to I file


From I file:
hex2nm('d7ee2b3359')-hex2nm('d7e81a8bbc') -256.*(hex2nm('7361e0')-hex2nm('7316e0')) = 96839581
2015-05-29	02:46:35.898	150528215037	"37,d7e81a8bbc,86e439b722,7316e0,83"
2015-05-29	02:46:39.898	150528215041	"41,d7ee2b3359,86ecccf1ba,7361e0,83"

From R file:
 hex2nm('01716b08') +hex2nm('01716ae9') +hex2nm('0171686e')+ hex2nm('0171693e') = 96839581
2015-05-29	02:46:35.773	150528215037	01716b08
2015-05-29	02:46:36.773	150528215038	01716ae9
2015-05-29	02:46:37.773	150528215039	0171686e
2015-05-29	02:46:38.773	150528215040	0171693e


flow-rate field3: a982999e

