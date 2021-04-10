function nsu = read_k8_nsu(filename);
%Script to read out Cimel ASCII files produced by Cimel Photoget software
%Script assumes that ASCII file is tab-delimited
%
%CJF 2015-09-11

if ~exist('filename', 'var')|~exist(filename,'file')
    filename = getfullname('*.nsu','k8');
    
end
fid = fopen(filename);

% 08/09/2015,21:48:57,
% 10 values 480875,906464,766204,908690,540753,725142,574059,334339,76093,8502,
% another 10 480962,906181,766560,908397,540481,724238,573608,332691,75981,8486,
% and another 480655,906076,765985,907652,539921,724244,573484,332867,75890,8476,
% and a temperature 36.9,

data = textscan(fid,'%d %d %d %d %d %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','delimiter',',/:','treatAsEmpty','!!!!');
fclose(fid);

day = data{1};data(1) = [];
month = data{1};data(1) = [];
year=data{1};data(1) = [];
hour=data{1};data(1) = [];
minute=data{1};data(1) = [];
second=data{1};data(1) = [];
V = [year,month,day,hour,minute,second];
nsu.time = datenum(double(V));
nsu.ch1a = data{1};data(1) = [];
nsu.ch2a = data{1};data(1) = [];
nsu.ch3a = data{1};data(1) = [];
nsu.ch4a = data{1};data(1) = [];
nsu.ch5a = data{1};data(1) = [];
nsu.ch6a = data{1};data(1) = [];
nsu.ch7a = data{1};data(1) = [];
nsu.ch8a = data{1};data(1) = [];
nsu.ch9a = data{1};data(1) = [];
nsu.ch10a = data{1};data(1) = [];

nsu.ch1b = data{1};data(1) = [];
nsu.ch2b = data{1};data(1) = [];
nsu.ch3b = data{1};data(1) = [];
nsu.ch4b = data{1};data(1) = [];
nsu.ch5b = data{1};data(1) = [];
nsu.ch6b = data{1};data(1) = [];
nsu.ch7b = data{1};data(1) = [];
nsu.ch8b = data{1};data(1) = [];
nsu.ch9b = data{1};data(1) = [];
nsu.ch10b = data{1};data(1) = [];

nsu.ch1c = data{1};data(1) = [];
nsu.ch2c = data{1};data(1) = [];
nsu.ch3c = data{1};data(1) = [];
nsu.ch4c = data{1};data(1) = [];
nsu.ch5c = data{1};data(1) = [];
nsu.ch6c = data{1};data(1) = [];
nsu.ch7c = data{1};data(1) = [];
nsu.ch8c = data{1};data(1) = [];
nsu.ch9c = data{1};data(1) = [];
nsu.ch10c = data{1};data(1) = [];

nsu.headT = data{1};data(1) = [];

nsu.ch1 = mean([nsu.ch1a,nsu.ch1b, nsu.ch1c],2);
nsu.ch2 = mean([nsu.ch2a,nsu.ch2b, nsu.ch2c],2);
nsu.ch3 = mean([nsu.ch3a,nsu.ch3b, nsu.ch3c],2);
nsu.ch4 = mean([nsu.ch4a,nsu.ch4b, nsu.ch4c],2);
nsu.ch5 = mean([nsu.ch5a,nsu.ch5b, nsu.ch5c],2);
nsu.ch6 = mean([nsu.ch6a,nsu.ch6b, nsu.ch6c],2);
nsu.ch7 = mean([nsu.ch7a,nsu.ch7b, nsu.ch7c],2);
nsu.ch8 = mean([nsu.ch8a,nsu.ch8b, nsu.ch8c],2);
nsu.ch9 = mean([nsu.ch9a,nsu.ch9b, nsu.ch9c],2);
nsu.ch10 = mean([nsu.ch10a,nsu.ch10b, nsu.ch10c],2);

