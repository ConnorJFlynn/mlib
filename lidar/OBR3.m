lambda = 1e-9*[100:10:2000];
T = [3250, 5800]
radiant_intensity = planck(T,lambda);
Si_resp = [100,299, 300,350,400,450,500,550,600,650,700,750,800,850,900,950,1000,1050,1100, 1150, 2050;0,0,0.07,.13, .2,.3,.35,.38,.405,.435,.45,.485,.52,.55,.44,.28,.08,.04,.01, 0, 0];
Si_2 = interp1(Si_resp(1,:), Si_resp(2,:), 1e9*lambda);

for i = 1:length(T)
    detected(i,:) = radiant_intensity(i,:) .* Si_2;
%        detected(i,:) = radiant_intensity(i,:);
    sum_rad = sum(detected(i,:))
    frac_rad(i,:) = detected(i,:) ./ sum_rad;
end
sub = find((lambda>=100e-9)&(lambda<=1200e-9));
subsub = find((lambda>=400e-9)&(lambda<=900e-9));
figure; plot(lambda(subsub), 1./frac_rad(:,subsub)')
Title(['Ratio of expected out of band to in band signal'])
text(6.5e-7, 500, 'Blue is for 3250 K')
text(6.5e-7, 450, 'Green is for 5800 K')
figure; plot(lambda(subsub), 1e-4./frac_rad(:,subsub)')
Title(['Fractional Out of Band contribution for 0.01% rejection.'])
text(6.5e-7, .0450, 'Blue: 5800 K')
text(6.5e-7, .050, 'Green: 3250 K')