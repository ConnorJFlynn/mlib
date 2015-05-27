Aeronet phase functions...
% 
% SA = [SA;26.3; 28.5; 30.75; 32.98; 35.22; 37.45; 39.7;41.9;44.16;46.4;48.6; 50.8; ...
%    SA;53.1; 55.3; 57.6;59.8; 62.05; 64.29;66.6; 68.76; 71;  73.23; 75.47; 77.7; ...
%    79.94; 82.17; 84.4; 86.65; 88.88; 90];
%%
tot.SA = [0.0000,1.7100,3.9300,6.1600,8.3900,10.6300,12.8600,15.1000,17.3300,19.5700, ...
21.8000,24.0400,26.2800,28.5100,30.7500,32.9800,35.2200,37.4500,39.6900,41.9300,44.1600,46.4000,...
48.6300,50.8700,53.1100,55.3400,57.5800,59.8100,62.0500,64.2900,66.5200,68.7600,70.9900,73.2300,...
75.4700,77.7000,79.9400,82.1700,84.4100,86.6500,88.8800,90.0000,...
91.1200,93.3500,95.5900,...
97.8300,100.0600,102.3000,104.5300,106.7700,109.0100,111.2400,113.4800,115.7100,117.9500,120.1900,...
122.4200,124.6600,126.8900,129.1300,131.3700,133.6000,135.8400,138.0700,140.3100,142.5500,...
144.7800,147.0200,149.2500,151.4900,153.7200,155.9600,158.2000,160.4300,162.6700,164.9000,...
167.1400,169.3700,171.6100,173.8400,176.0700,178.2900,180.0000];
coarse.SA = tot.SA;
fine.SA = tot.SA;
fields = fieldnames(tot);
start_414 = 13;
start_675 = 96;
start_870 = 179;
start_1020 =262;
tot.pf_414nm = tot.(fields{start_414});
tot.pf_675nm = tot.(fields{start_675});
tot.pf_870nm = tot.(fields{start_870});
tot.pf_1020nm = tot.(fields{start_1020});

fine.pf_414nm = fine.(fields{start_414});
fine.pf_675nm = fine.(fields{start_675});
fine.pf_870nm = fine.(fields{start_870});
fine.pf_1020nm = fine.(fields{start_1020});

coarse.pf_414nm = coarse.(fields{start_414});
coarse.pf_675nm = coarse.(fields{start_675});
coarse.pf_870nm = coarse.(fields{start_870});
coarse.pf_1020nm = coarse.(fields{start_1020});

for f = 1:82;
tot.pf_414nm = [tot.pf_414nm, tot.(fields{start_414+f})];
tot.pf_675nm = [tot.pf_675nm, tot.(fields{start_675+f})];
tot.pf_870nm = [tot.pf_870nm, tot.(fields{start_870+f})];
tot.pf_1020nm = [tot.pf_1020nm, tot.(fields{start_1020+f})];

coarse.pf_414nm = [coarse.pf_414nm, coarse.(fields{start_414+f})];
coarse.pf_675nm = [coarse.pf_675nm, coarse.(fields{start_675+f})];
coarse.pf_870nm = [coarse.pf_870nm, coarse.(fields{start_870+f})];
coarse.pf_1020nm = [coarse.pf_1020nm, coarse.(fields{start_1020+f})];

fine.pf_414nm = [fine.pf_414nm, fine.(fields{start_414+f})];
fine.pf_675nm = [fine.pf_675nm, fine.(fields{start_675+f})];
fine.pf_870nm = [fine.pf_870nm, fine.(fields{start_870+f})];
fine.pf_1020nm = [fine.pf_1020nm, fine.(fields{start_1020+f})];
end
   
% pos0pt0000_441nm_, tot.pos1pt7100_441nm_, tot.pos3pt9300_441nm_, ...
%    tot.pos6pt1600_441nm_, tot.pos8pt3900_441nm_, tot.pos10pt6300_441nm_, tot.pos12pt8600_441nm_, ...
%    tot.pos15pt1000_441nm_, tot.pos17pt3300_441nm_, tot.pos19pt5700_441nm_, tot.pos21pt8000_441nm_, ...
%    tot.pos24pt0400_441nm_, tot.pos26pt2800_441nm_, tot.pos28pt5100_441nm_, tot.pos30pt7500_441nm_, ...
%    tot.pos32pt9800_441nm_, tot.pos35pt2200_441nm_, tot.pos37pt4500_441nm_, tot.pos39pt6900_441nm_, ...
%    tot.pos41pt9300_441nm_, tot.pos44pt1600_441nm_, tot.pos46pt4000_441nm_, tot.pos48pt6300_441nm_, ...
%    tot.pos50pt8700_441nm_, tot.pos53pt1100_441nm_, tot.pos55pt3400_441nm_, tot.pos57pt5800_441nm_, ...
%    tot.pos59pt8100_441nm_, tot.pos62pt0500_441nm_, tot.pos64pt2900_441nm_, tot.pos66pt5200_441nm_, ...
%    tot.pos68pt7600_441nm_, tot.pos70pt9900_441nm_, tot.pos73pt2300_441nm_, tot.pos75pt4700_441nm_, ...
%    tot.pos77pt7000_441nm_, tot.pos79pt9400_441nm_, tot.pos82pt1700_441nm_, tot.pos84pt4100_441nm_, ...
%    tot.pos86pt6500_441nm_, tot.pos88pt8800_441nm_, tot.pos90pt0000_441nm_];
% 
% 
% %0.0000,1.7100,3.9300,6.1600,8.3900,10.6300,12.8600,15.1000,17.3300,19.5700
% %,21.8000,24.0400,26.2800,28.5100,30.7500,32.9800,35.2200,37.4500,39.6900,41.9300,44.1600,46.4000,
% %48.6300,50.8700,53.1100,55.3400,57.5800,59.8100,62.0500,64.2900,66.5200,68.7600,70.9900,73.2300,
% %75.4700,77.7000,79.9400,82.1700,84.4100,86.6500,88.8800,90.0000,
% %91.1200,93.3500,95.5900,
% %97.8300,100.0600,102.3000,104.5300,106.7700,109.0100,111.2400,113.4800,115.7100,117.9500,120.1900,
% %122.4200,124.6600,126.8900,129.1300,131.3700,133.6000,135.8400,138.0700,140.3100,142.5500,
% %144.7800,147.0200,149.2500,151.4900,153.7200,155.9600,158.2000,160.4300,162.6700,164.9000,
% %167.1400,169.3700,171.6100,173.8400,176.0700,178.2900,180.0000