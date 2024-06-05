function twst = twst_LP(in_file)
if ~isavar('in_file')||isempty(in_file)
   in_file = getfullname('*TWST*.nc','twst_nc4','Select instrument-level TWST file(s)');
end
if isstruct(in_file)&&~empty(in_file)&&isafile(in_file{1})
   in_file = in_file{1};
end
twst = twst4_to_struct(in_file)

% Open, 395, 455, 495, 550, 570, 610, 715, 780, 1200, 1350 15-s each
spec = {'Open', '395', '455', '495', '550', '570', '610', '715', '780', '1200', '1350'}
n = n +1;
plot(twst.wl_B, twst.zenrad_B(:,15.*(n-1)+[4:15]), '-b'); legend(spec{n})
% 455 2:15
% 780 [4:15]),
n = 1;
full_A = mean(twst.zenrad_A(:,[2:14]),2);
n = n +1;
LP_395 = mean(twst.zenrad_A(:,15.*(n-1)+[2:14]),2); 
n = n +1;
LP_455 = mean(twst.zenrad_A(:,15.*(n-1)+[2:14]),2); 
n = n +1;
LP_495 = mean(twst.zenrad_A(:,15.*(n-1)+[2:14]),2);
n = n +1;
LP_550 = mean(twst.zenrad_A(:,15.*(n-1)+[2:14]),2);
n = n +1;
LP_570 = mean(twst.zenrad_A(:,15.*(n-1)+[2:14]),2);
n = n +1;
LP_610 = mean(twst.zenrad_A(:,15.*(n-1)+[2:14]),2);
n = n +1;
LP_715 = mean(twst.zenrad_A(:,15.*(n-1)+[2:14]),2);
n = n +1;
LP_780 = mean(twst.zenrad_A(:,15.*(n-1)+[4:14]),2);
n = n +1;
LP_1200 = mean(twst.zenrad_B(:,15.*(n-1)+[2:14]),2);
n = n +1;
LP_1350 = mean(twst.zenrad_B(:,15.*(n-1)+[2:14]),2);
full_B = mean(twst.zenrad_B(:,15*8+[2:14]),2);

figure; plot(twst.wl_A, [LP_395./full_A,LP_455./full_A,LP_495./full_A,LP_550./full_A,LP_570./full_A,LP_610./full_A,LP_715./full_A,LP_780./full_A],'-'); 

figure; plot(twst.wl_B, [LP_1200./full_B,LP_1350./full_B],'-'); 

figure; plot(twst.wl_A, twst.zenrad_A(:,[1:15]), '-b',twst.wl_A, twst.zenrad_A(:,15+ [1:15]), '-g',twst.wl_A, twst.zenrad_A(:,30+ [1:15]), '-r')

figure; plot(twst.wl_A, full_A, '-', twst.wl_B, full_B,'-');

figure; plot(twst.wl_A, 