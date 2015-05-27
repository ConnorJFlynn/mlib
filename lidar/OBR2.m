lambda = 1e-9*[100:10:2000];
T = [3250]
radiant_intensity = planck(T,lambda);
Si_resp = [100,299, 300,350,400,450,500,550,600,650,700,750,800,850,900,950,1000,1050,1100, 1150, 2050;0,0,0.07,.13, .2,.3,.35,.38,.405,.435,.45,.485,.52,.55,.44,.28,.08,.04,.01, 0, 0];
Si_2 = interp1(Si_resp(1,:), Si_resp(2,:), 1e9*lambda);
detected = radiant_intensity .* Si_2;
sum_rad =sum(detected)
frac_rad = detected;
frac_rad = frac_rad ./ sum_rad;

sub = find((lambda>=100e-9)&(lambda<=1200e-9));
subsub = find((lambda>=400e-9)&(lambda<=800e-9));

figure; plot(lambda(subsub), 1./frac_rad(:,subsub)')
Title(['Ratio of expected out of band to in band signal'])
text(6.5e-7, 500, 'Cyan is for 3500 K')
text(6.5e-7, 450, 'Violet is for 5800 K')
figure; plot(lambda(subsub), 1e-4./frac_rad(:,subsub)')
Title(['Fractional Out of Band contribution for 0.01% rejection.'])
text(6.5e-7, .0450, 'Violet: 5800 K')
text(6.5e-7, .050, 'Cyan: 3500 K')