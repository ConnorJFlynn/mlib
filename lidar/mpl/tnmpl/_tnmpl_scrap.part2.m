
figure; semilogy(mplz.range, mean(mplz.prof(:,mplz.hk.zenith==91)')','g.',mplz.range, mean(mplz.prof(:,mplz.hk.zenith==91)')'.*ol_corr(:,2))
ol_corr = [mplz.range, real(10.^(polyval(P,mplz.range))./(10.^(logprof)))];
save('C:\tnmpl\Downtown\cals\ol_corr_raw.mat', 'ol_corr', '-mat')
!!
%%
ol_corr = loadinto('C:\tnmpl\Downtown\cals\ol_corr_raw.mat');
ol_corr(ol_corr(:,1)>7,2)==1;

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

% ol_mat = ol_corr(:,2)*ones(size(mplz.time));
% figure; imagesc(serial2Hh(mplz.time(~isnan(mplz.hk.zenith))), ... 
%     mplz.range(mplz.r.lte_15), ... 
%     ol_mat(mplz.r.lte_10,~isnan(mplz.hk.zenith)).*mplz.prof(mplz.r.lte_10,(~isnan(mplz.hk.zenith)))); 
% colormap('jet'); colorbar; axis('xy')
% caxis([0,10]);colorbar

ol_mat = ol_corr(:,2)*ones(size(mplz_day.time));
figure; imagesc(serial2Hh(mplz_day.time((mplz_day.hk.zenith==0))), ...
    mplz.range(mplz.r.lte_10), ...
    real(log10(ol_mat(mplz.r.lte_10,(mplz_day.hk.zenith==0)).*mplz_day.prof(mplz.r.lte_10,((mplz_day.hk.zenith==0)))))); 
colormap('jet'); caxis([-1 2]);colorbar; axis('xy');

% colormap('nasa'); colorbar
% corr_prof = ol_mat.*mplz_day.prof;
% 
% % mplz_day.rawcts = mplz_day.prof ./ ((mplz_day.range .^2)*ones(size(mplz_day.time)));
% % mplz_day = apply_ap_to_mpl(mplz_day, ap_mpl105_20060808(mplz_day.range));
% 
% mplz_day = apply_ol_to_mpl(mplz_day, ol_mpl105_20060808(mplz_day.range));
% figure; imagesc(serial2Hh(mplz_day.time((mplz_day.hk.zenith==0))), mplz_day.range(mplz_day.r.lte_10), real(log10(corr_prof(mplz_day.r.lte_10,(mplz_day.hk.zenith==0))))); colormap('jet'); caxis([-1 2]);colorbar
% axis('xy')
%%
% 18 stories = ~180 feet or 60 meters
% 4120 = adjacent
% 60 = opposite
% ==> angle = 0.83 degrees = 90.83
% We record 91.33, so zenith = hk.zenith - .5;

