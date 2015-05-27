NASA Ames Radiation Calibration facility light sources

SWS calibration visits:
2008_11_19 - Optronics - use 2008_02_04 calibration
2009_07_01 - SPEX, 30" sphere - use 2009_03_14 calibration
2009_09_08 - 30" sphere - use 2009_03_14 calibration

ARCHI_30" calibration files
   2005_09_17   
   2007_05_18
   2008_03_14
   
   
Optronics OL 746 (ARC radiance standard 455)
   Feb 4, 2008, apers A,B,C,D
   March 19, 2008

% build Archi 30 calibration source,
% patching optronic with a Planck curve below 450 nm worked reasonably well
% (sws_cal_scraps).  Not sure how well it's working for Archi 30.  How did
% previous SWS team calibrate below ARCHI or Opronics quoted ranges?
Archi_30in.12lamp.time(N)
Archi_30in.12lamp.radiance_units
Archi_30in.12lamp.flux(N)

Archi_30in.12lamp.cal{N}.nm
Archi_30in.12lamp.cal{N}.radiance
Archi_30in.12lamp.cal{N}.radiance_orig
Archi_30in.12lamp.cal{N}.planck
Archi_30in.12lamp.cal{N}.planck_T
Archi_30in.12lamp.cal{N}.radiance_note