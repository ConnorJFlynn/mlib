function out = timehtcurtain2rawpopsextfltlvl(mpl, ASD)

% alpha_a is transpose so size(dim1) == length(mpl.time) for interp1
ext_curtain = interp1(mpl.time, mpl.klett.alpha_a', ASD.time, 'linear')';

bin = double(interp1(1000.*mpl.range(1:1001),[1:1001],ASD.alt_m_AGL, 'nearest', 'extrap')');
ij = sub2ind(size(ext_curtain),bin, [1:length(bin)]');
out = ext_curtain(ij);

% % This also works...
% for t = length(aafnav.time):-1:1
%    out(t) = real(ext_curtain(bin(t),t));
% end
figure; scatter(serial2Hh(ASD.time), ASD.alt_m_AGL./1000, 12,out)

figure; plot(out, ASD.alt_m_AGL./1000,'x'); xlabel('ext [1/km]'); ylabel('flight alt (km)');
title(['MPL extinction profile mapped to AAF flight ',datestr((ASD.time(1)),'yyyy-mm-dd HH-'),datestr((ASD.time(end)),'HH UT')])
hold('on')
figure; 
plot(ASD.ext_532, ASD.alt_m_AGL./1000,'r.');
figure; plot(nanmean(mpl.klett.alpha_a(:,mpl.time>ASD.time(1)&mpl.time<ASD.time(end)),2), mpl.range(1:1001),'kx')

end