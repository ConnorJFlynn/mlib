% Trying to devise a finger-print for TAP filter
% Taking 
% Known white filter
tap = rd_tap_tty(getfullname('*.log','tap_tty'));
mean_ref_blue = (mean(tap.signal_blue(9:10,:)));
mean_ref_green = (mean(tap.signal_green(9:10,:)));
mean_ref_red = (mean(tap.signal_red(9:10,:)));
norm_blue = tap.signal_blue./(ones([10,1])*mean_ref_blue);
norm_green = tap.signal_green./(ones([10,1])*mean_ref_green);
norm_red = tap.signal_red./(ones([10,1])*mean_ref_red);
blue_marks = mean(norm_blue,2);
green_marks = mean(norm_green,2);
red_marks = mean(norm_red,2);
rgb_marks = [red_marks; green_marks; blue_marks];
[marks, inds] = sort(rgb_marks);
figure; plot([1:30],marks,'o-',find(inds<11), marks(find(inds<11)), 'r*',...
   find(inds>10 & inds<21), marks(find(inds>10 & inds<21)), 'g*',...
   find(inds>20), marks(find(inds>20)), 'b*');
figure; plot([1:10],rgb_marks(1:10),'rx',...
   [1:10],rgb_marks(11:20),'gx',...
   [1:10],rgb_marks(21:30),'bx');

% Now select next filter run
tap2 = rd_tap_tty(getfullname('*.log','tap_tty'));
mean_ref_blue_2 = (mean(tap2.signal_blue(9:10,:)));
mean_ref_green_2 = (mean(tap2.signal_green(9:10,:)));
mean_ref_red_2 = (mean(tap2.signal_red(9:10,:)));
norm_blue_2 = tap2.signal_blue./(ones([10,1])*mean_ref_blue_2);
norm_green_2 = tap2.signal_green./(ones([10,1])*mean_ref_green_2);
norm_red_2 = tap2.signal_red./(ones([10,1])*mean_ref_red_2);
blue_marks_2 = mean(norm_blue_2,2);
green_marks_2 = mean(norm_green_2,2);
red_marks_2 = mean(norm_red_2,2);
rgb_marks_2 = [red_marks_2; green_marks_2; blue_marks_2];
figure; 
sb(1) = subplot(3,1,1); plot([1:30],marks,'o-', [1:30],rgb_marks_2(inds),'kx-');
tl = title({['Ref:',tap.fname];['2nd:',tap2.fname]}); set(tl, 'interp','none')
sb(2) = subplot(3,1,2); plot([1:30],100.*(marks-rgb_marks_2(inds)),'+r-'); linkaxes(sb,'x');
res = std(marks-rgb_marks_2(inds));
title([sprintf('Standard deviation = %2.2f',100.*res),'%']);
ylim([-1,1]);ylabel('% diff')
subplot(3,1,3); plot([1:10],100.*(rgb_marks(1:10)-rgb_marks_2(1:10)),'rx',...
   [1:10],100.*(rgb_marks(11:20)-rgb_marks_2(11:20)),'gx',...
   [1:10],100.*(rgb_marks(21:30)-rgb_marks_2(21:30)),'bx');
lim([-1,1]);ylabel('% diff'); xlabel('spot #')