nsu.nch1 = nsu.ch1./max(nsu.ch1);
nsu.nch2 = nsu.ch2./max(nsu.ch2);
nsu.nch3 = nsu.ch3./max(nsu.ch3);
nsu.nch4 = nsu.ch4./max(nsu.ch4);
nsu.nch5 = nsu.ch5./max(nsu.ch5);
nsu.nch6 = nsu.ch6./max(nsu.ch6);
nsu.nch7 = nsu.ch7./max(nsu.ch7);
nsu.nch8 = nsu.ch8./max(nsu.ch8);
nsu.nch9 = nsu.ch9./max(nsu.ch9);
nsu.nch10 = nsu.ch10./max(nsu.ch10);
nsu.nT = nsu.headT./max(nsu.headT);

nsu.ch1_sd = std([nsu.ch1a,nsu.ch1b, nsu.ch1c]')'./nsu.ch1;
nsu.ch2_sd = std([nsu.ch2a,nsu.ch2b, nsu.ch2c]')'./nsu.ch2;
nsu.ch3_sd = std([nsu.ch3a,nsu.ch3b, nsu.ch3c]')'./nsu.ch3;
nsu.ch4_sd = std([nsu.ch4a,nsu.ch4b, nsu.ch4c]')'./nsu.ch4;
nsu.ch5_sd = std([nsu.ch5a,nsu.ch5b, nsu.ch5c]')'./nsu.ch5;
nsu.ch6_sd = std([nsu.ch6a,nsu.ch6b, nsu.ch6c]')'./nsu.ch6;
nsu.ch7_sd = std([nsu.ch7a,nsu.ch7b, nsu.ch7c]')'./nsu.ch7;
nsu.ch8_sd = std([nsu.ch8a,nsu.ch8b, nsu.ch8c]')'./nsu.ch8;
nsu.ch9_sd = std([nsu.ch9a,nsu.ch9b, nsu.ch9c]')'./nsu.ch9;
nsu.ch10_sd = std([nsu.ch10a,nsu.ch10b, nsu.ch10c]')'./nsu.ch10;

figure; plot(serial2hs(nsu.time), [nsu.ch1, nsu.ch2, nsu.ch3,nsu.ch4, nsu.ch5],'.');
legend('1','2','3','4','5')
title('Cimel sun triplet means');

figure; plot(serial2hs(nsu.time), [nsu.ch6, nsu.ch7, nsu.ch8, nsu.ch9,nsu.ch10],'-');
legend('6','7','8','9','10')
title('Cimel sun triplet means');

figure; plot(nsu.time, [nsu.nch1, nsu.nch2, nsu.nch3,nsu.nch4, nsu.nch5,...
   nsu.nch6, nsu.nch7, nsu.nch8, nsu.nch9,nsu.nch10],'x');
dynamicDateTicks;
   zoom('on');
   title('Zoom in to restrict the desired region of data to use.');
% menu('Zoom in to restrict the desired region of data to use.','OK');    
%   v = axis;
% out = (nsu.time)<v(1) | (nsu.time)>v(2) ;
% 
% nsu.nch1(out|nsu.nch1<v(3)) = NaN; nsu.nch2(out|nsu.nch2<v(3)) = NaN; 
% nsu.nch3(out|nsu.nch3<v(3)) = NaN; nsu.nch4(out|nsu.nch4<v(3)) = NaN;
% nsu.nch5(out|nsu.nch5<v(3)) = NaN; nsu.nch6(out|nsu.nch6<v(3)) = NaN;
% nsu.nch7(out|nsu.nch7<v(3)) = NaN; nsu.nch8(out|nsu.nch8<v(3)) = NaN;
% nsu.nch9(out|nsu.nch9<v(3)) = NaN; nsu.nch10(out|nsu.nch10<v(3)) = NaN;

nsu.I_340 = nsu.ch10;
nsu.I_380 = nsu.ch9;
nsu.I_440 = nsu.ch5;
nsu.I_500 = nsu.ch6;
nsu.I_675 = nsu.ch4;
nsu.I_870 = nsu.ch3;
nsu.I_939 = nsu.ch8;
nsu.I_1019 = nsu.ch1;
nsu.I_1020 = nsu.ch7;
nsu.I_1640 = nsu.ch2;
nsu.I = [nsu.I_340,nsu.I_380,nsu.I_440,nsu.I_500,nsu.I_675,nsu.I_870,nsu.I_939,nsu.I_1019,nsu.I_1020,nsu.I_1640];
nsu.wl = [340,380,440,500,675,870,940,1019,1020,1640];
%  plot(serial2hs(nsu.time), [nsu.nch1, nsu.nch2, nsu.nch3,nsu.nch4, nsu.nch5,...
%    nsu.nch6, nsu.nch7, nsu.nch8, nsu.nch9,nsu.nch10],'*');
%    legend('1','2','3','4','5','6','7','8','9','10');
%    % From Ilya Slutsker:
%    legend('1020 Si', '1640 nm','870 nm','675 nm', '440 nm', '500 nm', '1020 In','940 nm','380 nm','340 nm')
%    
figure
these = plot(nsu.time, nsu.I(:,1:5),'x',nsu.time, nsu.I(:,6:10),'-'); recolor(these, nsu.wl);
legend('1640 nm','1020 In','1019 Si','939 nm', '870 nm','675 nm','500 nm', '440 nm','380 nm','340 nm');
legend('340 nm','380 nm','440 nm','500 nm','675 nm','870 nm','939 nm','1019 Si','1020 In','1640 nm');

zoom('on');
dynamicDateTicks
title('Cimel signals normalized to maximum.');
% axis(v);

  %   Ilya              I thought...
% filter 1 1020 Si        870?             Mismatch
% filter 2 1640 InGa      1640             
% filter 3 870 Si         780?             Mismatch
% filter 4 675 Si         675              
% filter 5 440            937              Mismatch
% filter 6 500            500
% filter 7 1020 In        1020
% filter 8 940 nm,        440?             Mismatch
% filter 9 380            380
% filter 10 340           340
% head T
% I swapped 440 and 940, and I didn't know about 1020 Si.  And I though 870 looked shorter
   

  %From 4STAR comparisons
  % Is channel 1 (cyan) = 870 nm?
  % Is channel 2 (brt grn) = 1640?
  % channel 3 (brn / dark red) maybe 780?. 
  % channel 4 (teal) looks like 675
  % Is channel 5 (purple changed to pink) 937 nm
  % channel 6 (grn-gold looks like 500 nm
  % channel 7 (black) 1020?  
  % channel 8 (blue) looks shorter than 452.  Probably 440 nm
  % channel 9 (dark grn)  matches AATS 380 nm
  % channel 10 (red) looks shorter than AATS 354, so is probably 340.
  
  %#3?
  

% #2 wl_1640 = 1639.700000
% #7 wl_1020 = 1020.100000
% #1 wl_870 = 869.500000
% #4 wl_675 = 674.400000
%wl_ =N/A
%wl_ = N/A
%wl_ = N/A
%wl_ N/A
%wl _ N/A
%#6 wl_500 = 500.400000
%wl_=N/A
%wl_=N/A,
%#8 wl_440 = 439.900000;
%wl_ =N/A
%#9 wl_380 = 379.500000;
%#10 wl_340 = 341.100000
%#5 wl_937 = 937.000000;


% % from Ilya Slutsker:
% filter 1 1020 Si
% filter 2 1640 InGa
% filter 3 870 Si
% filter 4 675 Si
% filter 5 440
% filter 6 500
% filter 7 1020 In
% filter 8 940 nm, 
% filter 9 380
% filter 10 340
% head T
% 
% Polarization:
% 
% PPL polarized, first 6 all same channels, 
% pol ALM R, ALM L
% Pol hybrid, starts at larger angle. 

return
