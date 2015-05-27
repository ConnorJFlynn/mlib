function [status, statics] = process_ipa;
%[status, statics] = process_ipa;
% Steps through ingest of ipa ocr and ps files
% Then applies dtc and meshes files with ophir and mirror data
% 2005-04-01 CJF
%
% Modifying/completing to provide finished IPA IOP data set to ARM
% Need to check dtc for ocr and mplps
% 2006-07-13 CJF

% Ingest ocr data
statics.in_dir = ['D:\case_studies\ipa\lidar\processed\ipasmplocrC1.00\'];
statics.out_dir = ['D:\case_studies\ipa\lidar\processed\ipasmplocrC1.a0\'];
statics.fstem = 'ipasmplocrC1.a0';
statics.datastream = statics.fstem ;
statics.datalevel = 'a0';
statics.polarized = 'no';
statics.ocr = 'yes';
statics.scanning = 'yes';
statics.averaging_int = '10 seconds';
statics.lat = 40.38;
statics.lon = -79.06;
statics.alt = 1405*12*2.54*1e-2;%feet to inches to cm to meters
[status] = ingest_ipasmpl(statics);
%[status] = ingest_ipasmplocr(statics);

% Mesh ocr data with em and mirror
statics.mirror_fullname = 'C:\case_studies\ipa\Alldays\mat_files\mirror.mat';
statics.ophir_fullname = 'C:\case_studies\ipa\Alldays\mat_files\ophir.mat';
statics.in_dir = ['D:\case_studies\ipa\lidar\processed\ipasmplocrC1.a0\'];
statics.out_dir = ['D:\case_studies\ipa\lidar\processed\ipasmplocrC1.a1\'];
statics.fstem = 'ipasmplocrC1.a1.';
statics.datastream = statics.fstem ;
statics.datalevel = 'a1';
statics.polarized = 'no';
statics.ocr = 'yes';
statics.scanning = 'yes';
statics.averaging_int = '10 seconds';
[status] = mesh_ipaps_5(statics);

% Ingest mplps data
statics.in_dir = ['D:\case_studies\ipa\lidar\processed\ipasmplpsC1.00\tmp\'];
statics.out_dir = ['D:\case_studies\ipa\lidar\processed\ipasmplpsC1.a0\tmp\'];
statics.fstem = 'ipasmplpsC1.a0';
statics.datastream = statics.fstem ;
statics.datalevel = 'a0';
statics.polarized = 'yes';
statics.ocr = 'no';
statics.scanning = 'yes';
statics.averaging_int = '5 seconds';
statics.lat = 40.38;
statics.lon = -79.06;
statics.alt = 1405*12*2.54*1e-2;%feet to inches to cm to meters
% [status] = ingest_ipasmpl(statics);

% Mesh mplps data with em and mirror
statics.mirror_fullname = 'C:\case_studies\ipa\Alldays\mat_files\mirror.mat';
statics.ophir_fullname = 'C:\case_studies\ipa\Alldays\mat_files\ophir.mat';
statics.in_dir = ['D:\case_studies\ipa\lidar\processed\ipasmplpsC1.a0\tmp\'];
statics.out_dir = ['D:\case_studies\ipa\lidar\processed\ipasmplpsC1.a1\tmp\'];
statics.fstem = 'ipasmplpsC1.a1.';
statics.datastream = statics.fstem ;
statics.datalevel = 'a1';
statics.polarized = 'yes';
statics.ocr = 'no';
statics.scanning = 'yes';
statics.averaging_int = '5 seconds';
[status] = mesh_ipaps_5(statics);
