%%

close('all');

clear
base = 'C:\tnmpl\Downtown\four\';
day = 'tnmplzen.2006_09_03*.dat';
mat_dir = dir([base,day]);
for m = length(mat_dir):-1:1
   mplz = loadinto([base, mat_dir(m).name]);
%    figure; subplot(2,1,1); semilogy(mplz.range, mean(mplz.prof(:,mplz.hk.zenith==90.66)')'./(mplz.range.^2),'r');
%    title(['Mean horiz profile for ',datestr(mplz.time(1),'yyyy-mm-dd HH:00')]);
%    v1 = [ 0   20    0.0007    6.1832];    axis(v1);
%    subplot(2,1,2); semilogy(mplz.range, mean(mplz.prof(:,mplz.hk.zenith==90.66)')','g');
%    v2 = [0,20,0.0858 ,4.3164]; axis(v2)
   if ~exist('mplz_day','var')
      mplz_day = mplz;
   else
      mplz_day = tnmpl_tcat(mplz_day,mplz);
   end
end
%%
mplz_day = apply_ap_to_mpl(mplz_day, ap_mpl105_20060808(mplz_day.range));
mplz_day = apply_dtc_to_mpl(mplz_day, 'dtc_apd9391');
%%

mplz_day = apply_ol_to_mpl(mplz_day, ol_mpl105_20060808(mplz_day.range));
%%


% 
% 18 stories = ~180 feet or 60 meters
% 
% 4120 = adjacent
% 60 = opposite
% ==> angle = 0.83 degrees = 90.83
% We record 91.33, so zenith = hk.zenith - .5;