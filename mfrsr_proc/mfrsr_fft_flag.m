function [mfr, fail] = mfrsr_fft_flag(mfr);
% [mfr, bad] = mfrsr_fft_flag(mfr);
% applies a variant of Alexandrov fft test to identify banding failure with MFRSR
% Looks at 270 contiguous values, ~90 minutes
if ~isavar('mfr')
   mfr = anc_load('mfrsr');
end
fail = false(size(mfr.time));
dur = 300; dur_ = dur -1;
X = 1;
if length(mfr.time)>0
   [zen, az, soldst, ha, dec, el, am] = sunae(mfr.vdata.lat, mfr.vdata.lon, mfr.time);
   %I tried diffuse/total, diffuse./dirh, and dirh/diffuse.
   % Similar results. Likely Alexandrov results in tau are improved by
   % pre-screening with eps test.  Instead let's try direct normal to diffuse
   % We can also attempt to use eps-screen on that by normalizing to maxima,
   % perhaps limited to the max over some airmass range such as 1:6

   Dd = mfr.vdata.direct_diffuse_ratio_filter5;
   diff5 = mfr.vdata.diffuse_hemisp_narrowband_filter5;
   dv = datevec(mfr.time);
   dts = [20;dtime(dv(2:end,:), dv(1:end-1,:))]'; %difference between time records in seconds
   dts_ = dts>18 & dts < 22 & am>1 & am<6 & Dd>0 & diff5>0; % contiguous good measurements
   fail = false(size(dts_));
   s = find(dts_,1,'first');
   while (s + dur_) <= length(dts_)
      contig = prod(dts_(s+[0:dur_]));
      if ~contig
         s = s+1;
      else
         fft_test.time(X) = mean(mfr.time(s+[0:dur_]));
         fft_test.dif_fraction(X) = mean(Dd(s+[0:dur_]));
         mom = fft_moments(mfr.time(s+[0:dur_]), Dd(s+[0:dur_]));
         in_band = mom.P>95 & mom.P<120;
         out_band = mom.P>90 & mom.P<130 & ~in_band;
         fft_test.fft_M(X,:) = mom.fft_M;
         fft_test.in_band(X) = mean(abs(mom.fft_M(in_band)));
         [P,S,MU] = polyfit(mom.P(out_band),abs(mom.fft_M(out_band)),1);
         fft_test.side_bands(X) = mean(polyval(P,mom.P(in_band),S,MU));
         fft_test.pwr_frac(X) = (fft_test.in_band(X) - fft_test.side_bands(X))./fft_test.side_bands(X);
         if (fft_test.pwr_frac(X)>1)
            fail(s+[0:dur_]) = true;
         end
         %                              figure_(12); plot(mom.P, abs(fft_test.fft_M(X,:)),'-',...
         %                                  mom.P(in_band), abs(fft_test.fft_M(X,in_band)),'go',...
         %                                  mom.P(out_band), abs(fft_test.fft_M(X,out_band)),'rx'); xlim([80,140]);
         %                              title([datestr(mfr.time(s)),sprintf('; power frac: %g',fft_test.pwr_frac(X))]);
         %                              pause(0.05);
         s = s + 100;
         X = X +1;
      end
   end
end
if any(fail)
   figure_(5); plot(mfr.time(dts_), Dd(dts_),'.',mfr.time(dts_&fail), Dd(dts_&fail),'r.'); dynamicDateTicks
   title_str = datestr(mean(mfr.time),'yyyy-mm-dd HH:MM:SS'); title(title_str);
   pause(0.05)
end


return
