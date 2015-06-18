function bnl_psap_filter_change(b1)


t = 1;b = 1;
b0.time(b) = b1.time(t);
b0.tr_blue(b) = b1.vdata.tr_blue(t);


while t<length(b1.time)
   n = 1;
   b0.trans_blue(b) = b1.vdata.transmittance_blue(t);
   while t<(length(b1.time)-1)&(b1.vdata.tr_blue(t) == b1.vdata.tr_blue(t+1)) 
      n = n+1;
      t = t+1;
      b0.trans_blue(b) = b0.trans_blue(b)+b1.vdata.transmittance_blue(t);
   end
   b0.trans_blue(b) = b0.trans_blue(b)./n;
   b = b+1;
   t = t+1;
   b0.time(b) = b1.time(t);
   b0.tr_blue(b) = b1.vdata.tr_blue(t);
   if mod(t,1000)==0
      disp(t)
   end
end
b0.trans_blue(b) = b1.vdata.transmittance_blue(t);
b0.rat_blue =  b0.trans_blue./b0.tr_blue;
stable = false(size(b0.trans_blue));
stable(2:end-1) = abs(diff(b0.rat_blue(1:end-1)))<5e-3 & abs(diff(b0.rat_blue(2:end)))<5e-3;
bo.stable = stable;
changes = find(diff(stable)==1);

return









return