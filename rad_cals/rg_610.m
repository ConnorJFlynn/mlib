function out = rg_610
mat = [mfilename('fullpath'),'.mat'];
if exist(mat,'file')
    out = load(mat);
else
    data = read_txt;
    out.nm = data(:,1:2:end);
    out.nm = out.nm(:);
    out.Tr = data(:,2:2:end);
    out.Tr = out.Tr(:);
    save(mat, '-struct','out');
end

return

function data = read_txt 
% Copied from Schott glass table in PDF file
data =  [200  1.0E-05 500  1.0E-05 800 9.7E-01 1100 9.6E-01 2200 9.5E-01 3700 2.3E-01
210  1.0E-05 510  1.0E-05 810 9.7E-01 1110 9.6E-01 2250 9.5E-01 3750 2.4E-01
220  1.0E-05 520  1.0E-05 820 9.7E-01 1120 9.6E-01 2300 9.6E-01 3800 2.5E-01
230  1.0E-05 530  1.0E-05 830 9.7E-01 1130 9.6E-01 2350 9.6E-01 3850 2.6E-01
240  1.0E-05 540  1.0E-05 840 9.7E-01 1140 9.6E-01 2400 9.5E-01 3900 2.7E-01
250  1.0E-05 550  1.0E-05 850 9.7E-01 1150 9.6E-01 2450 9.5E-01 3950 2.8E-01
260  1.0E-05 560  1.0E-05 860 9.7E-01 1160 9.6E-01 2500 9.5E-01 4000 2.7E-01
270  1.0E-05 570 2.1E-05 870 9.7E-01 1170 9.6E-01 2550 9.4E-01 4050 2.6E-01
280  1.0E-05 580 1.5E-03 880 9.7E-01 1180 9.6E-01 2600 9.3E-01 4100 2.4E-01
290  1.0E-05 590 3.1E-02 890 9.7E-01 1190 9.6E-01 2650 9.2E-01 4150 2.1E-01
300  1.0E-05 600 2.0E-01 900 9.7E-01 1200 9.7E-01 2700 8.7E-01 4200 1.8E-01
310  1.0E-05 610 5.2E-01 910 9.7E-01 1250 9.7E-01 2750 5.2E-01 4250 1.5E-01
320  1.0E-05 620 7.7E-01 920 9.6E-01 1300 9.7E-01 2800 3.7E-01 4300 1.1E-01
330  1.0E-05 630 8.9E-01 930 9.6E-01 1350 9.7E-01 2850 3.6E-01 4350 7.8E-02
340  1.0E-05 640 9.5E-01 940 9.6E-01 1400 9.7E-01 2900 3.7E-01 4400 4.8E-02
350  1.0E-05 650 9.7E-01 950 9.6E-01 1450 9.8E-01 2950 3.7E-01 4450 2.4E-02
360  1.0E-05 660 9.7E-01 960 9.6E-01 1500 9.8E-01 3000 3.5E-01 4500 1.1E-02
370  1.0E-05 670 9.8E-01 970 9.6E-01 1550 9.8E-01 3050 3.3E-01 4550 4.5E-03
380  1.0E-05 680 9.8E-01 980 9.6E-01 1600 9.8E-01 3100 3.0E-01 4600 1.6E-03
390  1.0E-05 690 9.8E-01 990 9.6E-01 1650 9.8E-01 3150 2.8E-01 4650 5.7E-04
400  1.0E-05 700 9.8E-01 1000 9.6E-01 1700 9.8E-01 3200 2.5E-01 4700 2.5E-04
410  1.0E-05 710 9.8E-01 1010 9.6E-01 1750 9.8E-01 3250 2.3E-01 4750 1.3E-04
420  1.0E-05 720 9.8E-01 1020 9.6E-01 1800 9.8E-01 3300 2.2E-01 4800 6.7E-05
430  1.0E-05 730 9.8E-01 1030 9.6E-01 1850 9.8E-01 3350 2.1E-01 4850 3.4E-05
440  1.0E-05 740 9.8E-01 1040 9.6E-01 1900 9.8E-01 3400 2.0E-01 4900 1.7E-05
450  1.0E-05 750 9.8E-01 1050 9.6E-01 1950 9.8E-01 3450 1.9E-01 4950  1.0E-05
460  1.0E-05 760 9.8E-01 1060 9.6E-01 2000 9.7E-01 3500 1.9E-01 5000  1.0E-05
470  1.0E-05 770 9.8E-01 1070 9.6E-01 2050 9.7E-01 3550 2.0E-01 5050  1.0E-05
480  1.0E-05 780 9.7E-01 1080 9.6E-01 2100 9.7E-01 3600 2.1E-01 5100  1.0E-05
490  1.0E-05 790 9.7E-01 1090 9.6E-01 2150 9.7E-01 3650 2.2E-01 5150  1.0E-05];
return