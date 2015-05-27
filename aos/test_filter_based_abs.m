function b1 = test_filter_based_abs(b1);% Check b1s
% Match b1 quantities from a1/raw datastreams.
% Apply Ogren 2010 corrections to PSAP 3W.
% Test computation of K from aeth2spot.
% Verify by matching corrected BC and corresponding abs. coef.
% Test with collocated PSAP and CLAP.
% Check against before and after filter change.
if ~exist('b1','var')
   b1 = anc_bundle_files;
end
% filter change identified when tr drops down from 9.999
fc = find(diff(b1.vdata.tr_blue>9.9&b1.vdata.tr_blue<10)<0);
tr = b1.vdata.tr_blue;
T = b1.vdata.transmittance_blue_raw;
bad = T<-1000;
T(bad) = NaN;

figure;
plot(serial2doys(b1.time), T, 'bo',serial2doys(b1.time), tr,'r.');
title('old')

for c = 1:(length(fc)-1)
   disp(c)
   %Identifies the entire region between filter changes.  No explicit time
   %limit for how close to filter change.
   after = b1.time>b1.time(fc(c))&b1.time<(b1.time(fc(c+1)))&(tr>.5&tr<2)&(T>.5&T<2)&~isNaN(T);
   % This function "unique" returns a sorted list of front-panel
   % transmittances that were reported by the PSAP
   tr_after = unique(tr(after));
   for aa = length(tr_after):-1:1
      aa_ = after & tr==tr_after(aa);
      % Then, for each of these unique front-panel readings we'll compute the
      % ratio between the front-panel and raw transmittances.
      rats = T(aa_)./tr(aa_);
      % if we have enough values, we'll apply an interquartile filter to
      % remove outliers, otherwise just take the mean
      if length(rats)>3
         tr_rats(aa) = mean(rats(IQ(rats)));
      else
         tr_rats(aa) = mean(rats);
      end
      
   end
   %tr_rats is the collection of ratios, one per unique front-panel
   %transmittance
   % Take the interquartile of these, and the mean.  
   T_top = mean(tr_rats(IQ(tr_rats)));
   % T_top is the robust ratio between the front-panel transmittance and
   % the raw transmittance.  We'll divide our raw transmittances by this
   % value to normalize them all to 1 when the front panel is 1 and thus
   % when the filter is clean.
   
   this_filter = [fc(c):(fc(c+1)-1)];
   T(this_filter) = T(this_filter)./T_top;
   figure(12);
   plot(serial2doys(b1.time), T, 'bo',serial2doys(b1.time), tr,'r.',serial2doys(b1.time(fc(c):fc(c+1))), T(fc(c):fc(c+1)), 'k-');
   title('new')
end
% b1.vdata.transmittance_blue = T;
%  b1.vdata.qc_transmittance_blue = bitset(b1.vdata.qc_transmittance_blue,5,abs(log10((T./tr)))<0.01);
return
