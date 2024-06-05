function ab = patch_ab(ax,ay,bx,by)
% ab = patch_ab(ax,ay,bx,by);
% Patches b over undefined portions of a, pinning b to a at end points
% Intended to be used to interpolate lamp responsivities onto langley responsivities
% a and b need to be the same length as x
% a needs be be pre-filled with NaN where it is bad.
% This works mostly but may leave leading and trailing NaNs that could be addressed
% 
bay = interp1(bx, by, ax,'linear'); % this is "by" on the "ax" grid
bay(isnan(bay)) = interp1(bx, by, ax(isnan(bay)),'nearest','extrap');
% bay(isnan(bay)) = interp1(bx(~isnan(by)), by(~isnan(by)), ax(isnan(bay)),'nearest','extrap');
ab = ay;
lenx = length(ax);
ii = 1;
if isnan(ay(ii))
   ii = find(~isnan(ay),1,'first');
end
jj = ii + 1;

while jj < lenx

   while  ii < lenx && ~isnan(ay(ii+1))
      ii = ii + 1;
   end
   % At this point ay(ii+1) is NaN OR ii == lenx
   jj = ii+1;

   while jj< lenx && isnan(ay(jj))
      jj = jj + 1;
   end

   % At this point, ay(jj) is not nan OR jj == lenx
   if ii < lenx && jj <= lenx
      Pab = polyfit([ax(ii),ax(jj)], [ay(ii)./bay(ii),ay(jj)./bay(jj)],1);
      ab(ii:jj) = bay(ii:jj).*polyval(Pab,ax(ii:jj));
      ii = jj + 1;
   end

end
% See if I've got these indices right, then 
end