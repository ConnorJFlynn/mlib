function [mplz] = tnmpl_mplz(mpl);
% [mplz] = tnmpl_mplz(mpl);
% Returns averages at each zenith angle
mirror_pos = mpl.hk.zenith;
n = 1;
cur = 1;
tmp = cur;
while cur <= length(mirror_pos)
   tmp = cur;
   while(tmp>0)&(mirror_pos(tmp)==mirror_pos(cur))|(isnan(mirror_pos(cur))&isnan(mirror_pos(tmp)))
      tmp = tmp-1;
      if tmp<1
         break
      end
   end
   bot = tmp + 1;
   tmp = cur;
   while(tmp<=length(mirror_pos))&(mirror_pos(tmp)==mirror_pos(cur))|(isnan(mirror_pos(cur))&isnan(mirror_pos(tmp)))
      tmp = tmp+1;
      if tmp>length(mirror_pos)
         break
      end
   end
   top = tmp -1;
   mpl_tavg = tnmpl_tavg(mpl,[bot:top]);
   if ~exist('mplz','var')
         mplz = mpl_tavg;
      else
         mplz = tnmpl_tcat(mplz, mpl_tavg);
   end
   cur = top+1;
end

%%
% mpl = apply_ap_to_mpl(mpl, ap_mpl105_20060808(mpl.range));
% mpl = apply_dtc_to_mpl(mpl, 'dtc_apd9391');
% mpl = trim_tnmpl(mpl);
%%
