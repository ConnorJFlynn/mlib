function filt = cim1640filtfun
filt= load(['cim1640filt.mat']);
% filt.nm = filt.txt(:,1);
% filt.Tr = filt.txt(:,2); filt.Tr = filt.Tr./trapz(filt.nm, filt.Tr);
% outmat = which('cim1640filt.mat','-all'); outmat = outmat{1};
% filt = rmfield(filt,'txt')
% save(outmat,'-struct','filt')
% figure; plot(filt.nm, filt.Tr,'-')

end