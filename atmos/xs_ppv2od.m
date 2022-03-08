function od_spec = xs_ppv2od (xs,ppv)
% od_spec = xs_ppv2od (xs,ppv)
% yields OD spectra from supplied gas cross-section and ammount in ppv 

% Example CH4 PPV ppv = 1860e-9;
Losch = 2.687e19; %molec/cm3
nm_hi = xs(:,1); xs = xs(:,2);
coef = xs.*Losch;
cm = ppv2cm(ppv);
od_spec = coef.*cm;

end