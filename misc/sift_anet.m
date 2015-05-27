function anet = sift_anet(anet, keep);
% anet = sift_anet(anet, aero);
% Designed to sift or trim off bad times from an aeronet structure;

if all(size(anet.time)==size(keep))||all(size(anet.time)==size(keep'))
   fields = fieldnames(anet);
   for f = 1:length(fields)
      if length(anet.(fields{f}))==length(keep)
         anet.(fields{f}) = anet.(fields{f})(keep);
      end
   end
end