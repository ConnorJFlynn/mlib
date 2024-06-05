% Just a quick scrap file to estimate filter loading times for the PSAP for AMICE
% assuming about 120 1/Mm
% [Bap] = Bap_ss(time, sample_flow, Tr

% model reduction in Tr vs time assuming Beers law

ttime = (0:2*60)./(24*60); % two hours in minutes)
Tr = exp(-8 * ttime); 

figure; plot(ttime*24, Tr,'.'); logy
xlabel('time (hours)') ; ylabel('Filter Tr');
title('PSAP filter Tr vs Time for ~125 1/Mm')

Bap = Bap_ss(ttime, ones(size(ttime)), Tr,30);

figure; plot(ttime*24, Bap,'o')
xlabel('time (hours)') ; ylabel('Bap [1/Mm]]');
