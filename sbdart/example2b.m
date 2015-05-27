%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matlab script for Example 2
% vary optical depth and surface albedo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

r=[]; % Initialize the data array

for albcon = [0 .2 .4 .6 .8 1] 
for tcloud = [0 1 2 4 8 16 32 64]
r=[r sbdart(...
 'tcloud', tcloud, ...
 'albcon', albcon, ...
 'idatm', 4, ...
 'isat', 0, ...
 'wlinf', .55, ...
 'wlsup', .55, ...
 'isalb', 0, ...
 'iout', 10, ...
 'sza', 30)'];
end
end

% Plot of figure 1
semilogx([0 1 2 4 8 16 32 64],reshape(r(7,:),8,6))
axis tight; ylim([0 2])

title('Monochromatic Surface Irradiance (\lambda=0.55, SZA=30)')
ylabel('w/m^2/{\mu}m');xlabel('wavelength (microns)');
legend(num2str([0 .2 .4 .6 .8 1]','%3.1f'),3)

figure % Initialize new figure to start plotting

% Plot of figure 2
semilogx([0 1 2 4 8 16 32 64],reshape(r(5,:),8,6))
axis tight; ylim([0 1.6])

title('Planetary Albedo (\lambda=0.55, SZA=30)')
ylabel('w/m^2/{\mu}m');xlabel('wavelength (microns)');
legend(num2str([0 .2 .4 .6 .8 1]','%3.1f'),4)