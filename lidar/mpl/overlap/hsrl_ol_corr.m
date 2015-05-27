function corr = hsrl_ol_corr(range);
% x = range in meters
if max(range)<1000 %then this range is in km, so convert to meters
   range = range.*1000;
end
corr = NaN(size(range));
pos = range>0;
x = range(pos);
   a= 1.871600673593827 ;
   b= 532.4127548559276 ;
y=a.*exp(-x./b);
corr(pos) = 10.^y;