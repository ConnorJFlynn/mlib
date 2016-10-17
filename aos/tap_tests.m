% TAP filter tests
% Analyzing variability of TAP signals for white/clean filters
% Repeated for same filter, same postion and repositioned, and for
% different filters, and for filter-errors (two filters, filter upside
% down)

[tap, raw] = rd_tap_tty(getfullname('*.log','tap_tty'));

% figure; 
% sb(1) = subplot(2,1,1); 
% plot(1:length(tap.time), tap.flags,'o');
% title(raw.fname, 'interp','none')
% sb(2) = subplot(2,1,2); 
% plot(1:length(tap.time), tap.signal_blue, 'x');
% linkaxes(sb,'x');

[tap2, raw2] = rd_tap_tty(getfullname('*.log','tap_tty'));

figure(1); 
ch = 1;
sb(1) = subplot(5,1,ch);
plot(1:length(tap2.time), 100.*(tap2.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap2.time), 100.*(tap2.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap2.time), 100.*(tap2.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');
title(raw2.fname, 'interp','none')

ch = 2;
sb(2) = subplot(5,1,ch);
plot(1:length(tap2.time), 100.*(tap2.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap2.time), 100.*(tap2.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap2.time), 100.*(tap2.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 3;
sb(3) = subplot(5,1,ch);
plot(1:length(tap2.time), 100.*(tap2.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap2.time), 100.*(tap2.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap2.time), 100.*(tap2.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 4;
sb(4) = subplot(5,1,ch);
plot(1:length(tap2.time), 100.*(tap2.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap2.time), 100.*(tap2.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap2.time), 100.*(tap2.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 5;
sb(5) = subplot(5,1,ch);
plot(1:length(tap2.time), 100.*(tap2.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap2.time), 100.*(tap2.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap2.time), 100.*(tap2.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

figure(2); 
ch = 6;
sb(6) = subplot(5,1,ch-5);
plot(1:length(tap2.time), 100.*(tap2.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap2.time), 100.*(tap2.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap2.time), 100.*(tap2.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');
title(raw2.fname, 'interp','none')

ch = 7;
sb(7) = subplot(5,1,ch-5);
plot(1:length(tap2.time), 100.*(tap2.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap2.time), 100.*(tap2.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap2.time), 100.*(tap2.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 8;
sb(8) = subplot(5,1,ch-5);
plot(1:length(tap2.time), 100.*(tap2.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap2.time), 100.*(tap2.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap2.time), 100.*(tap2.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 9;
sb(9) = subplot(5,1,ch-5);
plot(1:length(tap2.time), 100.*(tap2.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap2.time), 100.*(tap2.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap2.time), 100.*(tap2.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

ch = 10;
sb(10) = subplot(5,1,ch-5);
plot(1:length(tap2.time), 100.*(tap2.signal_blue(ch,:) - mean(tap.signal_blue(ch,:)))./mean(tap.signal_blue(ch,:)), 'b-', ...
    1:length(tap2.time), 100.*(tap2.signal_green(ch,:) - mean(tap.signal_green(ch,:)))./mean(tap.signal_green(ch,:)), 'g-', ...
    1:length(tap2.time), 100.*(tap2.signal_red(ch,:) - mean(tap.signal_red(ch,:)))./mean(tap.signal_red(ch,:)), 'r-');

figure(3)
plot(1:length(tap2.time), tap2.spot_active, 'o-');title('active spot');sb(end+1) = gca; 
linkaxes(sb,'x')
