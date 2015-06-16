function flight = rd_g1_rad_cl(rad_file) 

if ~exist('rad_file','var')||~exist(rad_file,'file')
rad_file = getfullname('*rad_cl*.txt','tcap_g1','Select rad file');
end

fid = fopen(rad_file);
first = fgetl(fid);
%%
C = textscan(first, '%f','delimiter',':,');
% C is length 26 for "rad" file.
% C is length 32 for "rad_cl" file
fseek(fid,0,-1);
%%
f_str = repmat('%f ',[1,length(C{:})]);
D = textscan(fid,f_str,'delimiter',':,');
fclose(fid);
%%

[pname, fname, ext] = fileparts(rad_file);
flight.fname = rad_file;
%%
flight_date = datenum(fname(1:8),'yyyymmdd');
DV = datevec(flight_date);
DV = repmat(DV,length(D{1}),1);
DV(:,4) = D{1};DV(:,5) = D{2};DV(:,6) = D{3};
flight.time = datenum(DV);
D(3)=[]; D(2) = []; D(1) = [];
%%
flight.Lat = D{1}; D(1) = [];
flight.Lon = D{1}; D(1) = [];
flight.Altitude_ft = D{1}; D(1) = [];
flight.roll_deg = D{1}; D(1) = [];
flight.Pitch_deg = D{1}; D(1) = [];
flight.Azimuth_deg = D{1}; D(1) = [];
flight.mfr415gnd_AD = D{1};
flight.mfr500gnd_AD = D{2};
flight.mfr615gnd_AD = D{3};
flight.mfr673gnd_AD = D{4};
flight.mfr870gnd_AD = D{5};
flight.mfr940gnd_AD = D{6};
flight.mfr1625gnd_AD = D{7};
flight.mfrTempgnd_AD = D{8};
flight.mfrTHTCgnd_AD = D{9};
flight.mfrHeater_AD = D{10};
flight.SPN1_tot_AD = D{11};
flight.SPN1_dif_AD = D{12};
if length(D)>12
flight.mfr415 = D{13};
flight.mfr500 = D{14};
flight.mfr615 = D{15};
flight.mfr673 = D{16};
flight.mfr870 = D{17};
flight.mfr940 = D{18};
flight.mfr1625 = D{19};
flight.mfrTemp = D{20};
flight.mfrTHTC = D{21};
flight.SPN_tot = D{22};
flight.SPN_dif = D{23};
end

figure; 
s(1)= subplot(2,1,1);
semilogy(serial2doy(mfr.time), [mfr.mfr500gnd_AD+0.068426, mfr.mfr870gnd_AD+0.068145],'.');zoom('on')
s(2)= subplot(2,1,2);
semilogy(serial2doy(mfr.time), [mfr.mfr1625gnd_AD+4.2613],'.');zoom('on');


% "MFRgnd415_W/m^2/nm"    Row 1 F4509 ",%10.6f"12
% "MFRgnd500"           Row 1 F4510 ",%10.6f"
% "MFRgnd615"           Row 1 F4511 ",%10.6f"
% "MFRgnd673"           Row 1 F4512 ",%10.6f"
% "MFRgnd870"           Row 1 F4513 ",%10.6f"
% "MFRgnd940"           Row 1 F4514 ",%10.6f"
% "MFRgnd1625"          Row 1 F4515 ",%10.6f"
% "MFRgndTemp_C"        Row 1 F4516 ",%10.6f"
% "MFRgndTHTC_C"        Row 1 F4517 ",%10.6f"
% 
% "SPN_total_W/m2 "     Row 1 F4602 ",%10.6f"
% "SPN_diff_W/m2"       Row 1 F4603 ",%10.6f"

% mfr415=data[12,*]
% mfr500=data[13,*]
% mfr615=data[14,*]
% mfr673=data[15,*]
% mfr870=data[16,*]
% mfr940=data[17,*]
% mfr1625=data[18,*]
% mfrtheadV=data[19,*]
% mfrthtcV=data[20,*]


%% This pattern holds for rad_cl, for rad skip the first 6 are absent.
% From rad_cl.asc from Hubbe
% "Latitude"            Row -1 F801 ",%8.5f"
% "Longitude"           Row -1 F802 ",%8.5f"
% "Altitude_ft"         Row -1 F446 ",%5.0f"
% "Roll_deg"            Row -1 F238 ",%4.2f"
% "Pitch_deg"           Row -1 F239 ",%4.2f"
% "Azimuth_deg"         Row -1 F240 ",%4.1f"
% 
% "A3_1_MFRgnd415"      Row 1 F86  ",%7.6f"0
% "A3_2_MFRgnd500"      Row 1 F87  ",%7.6f"1
% "A3_3_MFRgnd615"      Row 1 F88  ",%7.6f"2
% "A3_4_MFRgnd673"      Row 1 F89  ",%7.6f"3
% "A3_5_MFRgnd870"      Row 1 F90  ",%7.6f"4
% "A3_6_MFRgnd940"      Row 1 F91  ",%7.6f"5
% "A3_7_MFRgnd1625"     Row 1 F92  ",%7.6f"6
% "A3_8_MFRgndTemp"     Row 1 F93  ",%7.6f"7
% "A3_9_MFRgndTHTC"     Row 1 F94  ",%7.6f"8
% "A3_10_MFR_heater"    Row 1 F95  ",%7.6f"9
% "A3_12_SPN1_tot"      Row 1 F182 ",%7.6f"10
% "A3_13_SPN1_dif"      Row 1 F183 ",%7.6f"11
% 
% "MFRgnd415_W/m^2/nm"    Row 1 F4509 ",%10.6f"12
% "MFRgnd500"           Row 1 F4510 ",%10.6f"
% "MFRgnd615"           Row 1 F4511 ",%10.6f"
% "MFRgnd673"           Row 1 F4512 ",%10.6f"
% "MFRgnd870"           Row 1 F4513 ",%10.6f"
% "MFRgnd940"           Row 1 F4514 ",%10.6f"
% "MFRgnd1625"          Row 1 F4515 ",%10.6f"
% "MFRgndTemp_C"        Row 1 F4516 ",%10.6f"
% "MFRgndTHTC_C"        Row 1 F4517 ",%10.6f"
% 
% "SPN_total_W/m2 "     Row 1 F4602 ",%10.6f"
% "SPN_diff_W/m2"       Row 1 F4603 ",%10.6f"

%%
% from Comstock, IDL code for rad (not rad_cl)
% I parse the time string out of the data matrix, so the first data column after the time string would be index 0 in IDL.
% spntot=data[21,*]
% spndif=data[22,*]
% mfr415=data[12,*]
% mfr500=data[13,*]
% mfr615=data[14,*]
% mfr673=data[15,*]
% mfr870=data[16,*]
% mfr940=data[17,*]
% mfr1625=data[18,*]
% mfrtheadV=data[19,*]
% mfrthtcV=data[20,*]

%%

return
