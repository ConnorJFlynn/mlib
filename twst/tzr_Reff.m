function Reff = tzr_Reff(tzr, LWP)
% LWP = tzr_lwp(tzr)
LWP = 2e-3.*tzr.Reff.*tzr.rcod./3;
Reff = 3.*LWP./tzr.rcod./(2e-3)