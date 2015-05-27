lambda = 1e-9*[100:10:2000 400:.1:450]; % note the emphasis on the 415nm region
%lambda = 1e-9*[100:10:2000]; 
lambda = sort(lambda);
T = [3500 5800];
bandwidth = 1e-8;
radiant_intensity = planck(T,lambda,bandwidth);
sum_rad =trapz(1e8*lambda, radiant_intensity')';
%sum_rad =sum(radiant_intensity')'
frac_rad = radiant_intensity ./ (sum_rad * ones(size(lambda)));
sub = find((lambda>=100e-9)&(lambda<=1200e-9));
subsub = find((lambda>=400e-9)&(lambda<=800e-9));
figure; plot(1e9*lambda(subsub), 1./frac_rad(:,subsub)')
Title(['Ratio of expected out of band to in band signal'])
text(6.5e-7, 500, 'Cyan is for 3500 K')
text(6.5e-7, 450, 'Violet is for 5800 K')
figure; plot(lambda(subsub), 1e-4./frac_rad(:,subsub)')
Title(['Fractional Out of Band contribution for 0.01% rejection.'])
text(6.5e-7, .0450, 'Violet: 5800 K')
text(6.5e-7, .050, 'Cyan: 3500 K')