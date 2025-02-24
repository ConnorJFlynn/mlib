function [v,vAAE] = multi_allanx(wl, time, Bap)
% [v,vAAE] = multi_allanx(wl, time, Bap)
% custom for TAP to exclude noisy green WL
dt = abs(dtime(datevec(time(end-1)), datevec(time(end))));
DATA.rate = 1./dt;

for w = size(Bap,2):-1:1
    % bad = isnan(Bap(:,w))|Bap(:,w)<-100;  Bap(bad,w) = interp1(time(~bad), Bap(~bad,w),time(bad),'linear');
   bad = isnan(Bap(:,w));  Bap(bad,w) = interp1(time(~bad), Bap(~bad,w),time(bad),'linear');
   bad = isnan(Bap(:,w)); Bap(bad,w) = interp1(time(~bad), Bap(~bad,w),time(bad),'nearest','extrap');
   DATA.freq= Bap(:,w);
   [v(w).retval,v(w).s, v(w).err,v(w).t] = allan(DATA, 'Bap ',[],0);
end

for t = length(time):-1:1
   Bap_plog(t) = polyval(polyfit(log(wl([1 3])), Bap(t,[1 3]), 1),log(500));
   P_AAE(t,:) = polyfit(log(wl), Bap(t,:), 1);
end
Bap_plog = Bap_plog';

if length(wl)>1
   DATA.freq= Bap_plog; 
   [vAAE(1).retval,vAAE(1).s, vAAE(1).err,vAAE(1).t] = allan(DATA, 'Bap 500nm',[],0);
   DATA.freq= P_AAE(:,1);
   [vAAE(2).retval,vAAE(2).s, vAAE(2).err,vAAE(2).t] = allan(DATA, 'AAE',[],0);
else
   vAAE = [];
end

end