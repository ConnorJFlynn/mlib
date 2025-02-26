function IWP = tzr_iwp(tzr)

pos = tzr.rcod>0;
IWP = NaN(size(tzr.time));
IWP(pos) = 1e-3.*exp( log(tzr.rcod(pos)./065)./84);