% det_23928
det.RS_KHz = [5.9,36.3, 91.6 227.7 571.6 1398.3 2173.8 3257.3 4796.7 6898.4 ...
   9624.7 11050.2 12597.8 14127.4 15701.7 17309.1 18845.8 20250.8 21602, ...
   22787.2 23832 24748.2 25527.9 26239.4 26629.6];
det.cf = [ 1 1.02 1.01 1.02 1.02, 1.05, 1.07, 1.13 1.22 1.34 1.53 1.67 1.85 ...
   2.08 2.35 2.69 3.1 3.64 4.29 5.12 6.17 7.48 9.12 11.18 13.86];

td = 29e-9; RS_Hz = det.RS_KHz.*1e3;
cf = 1./(1-td.*RS_Hz);

figure; plot(det.RS_KHz./1000, cf, 'c-o', det.RS_KHz./1000, det.cf,'b-x');
xlabel('Reported Counts (MHz)'); ylabel('Correction factor'); 
title('Detector 23928');
legend('based on deadtime','from tabled values')