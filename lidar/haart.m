function wct = haart(height, prof);
bins = 1:length(height);
dz = height(2)-height(1);

min_h = 0.25; max_h = 15; % Not general, specific to MPL-ML 
min_b = find(height>min_h, 1,'first');
max_b = find(height<max_h,1,'last');

dil = floor(height./(4.*dz));
dil(dil < floor(min_b/2)) = floor(min_b/2);
max_dil = floor(1.2./dz);
dil(dil>max_dil) = max_dil;
p25 = find(height>.25,1,'first');
profr2 = prof.*height.^2;
profr2(1:p25) = profr2(p25);
profr2 = profr2 ./ max(profr2(height<2));
figure; plot(bins, profr2, '-'); legend('profr2')

wct = NaN(size(profr2));
dil = dil./dil;
for b = min_b:max_b
   wct(b) = sum(profr2((b):(b-dil(b))))-sum(profr2((b):(b+dil_a(b)))) - 2.*profr2(b)*dil_a(b);;
end
figure; plot(bins, wct,'-'); legend('wct')

figure; plot(height, dil.*dz,'-')
