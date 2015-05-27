
data = load ('CCN_data_test_ascii.dat');

delta_T_ = data(:,4);
T1_set = data(:,5);
T2_set = data (:,7); % Set on CCNC as T2_set = T1_set + 0.5 * Delta_T_cal;
delta_T_cal = 2.*(T2_set - T1_set); % so this line recovers the underlying calibration setting
T3_set = data (:,9); % Set on CCNC as T3_set = T1_set + Delta_T_cal*(1-TG)
delta_T_set = T3_set - T1_set;
TG_ = 1 - (delta_T_set./delta_T_);
TG = 1 - (delta_T_set./delta_T_cal);
% there is some weird variability here.  Take the most median, I suppose.

delta_T_set = delta_T *(1-TG);
T3_set = T1_set + delta_T_set;

delta_T_set = (T3_set - T1_set);




T1_read = data(:,6);
T2_read = data(:,8);
T3_read = data (:,10);

T_inlet = data (:,14);
T_sample = data (:,17)








%Column number    Heading variables

% 1	    Time
% 2	 Current SS
% 3	 Temps Stabilized
% 4	  Delta T
% 5	   T1 Set
% 6	  T1 Read
% 7	   T2 Set
% 8	  T2 Read
% 9	   T3 Set
% 10	  T3 Read
% 11	 Nafion Set
% 12	 T Nafion
% 13	 Inlet Set
% 14	  T Inlet
% 15	  OPC Set
% 16	    T OPC
% 17	 T Sample
% 18	 Sample Flow
% 19	 Sheath Flow
% 20	 Sample Pressure
% 21	 Laser Current
% 22	 overflow
% 23	 Baseline Mon
% 24	 1st Stage Mon
% 25	    Bin #
% 26	    Bin 1
% 27	    Bin 2
% 28	    Bin 3
% 29	   Bin 4 
% 30	    Bin 5
% 31	    Bin 6
% 32	    Bin 7
% 33	    Bin 8
% 34	    Bin 9
% 35	   Bin 10
% 36	   Bin 11
% 37	   Bin 12
% 38	   Bin 13
% 39	   Bin 14
% 40	   Bin 15
% 41	   Bin 16
% 42	   Bin 17
% 43	   Bin 18
% 44	   Bin 19
% 45	   Bin 20
% 46	 CCN Number Conc
% 47	 Valve Set
% 48	 Alarm Code
