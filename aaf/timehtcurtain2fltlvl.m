function out = timehtcurtain2fltlvl(mpl, popsext)

% alpha_a is transpose so size(dim1) == length(mpl.time) for interp1
ext_curtain = interp1(mpl.time, mpl.klett.alpha_a', popsext.time, 'linear')';

bin = interp1(mpl.range(1:1001),[1:1001],popsext.alt_mAGL./1000, 'nearest');

out = real(ext_curtain(sub2ind(size(ext_curtain),bin', 1:length(bin))));

% % This also works...
% for t = length(aafnav.time):-1:1
%    out(t) = real(ext_curtain(bin(t),t));
% end
figure; scatter(serial2Hh(popsext.time), popsext.alt_mAGL./1000, 12, out)

figure; plot(popsext.ext_um./1e3, popsext.alt_mAGL./1000,'x'); xlabel('ext'); ylabel('flight alt (km)');
title('MPL extinction profile mapped to AAF U2 flight for July 9, 2022')

end